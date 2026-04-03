[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Week 04 — Advanced Linux Tools

> **Duration:** Feb 10 – Feb 16, 2026

## ✦ Concepts Learned

### ✦ ACL (Access Control Lists)
Fine-grained permissions beyond basic owner/group/others.
```bash
setfacl -m u:username:rwx filename
getfacl filename
```

### ✦ GREP
Search text in files — used constantly in DevOps for log analysis.
```bash
grep "error" /var/log/syslog
grep -r "TODO" /home/
grep -E "error|warning" app.log
```

### ✦ tar (Archives)
```bash
tar -czvf archive.tar.gz folder/     # Create
tar -xzvf archive.tar.gz             # Extract
```

### ✦ Cron Jobs & at
- **cron** — recurring scheduled tasks
- **at / atq** — one-time scheduled tasks
```bash
crontab -e                           # Edit cron schedule
# format: min hour day month weekday command
0 2 * * * /home/user/backup.sh      # Run backup at 2am daily
atq                                  # List at jobs
```

### ✦ SUID & SGID
- **SUID** on binary: runs as the file's owner, not the current user
- **SGID** on directory: new files inherit directory's group

### ✦ Wheel Group
Users in `wheel` group can use `sudo`.
```bash
usermod -aG wheel username
```

### ✦ nmcli
CLI tool for NetworkManager.
```bash
nmcli device status
nmcli connection show
```

---

## ✦ Personal Notes
<!-- Add notes here -->

## ✦ Resources
See [resources.md](./resources.md)
