[![Sector](https://img.shields.io/badge/SECTOR-STORAGE-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Storage & Domain — Commands

> **Week:** 12
> **Folder:** S3 & Route-53
> **Topic:** CLI Management for Objects & DNS Records

---

## ✦ Amazon S3: Object Operations

### ⚡ Bucket Management
```bash
# List all buckets in the account
aws s3 ls

# Create a new bucket (globally unique)
aws s3 mb s3://my-unique-devops-001

# Force delete a bucket and all its objects (CAUTION)
aws s3 rb s3://my-unique-devops-001 --force
```

### ⚡ File Operations (CP/MV/SYNC)
```bash
# Upload a local file to S3
aws s3 cp app.jar s3://my-bucket/builds/

# Sync a local directory to S3 (only uploads changed files)
aws s3 sync ./dist s3://my-static-site-bucket/ --delete

# Generate a temporary download link (Pre-signed URL)
aws s3 presign s3://my-bucket/private-file.zip --expires-in 3600
```

### ⚡ API-Level Configurations
```bash
# Enable versioning for the bucket
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# Attach a bucket policy from a JSON file
aws s3api put-bucket-policy \
  --bucket my-bucket \
  --policy file://policy.json
```

---

## ✦ Amazon Route 53: DNS Operations

### ⚡ Hosted Zones & Records
```bash
# List all hosted zones in the account
aws route53 list-hosted-zones

# List all record sets for a specific zone
aws route53 list-resource-record-sets --hosted-zone-id Z123456789

# Create/Delete record sets using a JSON batch file
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://record-update.json
```

### ⚡ Health Checks
```bash
# List existing health checks
aws route53 list-health-checks

# Get health status for a specific checker
aws route53 get-health-check-status --health-check-id hc-12345
```

---

## ✦ Configuration Templates

### ⚡ S3 Public Read Policy (Static Web)
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicRead",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-bucket/*"
  }]
}
```

    "FailureThreshold": 3
  }'

aws route53 list-health-checks
aws route53 get-health-check-status \
  --health-check-id <health-check-id>
```

### Route 53 Record JSON Example

```json
{
  "Comment": "Create A record for myapp.com",
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "myapp.example.com",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [
        {"Value": "54.22.33.44"}
      ]
    }
  }]
}
```

### Alias Record JSON Example (pointing to ALB)
```json
{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "example.com",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "Z35SXDOTRQ7X7K",
        "DNSName": "my-alb-1234.us-east-1.elb.amazonaws.com",
        "EvaluateTargetHealth": true
      }
    }
  }]
}
```

---

## 📝 My Notes

| Command | What it does | Notes |
|---|---|---|
| | | |
