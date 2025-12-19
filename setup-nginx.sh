#!/bin/bash
# Nginx Setup Script for Zhigo
# Run with: sudo ./setup-nginx.sh

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

echo "========================================"
echo "  Nginx Configuration for Zhigo"
echo "========================================"

# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt update
    apt install -y nginx
    echo "✓ Nginx installed"
else
    echo "✓ Nginx already installed"
fi

# Remove default config
echo "Removing default Nginx config..."
rm -f /etc/nginx/sites-enabled/default

# Create Zhigo Nginx configuration
echo "Creating Zhigo Nginx configuration..."
cat > /etc/nginx/sites-available/zhigo << 'NGINX_CONFIG'
# Admin Dashboard
server {
    listen 80;
    server_name admin.zhigo.com.bd 52.74.236.219;

    client_max_body_size 10M;

    access_log /var/log/nginx/admin-access.log;
    error_log /var/log/nginx/admin-error.log;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        proxy_cache_bypass $http_upgrade;
    }

    location /_next/static {
        proxy_pass http://localhost:3001;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable";
    }
}

# Restaurant Dashboard
server {
    listen 80;
    server_name restaurant.zhigo.com.bd;

    client_max_body_size 10M;

    access_log /var/log/nginx/restaurant-access.log;
    error_log /var/log/nginx/restaurant-error.log;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        proxy_cache_bypass $http_upgrade;
    }

    location /_next/static {
        proxy_pass http://localhost:3002;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable";
    }
}

# Backend API
server {
    listen 80;
    server_name api.zhigo.com.bd;

    client_max_body_size 50M;

    access_log /var/log/nginx/api-access.log;
    error_log /var/log/nginx/api-error.log;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONFIG

echo "✓ Nginx configuration created"

# Enable the site
echo "Enabling Zhigo site..."
ln -sf /etc/nginx/sites-available/zhigo /etc/nginx/sites-enabled/

# Test configuration
echo "Testing Nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx configuration is valid"
    
    # Restart Nginx
    echo "Restarting Nginx..."
    systemctl restart nginx
    systemctl enable nginx
    
    echo "✓ Nginx restarted successfully"
    
    echo ""
    echo "========================================"
    echo "  Nginx Setup Complete!"
    echo "========================================"
    echo ""
    echo "Test your applications:"
    echo "  http://52.74.236.219 → Admin Dashboard"
    echo "  http://admin.zhigo.com.bd (when DNS works)"
    echo "  http://restaurant.zhigo.com.bd"
    echo "  http://api.zhigo.com.bd"
    echo ""
    echo "Check Nginx status: sudo systemctl status nginx"
    echo "View logs: sudo tail -f /var/log/nginx/error.log"
    echo ""
else
    echo "✗ Nginx configuration test failed"
    exit 1
fi
