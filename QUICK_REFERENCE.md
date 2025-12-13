# Zhigo Food Delivery - Quick Reference

## 🚀 Running the Apps

### Backend (Express.js)
```powershell
cd backend-express
npm install
npm run dev
# Runs on http://localhost:3000
```

### Android Apps
```powershell
# Customer App
cd android/customer
.\gradlew installDebug

# Rider App
cd android/rider
.\gradlew installDebug

# Restaurant Owner App
cd android/restaurant
.\gradlew installDebug

# Admin App
cd android/admin
.\gradlew installDebug
```

### Web Apps
```powershell
# Customer Web
cd packages/customer-mobile
npm install
npm run dev
# Runs on http://localhost:3000

# Rider Web
cd packages/rider-mobile
npm install
npm run dev
# Runs on http://localhost:3002

# Admin Web
cd packages/admin-portal
npm install
npm run dev
# Runs on http://localhost:3001
```

---

## 📁 Project Structure

```
zhigo3/
├── backend-express/          # Express.js API
│   ├── src/
│   │   ├── server.ts
│   │   ├── routes/          # API routes
│   │   └── services/        # Cognito, S3, Database
│   └── ecosystem.config.js  # PM2 config
│
├── android/                  # Native Android Apps
│   ├── customer/
│   ├── rider/
│   ├── restaurant/
│   └── admin/
│
├── packages/                 # Web Apps
│   ├── customer-mobile/
│   ├── rider-mobile/
│   ├── admin-portal/
│   ├── shared-ui/
│   ├── shared-utils/
│   └── shared-types/
│
└── backend/
    ├── database/
    │   └── schema.sql       # PostgreSQL schema
    └── services/            # Reusable services
```

---

## 🔑 Environment Variables

### Backend (.env)
```env
DATABASE_URL=postgresql://...
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=...
COGNITO_CLIENT_ID=...
S3_BUCKET_NAME=...
PORT=3000
NODE_ENV=development
```

### Web Apps (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:3000
```

---

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/auth/signin` | POST | Sign in |
| `/api/auth/signup` | POST | Sign up |
| `/api/auth/confirm` | POST | Confirm email |
| `/api/auth/signout` | POST | Sign out |
| `/api/auth/me` | GET | Get current user |
| `/api/restaurants` | GET | List restaurants |
| `/api/restaurants` | POST | Create restaurant |
| `/api/orders` | GET | List orders |
| `/api/orders` | POST | Create order |
| `/api/storage/upload-url` | POST | Get upload URL |

---

## 🛠️ Common Commands

### Backend
```powershell
npm run dev          # Development
npm run build        # Build TypeScript
npm start            # Production
pm2 start ecosystem.config.js  # PM2 cluster
pm2 logs             # View logs
pm2 monit            # Monitor
```

### Android
```powershell
.\gradlew clean              # Clean build
.\gradlew assembleDebug      # Build APK
.\gradlew installDebug       # Install on device
adb logcat | grep Zhigo      # View logs
```

### Database
```powershell
npm run db:migrate   # Run migrations
psql $DATABASE_URL   # Connect to database
```

---

## 📊 Costs

| Service | Monthly Cost |
|---------|--------------|
| EC2 t3.small | $17 |
| Neon PostgreSQL | $0 (free tier) |
| S3 Storage | $2 |
| Cognito | $0 |
| Domain | $1 |
| **TOTAL** | **~$20/month** |

---

## 🐛 Troubleshooting

### Backend won't start
```powershell
# Check environment variables
cat .env

# Check if port is in use
netstat -ano | findstr :3000

# Restart
pm2 restart all
```

### Android build fails
```powershell
# Clean and rebuild
.\gradlew clean
.\gradlew assembleDebug --stacktrace
```

### Database connection fails
```powershell
# Test connection
psql $DATABASE_URL

# Check if schema is created
npm run db:migrate
```

---

## 📚 Documentation

1. **ANDROID_RUN_GUIDE.md** - How to run Android apps
2. **EC2_DEPLOYMENT_GUIDE.md** - Deploy to production
3. **DATABASE_COMPARISON.md** - Database options
4. **FINAL_SUMMARY.md** - Project overview
5. **ENV_SETUP_GUIDE.md** - Environment setup

---

## 🎯 Next Steps

1. Test backend locally
2. Test Android apps on emulator
3. Deploy backend to EC2
4. Publish Android apps to Play Store
5. Deploy web apps to Vercel

---

**Need help?** Check the documentation guides!
