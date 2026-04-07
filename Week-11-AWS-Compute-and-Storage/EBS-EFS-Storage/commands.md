[![Sector](https://img.shields.io/badge/SECTOR-AWS_Storage-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-EBS_EFS_Storage_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ EBS & EFS — CLI & Console Execution

---

## ✦ ⚙️ AWS CLI — Management Blocks

### ✦ EBS Volume Controls

```bash
# Audit all available storage in AZ us-east-1a
aws ec2 describe-volumes --filters "Name=availability-zone,Values=us-east-1a"

# Create a 20GB gp3 volume dynamically
aws ec2 create-volume \
  --availability-zone us-east-1a \
  --size 20 \
  --volume-type gp3

# Attach targeting specifically /dev/sdf (Nitro instances might map to /dev/nvmeXn1)
aws ec2 attach-volume --volume-id vol-xxx --instance-id i-xxx --device /dev/sdf
```

### ✦ Snapshot & Migration

```bash
# Capture an incremental delta
aws ec2 create-snapshot --volume-id vol-xxx --description "Prod-DB-Backup"

# Copy Snapshot to another geographic region (Mumbai)
aws ec2 copy-snapshot \
  --source-region us-east-1 \
  --source-snapshot-id snap-xxx \
  --destination-region ap-south-1 \
  --description "Disaster Recovery Copy"
```

---

## ✦ 🖥️ Linux Shell — Filesystem Mounting

### ✦ Formatting & Initial Mounting

```bash
# Identify newly attached block hardware
lsblk

# Check if the volume has an existing filesystem (Empty if brand new)
sudo file -s /dev/xvdf

# Format as XFS (Modern Linux standard)
sudo mkfs -t xfs /dev/xvdf

# Mount to the directory tree
sudo mkdir /data
sudo mount /dev/xvdf /data
```

### ✦ Persistent Persistence (`/etc/fstab`)

> [!WARNING]
> If you edit `fstab` incorrectly, your EC2 instance will **NOT BOOT** on next restart! Always use `nofail`.

```bash
# Get the Unique ID
sudo blkid /dev/xvdf

# Append securely to fstab logic (Example entry)
# UUID=xxxx /data xfs defaults,nofail 0 2
echo "UUID=$(sudo blkid -s UUID -o value /dev/xvdf) /data xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Test the entry without rebooting!
sudo mount -a
```

---

## ✦ 📝 My Implementation Checklist

| Command | Real-World Use |
|---|---|
| `lsblk` | Finding my drive after AWS Console says it's "Attached". |
| `aws ec2 modify-volume` | Increasing disk space without shutting down the server. |
| `amazon-efs-utils` | Helper package for mounting EFS simplified. |
