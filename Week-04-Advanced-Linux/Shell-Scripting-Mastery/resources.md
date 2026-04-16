[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Shell_Scripting_Resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Shell Scripting Resources

| Category | Resource | Type | Level | Link |
|---|---|---|---|---|
| **Guide** | Bash Guide for Beginners | Document | Beginner | [Visit](https://tldp.org/LDP/Bash-Beginners-Guide/html/index.html) |
| **Tool** | ShellCheck (Syntax Analysis) | Tool | All Levels | [Visit](https://www.shellcheck.net/) |
| **Deep Dive** | Advanced Bash Scripting Guide | Document | Advanced | [Visit](https://tldp.org/LDP/abs/html/) |
| **Visual** | Mermaid.js Flowchart Guide | Guide | All Levels | [Visit](https://mermaid.js.org/syntax/flowchart.html) |

---

## ✦ Industrial Practice Labs

### 🧪 Lab 1: Automated User Audit
- **Goal:** Create a script that lists all users on the system with UID > 1000 and outputs them to a CSV file.
- **Workflow:** 
    1. Parse `/etc/passwd`.
    2. Filter by UID.
    3. Use `awk` to format into `Username,UID,Shell`.

### 🧪 Lab 2: Disk Space Watchdog
- **Goal:** Send an alert echo if any disk partition is over 90% full.
- **Workflow:** 
    1. run `df -h`.
    2. Extract percentage using `grep` and `awk`.
    3. Use an `if` condition to trigger the alert.

### 🧪 Lab 3: Log Rotation Simulation
- **Goal:** Zip all files in `/var/log` ending in `.log` that are older than 7 days.
- **Workflow:** 
    1. Use `find` with `-mtime`.
    2. Pipe results into `gzip` or `tar`.
