[![Sector](https://img.shields.io/badge/SECTOR-NETWORKING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Route_53_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Route 53 CLI Reference

## ✦ 1. Hosted Zone Management

### ✦ Listing Zones
```bash
# List all hosted zones in your account
aws route53 list-hosted-zones

# Get details of a specific zone
aws route53 get-hosted-zone --id <ZONE_ID>
```

---

## ✦ 2. Record Management

### ✦ Listing Records
```bash
# List all resource records for a specific zone
aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID>
```

### ✦ Changing Records (JSON Payload)
Route 53 uses a JSON batch format for updates.
```bash
# Example command to apply a batch file
aws route53 change-resource-record-sets \
    --hosted-zone-id <ZONE_ID> \
    --change-batch file://change-set.json
```

**Example `change-set.json`:**
```json
{
  "Comment": "Update A record for api subdomain",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "api.example.com.",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "1.2.3.4" }]
      }
    }
  ]
}
```

---

## ✦ 3. Health Checks

### ✦ Management
```bash
# List all health checks
aws route53 list-health-checks

# Get health check status
aws route53 get-health-check-status --health-check-id <HC_ID>
```
