[![Sector](https://img.shields.io/badge/SECTOR-Linux_Fundamentals-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Permissions_and_Users_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Permissions & Users — Commands Reference

---

## ✦ 🔐 Privilege Execution

```bash
# View active permissions
ls -l filename               # Show explicit file matrices

# Numeric Overrides
chmod 755 script.sh          # rwxr-xr-x (Public Executable)
chmod 644 file.txt           # rw-r--r-- (Standard Global Read)
chmod 600 private.key        # rw------- (Strict Owner Lockdown)

# Symbolic Modifiers
chmod +x script.sh           # Inject execute abilities inherently
chmod u+x,g-w file.txt       # Target Owner (+x) and target Group (-w)

# Object Ownership Transfers
chown user file.txt          # Reassign singular file ownership
chown user:group file.txt    # Dual-reassign user & group
chown -R user folder/        # Recursive ownership takeover
```

---

## ✦ 👤 Identity Operations

```bash
# Core Profile Generation
useradd -m username          # Scaffold user & build internal /home/ directory
passwd username              # Inject password mechanism
userdel -r username          # Obliterate user & wipe their /home footprint

# Group Dynamics
groupadd team                # Instantiate custom cluster
usermod -aG team user        # Append user natively to team group
groups username              # Display attached clusters

# Escalation Vectors
su -                         # Escalate silently entirely to strict Root
sudo systemctl restart       # Execute arbitrary command temporarily via Root
```

---

## ✦ 🌍 Core Networking & Syncing

```bash
# Secure File Transport
scp source.zip root@10.0.0.1:/path/         # Standard direct transfer
scp -r folder/ root@10.0.0.1:/path/         # Recursive transfer

# Algorithmic Synchronizations
rsync -avh database/ root@10.0.0.1:/backup/ # Delta-synced high performance backup

# Teaming (Link Aggregation) Validations
teamdctl team0 state                        # Verify the active failover topology routing of bonded NICs
```

---

## ✦ 📝 My Command Notes

| Command | What it does | When I used it |
|---------|-------------|----------------|
| `ssh-keygen -t ed25519` | Generates highly secure cryptological access keys. | Establishing password-less authentications between master nodes and Jenkins workers. |
| `visudo` | Enters a safe operational locking script for sudoers configuration. | Injecting a user into sudoers without potentially corrupting the kernel parser. |
