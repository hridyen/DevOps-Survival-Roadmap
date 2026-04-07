[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Automation_and_Crons_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Automation — Commands Reference

---

## ✦ 🔁 Scheduling Logistics

```bash
# Cron Control
crontab -e                           # Edit user's current cron table
crontab -l                           # List active jobs assigned to user
0 2 * * * /home/user/backup.sh       # Example: Run 2AM specifically

# The AT Daemon (One-time jobs)
at 10:00 AM tomorrow                 # Open sub-shell for one-time command
atq                                  # Enumerate all pending `at` tasks
atrm 3                               # Forcefully drop task queue #3
```

---

## ✦ 🔍 Parsing Outputs

```bash
# Advanced Regular Expressions
grep -E "error|warning" file.log     # Native OR extraction parameters
grep -i "error" file.log             # Bypass all case-sensitive tracking
grep -A 5 "kernel" /var/log/messages # Also print the 5 lines sequentially AFTER 'kernel' matches
```

---

## ✦ 📝 My Script Debugging Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `crontab -u admin -e` | Safely access and edit another user's cron schedule natively. | Intercepting and debugging why a teammate's database backup is failing overnight. |
| `> /dev/null 2>&1` | Stream redirection completely absorbing Output AND Errors. | Putting this at the end of a cronjob prevents the kernel from spamming your `/var/mail/` directory with cron logs. |
