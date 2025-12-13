import { Router, Request, Response } from 'express';
import { S3StorageService } from '../services/storage/s3-service';
import { CognitoAuthService } from '../services/auth/cognito-service';

const router = Router();
const storageService = S3StorageService.getInstance();
const authService = CognitoAuthService.getInstance();

// POST /api/storage/upload-url
router.post('/upload-url', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const accessToken = authHeader.substring(7);
        const user = await authService.getCurrentUser(accessToken);

        if (!user || !user.attributes.sub) {
            return res.status(401).json({ error: 'Invalid user' });
        }

        const { fileName, contentType, folder } = req.body;

        if (!fileName || !contentType || !folder) {
            return res.status(400).json({
                error: 'fileName, contentType, and folder are required'
            });
        }

        const key = storageService.generateKey(folder, user.attributes.sub, fileName);
        const uploadUrl = await storageService.getUploadUrl(key, contentType, 3600);

        res.json({
            success: true,
            data: { uploadUrl, key }
        });
    } catch (error: any) {
        let message = 'Failed to generate upload URL';
        let status = 500;

        if (error.name === 'NotAuthorizedException') {
            message = 'Invalid or expired token';
            status = 401;
        }

        res.status(status).json({ error: message });
    }
});

// POST /api/storage/download-url
router.post('/download-url', async (req: Request, res: Response) => {
    try {
        const { key } = req.body;

        if (!key) {
            return res.status(400).json({ error: 'Key is required' });
        }

        const downloadUrl = await storageService.getDownloadUrl(key, 3600);

        res.json({
            success: true,
            data: { downloadUrl }
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to generate download URL' });
    }
});

// DELETE /api/storage/delete
router.delete('/delete', async (req: Request, res: Response) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        const { key } = req.body;

        if (!key) {
            return res.status(400).json({ error: 'Key is required' });
        }

        await storageService.delete(key);

        res.json({
            success: true,
            message: 'File deleted successfully'
        });
    } catch (error: any) {
        res.status(500).json({ error: 'Failed to delete file' });
    }
});

export default router;
