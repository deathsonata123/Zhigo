import { Router, Request, Response } from 'express';

const router = Router();

// Placeholder routes - will implement admin functionality

// GET /api/admin/restaurants
router.get('/restaurants', async (req: Request, res: Response) => {
    res.json({ success: true, data: [], message: 'Admin routes coming soon' });
});

export default router;
