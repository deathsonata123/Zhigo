# Quick Deployment Commands Cheat Sheet

## 🔥 Quick Start (First Time)

```bash
# 1. Connect to EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Clone repository
git clone https://github.com/yourusername/zhigo-clean.git
cd zhigo-clean

# 3. Install dependencies and build
cd web/admin-dashboard && npm install && npm run build && cd ../..
cd web/restaurant-dashboard && npm install && npm run build && cd ../..
cd backend-express && npm install && npm run build && cd ..

# 4. Create environment files
nano backend-express/.env
nano web/admin-dashboard/.env.local
nano web/restaurant-dashboard/.env.local

# 5. Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup  # Follow instructions

# 6. Configure Nginx
sudo nano /etc/nginx/sites-available/zhigo
# Paste nginx configuration from DEPLOYMENT_GUIDE.md
sudo ln -s /etc/nginx/sites-available/zhigo /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 7. Get SSL certificates
sudo certbot --nginx -d admin.yourdomain.com -d restaurant.yourdomain.com -d api.yourdomain.com
```

---

## 🔄 Update/Redeploy

```bash
# Connect
ssh -i your-key.pem ubuntu@your-ec2-ip

# Navigate
cd ~/zhigo-clean

# Pull changes
git pull

# Rebuild if needed
cd web/admin-dashboard && npm run build && cd ../..

# Restart
pm2 restart all

# Check
pm2 status
pm2 logs --lines 20
```

---

## 🐛 Troubleshooting Commands

```bash
# Check app status
pm2 status
pm2 logs
pm2 monit

# Check Nginx
sudo systemctl status nginx
sudo nginx -t

# Check ports
sudo netstat -tulpn | grep LISTEN

# Restart everything
pm2 restart all
sudo systemctl restart nginx

# View error logs
pm2 logs --err
sudo tail -f /var/log/nginx/error.log

# Database connection test
cd backend-express
node -e "require('./dist/db/connection').testConnection()"
```

---

## 📊 Monitoring

```bash
# Real-time monitoring
pm2 monit

# Server resources
htop

# Disk space
df -h

# Memory usage
free -h

# Recent logs
pm2 logs --lines 50
```

---

## 🔐 SSL Certificate Management

```bash
# Check certificate expiry
sudo certbot certificates

# Renew certificates (manual)
sudo certbot renew

# Test auto-renewal
sudo certbot renew --dry-run

# Check renewal timer
sudo systemctl list-timers | grep certbot
```

---

## 💾 Backup Commands

```bash
# Backup PM2 configuration
pm2 save

# Backup environment files
mkdir -p ~/backups
cp backend-express/.env ~/backups/.env.$(date +%Y%m%d)

# Backup Nginx config
sudo cp /etc/nginx/sites-available/zhigo ~/backups/nginx-zhigo.$(date +%Y%m%d)

# Database backup (if PostgreSQL on EC2)
pg_dump zhigo_db > ~/backups/zhigo_db_$(date +%Y%m%d).sql
```

---

## 🚨 Emergency Recovery

```bash
# Stop all apps
pm2 stop all

# Kill all node processes
pkill -f node

# Restart from scratch
pm2 delete all
pm2 start ecosystem.config.js
pm2 save

# Nginx emergency restart
sudo systemctl stop nginx
sudo systemctl start nginx

# Check which process is using a port
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :3002
```

---

## 📱 Testing URLs

```bash
# API health check
curl https://api.yourdomain.com/health

# Test with authentication
curl -X POST https://api.yourdomain.com/api/restaurants \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}'

# Check response time
curl -o /dev/null -s -w 'Time: %{time_total}s\n' https://admin.yourdomain.com
```

---

## 🔧 Performance Tuning

```bash
# Increase PM2 instances for API
pm2 scale zhigo-api 4

# Restart with zero downtime
pm2 reload all

# Clear PM2 logs
pm2 flush

# Optimize PM2
pm2 optimize
```
