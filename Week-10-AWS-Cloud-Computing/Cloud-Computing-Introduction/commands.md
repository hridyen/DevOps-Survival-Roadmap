[![Sector](https://img.shields.io/badge/SECTOR-AWS_Cloud_Computing-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Cloud_Computing_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ AWS Baseline Commands

## ✦ 1. CLI Configuration

Before you can interact with any AWS service, you must configure your environment.

### ✦ Initial Setup
```bash
# Configure access keys, region, and output format
aws configure

# Check the current identity (Verifies your login)
aws sts get-caller-identity
```

### ✦ Multi-Profile Management
```bash
# Set up a secondary profile (e.g. for a Production account)
aws configure --profile prod

# Use a specific profile for a command
aws s3 ls --profile prod
```

---

## ✦ 2. IAM & Account Discovery

### ✦ Listing Resources
```bash
# List all IAM Users
aws iam list-users

# List EC2 regions available to your account
aws ec2 describe-regions
```

---

## ✦ 3. Debugging CLI Requests

### ✦ Verbose Output
If a command is failing without a clear error, use `--debug`.
```bash
aws s3 ls --debug
```

### ✦ Dry Run
Check if you have permissions to execute a command without actually performing the action.
```bash
aws ec2 run-instances --image-id ami-xxxxxxx --dry-run
```
