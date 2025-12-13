import { Router, Request, Response } from 'express';

const router = Router();

// Placeholder routes - will implement when rider repository is created

// GET /api/riders
router.get('/', async (req: Request, res: Response) => {
    res.json({ success: true, data: [], message: 'Rider routes coming soon' });
});

// POST /api/riders
router.post('/', async (req: Request, res: Response) => {
    res.status(501).json({ error: 'Not implemented yet' });
});

export default router;
