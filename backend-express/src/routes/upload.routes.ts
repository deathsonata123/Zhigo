import { Router, Request, Response } from 'express';
import multer from 'multer';
import { S3StorageService, getStorageService } from '../services/storage/s3-service';

const router = Router();

// Configure multer for memory storage (files stored in memory as Buffer)
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB max file size
    },
    fileFilter: (req, file, cb) => {
        // Only allow images
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'));
        }
    },
});

// POST /api/upload/restaurant-photo - Upload restaurant photo to S3
router.post('/restaurant-photo', upload.single('photo'), async (req: Request, res: Response) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        let storageService: S3StorageService;
        try {
            storageService = getStorageService();
        } catch (error) {
            // S3 not configured - return a mock URL for development
            console.warn('⚠️ S3 not configured, returning mock URL');
            const mockUrl = `https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=400&fit=crop`;
            return res.status(200).json({
                success: true,
                data: {
                    url: mockUrl,
                    key: 'mock-key',
                },
                message: 'Mock photo URL returned (S3 not configured)',
            });
        }

        // Generate unique key for the file
        const restaurantId = req.body.restaurantId || 'temp';
        const timestamp = Date.now();
        const extension = req.file.originalname.split('.').pop() || 'jpg';
        const key = `restaurants/${restaurantId}/${timestamp}.${extension}`;

        // Upload to S3
        await storageService.upload(key, req.file.buffer, {
            contentType: req.file.mimetype,
            acl: 'public-read', // Make the image publicly accessible
        });

        // Generate the public URL
        const bucketName = process.env.S3_BUCKET_NAME;
        const region = process.env.AWS_REGION || 'ap-southeast-1';
        const publicUrl = `https://${bucketName}.s3.${region}.amazonaws.com/${key}`;

        console.log('✅ Restaurant photo uploaded:', publicUrl);

        res.status(200).json({
            success: true,
            data: {
                url: publicUrl,
                key: key,
            },
            message: 'Photo uploaded successfully',
        });
    } catch (error: any) {
        console.error('Failed to upload photo:', error);
        res.status(500).json({ error: 'Failed to upload photo: ' + error.message });
    }
});

// POST /api/upload/presigned-url - Get a presigned URL for direct upload
router.post('/presigned-url', async (req: Request, res: Response) => {
    try {
        const { fileName, contentType, folder = 'restaurants' } = req.body;

        if (!fileName || !contentType) {
            return res.status(400).json({ error: 'fileName and contentType are required' });
        }

        let storageService: S3StorageService;
        try {
            storageService = getStorageService();
        } catch (error) {
            return res.status(503).json({ error: 'S3 storage not configured' });
        }

        // Generate unique key
        const timestamp = Date.now();
        const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
        const key = `${folder}/${timestamp}_${sanitizedFileName}`;

        // Get presigned URL (valid for 1 hour)
        const presignedUrl = await storageService.getUploadUrl(key, contentType, 3600);

        // Generate the public URL (after upload)
        const bucketName = process.env.S3_BUCKET_NAME;
        const region = process.env.AWS_REGION || 'ap-southeast-1';
        const publicUrl = `https://${bucketName}.s3.${region}.amazonaws.com/${key}`;

        res.status(200).json({
            success: true,
            data: {
                presignedUrl,
                publicUrl,
                key,
            },
        });
    } catch (error: any) {
        console.error('Failed to generate presigned URL:', error);
        res.status(500).json({ error: 'Failed to generate presigned URL: ' + error.message });
    }
});

export default router;
