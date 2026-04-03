[![Sector](https://img.shields.io/badge/SECTOR-Networking-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Week 02 — Networking

> **Duration:** Jan 27 – Feb 02, 2026

## ✦ Concepts Learned

### ✦ IPv4 vs IPv6
- **IPv4** — 32-bit (e.g. 192.168.1.10), ~4.3B addresses
- **IPv6** — 128-bit (e.g. 2001:db8::1), virtually unlimited

### ✦ Subnetting & CIDR
- **Subnet** — a division of a larger network
- **CIDR** — shorthand notation: `192.168.1.0/24` = 256 addresses
- **Netmask** — e.g. `255.255.255.0` defines network vs host portion

### ✦ DHCP
Automatically assigns IP addresses to devices on a network.

### ✦ TCP vs UDP
| TCP | UDP |
|---|---|
| Reliable, ordered | Fast, no guarantee |
| Web, email | Streaming, gaming, DNS |

### ✦ OSI Model (7 Layers)
```
7 Application  → HTTP, DNS, FTP
6 Presentation → Encryption
5 Session      → Session mgmt
4 Transport    → TCP, UDP, Ports
3 Network      → IP, Routing
2 Data Link    → MAC, Switches
1 Physical     → Cables, Signals
```

### ✦ Network Topologies
- **Star** — all connect to central switch (most common)
- **Bus** — all on one cable
- **Ring** — devices in a loop
- **Mesh** — every device connects to every other

### ✦ Client-Server Architecture
Client sends requests → Server responds with data.

---

## ✦ Personal Notes
<!-- Add your notes here -->

## ✦ Resources
See [resources.md](./resources.md)
