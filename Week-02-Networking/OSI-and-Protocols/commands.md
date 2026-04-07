[![Sector](https://img.shields.io/badge/SECTOR-Networking-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-OSI_and_Protocols_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Troubleshooting — Commands Reference

---

## ✦ 🌐 Port & Protocol Verification

```bash
# Socket Diagnostics
netstat -tulnp                       # Legacy command: show listening TCP/UDP ports
ss -tulnp                            # Modern variant of netstat (much faster)
lsof -i -P -n                        # List active open IP sockets

# Connectivity Testing
ping 8.8.8.8                         # Indefinite ICMP echo requests
traceroute google.com                # Map exact Layer 3 router hops packet takes
telnet 10.0.0.1 80                   # Verify if a specific TCP port is open
```

---

## ✦ 📝 My Protocol Debugging Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `nc -zv 10.0.0.5 3306` | Netcat zero-I/O TCP connection test. | When DB connections timeout, this confirms if the firewall is forcefully dropping Port 3306 traffic. |
| `curl -I https://domain.com` | Fetches HTTP headers only (Layer 7). | Validating if a web server is strictly returning 200 OK or 503 HTTP codes without downloading html. |
