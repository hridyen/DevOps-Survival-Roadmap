# 🔐 Week 04 — Advanced Linux Commands

```bash
# ACL
setfacl -m u:bob:rw file.txt
getfacl file.txt
setfacl -x u:bob file.txt           # Remove ACL entry

# GREP
grep "error" file.log
grep -i "error" file.log            # Case-insensitive
grep -n "error" file.log            # Line numbers
grep -r "pattern" /etc/             # Recursive
grep -v "debug" file.log            # Invert (exclude)
grep -E "error|warning" file.log    # Multiple patterns

# tar
tar -czvf backup.tar.gz folder/
tar -xzvf backup.tar.gz
tar -tzvf backup.tar.gz             # List contents

# Cron
crontab -l                           # List jobs
crontab -e                           # Edit
# * * * * * = min hour day month weekday
0 2 * * * /home/user/backup.sh

# at (one-time)
at 10:00 AM tomorrow
atq                                  # List pending
atrm 3                               # Remove job #3

# SUID / SGID / Sticky
chmod u+s binary
chmod g+s directory/
chmod +t /tmp
find / -perm -u=s 2>/dev/null       # Find all SUID files

# nmcli
nmcli device status
nmcli connection show
nmcli connection up "Wired connection 1"
```

## 📝 My Notes
<!-- Add command notes -->
