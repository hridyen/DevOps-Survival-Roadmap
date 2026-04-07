[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-DNS_and_Proxies_Scripts-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Proxy Scripts & Configurations

---

## ✦ 📜 Nginx Core Reverse-Proxy Block

```nginx
server {
    listen 80;
    server_name myapp.com www.myapp.com;
    
    location / {
        proxy_pass http://localhost:3000;
        
        # Ensures client IP identity passes through the proxy to the backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## ✦ 📜 Shell Automated Nginx Proxy Injector

```bash
#!/bin/bash
# ✦ Quick Proxy Config Injection
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name mydomain.com;
    
    location / {
        proxy_pass http://localhost:8080;
    }
}
EOF

# Activate site via symlink creation
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Re-evaluate live daemon and spin the new config actively
nginx -t && systemctl restart nginx
```

---

## ✦ 📝 My Script Debugging Notes

| Script Component | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `nginx -t` | Syntax evaluation tester native to Nginx. | Run this before restarting systemctl to ensure you never accidentally crash production with a bad semi-colon placement in the `nginx.conf`. |
