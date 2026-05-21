# ⚡ Week 13 — AWS Messaging & Containers Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on SQS, SNS, ECS Fargate, ECR, CloudFront, Global Accelerator, and Hybrid Storage.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You are building an e-commerce checkout system where payments must be processed exactly once and in the precise order they were placed. How do you implement this using AWS SQS?</b></summary>
<b>Answer:</b>
Use an **SQS FIFO (First-In-First-Out) Queue**:
1. **Ordering:** SQS FIFO queues guarantee that messages are processed in the exact order they are sent (using a Message Group ID).
2. **Exactly-Once Processing:** Enable **Message Deduplication**:
   - You can provide a **Message Deduplication ID** (e.g., a hash of the transaction ID) or enable **Content-Based Deduplication** (where SQS hashes the message body).
   - If a duplicate message is sent within the 5-minute deduplication window, SQS accepts it but does not deliver it to the consumer, avoiding duplicate payments.
3. **Message Grouping:** Set the `MessageGroupId` parameter. Messages within the same group are processed sequentially, allowing you to parallelize processing across different users (different groups) while keeping order within a single user session.
</details>

<details>
<summary><b>Q2: Scenario: Your backend consumers are reading from an SQS queue. A few "poison pill" messages are malformed, causing the consumer to crash and restart every time it reads them. These messages return to the queue, creating an infinite processing loop. How do you prevent this?</b></summary>
<b>Answer:</b>
Implement an **SQS Dead Letter Queue (DLQ) with a Redrive Policy**:
1. **Create DLQ:** Create a second SQS queue to act as the DLQ.
2. **Configure Redrive Policy:** Attach a redrive policy to the main queue:
   ```json
   {
     "maxReceiveCount": 3,
     "deadLetterTargetArn": "arn:aws:sqs:us-east-1:123456789012:main-queue-dlq"
   }
   ```
   - *Logic:* The `maxReceiveCount` dictates how many times a consumer can attempt to process a message. If a message fails and is returned to the queue 3 times, SQS automatically moves it to the DLQ.
3. **Monitoring & Alerting:** Configure a CloudWatch Alarm on the `ApproximateNumberOfMessagesVisible` metric of the DLQ to alert the engineering team via SNS for manual inspection of poison-pill payloads.
</details>

<details>
<summary><b>Q3: Scenario: When an order is placed, three downstream services need to receive the event: Billing, Inventory, and Shipping. Additionally, the Shipping service only cares about orders destined for the United States. How do you architect this efficiently?</b></summary>
<b>Answer:</b>
Use the **SNS Fan-Out Pattern with Subscription Filter Policies**:
1. **Publish Event:** The frontend publishes the order event to a single **Amazon SNS Topic**.
2. **Subscriptions:** Create three SQS queues (one for Billing, one for Inventory, one for Shipping) and subscribe all three to the SNS topic. When SNS receives the message, it automatically duplicates (fans out) the message to all subscribed queues.
3. **Filter Policy:** On the Shipping service's SQS subscription, configure an **SNS Subscription Filter Policy**:
   ```json
   {
     "country": ["US"]
   }
   ```
   - When publishing the message to SNS, pass `country` as a message attribute. SNS evaluates this attribute and only delivers the event to the Shipping queue if the country is "US", reducing unnecessary worker compute costs.
</details>

<details>
<summary><b>Q4: Scenario: You need to deploy a Docker containerized microservice on AWS ECS. Under what conditions would you choose the AWS Fargate launch type over hosting the container fleet on EC2?</b></summary>
<b>Answer:</b>
- **Choose AWS Fargate (Serverless) when:**
  1. **Minimal Management Overhead:** You do not want to manage underlying EC2 operating systems, patch Docker daemons, or configure EC2 Auto Scaling groups.
  2. **Predictable Scaling:** Workloads have quick scaling requirements. Fargate scales containers directly without waiting for new EC2 instances to provision and join the cluster.
  3. **Security Isolation:** You require tight kernel-level isolation between different running tasks. Each Fargate task runs in its own single-use VM boundary.
- **Choose ECS on EC2 when:**
  1. **Cost at Scale:** You run high-volume, highly utilized container workloads 24/7. EC2 instances can be purchased under Savings Plans or Spot instances, which becomes cheaper than Fargate at high volume.
  2. **Custom OS Requirements:** You require access to specific Linux kernel modifications, system privileges (e.g. running privileged containers), or custom mount pathways on the host.
  3. **GPU Compute:** The workload requires specialized GPU architectures which have limited or high-cost support on Fargate.
</details>

<details>
<summary><b>Q5: Scenario: An application running inside an ECS Fargate task needs to retrieve a configuration file from an S3 bucket. However, when the container starts, it exits with an "Access Denied" error when calling the S3 API. How do you troubleshoot this, and what ECS roles are involved?</b></summary>
<b>Answer:</b>
1. **Differentiate ECS Roles:**
   - **Task Execution Role:** Used by the ECS agent to perform actions on your behalf before the container runs (e.g. pulling the Docker image from ECR, sending container logs to CloudWatch, or decrypting secrets from Secrets Manager).
   - **Task Role:** Used by the application code *inside* the container once it is running.
2. **Troubleshooting Steps:**
   - The "Access Denied" error is thrown by the application code attempting to read from S3. This means the **Task Role** (not the execution role) is missing permissions.
   - Edit the ECS Task Definition. Ensure a role is assigned to the `taskRoleArn` parameter.
   - Verify that this IAM Role has an attached policy allowing `s3:GetObject` on the target bucket ARN.
   - Ensure the S3 bucket policy does not explicitly deny access to this role.
</details>

<details>
<summary><b>Q6: Scenario: You deployed an updated frontend bundle to your S3 bucket, but users globally still see the old webpage when hitting your CloudFront domain. How do you resolve this immediately, and what is the best practice for future deployments?</b></summary>
<b>Answer:</b>
1. **Immediate Resolution (CloudFront Invalidation):** Create a CloudFront Invalidation to purge the cached assets from all Edge Locations globally:
   ```bash
   aws cloudfront create-invalidation --distribution-id E1234567890ABC --paths "/*"
   ```
2. **Best Practice (Cache Busting):** Invalidating all files is slow and can be expensive if triggered frequently. Instead:
   - Use **versioned filenames** or content hashes during your build step (e.g., `bundle.8a3c9b.js` instead of `bundle.js`).
   - Configure a long TTL (e.g., 1 year) on these versioned static assets.
   - Keep the main `index.html` non-versioned, but set its cache behaviors in CloudFront to `Cache-Control: no-cache, no-store, must-revalidate` (forcing CloudFront to fetch it every time). When `index.html` updates, it points to the new versioned bundle filenames, loading them instantly.
</details>

<details>
<summary><b>Q7: Scenario: You are designing a global real-time multiplayer gaming backend that communicates via UDP. How do you optimize latency and route users to the nearest game server globally? Do you use CloudFront or AWS Global Accelerator?</b></summary>
<b>Answer:</b>
Use **AWS Global Accelerator**:
- **Why not CloudFront:** CloudFront is a Content Delivery Network (CDN) optimized for caching HTTP/HTTPS content. It does not support routing raw UDP traffic.
- **How Global Accelerator Works:** 
  1. It provides you with two static Anycast IP addresses.
  2. Traffic from the gamer enters the closest AWS Edge Location via Anycast.
  3. It then travels over the private, congested-free AWS Global Network (instead of the public internet) directly to your application servers running in your primary AWS regions.
  4. It natively supports **UDP** and TCP traffic, routing users to the closest healthy endpoint based on latency, and handles instant failover in under 30 seconds if a regional endpoint fails.
</details>

<details>
<summary><b>Q8: Scenario: Your company has 150 TB of local database backup files on-premises that must be migrated to AWS S3. Your corporate network connection is a shared 50 Mbps broadband line. How do you migrate this data?</b></summary>
<b>Answer:</b>
Do NOT upload this over the internet.
- **Math:** Uploading 150 TB over a dedicated 50 Mbps line would take approximately **277 days** of continuous, error-free uploading.
- **Solution:** Use **AWS Snowball Edge Storage Optimized**:
  1. Request an AWS Snowball Edge device (which supports up to 80 TB or 210 TB of storage) from the AWS Console.
  2. Once the device arrives at your data center, connect it to your local high-speed network (supporting 10Gbps or 40Gbps interfaces).
  3. Use the AWS Snowball client or mount the device as an NFS share to copy the 150 TB of backup files onto the device (encrypted at rest).
  4. Ship the device back to AWS. AWS will import the files directly into your specified S3 bucket.
</details>

<details>
<summary><b>Q9: Scenario: You have legacy Windows file share applications on-premises that need access to cloud storage. You need a solution that caches active files locally for low latency but offloads cold data to S3. What storage service do you choose?</b></summary>
<b>Answer:</b>
Use **AWS Storage Gateway (File Gateway / Amazon S3 File Gateway)**:
1. **Deployment:** Deploy the Storage Gateway virtual appliance on-premises (on VMware ESXi or Hyper-V).
2. **Access Protocol:** Expose the file share using the SMB (Server Message Block) protocol for Windows clients.
3. **Caching & S3 sync:** The gateway caches frequently accessed files locally on its local VM disk, providing low-latency access to the local office.
4. **Offloading:** It asynchronously syncs all files and directories directly to an S3 bucket in your AWS account, translating SMB directory structures to S3 object keys.
</details>

<details>
<summary><b>Q10: Scenario: Your production Docker containers in ECR have been flagged by the security team as having critical CVE vulnerabilities. How do you automate vulnerability scanning and prevent these images from being deployed?</b></summary>
<b>Answer:</b>
1. **ECR Image Scanning:** Configure ECR repositories to enable **"Scan on Push"**. This automatically runs a vulnerability scan using Amazon Inspector whenever a new image is pushed.
2. **Vulnerability Alerting:** Use Amazon EventBridge to listen for ECR scan completion events. Route critical findings to an SNS Topic to alert the security team.
3. **CI/CD Pipeline Gate:** In your Jenkins pipeline, after pushing the image to ECR, run a CLI command to poll the ECR scan status and fail the build if any "CRITICAL" vulnerabilities are detected:
   ```bash
   aws ecr describe-image-scan-findings --repository-name my-app --image-id imageTag=latest --query 'imageScanFindings.findings[?severity==`CRITICAL`]'
   ```
4. **Tag Immutability:** Enable **Tag Immutability** in ECR. This prevents developers from overwriting tags (like `prod` or `latest`) with un-scanned or modified images.
</details>
