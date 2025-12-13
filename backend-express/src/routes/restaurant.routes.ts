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

// POST /api/restaurants
router.post('/', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const restaurant = await restaurantRepo.create(req.body);

        res.status(201).json({
            success: true,
            data: restaurant
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to create restaurant' });
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
