# 🔧 Week 03 — Shell Scripts

## Install Multiple PHP Versions

```bash
#!/bin/bash
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install -y php7.4 php7.4-fpm php8.1 php8.1-fpm
echo "PHP 7.4 and 8.1 installed"
```

## WordPress Installation Script

```bash
#!/bin/bash
apt-get install -y nginx mysql-server php php-mysql php-fpm
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
echo "WordPress downloaded to /var/www/html/wordpress"
```

## Nginx Reverse Proxy Config

```nginx
server {
    listen 80;
    server_name myapp.com;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

## 📝 My Scripts
<!-- Add your own scripts here -->
