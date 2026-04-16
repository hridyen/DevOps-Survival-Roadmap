[![Sector](https://img.shields.io/badge/SECTOR-STORAGE-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Storage CLI Reference

## ✦ 1. AWS Snowball Commands

### ✦ Job Management
```bash
# List Snowball Jobs
aws snowball list-jobs

# Describe a specific Job
aws snowball describe-job --job-id <JOB_ID>

# Get the Unlock Code for a Snowball Device
aws snowball get-job-unlock-code --job-id <JOB_ID>
```

---

## ✦ 2. Amazon FSx & Storage Gateway

### ✦ FSx Operations
```bash
# List all File Systems
aws fsx describe-file-systems

# Create a Backup (Snapshot)
aws fsx create-backup --file-system-id <FS_ID>

# Update File System Storage Capacity
aws fsx update-file-system --file-system-id <FS_ID> --storage-capacity 1024
```

### ✦ Storage Gateway
```bash
# List all Gateways
aws storagegateway list-gateways

# Describe a Gateway's status
aws storagegateway describe-gateway-information --gateway-arn <GW_ARN>

# List SMB/NFS File Shares
aws storagegateway list-file-shares
```

---

## ✦ 3. DataSync & Transfer Family

### ✦ DataSync Automation
```bash
# List DataSync Tasks
aws datasync list-tasks

# Start a DataSync Task
aws datasync start-task-execution --task-arn <TASK_ARN>

# Monitor Task Execution
aws datasync describe-task-execution --task-execution-arn <EXEC_ARN>
```

### ✦ Transfer Family (SFTP/FTP)
```bash
# List SFTP Servers
aws transfer list-servers

# List Users on a specific Server
aws transfer list-users --server-id <SERVER_ID>
```
