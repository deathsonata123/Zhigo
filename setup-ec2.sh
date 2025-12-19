#!/bin/bash
# Zhigo EC2 Setup Script
# Run this on your EC2 instance after transferring files

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Zhigo EC2 Deployment Setup"
echo "========================================"

# Check if running as sudo for some commands
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Note: Some steps may require sudo password${NC}"
fi

PROJECT_DIR="$HOME/zhigo-clean"

# Create project directory if doesn't exist
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Creating project directory...${NC}"
    mkdir -p "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo " Step 1: Install Dependencies on EC2"
echo "=========================================="

# Backend
echo -e "${YELLOW}[1/3] Installing backend dependencies...${NC}"
if [ -d "backend-express" ]; then
    cd backend-express
    npm install --production
    cd ..
    echo -e "${GREEN}✓ Backend dependencies installed${NC}"
else
    echo -e "${RED}✗ backend-express directory not found${NC}"
fi

# Admin Dashboard
echo -e "${YELLOW}[2/3] Installing admin dashboard dependencies...${NC}"
if [ -d "web/admin-dashboard" ]; then
    cd web/admin-dashboard
    npm install --production
    cd ../..
    echo -e "${GREEN}✓ Admin dashboard dependencies installed${NC}"
else
    echo -e "${RED}✗ web/admin-dashboard directory not found${NC}"
fi

# Restaurant Dashboard
echo -e "${YELLOW}[3/3] Installing restaurant dashboard dependencies...${NC}"
if [ -d "web/restaurant-dashboard" ]; then
    cd web/restaurant-dashboard
    npm install --production
    cd ../..
    echo -e "${GREEN}✓ Restaurant dashboard dependencies installed${NC}"
else
    echo -e "${RED}✗ web/restaurant-dashboard directory not found${NC}"
fi

echo ""
echo "=========================================="
echo " Step 2: Create Environment Files"
echo "=========================================="

echo -e "${YELLOW}Creating .env files from examples...${NC}"

# Backend .env
if [ -f "backend-express/.env.example" ] && [ ! -f "backend-express/.env" ]; then
    cp backend-express/.env.example backend-express/.env
    echo -e "${GREEN}✓ Created backend-express/.env${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Edit backend-express/.env with your credentials${NC}"
elif [ -f "backend-express/.env" ]; then
    echo -e "${GREEN}✓ backend-express/.env already exists${NC}"
fi

# Admin .env.local
if [ ! -f "web/admin-dashboard/.env.local" ]; then
    cat > web/admin-dashboard/.env.local << 'EOF'
NEXT_PUBLIC_API_URL=http://52.74.236.219:3000
NEXT_PUBLIC_COGNITO_USER_POOL_ID=your_user_pool_id
NEXT_PUBLIC_COGNITO_CLIENT_ID=your_client_id
NEXT_PUBLIC_AWS_REGION=us-east-1
EOF
    echo -e "${GREEN}✓ Created web/admin-dashboard/.env.local${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Edit with your Cognito credentials${NC}"
elif [ -f "web/admin-dashboard/.env.local" ]; then
    echo -e "${GREEN}✓ web/admin-dashboard/.env.local already exists${NC}"
fi

# Restaurant .env.local
if [ ! -f "web/restaurant-dashboard/.env.local" ]; then
    cat > web/restaurant-dashboard/.env.local << 'EOF'
NEXT_PUBLIC_API_URL=http://52.74.236.219:3000
NEXT_PUBLIC_COGNITO_USER_POOL_ID=your_user_pool_id
NEXT_PUBLIC_COGNITO_CLIENT_ID=your_client_id
NEXT_PUBLIC_AWS_REGION=us-east-1
EOF
    echo -e "${GREEN}✓ Created web/restaurant-dashboard/.env.local${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Edit with your Cognito credentials${NC}"
elif [ -f "web/restaurant-dashboard/.env.local" ]; then
    echo -e "${GREEN}✓ web/restaurant-dashboard/.env.local already exists${NC}"
fi

echo ""
echo "=========================================="
echo " Step 3: Create Logs Directory"
echo "=========================================="

mkdir -p logs
echo -e "${GREEN}✓ Logs directory created${NC}"

echo ""
echo "=========================================="
echo " Step 4: Start Applications with PM2"
echo "=========================================="

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}PM2 not found. Installing...${NC}"
    sudo npm install -g pm2
fi

# Start apps
echo -e "${YELLOW}Starting applications...${NC}"
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

echo ""
echo -e "${GREEN}✓ Applications started with PM2${NC}"

echo ""
echo "=========================================="
echo " Step 5: Setup PM2 Startup"
echo "=========================================="

echo -e "${YELLOW}Generating PM2 startup script...${NC}"
pm2 startup

echo ""
echo -e "${YELLOW}⚠ IMPORTANT: Run the command shown above with sudo${NC}"

echo ""
echo "=========================================="
echo " Step 6: Check Application Status"
echo "=========================================="

sleep 3
pm2 status

echo ""
echo "=========================================="
echo " Deployment Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo -e "${GREEN}✓ Environment files created${NC}"
echo -e "${GREEN}✓ Applications started${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Edit environment files with your credentials"
echo "2. Run the PM2 startup command shown above"
echo "3. Configure Nginx (run: sudo ./setup-nginx.sh)"
echo "4. Get SSL certificates (after DNS works)"
echo ""
echo "Test your apps:"
echo "  Backend: curl http://localhost:3000/health"
echo "  Admin: curl http://localhost:3001"
echo "  Restaurant: curl http://localhost:3002"
echo ""
