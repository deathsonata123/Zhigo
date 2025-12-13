import { Router, Request, Response } from 'express';
import { DatabaseService } from '../services/database/client';
import { OrderRepository } from '../services/database/repositories/order.repository';

const router = Router();
const orderRepo = new OrderRepository();

// GET /api/orders
router.get('/', async (req: Request, res: Response) => {
    try {
        const { status, restaurantId, riderId, limit, offset } = req.query;

        const orders = await orderRepo.findAll({
            status: status as string,
            restaurantId: restaurantId as string,
            riderId: riderId as string,
            limit: limit ? parseInt(limit as string) : 100,
            offset: offset ? parseInt(offset as string) : 0
        });

        res.json({
            success: true,
            data: orders
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
});

// POST /api/orders
router.post('/', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const order = await orderRepo.create(req.body);

        res.status(201).json({
            success: true,
            data: order
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to create order' });
    }
});

// GET /api/orders/:id
router.get('/:id', async (req: Request, res: Response) => {
    try {
        const order = await orderRepo.findById(req.params.id);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({
            success: true,
            data: order
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to fetch order' });
    }
});

// PUT /api/orders/:id/status
router.put('/:id/status', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const { status, ...additionalData } = req.body;

        const order = await orderRepo.updateStatus(req.params.id, status, additionalData);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({
            success: true,
            data: order
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to update order status' });
    }
});

// PUT /api/orders/:id/assign-rider
router.put('/:id/assign-rider', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const { riderId } = req.body;

        if (!riderId) {
            return res.status(400).json({ error: 'Rider ID is required' });
        }

        const order = await orderRepo.assignRider(req.params.id, riderId);

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({
            success: true,
            data: order
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to assign rider' });
    }
});

export default router;
