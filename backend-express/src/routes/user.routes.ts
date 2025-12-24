import { Router, Response } from 'express';
import { getDatabase } from '../services/database/client';
import { authenticate, AuthRequest } from '../middleware/auth.middleware';

const router = Router();

// GET /api/users/profile
router.get('/profile', authenticate, async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?.userId;

        if (!userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        const db = getDatabase();

        // Fetch user from database - use snake_case column names
        const user = await db.queryOne<any>(
            'SELECT id, email, full_name, phone, avatar_url, role, created_at FROM users WHERE id = $1',
            [userId]
        );

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Map snake_case to camelCase for frontend
        res.json({
            success: true,
            data: {
                id: user.id,
                email: user.email,
                fullName: user.full_name,
                phone: user.phone,
                avatarUrl: user.avatar_url,
                role: user.role,
                createdAt: user.created_at
            }
        });
    } catch (error) {
        console.error('Error fetching profile:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// PUT /api/users/profile
router.put('/profile', authenticate, async (req: AuthRequest, res: Response) => {
    res.status(501).json({ error: 'Not implemented yet' });
});

export default router;
