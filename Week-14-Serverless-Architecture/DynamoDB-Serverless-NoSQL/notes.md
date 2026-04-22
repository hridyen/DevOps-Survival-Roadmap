[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-dynamodb--nosql-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Amazon DynamoDB: Serverless NoSQL

> **Week:** 14
> **Folder:** DynamoDB-Serverless-NoSQL
> **Topic:** Managed, High-Performance Database Architecture

---

## ✦ 1. What is DynamoDB?

DynamoDB is a fully managed NoSQL database service that provides fast and predictable performance with seamless scalability. It is designed to handle millions of requests per second and trillions of rows.

### ⚡ Technical Fundamentals
- **Managed:** No servers to patch, no OS to manage.
- **Scaling:** Scales to massive workloads without downtime.
- **Latency:** Consistent, single-digit millisecond performance.
- **Schema:** Schema-less (except for the Primary Key).

---

## ✦ 2. Data Structure & Types

A DynamoDB table is composed of **Items**, which are further composed of **Attributes**.

### ⚡ The Primary Key
Must be decided at creation time. It can be:
1.  **Partition Key (Hashing):** Determines where the data is stored.
2.  **Composite Key:** Partition Key + Sort Key.

### ⚡ Supported Data Types
- **Scalar Types:** String, Number, Binary, Boolean, Null.
- **Document Types:** List, Map.
- **Set Types:** String Set, Number Set, Binary Set.

---

## ✦ 3. Capacity Modes (Scaling)

DynamoDB offers two pricing/scaling models:

### ⚡ Provisioned Mode (Default)
- You specify the number of **Reads/Writes per second** (RCU/WCU).
- Best for predictable traffic.
- Can use **Auto-Scaling** to adjust capacity based on utilization.

### ⚡ On-Demand Mode
- DynamoDB automatically scales up/down based on your workload.
- No capacity planning needed.
- Pay-per-request (more expensive if traffic is high and consistent).
- Great for unpredictable spikes.

---

## ✦ 4. Backups & Resilience

### ⚡ Point-In-Time Recovery (PITR)
- Continuous backups for the last 35 days.
- Allows you to restore your table to any second within the window.
- Restoration creates a **new table**.

### ⚡ On-Demand Backups
- Full backups for long-term retention.
- No impact on performance or latency.
- Can be managed globally via **AWS Backup**.

---

## ✦ 🍟 Personal Notes & Interview Tips

- **Maximum Item Size:** 400 KB. If you need to store larger data, store the metadata in DynamoDB and the actual file in **S3**, then link them.
- **LSI vs GSI:** 
    - **LSI (Local Secondary Index):** Same partition key, different sort key. Can only be created *at table creation*.
    - **GSI (Global Secondary Index):** Different partition key and sort key. Can be created/deleted *anytime*.
- **Consistency Models:**
    - **Eventually Consistent (Default):** Faster, cheaper, but data might be slightly stale.
    - **Strongly Consistent:** Guaranteed latest data, but costs 2x RCU and has higher latency.
- **S3 Integration:** You can export DynamoDB data to S3 in JSON or ION format for analysis in **Athena**.
