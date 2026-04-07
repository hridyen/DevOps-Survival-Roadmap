[![Sector](https://img.shields.io/badge/SECTOR-Linux_Fundamentals-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-CLI_Basics_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ CLI Basics — Commands Reference

---

## ✦ 📂 Core Navigation

```bash
pwd                          # Print present working directory
ls -lah                      # List human-readable files including hidden
cd ~                         # Escape back to user home
touch filename.txt           # Initialize blank file
mkdir -p a/b/c               # Create deep folder chains silently
rm -rf foldername            # Recursive force destruct (DANGEROUS)
cp -r source/ dest/          # Recursive folder copy
cat file.txt                 # Print all stream contents
tail -f /var/log/syslog      # Real-time streaming of system logs
```

---

## ✦ 🖥️ Monitoring & Debugging

```bash
uname -a                     # Print full kernel & architecture
free -h                      # Display human-readable RAM consumption
df -h                        # Disk capacity status
top                          # Live performance monitoring
htop                         # Enhanced live monitoring (if installed)
ps aux | grep nginx          # Filter all processes natively for nginx
kill -9 <PID>                # Send SIGKILL to immediately terminate a hanging process
```

---

## ✦ 📝 Advanced Command Debugging

| Command | Objective | Real World DevOps Use Case |
|---|---|---|
| `strace -p <PID>` | Traces system calls | Identifying why a Jenkins agent disconnected abruptly |
| `sed -i 's/x/y/g' file` | Stream string replacement | Injecting new environment variables into configuration files rapidly |
| `lsof -i :8080` | List active port socket bindings | Determining if port 8080 is actually locked by a zombie process |
| `awk '{print $1}'` | Extracts text column one | Parsing Apache logs exclusively for unique IP address counts |
