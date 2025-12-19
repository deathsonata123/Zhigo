#!/bin/bash

# Zhigo Deployment Script
# This script automates the deployment process

set -e  # Exit on error

echo "🚀 Starting Zhigo Deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$HOME/zhigo-clean"
BACKUP_DIR="$HOME/zhigo-backups"

echo -e "${YELLOW}📁 Navigating to project directory...${NC}"
cd $PROJECT_DIR

# Create backup
echo -e "${YELLOW}💾 Creating backup...${NC}"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
pm2 save --force
cp ecosystem.config.js "$BACKUP_DIR/ecosystem.config.js.$TIMESTAMP"

# Pull latest changes
echo -e "${YELLOW}🔄 Pulling latest code from Git...${NC}"
git pull origin main

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"

# Backend
cd backend-express
npm install --production
cd ..

# Admin Dashboard
cd web/admin-dashboard
npm install --production
npm run build
cd ../..

# Restaurant Dashboard
cd web/restaurant-dashboard
npm install --production
npm run build
cd ../..

# Restart PM2 processes
echo -e "${YELLOW}🔄 Restarting PM2 processes...${NC}"
pm2 restart all

# Wait for apps to start
sleep 5

# Check status
echo -e "${YELLOW}📊 Checking PM2 status...${NC}"
pm2 status

# Test endpoints
echo -e "${YELLOW}🧪 Testing endpoints...${NC}"

if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API is running${NC}"
else
    echo -e "${RED}❌ API is not responding${NC}"
    exit 1
fi

if curl -f http://localhost:3001 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Admin Dashboard is running${NC}"
else
    echo -e "${RED}❌ Admin Dashboard is not responding${NC}"
    exit 1
fi

if curl -f http://localhost:3002 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Restaurant Dashboard is running${NC}"
else
    echo -e "${RED}❌ Restaurant Dashboard is not responding${NC}"
    exit 1
fi

echo -e "${GREEN}✨ Deployment completed successfully!${NC}"
echo -e "${YELLOW}📝 Check logs with: pm2 logs${NC}"
