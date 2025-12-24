import { Router, Request, Response } from 'express';
import { DatabaseService } from '../services/database/client';
import { RestaurantRepository } from '../services/database/repositories/restaurant.repository';

const router = Router();
const restaurantRepo = new RestaurantRepository();

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

        // Map camelCase from frontend to snake_case for database
        const restaurantData = {
            name: body.name,
            email: body.email,
            phone: body.phone,
            address: body.address,
            photo_url: body.photoUrl || 'placeholder.jpg',
            owner_id: body.ownerId || null, // Optional for now
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

        res.status(201).json({
            success: true,
            data: restaurant,
            message: 'Application submitted successfully! Waiting for admin review.'
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

// PUT /api/restaurants/:id
router.put('/:id', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const restaurant = await restaurantRepo.update(req.params.id, req.body);

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        res.json({
            success: true,
            data: restaurant
        });
    } catch (error: any) {
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
