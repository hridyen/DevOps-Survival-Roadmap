[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Web_Servers_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Web Server Commands

## ✦ 1. Nginx Management

### ✦ Service Control
```bash
# Start Nginx
sudo systemctl start nginx

# Enable to start on boot
sudo systemctl enable nginx

# Reload configuration (Zero Downtime)
sudo nginx -s reload
# or
sudo systemctl reload nginx
```

### ✦ Configuration Validation
**Always** run this before reloading Nginx to avoid crashing your server.
```bash
sudo nginx -t
```

---

## ✦ 2. Apache (HTTPD) Management

### ✦ Service Control
```bash
# Start Apache (RPM based)
sudo systemctl start httpd

# Start Apache (Debian based)
sudo systemctl start apache2
```

### ✦ Configuration Validation
```bash
sudo apachectl configtest
```

---

## ✦ 3. Debugging & Logs

### ✦ Journalctl
View real-time error logs for your web server.
```bash
# Nginx logs
sudo journalctl -u nginx -f

# Apache logs
sudo journalctl -u httpd -f
```

### ✦ Path Analysis
Check where your web files are served from.
```bash
# Default Nginx Path
ls /var/www/html/

# Search for Nginx configuration files
grep -r "server_name" /etc/nginx/
```
