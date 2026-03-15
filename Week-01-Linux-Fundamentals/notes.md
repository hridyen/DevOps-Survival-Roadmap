# 🐧 Week 01 — Linux Fundamentals

> **Duration:** Jan 20 – Jan 26, 2026
> **Goal:** Build a solid foundation in Linux, the operating system that powers 90%+ of DevOps infrastructure.

---

## 📌 Why Linux in DevOps?

Almost every server, cloud machine, and container runs Linux. If you want to work in DevOps, Linux is not optional — it is your daily workplace.

---

## 📚 Concepts Learned

### 1. What is Linux?
Linux is an open-source operating system (OS). Unlike Windows, it is mostly used through a **command-line interface (CLI)** — you type commands instead of clicking buttons.

Key terms:
- **Kernel** — the core of the OS, manages hardware
- **Shell** — the interface where you type commands (Bash is the most common shell)
- **Terminal** — the program that lets you type into the shell

---

### 2. Linux File System

Linux organizes files in a tree structure starting from `/` (called **root**).

```
/                      ← Root (top of everything)
├── /home              ← User home directories
├── /etc               ← Configuration files
├── /var               ← Logs and variable data
├── /usr               ← User-installed programs
├── /bin               ← Essential system commands
├── /tmp               ← Temporary files (cleared on reboot)
├── /dev               ← Device files (disk, USB, etc.)
└── /proc              ← Virtual files showing kernel info
```

> 💡 **Remember:** Everything in Linux is a file — even hardware devices.

---

### 3. File Permissions

Every file and folder in Linux has permissions. You can see them with `ls -l`.

```
-rwxr-xr--  1  user  group  4096  Jan 20  myfile.sh
```

**Breaking it down:**

| Symbol | Meaning |
|--------|---------|
| `-` | File type (`-` = file, `d` = directory) |
| `rwx` | Owner: read, write, execute |
| `r-x` | Group: read, execute |
| `r--` | Others: read only |

**Numeric (octal) permissions:**

| Number | Permission |
|--------|-----------|
| 7 | rwx (read + write + execute) |
| 6 | rw- (read + write) |
| 5 | r-x (read + execute) |
| 4 | r-- (read only) |
| 0 | --- (no permission) |

Example: `chmod 755 myfile.sh` gives owner full access, others can read and execute.

---

### 4. User Management

Linux supports multiple users. As a DevOps engineer you will constantly manage users.

Key concepts:
- **root** — the superuser, has full control of the system
- **sudo** — lets a normal user run commands with root privileges
- `/etc/passwd` — stores user account info
- `/etc/shadow` — stores encrypted passwords
- `/etc/group` — stores group info

---

### 5. Shell Scripting & Bash

A **shell script** is a file containing a series of Linux commands that run automatically. It lets you automate repetitive tasks.

Basic structure of a shell script:

```bash
#!/bin/bash
# This is a comment
echo "Hello, DevOps!"
```

- Line 1 (`#!/bin/bash`) is called a **shebang** — it tells the OS which shell to use
- `echo` prints text to the screen
- Make a script executable: `chmod +x myscript.sh`
- Run it: `./myscript.sh`

---

## 🏃 Practice Exercises

- [ ] Navigate the file system using `cd`, `ls`, `pwd`
- [ ] Create files and folders using `touch`, `mkdir`
- [ ] Change permissions on a file using `chmod`
- [ ] Create a new user and assign them to a group
- [ ] Write a shell script that prints your name and today's date
- [ ] Use `grep` to search for a word inside a file

---

## 📝 Personal Notes

<!-- Add your own notes here as you practice -->

> 💬 *Add your personal observations, mistakes you made, and aha moments here.*

---

## 🔗 Resources

See [resources.md](./resources.md) for useful links, documentation, and video references for this week.
