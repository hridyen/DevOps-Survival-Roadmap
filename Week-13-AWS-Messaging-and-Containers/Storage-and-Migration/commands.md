[![Sector](https://img.shields.io/badge/SECTOR-STORAGE-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Storage CLI Reference

## ✦ 1. AWS Snowball Commands

### ✦ List Jobs
```bash
aws snowball list-jobs
```

### ✦ Get Job Details
```bash
aws snowball describe-job --job-id <JOB_ID>
```

---

## ✦ 2. Amazon FSx Commands

### ✦ List File Systems
```bash
aws fsx describe-file-systems
```

### ✦ Create Snapshot (Backups)
```bash
aws fsx create-snapshot --file-system-id <FS_ID>
```

---

## ✦ 3. DataSync Commands
DataSync is often used in combination with migration tasks.
```bash
aws datasync list-tasks
aws datasync start-task-execution --task-arn <TASK_ARN>
```
