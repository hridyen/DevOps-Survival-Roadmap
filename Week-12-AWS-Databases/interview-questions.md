# ⚡ Week 12 — AWS Databases & Services Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on RDS, Aurora, ElastiCache, S3, Route 53, and Auto Scaling scaling logic.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You have a MySQL database on RDS experiencing severe performance degradation due to a surge in read queries. Additionally, you need to ensure the database can survive an Availability Zone outage with zero data loss. What is your architectural solution?</b></summary>
<b>Answer:</b>
Implement **RDS Multi-AZ** for disaster recovery and deploy **Read Replicas** for read scaling:
1. **Disaster Recovery (Multi-AZ):** Enable Multi-AZ. AWS will provision a standby database instance in a different Availability Zone and perform **synchronous replication** from the primary database. If the primary AZ goes down, RDS performs automatic DNS failover to the standby instance with zero data loss (RPO = 0, RTO = minutes).
2. **Read Performance (Read Replicas):** Create one or more Read Replicas. RDS uses **asynchronous replication** to update them. Point read traffic in your application configuration to the Read Replica endpoints, offloading read IOPS from the primary database. Read Replicas can also cross regions if global read access is required.
</details>

<details>
<summary><b>Q2: Scenario: Your application uses AWS Lambda functions that scale rapidly to handle surges. Each Lambda function opens a new database connection to RDS. During spikes, the database crashes because it runs out of connection slots. How do you resolve this?</b></summary>
<b>Answer:</b>
Implement **Amazon RDS Proxy**:
1. **Connection Pooling:** RDS Proxy is a fully managed database proxy that pools and shares established database connections. Instead of each Lambda instance opening a new database connection, they connect to the RDS Proxy.
2. **Pinning Mitigation:** RDS Proxy multiplexes connection requests, reducing database connection overhead by up to 90%.
3. **Failover Efficiency:** If an RDS failover occurs, RDS Proxy maintains active connections from the application and automatically routes queries to the new primary instance, reducing database failover times by up to 66%.
</details>

<details>
<summary><b>Q3: Scenario: You are hosting a static web application in S3. The security team demands that all uploaded files must be encrypted at rest, and that objects must be protected from accidental deletion or ransomware modification for a regulatory period of 7 years. How do you implement this?</b></summary>
<b>Answer:</b>
1. **Encryption at Rest:** Enforce Default Bucket Encryption using SSE-KMS (Server-Side Encryption with AWS KMS customer-managed keys) and attach a bucket policy that denies any `s3:PutObject` request that doesn't include header `"x-amz-server-side-encryption": "aws:kms"`.
2. **Delete/Modification Protection (WORM):**
   - Enable **S3 Versioning** on the bucket.
   - Enable **S3 Object Lock** in **Compliance Mode** (not Governance Mode) with a default retention period of 7 years.
   - *Why Compliance Mode:* Under compliance mode, the retention period cannot be bypassed, shortened, or overridden by any user, including the root user. This prevents ransomware from deleting old versions or overwriting objects.
</details>

<details>
<summary><b>Q4: Scenario: You run a video hosting platform where users upload raw video files (sizes up to 5 GB). Processing these uploads on your EC2 backend servers saturates network bandwidth and exhausts compute. How do you architect a solution where users upload directly to S3 securely?</b></summary>
<b>Answer:</b>
Use S3 **Pre-signed URLs** with **Multipart Uploads**:
1. **Authorization:** The client browser requests an upload token from your backend API.
2. **Generate URL:** The backend validates the user's session, calls the S3 API (`generate_presigned_url` or `CreateMultipartUpload`), and returns a temporary pre-signed URL containing authorization signatures valid for a short window (e.g. 15 minutes).
3. **Direct Upload:** The client browser uploads the file directly to the generated S3 endpoint using an HTTP PUT request. This bypasses your backend application servers, saving network bandwidth and EC2 compute resources.
4. **Multipart:** For files larger than 100 MB, the client uses S3 Multipart Upload APIs via pre-signed URLs to upload chunks in parallel and calls `CompleteMultipartUpload` to merge them at the end.
</details>

<details>
<summary><b>Q5: Scenario: You have a database cache in ElastiCache Redis. During traffic spikes, the database experiences "Cache Stampede" (cache missing triggers massive concurrent database reads). How do you configure and design the cache to prevent this?</b></summary>
<b>Answer:</b>
1. **Cache Warming / Pre-populating:** Pre-warm the cache during deployment or low-traffic periods before launching campaigns.
2. **Locking (Mutex):** Implement distributed locks in the application logic using Redis (e.g. Redlock). If a cache miss occurs, only the first application worker acquires the lock to query the database and update the cache; other workers wait or back off, preventing database saturation.
3. **Background Invalidation / Soft Expiration:** Set a logical TTL in the object metadata that is shorter than the physical Redis TTL. When an application thread reads an object near its logical expiration, it asynchronously triggers a background job to update the database cache while serving the slightly stale cached value to current users.
</details>

<details>
<summary><b>Q6: Scenario: You need to set up a multi-region active-passive disaster recovery site. If the primary region (us-east-1) goes down, traffic must fail over automatically to the secondary region (us-west-2). How do you configure Route 53 to handle this?</b></summary>
<b>Answer:</b>
Use **Route 53 Failover Routing Policy with Health Checks**:
1. **Configure Health Checks:** Create a Route 53 Health Check pointing to the primary region's Application Load Balancer endpoint. Configure it to query a health endpoint `/healthz` and set failure thresholds (e.g., 3 consecutive failures).
2. **DNS Records:** Create two records for the same domain name (e.g., `app.domain.com`):
   - **Primary Record:** Routing Policy: **Failover**, Record Type: **Alias** pointing to `us-east-1` ALB, Associate with Health Check: Yes, Failover Record Type: **Primary**.
   - **Secondary Record:** Routing Policy: **Failover**, Record Type: **Alias** pointing to `us-west-2` ALB, Failover Record Type: **Secondary**.
3. **TTL Adjustment:** If using non-alias records, ensure the TTL is set low (e.g., 60 seconds) to ensure recursive DNS servers purge the cached primary record and query Route 53 for the secondary IP quickly during failover.
</details>

<details>
<summary><b>Q7: Scenario: Your S3 bucket accumulates millions of build logs daily. Storage costs are growing rapidly. How do you implement a tiering strategy to minimize cost while retaining logs for 1 year for audits?</b></summary>
<b>Answer:</b>
Create an **S3 Lifecycle Policy** with the following transitions:
1. **0–30 Days:** Keep in **S3 Standard** (logs are actively accessed by developers for troubleshooting).
2. **Day 30:** Transition to **S3 Standard-IA (Infrequent Access)**. (Cheaper storage cost, but incurs retrieval fees).
3. **Day 90:** Transition to **Amazon S3 Glacier Flexible Retrieval** (for audit compliance, retrieval takes minutes to hours, storage cost drops significantly).
4. **Day 365:** Permanently delete the objects.
5. **Additional rule:** Enable a rule to **AbortIncompleteMultipartUpload** after 7 days. This automatically purges fragments of failed uploads that otherwise incur persistent storage charges.
</details>

<details>
<summary><b>Q8: Scenario: You want to route users to the fastest environment. If a user is in Europe, they should be directed to the Frankfurt region. If they are in Asia, they should go to Singapore. How do you configure Route 53, and what happens if a region goes down?</b></summary>
<b>Answer:</b>
1. **Routing Policy:** Use **Route 53 Latency-Based Routing** or **Geolocation Routing**:
   - *Latency-Based:* Route 53 measures network latency from the client's network to AWS regions and automatically returns the IP of the region with the lowest latency.
   - *Geolocation:* Explicitly maps geographic locations (e.g. Continent: Europe) to specific endpoints.
2. **Health Checks Integration:** Associate Route 53 health checks with each regional record.
3. **Failover behavior:** If the Frankfurt region is marked unhealthy by the health checks, Route 53 will bypass that record and route European users to the next best active region (e.g. London or N. Virginia) based on latency profiles.
</details>

<details>
<summary><b>Q9: Scenario: In Auto Scaling Groups, how does Target Tracking Scaling differ from Step Scaling? In what scenarios would you choose one over the other?</b></summary>
<b>Answer:</b>
- **Target Tracking Scaling:** You choose a metric (e.g., Average CPU Utilization) and set a target value (e.g., 60%). Auto Scaling automatically creates CloudWatch alarms and adjust instance counts to keep the metric near the target.
  - *When to use:* For standard workloads where traffic scales linearly and metrics change smoothly.
- **Step Scaling:** You define specific scaling steps based on alarm thresholds. (e.g., If CPU is 50-70%, add 1 instance; if CPU is >70%, add 4 instances).
  - *When to use:* For workloads with steep, sudden spikes where target tracking might not scale out fast enough. Step scaling allows you to trigger aggressive scaling actions immediately.
</details>

<details>
<summary><b>Q10: Scenario: You have a global app where European users access data stored in a central RDS database in the US, causing slow page loads. How does Amazon Aurora Global Databases solve this latency, and how does failover work?</b></summary>
<b>Answer:</b>
- **Aurora Global Database Architecture:** Aurora provisions a primary database cluster in one region and replicates data to up to 5 secondary read-only clusters in other regions. It uses dedicated storage-level transport infrastructure, achieving replication lags of less than 1 second.
- **Solving Latency:** European users are pointed to the local Aurora Reader endpoint in the EU region, serving reads with sub-millisecond latencies.
- **Failover (Promoting secondary):** If the primary US region suffers an outage:
  1. You can perform a **planned failover** (with no data loss) or an **unplanned failover** (promoting one of the secondary read-only regional clusters to be the new primary master write cluster).
  2. The promoted cluster immediately begins accepting write queries, and you update your application configuration to point to the new regional writer.
</details>
