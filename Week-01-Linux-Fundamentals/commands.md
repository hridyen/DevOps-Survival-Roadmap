[![Sector](https://img.shields.io/badge/SECTOR-Linux_Fundamentals-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ 🐧 Week 01 — Linux Commands Reference

> All commands used during Week 1. Use this as your personal cheat sheet.

---

## ✦ 📂 File & Directory Commands

```bash
# Navigation
pwd                          # Print current directory
ls                           # List files
ls -la                       # List all files with details (including hidden)
cd /path/to/folder           # Change directory
cd ..                        # Go up one level
cd ~                         # Go to home directory

# Create & Delete
touch filename.txt           # Create an empty file
mkdir foldername             # Create a directory
mkdir -p a/b/c               # Create nested directories
rm filename.txt              # Delete a file
rm -rf foldername            # Delete a folder and everything inside it (use carefully!)
cp file1.txt file2.txt       # Copy a file
mv file1.txt newname.txt     # Rename or move a file

# View files
cat filename.txt             # Print file contents
less filename.txt            # View file page by page
head -10 filename.txt        # View first 10 lines
tail -10 filename.txt        # View last 10 lines
tail -f /var/log/syslog      # Watch a log file in real time
```

---

## ✦ 🔐 Permission Commands

```bash
# View permissions
ls -l filename               # Show permissions

# Change permissions (numeric)
chmod 755 script.sh          # rwxr-xr-x
chmod 644 file.txt           # rw-r--r--
chmod 600 private.key        # rw------- (only owner can read/write)

# Change permissions (symbolic)
chmod +x script.sh           # Add execute permission
chmod -w file.txt            # Remove write permission
chmod u+x,g-w file.txt       # Give owner execute, remove group write

# Change ownership
chown user file.txt          # Change file owner
chown user:group file.txt    # Change owner and group
chown -R user foldername     # Change ownership recursively
```

---

## ✦ 👤 User Management Commands

```bash
# Create & manage users
useradd username             # Create a new user
useradd -m username          # Create user with a home directory
passwd username              # Set a password for a user
usermod -aG groupname user   # Add user to a group
userdel username             # Delete a user
userdel -r username          # Delete user and their home directory

# Groups
groupadd groupname           # Create a new group
groupdel groupname           # Delete a group
groups username              # Show which groups a user belongs to
id username                  # Show user ID and group info

# Switch users
su username                  # Switch to another user
su -                         # Switch to root
sudo command                 # Run a single command as root
whoami                       # Show current logged-in user
```

---

## ✦ 🔍 Search & Text Commands

```bash
# Search
grep "word" filename.txt     # Search for "word" in a file
grep -r "word" /path/        # Search recursively in a directory
grep -i "word" filename.txt  # Case-insensitive search
grep -n "word" filename.txt  # Show line numbers

# Find files
find / -name "filename.txt"  # Find file by name
find /home -type f -name "*.sh"   # Find all shell scripts in /home
find / -user username        # Find all files owned by a user

# Text processing
sort filename.txt            # Sort lines alphabetically
uniq filename.txt            # Remove duplicate lines
wc -l filename.txt           # Count lines in a file
```

---

## ✦ 🖥️ System Info Commands

```bash
uname -a                     # Show kernel and system info
hostname                     # Show machine hostname
df -h                        # Show disk space usage (human readable)
du -sh foldername            # Show folder size
free -h                      # Show RAM usage
top                          # Live view of running processes
htop                         # Better live process viewer (if installed)
ps aux                       # Show all running processes
ps aux | grep processname    # Filter processes by name
kill PID                     # Kill a process by its ID
kill -9 PID                  # Force kill a process
```

---

## ✦ 🛠️ Shell Scripting Basics

```bash
#!/bin/bash                  # Shebang line — always first

# Variables
NAME="DevOps"
echo "Hello $NAME"

# User input
read -p "Enter your name: " USERNAME
echo "Welcome, $USERNAME"

# If/else
if [ "$USERNAME" == "admin" ]; then
  echo "Welcome, admin!"
else
  echo "Access denied."
fi

# Loops
for i in 1 2 3 4 5; do
  echo "Number: $i"
done

# While loop
COUNT=1
while [ $COUNT -le 5 ]; do
  echo "Count: $COUNT"
  COUNT=$((COUNT + 1))
done

# Functions
greet() {
  echo "Hello, $1!"
}
greet "World"

# Make script executable and run
chmod +x myscript.sh
./myscript.sh
```

---

## ✦ 📝 My Command Notes

<!-- Add your own command discoveries below -->

| Command | What it does | When I used it |
|---------|-------------|----------------|
| Command | What it does | When I used it |
|---------|-------------|----------------|
| `awk '{print $1}'` | Extracts the first column of text output | Parsing Apache access logs to find unique IP addresses |
| `strace -p <PID>` | Traces system calls of a running process | Debugging a Jenkins agent that was stuck hanging |
| `sed -i 's/old/new/g' file` | Stream editor for inline string replacement | Mass replacing environment variables in configuration files |
| `lsof -i :8080` | Lists open files and ports | Checking if Jenkins is actively binding to port 8080 |
| `nslookup <domain>` | Queries DNS to find IP resolution | Troubleshooting reverse proxy routing failures |
