# Architecture Overview

## 🏗️ Current Setup (Post-Migration)

### Backend Infrastructure:
```
┌─────────────────────────────────────────┐
│         AWS EC2 Instance                │
│  - Express.js API (Node.js 20)          │
│  - PM2 cluster mode                     │
│  - Nginx reverse proxy                  │
└─────────────────────────────────────────┘
                ↓
        ┌───────┴───────┐
        ↓               ↓
┌──────────────┐  ┌──────────────┐
│ Neon         │  │ AWS Services │
│ PostgreSQL   │  │ - Cognito    │
│ (Serverless) │  │ - S3         │
└──────────────┘  └──────────────┘
```

### What We're Using:

#### ✅ Database: Neon PostgreSQL
- **NOT DynamoDB** (removed with Amplify)
- Serverless PostgreSQL
- Free tier: 0.5GB storage
- Connection string: `postgresql://...neon.tech/...`

#### ✅ Authentication: AWS Cognito
- **NEW User Pool** (not from Amplify)
- You need to create this via CDK or AWS Console
- User Pool ID: `us-east-1_XXXXX`
- Client ID: `xxxxxxxxxxxxx`

#### ✅ Storage: AWS S3
- **NEW S3 Bucket** (not from Amplify)
- You need to create this
- Bucket name: `zhigo-storage-xxxxx`

#### ✅ Backend: EC2
- Express.js server
- PM2 for process management
- Nginx for reverse proxy
- Let's Encrypt for SSL

### What We Removed:

#### ❌ AWS Amplify
- Completely removed
- No amplify CLI
- No amplify_outputs.json
- No Amplify hosting

#### ❌ DynamoDB
- Replaced with PostgreSQL
- All 18 tables now in Neon

#### ❌ Capacitor
- Removed from web apps
- Using native Android instead

---

## 🔧 Setup Required

### 1. Neon PostgreSQL (Already Done ✅)
```bash
# You already ran this:
npm run db:migrate
# Created 18 tables
```

### 2. AWS Cognito (Need to Create)
**Option A: Using CDK (Recommended)**
```bash
cd backend/infrastructure
npm install
cdk deploy CognitoStack
# This creates User Pool + Client
```

**Option B: AWS Console**
1. Go to AWS Cognito
2. Create User Pool
3. Note the User Pool ID and Client ID

### 3. AWS S3 (Need to Create)
**Option A: Using CDK**
```bash
cdk deploy StorageStack
# This creates S3 bucket with proper policies
```

**Option B: AWS Console**
1. Go to S3
2. Create bucket: `zhigo-storage-xxxxx`
3. Enable CORS

### 4. Environment Variables
Create `backend-express/.env`:
```env
# Neon PostgreSQL (you have this)
DATABASE_URL=postgresql://...

# AWS Cognito (need to create)
AWS_REGION=us-east-1
COGNITO_USER_POOL_ID=us-east-1_XXXXX
COGNITO_CLIENT_ID=xxxxxxxxxxxxx

# AWS S3 (need to create)
S3_BUCKET_NAME=zhigo-storage-xxxxx

# Server
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=*
```

---

## 💰 Cost Breakdown

| Service | Provider | Cost/Month |
|---------|----------|------------|
| **Database** | Neon PostgreSQL | $0 (free tier) |
| **Auth** | AWS Cognito | $0 (< 50k users) |
| **Storage** | AWS S3 | $2-5 |
| **Backend** | AWS EC2 t3.small | $17 |
| **CDN** | Cloudflare | $0 (free) |
| **Domain** | Namecheap | $1 |
| **TOTAL** | | **~$20/month** |

---

## 🚀 Next Steps

1. **Create AWS Resources:**
   ```bash
   cd backend/infrastructure
   npm install
   cdk bootstrap  # First time only
   cdk deploy CognitoStack
   cdk deploy StorageStack
   ```

2. **Update .env file** with the IDs from CDK output

3. **Start backend:**
   ```bash
   cd backend-express
   npm run dev
   ```

4. **Test:**
   ```bash
   curl http://localhost:3000/health
   ```

---

**Summary:** We're using NEW AWS resources (Cognito + S3), NOT from Amplify. Database is Neon PostgreSQL (serverless), NOT DynamoDB.
