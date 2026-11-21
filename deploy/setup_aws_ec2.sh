#!/bin/bash
# ==============================================================================
# AstroDashaCare - Automated AWS EC2 / Lightsail Deployment Script
# Target OS: Ubuntu 22.04 LTS / Ubuntu 24.04 LTS
# ==============================================================================

set -e

echo "=========================================================="
echo " Starting AstroDashaCare AWS Deployment"
echo "=========================================================="

# 1. Update packages
sudo apt update && sudo apt upgrade -y

# 2. Install essential dependencies (Nginx, Python3, Certbot)
sudo apt install -y python3 python3-pip python3-venv nginx certbot python3-certbot-nginx ufw curl

# 3. Create target directory structure
sudo mkdir -p /var/www/astrodashacare/web
sudo mkdir -p /var/www/astrodashacare/backend
sudo mkdir -p /var/www/astrodashacare/downloads
sudo chown -R ubuntu:ubuntu /var/www/astrodashacare

# 4. Set up Python virtual environment for FastAPI Backend
echo "Setting up FastAPI backend virtual environment..."
cd /var/www/astrodashacare/backend
python3 -m venv venv
./venv/bin/pip install --upgrade pip
if [ -f requirements.txt ]; then
    ./venv/bin/pip install -r requirements.txt
fi

# 5. Configure Systemd Service for FastAPI
echo "Configuring Systemd service..."
sudo cp /var/www/astrodashacare/backend/astrodashacare-backend.service /etc/systemd/system/ || true
sudo systemctl daemon-reload
sudo systemctl enable astrodashacare-backend
sudo systemctl restart astrodashacare-backend

# 6. Configure Nginx Web Server & Reverse Proxy
echo "Configuring Nginx..."
sudo cp /var/www/astrodashacare/nginx.conf /etc/nginx/sites-available/astrodashacare || true
sudo ln -sf /etc/nginx/sites-available/astrodashacare /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx

# 7. Configure Firewall (UFW)
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable || true

echo "=========================================================="
echo " AstroDashaCare deployed successfully!"
echo " Web app is live at: http://$(curl -s ifconfig.me)"
echo " API Docs is live at: http://$(curl -s ifconfig.me)/api/docs"
echo "=========================================================="

