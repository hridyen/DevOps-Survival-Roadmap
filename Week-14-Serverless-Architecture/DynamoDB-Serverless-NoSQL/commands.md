[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ DynamoDB CLI Commands

> **Implementation:** AWS CLI (v2)
> **Goal:** CRUD operations and table management.

---

## ✦ 1. Table Management

### Create a Table
```bash
aws dynamodb create-table \
    --table-name MyTable \
    --attribute-definitions AttributeName=ID,AttributeType=S \
    --key-schema AttributeName=ID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### List Tables
```bash
aws dynamodb list-tables
```

### Describe Table
```bash
aws dynamodb describe-table --table-name MyTable
```

---

## ✦ 2. Item Operations (CRUD)

### Put (Create/Update) an Item
```bash
aws dynamodb put-item \
    --table-name MyTable \
    --item '{"ID": {"S": "u001"}, "Name": {"S": "Hridyen"}, "Role": {"S": "DevOps"}}'
```

### Get an Item
```bash
aws dynamodb get-item \
    --table-name MyTable \
    --key '{"ID": {"S": "u001"}}'
```

### Delete an Item
```bash
aws dynamodb delete-item \
    --table-name MyTable \
    --key '{"ID": {"S": "u001"}}'
```

---

## ✦ 3. Batch & Scanning

### Scan (Read All Items - Expensive!)
```bash
aws dynamodb scan --table-name MyTable
```

### Query (Targeted Read)
```bash
aws dynamodb query \
    --table-name MyTable \
    --key-condition-expression "ID = :v1" \
    --expression-attribute-values '{":v1": {"S": "u001"}}'
```

---

## ✦ 4. Backups

### Create a Backup
```bash
aws dynamodb create-backup \
    --table-name MyTable \
    --backup-name MyTable-Final-Backup
```

---

## ✦ 🍟 Industrial Tips
- **Filter Expressions:** When scanning, use `--filter-expression` to reduce the amount of data sent over the network, but remember that **Scan still consumes RCU** for all items read before the filter is applied.
- **Dry Run for Throughput:** Use the `ReturnConsumedCapacity` parameter to see exactly how many RCU/WCU an operation consumes.
