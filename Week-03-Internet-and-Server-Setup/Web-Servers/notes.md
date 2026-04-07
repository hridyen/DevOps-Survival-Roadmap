[![Sector](https://img.shields.io/badge/SECTOR-Internet_and_Server_Setup-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Web_Servers_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Server Hardware & Web Configuration

> **Focus:** Bare-metal dependencies and Application scaling integrations.

---

## ✦ 1. Bare-metal Hardware Dependencies

Understanding underlying architectures allows Cloud Engineers to optimize VM compute allocations.

| Component | Function | Cloud Equivalent |
|---|---|---|
| **RAM** | Temporary volatile execution memory. Processes die without it. | EC2 Memory |
| **HDD vs SSD** | Spinning Magnetic platters vs Solid-State Logic arrays. | EBS `gp2` vs `gp3` IOPS |
| **BIOS & ROM** | Read-only structural firmware booting the OS. | AWS AMI Boot Sequences |
| **CPU** | Core execution thread count. | vCPU hyperthreading |

---

## ✦ 2. Web Engine Environments

When orchestrating internet traffic, specific daemons are tuned to handle incoming requests.

- **Nginx**: Extremely event-driven, handles thousands of concurrent static requests efficiently.
- **Apache (HTTPD)**: Process-driven, relies extensively on `.htaccess` rewriting rules natively.

> [!TIP]
> Modern DevOps leans extensively towards containerized **Nginx** due to its remarkably lower memory footprint per concurrent connection compared to legacy Apache bounds.

---

## ✦ Practice Exercises
- [ ] Determine the exactly RAM allocation limits of your local system execution states using `free -mh`.
- [ ] Spin up an offline Nginx installation and modify its default `/var/www/html/index.html` file. 
