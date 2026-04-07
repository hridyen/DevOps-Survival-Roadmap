[![Sector](https://img.shields.io/badge/SECTOR-AWS_Storage-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-EBS_EFS_Storage_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Industrial AWS Storage — Advanced CLI

---

## ✦ ⚙️ EBS Performance Optimization (Online)

### ✦ Modify Dynamic Performance (GP3)

```bash
# Modify an existing volume's size, IOPS, and throughput (Downtime: None)
aws ec2 modify-volume \
  --volume-id vol-0123456789abcdef0 \
  --size 100 \
  --volume-type gp3 \
  --iops 4000 \
  --throughput 250

# Track the progress of the volume modification
aws ec2 describe-volume-modification \
  --volume-id vol-0123456789abcdef0
```

### ✦ Snapshot Automation (DLM)

```bash
# Create a Data Lifecycle Manager (DLM) Lifecycle Policy
aws dlm create-lifecycle-policy \
  --description "Daily Production EBS Snapshots" \
  --execution-role-arn arn:aws:iam::123456789012:role/AWSDataLifecycleManagerDefaultRole \
  --state ENABLED \
  --policy-details file://policy-details.json
```

---

## ✦ 🖥️ EFS — Managed Mounting & TLS

### ✦ Mounting with TLS Encryption (Staging Environment)

```bash
# Install the EFS mount helper (Required for TLS)
sudo yum install -y amazon-efs-utils

# Secure mount with TLS (In-transit encryption)
sudo mount -t efs -o tls fs-0123456789abcdef0:/ /mnt/efs

# Automating with /etc/fstab (Safe boot with _netdev)
echo "fs-0123456789abcdef0:/ /mnt/efs efs _netdev,tls,defaults 0 0" | sudo tee -a /etc/fstab
```

---

## ✦ 🛡️ AWS Disaster Recovery Patterns

### ✦ Cross-Region Snapshot Copying

```bash
# Copy a production snapshot to a Disaster Recovery (DR) Region (Mumbai)
aws ec2 copy-snapshot \
  --source-region us-east-1 \
  --source-snapshot-id snap-0123456789abcdef0 \
  --destination-region ap-south-1 \
  --description "DR Copy" \
  --encrypted
```

---

## ✦ 📝 My Advanced Performance Snippets

| Operation | Command | Why it's used? |
|---|---|---|
| `lsblk -f` | Checking the filesystem on a disk without mounting. | Safety first before formatting. |
| `fast-restore` | `aws ec2 enable-fast-snapshot-restores` | Instant volume readiness from snapshots. |
| `encryption` | `aws ec2 copy-snapshot --encrypted` | Encrypting legacy snapshots before re-deployment. |
