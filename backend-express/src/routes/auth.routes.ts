import { Router, Request, Response } from 'express';
import { CognitoAuthService } from '../services/auth/cognito-service';

const router = Router();
const authService = CognitoAuthService.getInstance();

// POST /api/auth/signin
router.post('/signin', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                error: 'Email and password are required'
            });
        }

        const result = await authService.signIn(email, password);

        res.json({
            success: true,
            data: result
        });
    } catch (error: any) {
        let message = 'Sign in failed';
        let status = 401;

        if (error.name === 'NotAuthorizedException') {
            message = 'Incorrect email or password';
        } else if (error.name === 'UserNotConfirmedException') {
            message = 'Please confirm your email first';
            status = 403;
        } else if (error.name === 'UserNotFoundException') {
            message = 'User not found';
            status = 404;
        }

        res.status(status).json({ error: message });
    }
});

// POST /api/auth/signup
router.post('/signup', async (req: Request, res: Response) => {
    try {
        const { email, password, fullName, phone, role } = req.body;

        if (!email || !password || !fullName) {
            return res.status(400).json({
                error: 'Email, password, and full name are required'
            });
        }

        const attributes: Record<string, string> = {
            email,
            name: fullName
        };

        if (phone) attributes.phone_number = phone;
        if (role) attributes['custom:role'] = role;

        const result = await authService.signUp(email, password, attributes);

        res.json({
            success: true,
            data: result
        });
    } catch (error: any) {
        let message = 'Sign up failed';
        let status = 400;

        if (error.name === 'UsernameExistsException') {
            message = 'An account with this email already exists';
            status = 409;
        } else if (error.name === 'InvalidPasswordException') {
            message = 'Password does not meet requirements';
        }

        res.status(status).json({ error: message });
    }
});

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

export default router;
