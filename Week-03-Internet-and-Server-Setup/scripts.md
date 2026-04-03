[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-scripts-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ 🔧 Week 03 — Shell Scripts

## ✦ Install Multiple PHP Versions

```bash
#!/bin/bash
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install -y php7.4 php7.4-fpm php8.1 php8.1-fpm
echo "PHP 7.4 and 8.1 installed"
```

## ✦ WordPress Installation Script

```bash
#!/bin/bash
apt-get install -y nginx mysql-server php php-mysql php-fpm
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz
echo "WordPress downloaded to /var/www/html/wordpress"
```

## ✦ Nginx Reverse Proxy Config

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

## ✦ 📝 My Scripts
```bash
#!/bin/bash
# âœ¦ Quick Proxy Config Injection
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name mydomain.com;
    location / {
        proxy_pass http://localhost:8080;
    }
}
EOF
systemctl restart nginx
```
