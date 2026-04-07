[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Web_Servers_Scripts-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Server Scripts

---

## ✦ 📜 PHP FastCGI Process Manager Integration

```bash
#!/bin/bash
# Multi-version FPM deployment
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install -y php7.4 php7.4-fpm php8.1 php8.1-fpm
systemctl restart php8.1-fpm
```

---

## ✦ 📜 Monolithic WordPress Automation

```bash
#!/bin/bash
# LAMP/LEMP Stack bootstrap
apt-get install -y nginx mysql-server php php-mysql php-fpm

cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm latest.tar.gz

chown -R www-data:www-data /var/www/html/wordpress
echo "WordPress isolated successfully at /var/www/html/wordpress"
```

---

## ✦ 📝 My Script Debugging Notes

| Script Component | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `chown -R www-data:www-data` | Grants the Nginx web-daemon ownership of files. | Fixing "Permission Denied" errors when trying to upload media directly into WordPress. |
