import { Router, Request, Response } from 'express';
import { DatabaseService } from '../services/database/client';
import { RestaurantRepository } from '../services/database/repositories/restaurant.repository';
import { notifyRestaurantApproval, notifyRestaurantRejection } from '../services/notification.service';
import bcrypt from 'bcryptjs';

const router = Router();
const restaurantRepo = new RestaurantRepository();
const db = DatabaseService.getInstance();

// GET /api/restaurants
router.get('/', async (req: Request, res: Response) => {
    try {
        const { status, zone, city, limit, offset } = req.query;

        const restaurants = await restaurantRepo.findAll({
            status: status as string,
            zone: zone as string,
            city: city as string,
            limit: limit ? parseInt(limit as string) : 100,
            offset: offset ? parseInt(offset as string) : 0
        });

        res.json({
            success: true,
            data: restaurants
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to fetch restaurants' });
    }
});

// POST /api/restaurants - Partner Application
router.post('/', async (req: Request, res: Response) => {
    try {
        const body = req.body;

        // If password provided, create a user account for the partner
        let userId = body.ownerId || null;

        if (body.password && body.email) {
            // Check if user already exists
            const existingUser = await db.queryOne<any>(
                'SELECT id FROM users WHERE email = $1',
                [body.email]
            );

            if (existingUser) {
                return res.status(409).json({
                    error: 'An account with this email already exists. Please use a different email or login with your existing account.'
                });
            }

            // Hash password and create user
            const saltRounds = 10;
            const passwordHash = await bcrypt.hash(body.password, saltRounds);

            const newUser = await db.queryOne<any>(
                `INSERT INTO users (email, password_hash, full_name, phone, role, created_at, updated_at)
                 VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
                 RETURNING id, email, full_name, phone, role`,
                [body.email, passwordHash, body.name, body.phone || null, 'partner']
            );

            console.log('✅ Partner user account created:', newUser);
            userId = newUser.id;
        }

        // Map camelCase from frontend to snake_case for database
        const restaurantData = {
            name: body.name,
            email: body.email,
            phone: body.phone,
            address: body.address,
            photo_url: body.photoUrl || 'placeholder.jpg',
            owner_id: userId,
            business_type: body.businessType,
            has_bin_vat: body.hasBinVat === 'yes',
            bin_vat_number: body.binVatNumber || null,
            display_price_with_vat: body.displayPriceWithVat === 'yes',
            account_holder_name: body.accountHolderName,
            account_type: body.accountType,
            account_number: body.accountNumber,
            bank_name: body.bankName || null,
            branch_name: body.branchName || null,
            routing_number: body.routingNumber || null,
            city: body.city,
            postal_code: body.postalCode,
            pricing_plan: body.pricingPlan || 'basic',
            status: 'pending', // Always start as pending for admin review
        };

        console.log('Creating restaurant with data:', restaurantData);

        const restaurant = await restaurantRepo.create(restaurantData);

        // Update user with restaurant_id
        if (userId) {
            await db.query(
                'UPDATE users SET restaurant_id = $1 WHERE id = $2',
                [restaurant.id, userId]
            );
            console.log('✅ Linked restaurant to user account');
        }

        res.status(201).json({
            success: true,
            data: restaurant,
            message: 'Application submitted successfully! You can login after admin approval.'
        });
    } catch (error: any) {
        console.error('Failed to create restaurant:', error);
        res.status(500).json({ error: 'Failed to create restaurant: ' + error.message });
    }
});

// GET /api/restaurants/:id
router.get('/:id', async (req: Request, res: Response) => {
    try {
        const restaurant = await restaurantRepo.findById(req.params.id);

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        res.json({
            success: true,
            data: restaurant
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to fetch restaurant' });
    }
});

// PUT /api/restaurants/:id - Update restaurant (including status change for approval)
router.put('/:id', async (req: Request, res: Response) => {
    try {
        const previousRestaurant = await restaurantRepo.findById(req.params.id);
        const restaurant = await restaurantRepo.update(req.params.id, req.body);

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        // If status changed to 'approved', send approval notifications (email + SMS)
        if (previousRestaurant?.status !== 'approved' && req.body.status === 'approved') {
            console.log(`🎉 Restaurant ${restaurant.name} approved! Sending notifications...`);
            await notifyRestaurantApproval(restaurant);
        }

        // If status changed to 'rejected', send rejection notification
        if (previousRestaurant?.status !== 'rejected' && req.body.status === 'rejected') {
            console.log(`❌ Restaurant ${restaurant.name} rejected. Sending notification...`);
            await notifyRestaurantRejection(restaurant, req.body.rejectionReason);
        }

        res.json({
            success: true,
            data: restaurant
        });
    } catch (error: any) {
        console.error('Failed to update restaurant:', error);
        res.status(500).json({ error: 'Failed to update restaurant' });
    }
});

// DELETE /api/restaurants/:id
router.delete('/:id', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        await restaurantRepo.delete(req.params.id);

        res.json({
            success: true,
            message: 'Restaurant deleted successfully'
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to delete restaurant' });
    }
});

export default router;
