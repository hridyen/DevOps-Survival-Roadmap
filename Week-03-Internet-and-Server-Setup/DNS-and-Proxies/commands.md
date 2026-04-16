[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-DNS_and_Proxies_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ DNS & Proxy Commands

## ✦ 1. DNS Resolution & Debugging

### ✦ Dig (Domain Information Groper)
The primary tool for querying DNS name servers.
```bash
# Basic resolution
dig google.com

# Short answer (just the IP)
dig google.com +short

# Query a specific Name Server
dig @8.8.8.8 google.com

# Trace the resolution path
dig google.com +trace
```

### ✦ Nslookup
Legacy but essential for quick checks.
```bash
# Basic lookup
nslookup google.com

# Check specific record types (e.g., MX)
nslookup -type=mx google.com
```

---

## ✦ 2. Proxy & Connectivity Testing

### ✦ Curl (Client URL)
The "Swiss Army Knife" of internet requests.
```bash
# View HTTP Headers only
curl -I https://google.com

# Follow redirects (-L) and show verbose output (-v)
curl -Lv https://google.com

# Test through a proxy
curl -x http://proxy-server:port https://google.com
```

### ✦ OpenSSL
Essential for checking SSL/TLS certificates on proxies.
```bash
# Check SSL certificate details for a hostname
openssl s_client -connect google.com:443 -showcerts
```

---

## ✦ 3. Network Sockets

### ✦ Telnet & Netcat
Check if a port is open before configuring your proxy.
```bash
# Test if Port 80 is open
telnet google.com 80

# Netcat (Scan mode)
nc -zv google.com 443
```
