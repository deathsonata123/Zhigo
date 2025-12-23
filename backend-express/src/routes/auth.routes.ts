import { Router, Request, Response } from 'express';
import { getDatabase } from '../services/database/client';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const router = Router();

// JWT secret (in production, use environment variable)
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-this-in-production';

// POST /api/auth/signin
router.post('/signin', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                error: 'Email and password are required'
            });
        }

        const db = getDatabase();

        // Find user by email
        const user = await db.queryOne<any>(
            'SELECT * FROM users WHERE email = $1',
            [email]
        );

        if (!user) {
            return res.status(401).json({
                error: 'Incorrect email or password'
            });
        }

        // Verify password
        const passwordMatch = await bcrypt.compare(password, user.password_hash);

        if (!passwordMatch) {
            return res.status(401).json({
                error: 'Incorrect email or password'
            });
        }

        // Generate JWT token
        const token = jwt.sign(
            {
                userId: user.id,
                email: user.email,
                role: user.role
            },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            success: true,
            data: {
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    fullName: user.full_name,
                    phone: user.phone,
                    role: user.role
                }
            }
        });
    } catch (error: any) {
        console.error('Sign in error:', error);
        res.status(500).json({ error: 'Sign in failed' });
    }
});

// POST /api/auth/signup
router.post('/signup', async (req: Request, res: Response) => {
    try {
        const { email, password, fullName, phone, role } = req.body;

        console.log('Signup request:', { email, fullName, phone, role });

        if (!email || !password || !fullName) {
            return res.status(400).json({
                error: 'Email, password, and full name are required'
            });
        }

        const db = getDatabase();

        // Check if user already exists
        const existingUser = await db.queryOne<any>(
            'SELECT id FROM users WHERE email = $1',
            [email]
        );

        if (existingUser) {
            return res.status(409).json({
                error: 'An account with this email already exists'
            });
        }

        // Hash password
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(password, saltRounds);

        // Create user in database
        const newUser = await db.queryOne<any>(
            `INSERT INTO users (email, password_hash, full_name, phone, role, created_at, updated_at)
             VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
             RETURNING id, email, full_name, phone, role, created_at`,
            [email, passwordHash, fullName, phone || null, role || 'customer']
        );

        console.log('User created:', newUser);

        // Generate JWT token
        const token = jwt.sign(
            {
                userId: newUser.id,
                email: newUser.email,
                role: newUser.role
            },
            JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            success: true,
            data: {
                token,
                user: {
                    id: newUser.id,
                    email: newUser.email,
                    fullName: newUser.full_name,
                    phone: newUser.phone,
                    role: newUser.role
                }
            }
        });
    } catch (error: any) {
        console.error('Sign up error:', error);
        let message = 'Sign up failed';
        let status = 400;

        res.status(status).json({ error: message });
    }
});

// TODO: Implement with database auth
/*
// POST /api/auth/confirm
router.post('/confirm', async (req: Request, res: Response) => {
    try {
        const { email, code } = req.body;

        if (!email || !code) {
            return res.status(400).json({
                error: 'Email and confirmation code are required'
            });
        }

        await authService.confirmSignUp(email, code);

        res.json({
            success: true,
            message: 'Email confirmed successfully'
        });
    } catch (error: any) {
        let message = 'Confirmation failed';
        let status = 400;

        if (error.name === 'CodeMismatchException') {
            message = 'Invalid confirmation code';
        } else if (error.name === 'ExpiredCodeException') {
            message = 'Confirmation code has expired';
        }

        res.status(status).json({ error: message });
    }
});
*/

// TODO: Implement with database auth
/*
// POST /api/auth/signout
router.post('/signout', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                error: 'No access token provided'
            });
        }

        const accessToken = authHeader.substring(7);
        await authService.globalSignOut(accessToken);

        res.json({
            success: true,
            message: 'Signed out successfully'
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Sign out failed' });
    }
});
*/

// TODO: Implement with database auth
/*
// GET /api/auth/me
router.get('/me', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                error: 'No access token provided'
            });
        }

        const accessToken = authHeader.substring(7);
        const user = await authService.getCurrentUser(accessToken);

        res.json({
            success: true,
            data: user
        });
    } catch (error: any) {
        let message = 'Failed to get user';
        let status = 500;

        if (error.name === 'NotAuthorizedException') {
            message = 'Invalid or expired token';
            status = 401;
        }

        res.status(status).json({ error: message });
    }
});
*/

// TODO: Implement with database auth
/*
// POST /api/auth/forgot-password
router.post('/forgot-password', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ error: 'Email is required' });
        }

        await authService.forgotPassword(email);

        res.json({
            success: true,
            message: 'Password reset code sent to email'
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to send reset code' });
    }
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req: Request, res: Response) => {
    try {
        const { email, code, newPassword } = req.body;

        if (!email || !code || !newPassword) {
            return res.status(400).json({
                error: 'Email, code, and new password are required'
            });
        }

        await authService.confirmForgotPassword(email, code, newPassword);

        res.json({
            success: true,
            message: 'Password reset successfully'
        });
    } catch (error: any) {
        let message = 'Password reset failed';

        if (error.name === 'CodeMismatchException') {
            message = 'Invalid reset code';
        } else if (error.name === 'ExpiredCodeException') {
            message = 'Reset code has expired';
        }

        res.status(400).json({ error: message });
    }
});
*/

export default router;
