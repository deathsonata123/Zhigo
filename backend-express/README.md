# Zhigo Food Delivery - Express.js Backend

## 🚀 Quick Start

### Development
```bash
npm install
npm run dev
```

### Production
```bash
npm run build
npm start
```

### With PM2 (Recommended for Production)
```bash
npm run build
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 📁 Project Structure

```
backend-express/
├── src/
│   ├── server.ts              # Express app entry point
│   ├── routes/                # API route handlers
│   │   ├── auth.routes.ts
│   │   ├── restaurant.routes.ts
│   │   ├── order.routes.ts
│   │   ├── rider.routes.ts
│   │   ├── user.routes.ts
│   │   ├── storage.routes.ts
│   │   └── admin.routes.ts
│   └── services/              # Copied from backend/services
│       ├── database/
│       ├── auth/
│       └── storage/
├── dist/                      # Compiled JavaScript
├── logs/                      # PM2 logs
├── package.json
├── tsconfig.json
└── ecosystem.config.js        # PM2 configuration
```

## 🔧 Environment Variables

Create `.env` file:
```env
# Database
DATABASE_URL=postgresql://...

# AWS
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=us-east-1_XXXXX
COGNITO_CLIENT_ID=xxxxx
S3_BUCKET_NAME=zhigo-storage-xxxxx

# Server
PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com,https://api.yourdomain.com
```

## 📡 API Endpoints

### Authentication
- `POST /api/auth/signin` - Sign in
- `POST /api/auth/signup` - Sign up
- `POST /api/auth/confirm` - Confirm email
- `POST /api/auth/signout` - Sign out
- `GET /api/auth/me` - Get current user
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### Restaurants
- `GET /api/restaurants` - List restaurants
- `POST /api/restaurants` - Create restaurant
- `GET /api/restaurants/:id` - Get restaurant
- `PUT /api/restaurants/:id` - Update restaurant
- `DELETE /api/restaurants/:id` - Delete restaurant

### Orders
- `GET /api/orders` - List orders
- `POST /api/orders` - Create order
- `GET /api/orders/:id` - Get order
- `PUT /api/orders/:id/status` - Update order status
- `PUT /api/orders/:id/assign-rider` - Assign rider

### Storage
- `POST /api/storage/upload-url` - Get presigned upload URL
- `POST /api/storage/download-url` - Get presigned download URL
- `DELETE /api/storage/delete` - Delete file

### Health
- `GET /health` - Health check

## 🧪 Testing

```bash
# Test health endpoint
curl http://localhost:3000/health

# Test signin
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

## 📊 Monitoring

```bash
# PM2 monitoring
pm2 monit

# View logs
pm2 logs zhigo-api

# Check status
pm2 status
```

## 🔄 Deployment

See deployment guide in `DEPLOYMENT.md`
