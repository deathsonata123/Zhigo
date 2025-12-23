import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { createLogger, format, transports } from 'winston';

// Load environment variables FIRST
dotenv.config();

// Import and initialize services BEFORE routes
import { DatabaseService } from './services/database/client';
import { CognitoAuthService } from './services/auth/cognito-service';
import { S3StorageService } from './services/storage/s3-service';

// Initialize services immediately
if (process.env.DATABASE_URL) {
    DatabaseService.initialize({
        connectionString: process.env.DATABASE_URL
    });
}

if (process.env.COGNITO_USER_POOL_ID && process.env.COGNITO_CLIENT_ID) {
    CognitoAuthService.initialize({
        region: process.env.AWS_REGION || 'us-east-1',
        userPoolId: process.env.COGNITO_USER_POOL_ID,
        clientId: process.env.COGNITO_CLIENT_ID
    });
}

if (process.env.S3_BUCKET_NAME) {
    S3StorageService.initialize({
        region: process.env.AWS_REGION || 'us-east-1',
        bucketName: process.env.S3_BUCKET_NAME
    });
}

// NOW import routes (after services are initialized)
import authRoutes from './routes/auth.routes';
import restaurantRoutes from './routes/restaurant.routes';
import orderRoutes from './routes/order.routes';
import riderRoutes from './routes/rider.routes';
import userRoutes from './routes/user.routes';
import storageRoutes from './routes/storage.routes';
import adminRoutes from './routes/admin.routes';
import chatRoutes from './routes/chat.routes';


// Initialize logger
const logger = createLogger({
    level: 'info',
    format: format.combine(
        format.timestamp(),
        format.json()
    ),
    transports: [
        new transports.File({ filename: 'error.log', level: 'error' }),
        new transports.File({ filename: 'combined.log' }),
        new transports.Console({
            format: format.combine(
                format.colorize(),
                format.simple()
            )
        })
    ]
});

// Initialize Express app
const app: Express = express();
const PORT = process.env.PORT || 3000;

// ========================================
// Middleware
// ========================================

// Trust proxy - Required for rate limiting behind proxies/load balancers
app.set('trust proxy', 1);

// Security headers
app.use(helmet());

// CORS - Allow all origins for development
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per window
    message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Request logging
app.use((req: Request, res: Response, next: NextFunction) => {
    logger.info({
        method: req.method,
        path: req.path,
        ip: req.ip,
        timestamp: new Date().toISOString()
    });
    next();
});

// ========================================
// Services initialized at top of file
// ========================================


// ========================================
// Routes
// ========================================

// Health check
app.get('/health', async (req: Request, res: Response) => {
    try {
        const db = DatabaseService.getInstance();
        const dbHealth = await db.healthCheck();

        res.json({
            status: 'ok',
            timestamp: new Date().toISOString(),
            services: {
                database: dbHealth ? 'healthy' : 'unhealthy',
                cognito: 'healthy',
                s3: 'healthy'
            }
        });
    } catch (error) {
        res.status(500).json({
            status: 'error',
            message: 'Health check failed'
        });
    }
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/riders', riderRoutes);
app.use('/api/users', userRoutes);
app.use('/api/storage', storageRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/chat', chatRoutes);

// 404 handler
app.use((req: Request, res: Response) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} not found`
    });
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    logger.error({
        error: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method
    });

    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'production'
            ? 'An error occurred'
            : err.message
    });
});

// ========================================
// Start Server
// ========================================

app.listen(PORT, () => {
    logger.info(`🚀 Server running on port ${PORT}`);
    logger.info(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
    logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
});

export default app;
