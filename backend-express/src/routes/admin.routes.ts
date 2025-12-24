import { Router, Request, Response } from 'express';
import { RestaurantRepository } from '../services/database/repositories/restaurant.repository';
import { getDatabase } from '../services/database/client';
import { authenticate, AuthRequest } from '../middleware/auth.middleware';

const router = Router();
const restaurantRepo = new RestaurantRepository();

// GET /api/admin/restaurants - Get all restaurants (for admin review)
router.get('/restaurants', async (req: Request, res: Response) => {
    try {
        const { status } = req.query;
        const restaurants = await restaurantRepo.findAll({
            status: status as string,
            limit: 100
        });

        res.json({
            success: true,
            data: restaurants
        });
    } catch (error: any) {
        console.error('Failed to fetch restaurants:', error);
        res.status(500).json({ error: 'Failed to fetch restaurants' });
    }
});

// GET /api/admin/restaurants/pending - Get pending partner applications
router.get('/restaurants/pending', async (req: Request, res: Response) => {
    try {
        const restaurants = await restaurantRepo.findAll({
            status: 'pending',
            limit: 100
        });

        res.json({
            success: true,
            data: restaurants,
            count: restaurants.length
        });
    } catch (error: any) {
        console.error('Failed to fetch pending restaurants:', error);
        res.status(500).json({ error: 'Failed to fetch pending restaurants' });
    }
});

// PUT /api/admin/restaurants/:id/approve - Approve a partner application
router.put('/restaurants/:id/approve', async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const restaurant = await restaurantRepo.updateStatus(id, 'approved');

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        // TODO: Send email notification to partner

        res.json({
            success: true,
            data: restaurant,
            message: 'Partner application approved successfully'
        });
    } catch (error: any) {
        console.error('Failed to approve restaurant:', error);
        res.status(500).json({ error: 'Failed to approve restaurant' });
    }
});

// PUT /api/admin/restaurants/:id/reject - Reject a partner application
router.put('/restaurants/:id/reject', async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const { reason } = req.body;

        const restaurant = await restaurantRepo.updateStatus(id, 'rejected');

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        // TODO: Send email notification with rejection reason

        res.json({
            success: true,
            data: restaurant,
            message: 'Partner application rejected'
        });
    } catch (error: any) {
        console.error('Failed to reject restaurant:', error);
        res.status(500).json({ error: 'Failed to reject restaurant' });
    }
});

// PUT /api/admin/users/:id/role - Update user role (set admin, partner, etc.)
router.put('/users/:id/role', async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        if (!['customer', 'partner', 'rider', 'admin'].includes(role)) {
            return res.status(400).json({ error: 'Invalid role' });
        }

        const db = getDatabase();
        const result = await db.queryOne<any>(
            'UPDATE users SET role = $1, updated_at = NOW() WHERE id = $2 RETURNING id, email, full_name, role',
            [role, id]
        );

        if (!result) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json({
            success: true,
            data: result,
            message: `User role updated to ${role}`
        });
    } catch (error: any) {
        console.error('Failed to update user role:', error);
        res.status(500).json({ error: 'Failed to update user role' });
    }
});

// GET /api/admin/users - List all users
router.get('/users', async (req: Request, res: Response) => {
    try {
        const db = getDatabase();
        const users = await db.query<any>(
            'SELECT id, email, full_name, phone, role, created_at FROM users ORDER BY created_at DESC LIMIT 100'
        );

        res.json({
            success: true,
            data: users
        });
    } catch (error: any) {
        console.error('Failed to fetch users:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});

export default router;
