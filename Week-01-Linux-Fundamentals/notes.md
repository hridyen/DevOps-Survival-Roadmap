[![Sector](https://img.shields.io/badge/SECTOR-Linux_Fundamentals-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Week 01 — Linux Fundamentals

> **Duration:** Jan 20 – Jan 26, 2026
> **Goal:** Build a solid foundation in Linux, the operating system that powers 90%+ of DevOps infrastructure.

---

## ✦ Why Linux in DevOps?

Almost every server, cloud machine, and container runs Linux. If you want to work in DevOps, Linux is not optional — it is your daily workplace.

---

## ✦ Concepts Learned

### ✦ 1. What is Linux?
Linux is an open-source operating system (OS). Unlike Windows, it is mostly used through a **command-line interface (CLI)** — you type commands instead of clicking buttons.

Key terms:
- **Kernel** — the core of the OS, manages hardware
- **Shell** — the interface where you type commands (Bash is the most common shell)
- **Terminal** — the program that lets you type into the shell

---

### ✦ 2. Linux File System

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

### ✦ 3. File Permissions

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

### ✦ 4. User Management

Linux supports multiple users. As a DevOps engineer you will constantly manage users.

Key concepts:
- **root** — the superuser, has full control of the system
- **sudo** — lets a normal user run commands with root privileges
- `/etc/passwd` — stores user account info
- `/etc/shadow` — stores encrypted passwords
- `/etc/group` — stores group info

---

### ✦ 5. Shell Scripting & Bash

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

## ✦ Practice Exercises

- [ ] Navigate the file system using `cd`, `ls`, `pwd`
- [ ] Create files and folders using `touch`, `mkdir`
- [ ] Change permissions on a file using `chmod`
- [ ] Create a new user and assign them to a group
- [ ] Write a shell script that prints your name and today's date
- [ ] Use `grep` to search for a word inside a file

---

## ✦ Personal Notes

### ✦ Linux Administration Notes

#### 1. Process, Service & Daemon
- **What is a Process?**
  A process is an instance of a program in execution.
  Example: running an `.exe` file.
  One application can have multiple processes running at the same time.

- **What is a Daemon?**
  A daemon is a background process.
  Runs continuously and waits for specific events.
  Example: `sshd`, `httpd`
  Origin: Greek word meaning attendant spirit.

- **What is a Service?**
  A service is a program that responds to requests from other programs.
  Usually runs on a server.
  Example:
  - Web service → `httpd`
  - SSH service → `sshd`
  - Network service → `NetworkManager`

#### 2. Service Status (`systemctl`)
**Service States**
1. **Active (Running)**
2. **Inactive (Not running)**
3. **Enabled** – starts automatically at boot
4. **Disabled** – does not start at boot

**Common Service Commands**
```bash
systemctl status sshd     # Check service status
systemctl start sshd      # Start service
systemctl stop sshd       # Stop service
systemctl restart sshd    # Restart service
systemctl enable sshd     # Enable at boot
systemctl disable sshd    # Disable at boot
systemctl is-enabled sshd # Check enabled or not
```

#### 3. Package Management in Linux
- **What is a Package?**
  A package is a compressed file containing:
  - Application files
  - Libraries
  - Configuration files

- **Package Architecture**
  Example: `httpd-2.4.6-97.el7.x86_64.rpm`
  - Name → `httpd`
  - Version → `2.4.6`
  - Release → `97`
  - Architecture → `x86_64`
  - Extension → `rpm`

#### 4. Package Installation Methods
1. **Standalone Installation**
   Used for single or few systems.
   Example: CD, DVD, `.rpm` file.
2. **Network Installation**
   Used for multiple systems.
   Uses centralized repository (repo).

#### 5. RPM (Red Hat Package Manager)
- **RPM Syntax**
  `rpm [option] package-name`

- **Common Options**
  - `-i` → install
  - `-v` → verbose
  - `-h` → hash
  - `-e` → erase
  - `-q` → query

- **Install Package**
  `rpm -ivh httpd-2.4.6-97.el7.x86_64.rpm`

- **Drawbacks of RPM**
  - No automatic dependency resolution
  - No user confirmation

#### 6. YUM (Yellowdog Updater Modified)
- **What is YUM?**
  - Advanced package management tool
  - Automatically handles dependencies
  - Used in RHEL, CentOS, Rocky, AlmaLinux

- **YUM Syntax**
  `yum [option] package-name`

- **Common YUM Commands**
```bash
yum install httpd
yum remove httpd
yum update
yum list
yum clean all
yum repolist
```

#### 7. Create YUM Repository (Server Side)
**Step 1: Mount RHEL ISO**
```bash
lsblk
mount /dev/sr0 /mnt
```

**Step 2: Copy Packages**
`cp -rvf /mnt/Packages /var/www/html/`

**Step 3: Create Repo File**
`vim /etc/yum.repos.d/server.repo`
```ini
[app]
name=appstream
baseurl=file:///var/www/html/Packages
enabled=1
gpgcheck=0
```

**Step 4: Clean & Verify**
```bash
yum clean all
yum repolist
```

#### 8. Configure Client YUM Repo
`vim /etc/yum.repos.d/server.repo`
```ini
[app]
name=appstream
baseurl=http://192.168.1.2/Packages
enabled=1
gpgcheck=0
```
```bash
yum clean all
yum repolist
yum install httpd
```

#### 9. Secure Shell (SSH)
- **What is SSH?**
  - Secure protocol to access remote systems
  - Default port: 22
  - More secure than Telnet

- **SSH Configuration File**
  `vim /etc/ssh/sshd_config`
  Important parameters:
  - `PermitRootLogin yes`
  - `PasswordAuthentication yes`

- **Restart SSH:**
  `systemctl restart sshd`

#### 10. Disable Root Login via SSH (Security)
`vim /etc/ssh/sshd_config`
- `PermitRootLogin no`

```bash
systemctl restart sshd
systemctl enable sshd
```

#### 11. Remote File Transfer in Linux
- **SCP (Secure Copy)**
  - **Local → Remote**
    ```bash
    scp file.txt root@IP:/mnt/
    scp -r /india root@IP:/mnt/
    ```
  - **Remote → Local**
    ```bash
    scp root@IP:/mnt/file.txt /root/Desktop/
    scp -r root@IP:/mnt/india /root/Desktop/
    ```

#### 12. RSYNC (Remote Sync)
- Used for copying and syncing files
- Faster and efficient
```bash
rsync -avh file.txt root@IP:/mnt/
rsync -avh root@IP:/mnt/file.txt /root/Desktop/
```

#### 13. NIC Teaming (Bonding / Link Aggregation)
- **What is NIC Teaming?**
  Combines multiple NICs into one logical interface.
  Provides:
  - Load balancing
  - High availability
  - Fault tolerance

- **Benefits**
  If one NIC fails, traffic moves to another. Used in critical servers.

#### 14. NIC Teaming Modes
- `broadcast` – data sent on all NICs
- `active-backup` – one active, one backup
- `round-robin` – traffic sent in sequence
- `loadbalance` – traffic distributed equally

#### 15. Configure NIC Teaming
- **Install Teaming Tool**
  `yum install teamd`

- **Create Team Interface**
  `nmcli con add type team con-name Team1 ifname team0 config '{"runner":{"name":"activebackup"}}'`

- **Add Slave Interfaces**
  ```bash
  nmcli con add type team-slave con-name Team1-slave1 ifname ens33 master Team1
  nmcli con add type team-slave con-name Team1-slave2 ifname ens34 master Team1
  ```

- **Activate Team**
  `nmcli con up Team1`

- **Check Status**
  `teamdctl team0 state`


---

## ✦ Resources

See [resources.md](./resources.md) for useful links, documentation, and video references for this week.
