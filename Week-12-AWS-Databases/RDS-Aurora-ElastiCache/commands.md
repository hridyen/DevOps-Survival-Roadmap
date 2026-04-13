[![Sector](https://img.shields.io/badge/SECTOR-DATABASE-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Database Operations — Commands

> **Week:** 12
> **Folder:** RDS-Aurora-ElastiCache
> **Topic:** CLI Management for SQL & In-Memory Systems

---

## ✦ Amazon RDS: SQL Management

### ⚡ Instance Lifecycle
```bash
# Provision a new RDS MySQL instance
aws rds create-db-instance \
  --db-instance-identifier my-mysql-db \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0 \
  --master-username admin \
  --master-user-password MySecurePass123 \
  --allocated-storage 20 \
  --multi-az \
  --no-publicly-accessible

# Inspect connection endpoints
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address]'
```

### ⚡ High Availability & Scaling
```bash
# Create a Read Replica for horizontal scaling
aws rds create-db-instance-read-replica \
  --db-instance-identifier my-mysql-db-replica \
  --source-db-instance-identifier my-mysql-db \
  --db-instance-class db.t3.micro

# Trigger a manual failover for Multi-AZ testing
aws rds reboot-db-instance \
  --db-instance-identifier my-mysql-db \
  --force-failover
```

### ⚡ Backup & Recovery
```bash
# Create a manual DB snapshot
aws rds create-db-snapshot \
  --db-instance-identifier my-mysql-db \
  --db-snapshot-identifier prod-backup-$(date +%F)

# Point-In-Time Recovery (PITR) to a new instance
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier my-mysql-db \
  --target-db-instance-identifier my-restored-db \
  --restore-time 2026-04-13T10:00:00Z
```

---

## ✦ Amazon Aurora: Cluster Operations

Aurora uses a cluster-based architecture with separate writer and reader endpoints.

```bash
# Provision an Aurora MySQL Cluster
aws rds create-db-cluster \
  --db-cluster-identifier multi-az-aurora \
  --engine aurora-mysql \
  --master-username admin \
  --master-user-password SecurePass123!

# Create an Instance within the Cluster
aws rds create-db-instance \
  --db-instance-identifier aurora-instance-1 \
  --db-cluster-identifier multi-az-aurora \
  --engine aurora-mysql \
  --db-instance-class db.t3.medium
```

---

## ✦ ElastiCache: Redis & Memcached

### ⚡ Redis Management
```bash
# Create a Redis Cluster (Replication Group)
aws elasticache create-replication-group \
  --replication-group-id production-redis \
  --replication-group-description "High performance cache" \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-clusters 2 \
  --automatic-failover-enabled

# Connect to Redis (from EC2 in same VPC)
redis-cli -h <elasticache-endpoint> -p 6379

# Basic Redis commands
redis-cli -h <endpoint> SET mykey "hello"
redis-cli -h <endpoint> GET mykey
redis-cli -h <endpoint> EXPIRE mykey 3600    # TTL 1 hour
redis-cli -h <endpoint> TTL mykey
redis-cli -h <endpoint> DEL mykey
```

---

## 📝 My Notes

| Command | What it does | Notes |
|---|---|---|
| `aws rds reboot-db-instance --force-failover` | HA Test | Only works on Multi-AZ instances. Switches traffic to the standby node usually in < 60s. |
| `aws rds create-db-instance-read-replica` | Scaling trigger | Use this to offload read-heavy reports from your primary writer instance. |
| `redis-cli SET ... EXPIRE` | Cache control | Always set a TTL (Time-to-Live) to prevent the cache from filling up with stale data. |
| `describe-db-instances --query` | Filtered output | Use `--query` to extract just the endpoints for your automation scripts. |
