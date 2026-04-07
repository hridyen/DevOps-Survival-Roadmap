[![Sector](https://img.shields.io/badge/SECTOR-Networking-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-IP_and_Subnetting_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ IP Addressing — Commands Reference

---

## ✦ 💻 Network Identity & Routing

```bash
# Core Identity Lookups
ip addr show                         # The modern command for ifconfig
curl ifconfig.me                     # Rapidly fetches outward-facing Public IP
nslookup google.com                  # Basic CLI DNS fetcher
dig google.com                       # Advanced CLI DNS querying tool

# Routing Configurations
ip route show                        # Reveals all interconnected gateway IP hops
route -n                             # Legacy route display command
netstat -rn                          # Alternate routing table display
```

---

## ✦ 📝 My IP Resolution Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `dig +short domain.com` | Rapid compact DNS return metric. | Checking if new Route 53 entries in AWS have actually propagated yet. |
| `ip -4 a` | Clean filtration natively strictly for IPv4 blocks. | Automating Jenkins scripts that don't need messy IPv6 data to SSH properly. |
