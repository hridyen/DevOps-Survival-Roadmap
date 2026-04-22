[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-integration--edge-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Integration & Edge Logic

> **Week:** 14
> **Folder:** Integration-and-Edge-Logic
> **Topic:** Advanced Patterns & Edge Computing

---

## ✦ 1. Computing at the Edge

Many modern applications require logic to execute as close to the user as possible to minimize latency. AWS provides two primary ways to do this via **CloudFront**:

### ⚡ CloudFront Functions
- **Runtime:** Lightweight JavaScript.
- **Latency:** Sub-millisecond startup times.
- **Scale:** Millions of requests per second.
- **Use Cases:** Header manipulation, URL redirects, Cache key normalization.
- **Restriction:** No access to network or file system.

### ⚡ Lambda@Edge
- **Runtime:** Full Node.js or Python.
- **Latency:** Higher than CloudFront Functions (standard Lambda cold starts).
- **Scale:** Standard Lambda scaling.
- **Use Cases:** Dynamic web content generation, SEO, User prioritization, A/B Testing.
- **Advantage:** Can access external APIs and services.

---

## ✦ 2. RDS Proxy: Connecting Lambda to SQL

Lambda functions are ephemeral and scale rapidly. Traditional RDS databases have a limited number of connections.

### ⚡ Why use RDS Proxy?
- **Connection Pooling:** Pools and shares DB connections to improve scalability.
- **Availability:** Reduces failover time by up to 66% while preserving connections.
- **Security:** Enforces IAM authentication for DB access.
- **Requirement:** Must be deployed in your VPC (as RDS Proxy is not publicly accessible).

---

## ✦ 3. Common Serverless Patterns

### ⚡ Pattern A: Serverless Thumbnail Creation
A classic architecture for event-driven image processing.
1.  **Trigger:** User uploads an image to **S3**.
2.  **Compute:** S3 triggers an **AWS Lambda** function.
3.  **Process:** Lambda creates a thumbnail.
4.  **Store:** Lambda pushes the thumbnail back to **S3** and metadata to **DynamoDB**.

### ⚡ Pattern B: Serverless CRON Job
Automating tasks without a dedicated server.
1.  **Trigger:** **EventBridge (CloudWatch Events)** triggers on a schedule (e.g., every 1 hour).
2.  **Compute:** **AWS Lambda** executes the task (e.g., database cleanup, report generation).

---

## ✦ 🍟 Personal Notes & Interview Tips

- **Lambda@Edge vs CloudFront Functions:** If you need to make a network request (e.g., to a DB or API), you **must** use Lambda@Edge. If you only need to modify HTTP headers, CloudFront Functions are faster and cheaper.
- **EventBridge Pipes:** A newer service that simplifies point-to-point integrations between event producers and consumers with optional filtering and enrichment steps.
- **Idempotency:** In serverless architectures, events can sometimes be delivered more than once. Ensure your Lambda functions are **idempotent** (doing the same thing multiple times has the same result as doing it once).
