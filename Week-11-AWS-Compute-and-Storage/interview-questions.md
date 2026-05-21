# ⚡ Week 11 — AWS Compute & Storage Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on EC2, EBS, EFS, Load Balancers, and launch templates.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You run a stateless web application that experiences highly predictable traffic during business hours, but also gets brief, unpredictable surges. How do you design a cost-optimized EC2 hosting strategy using Spot Instances, On-Demand, and Savings Plans?</b></summary>
<b>Answer:</b>
1. **Baseline Load (Savings Plans):** Determine the absolute minimum compute required to run 24/7. Purchase an **EC2 Instance Savings Plan** or **Compute Savings Plan** to cover this baseline capacity, offering up to 72% discounts compared to On-Demand rates.
2. **Predictable Growth (Auto Scaling with On-Demand):** Use Auto Scaling Groups (ASG) to handle normal business hours traffic.
3. **Surges & Cost Optimization (Spot Instances in ASG):** Configure the ASG using a **Mixed Instances Policy**:
   - Set the baseline to run on On-Demand/Savings Plans (to guarantee uptime for core services).
   - Configure the scale-out capacity to allocate up to 70% Spot Instances.
   - Use Spot Instance allocation strategies like **capacity-optimized** to minimize the probability of Spot interruptions, and implement graceful termination handling by listening for the 2-minute Spot Interruption Notice via Amazon EventBridge.
</details>

<details>
<summary><b>Q2: Scenario: Your database is running on an EC2 instance with a `gp2` EBS volume. It is starting to run out of storage space, and latency has spiked due to disk IOPS exhaustion. How do you resolve this with zero downtime?</b></summary>
<b>Answer:</b>
Use the AWS **Elastic Volumes** feature to modify the volume dynamically:
1. **Modify Volume Size & Type:** Upgrade the volume from `gp2` to `gp3`. Increase the size (e.g. from 100 GB to 500 GB). 
   - *Advantage of gp3:* It decouples IOPS and throughput from volume size. You can provision high IOPS (e.g., 12,000 IOPS) and throughput (e.g., 500 MB/s) independently of the disk size, which is cheaper and more performant than `gp2`.
2. **Execution via CLI:**
   ```bash
   aws ec2 modify-volume --volume-id vol-0abcdef1234567890 --volume-type gp3 --size 500 --iops 12000 --throughput 500
   ```
3. **Extend File System:** While the volume modification is applied on the fly by AWS, you must extend the partition and file system within the OS:
   - Identify the partition format (e.g. ext4 or xfs).
   - Grow the partition using `growpart`:
     ```bash
     sudo growpart /dev/xvda 1
     ```
   - Extend the file system using `resize2fs` (for ext4) or `xfs_growfs` (for XFS):
     ```bash
     sudo resize2fs /dev/xvda1
     ```
</details>

<details>
<summary><b>Q3: Scenario: You have an encrypted EBS snapshot in AWS Account A that you want to share with AWS Account B. How do you share it securely, and how do you launch a volume from it in Account B?</b></summary>
<b>Answer:</b>
Because the snapshot is encrypted, you cannot share it directly without sharing the KMS key that encrypted it:
1. **Create/Modify KMS Key Policy:** In Account A, navigate to the Customer Managed Key (CMK) used to encrypt the EBS snapshot. Modify the key policy to grant the root principal of Account B permissions to use the key (`kms:DescribeKey`, `kms:CreateGrant`, `kms:Decrypt`, `kms:ReEncrypt*`).
2. **Share Snapshot:** Modify the snapshot permissions in Account A to add Account B's account ID.
3. **In Account B:**
   - You cannot directly create a volume from a shared encrypted snapshot in another account.
   - **Step 1:** Copy the shared snapshot to Account B, encrypting it with a KMS key owned by Account B.
   - **Step 2:** Create an EBS volume or launch an EC2 instance from this copied snapshot.
</details>

<details>
<summary><b>Q4: Scenario: You are deploying a high-availability WordPress site across three Availability Zones. The web servers need concurrent read-write access to a shared directory (`/var/www/html/uploads`) to store user-uploaded media. Do you use EBS or EFS, and how do you configure it?</b></summary>
<b>Answer:</b>
- **Storage Choice: AWS EFS (Elastic File System).** 
  - *Reasoning:* EBS is block storage and is typically restricted to a single EC2 instance within a single Availability Zone (excluding EBS Multi-Attach which requires clustered file systems and cannot cross AZs). EFS is a managed NFS server that supports the NFSv4 protocol and can be mounted concurrently by thousands of instances across multiple AZs.
- **Configuration Steps:**
  1. Create an EFS File System.
  2. Create **Mount Targets** in each of the three VPC subnets (one per AZ) associated with the web servers.
  3. Configure the EFS Security Group to allow inbound TCP port 2049 (NFS) traffic only from the security group assigned to the EC2 web servers.
  4. Mount the EFS file system on the EC2 instances using the EFS mount helper:
     ```bash
     sudo mount -t efs -o tls fs-12345678:/ /var/www/html/uploads
     ```
</details>

<details>
<summary><b>Q5: Scenario: Under what technical conditions would you choose a Network Load Balancer (NLB) over an Application Load Balancer (ALB)?</b></summary>
<b>Answer:</b>
Choose a **Network Load Balancer (NLB)** when:
1. **Extreme Performance:** The workload must handle millions of requests per second with ultra-low latency (single-digit milliseconds), whereas ALB is slower due to layer 7 request parsing.
2. **Static/Elastic IP Allocation:** You require the load balancer to present a single static IP address (or Elastic IP) per Availability Zone. ALB only provides DNS names, and its underlying IPs change dynamically.
3. **Layer 4 Protocols:** You need to load balance non-HTTP/HTTPS traffic (raw TCP, UDP, TLS, or WebSockets).
4. **Source IP Preservation:** You require the client's original source IP and port to be preserved at the TCP packet level without relying on HTTP headers (like `X-Forwarded-For`).
</details>

<details>
<summary><b>Q6: Scenario: You have an Application Load Balancer hosting multiple microservices. You want to direct traffic to different target groups depending on the URL path: `/api/users/*` goes to the Users Service, and `/api/products/*` goes to the Products Service. How do you configure this on the ALB?</b></summary>
<b>Answer:</b>
Use ALB **Path-Based Routing Rules**:
1. Create target groups for the Users Service and Products Service, and register the respective EC2/ECS hosts.
2. Create an ALB Listener on port 443 (HTTPS) with an SSL Certificate.
3. Add routing rules to the listener:
   - **Rule 1:** IF Path is `/api/users/*` THEN Forward to `Users-Target-Group`.
   - **Rule 2:** IF Path is `/api/products/*` THEN Forward to `Products-Target-Group`.
   - **Default Rule:** IF no rules match, forward to a static maintenance page or a default landing page target group.
</details>

<details>
<summary><b>Q7: Scenario: You launched an EC2 instance with a complex User Data shell script to install and launch your app. However, when the instance boots up, the application is not running. How do you troubleshoot this?</b></summary>
<b>Answer:</b>
1. **Check execution logs:** Log in to the instance via SSH or Systems Manager Session Manager, and view the cloud-init logs:
   - `/var/log/cloud-init.log` (logs the high-level stages of instance initialization).
   - `/var/log/cloud-init-output.log` (captures the raw stdout/stderr output of your User Data script).
2. **Verify run frequency:** Remember that User Data scripts **only execute once** by default during the first boot cycle. If the instance was restarted, the script will not run again unless configured using cloud-init mime multipart configs.
3. **Check permissions:** Ensure the script starts with a valid shebang (e.g., `#!/bin/bash`). If it lacks a shebang, the OS will not execute it.
4. **Common issue (non-interactive blocks):** Ensure there are no prompts in the script (like `apt-get install` without the `-y` flag) that block the script indefinitely waiting for terminal input.
</details>

<details>
<summary><b>Q8: Scenario: You are hosting three distinct web applications with three separate domains (`app1.domain.com`, `app2.domain.com`, `app3.domain.com`) on a single EC2 instance fleet behind a single Application Load Balancer. How do you implement this cost-effectively?</b></summary>
<b>Answer:</b>
Use **Server Name Indication (SNI)** combined with **Host-Based Routing** on a single ALB:
1. **SSL Certificates:** Create a wildcard ACM Certificate (e.g., `*.domain.com`) or request three individual certificates.
2. **Listener setup:** Associate all three certificates with the ALB's HTTPS (443) listener. The ALB will use SNI to dynamically present the correct certificate matching the host header sent by the client.
3. **Host Rules:** Configure host-based routing rules on the ALB listener:
   - Rule 1: IF Host Header is `app1.domain.com` -> Forward to `App1-Target-Group`.
   - Rule 2: IF Host Header is `app2.domain.com` -> Forward to `App2-Target-Group`.
   - Rule 3: IF Host Header is `app3.domain.com` -> Forward to `App3-Target-Group`.
</details>

<details>
<summary><b>Q9: Scenario: Your ALB target group shows that all EC2 instances are in an "Unhealthy" state, and users are getting 502 Bad Gateway errors. However, you can access the application fine when calling it on localhost inside the EC2 instance. What is wrong?</b></summary>
<b>Answer:</b>
This is a common configuration mismatch. Check the following:
1. **Security Groups:** Verify that the Security Group attached to the EC2 instances has an inbound rule permitting TCP traffic on the application port (e.g., 80 or 8080) originating from the **Security Group of the ALB**.
2. **Port/Protocol Mismatch:** Check that the ALB Target Group is configured with the correct protocol and port that your web server is listening on.
3. **Health Check Path:** Ensure the health check path (e.g., `/healthz` or `/`) exists, returns a `200 OK` status, and does not require authentication.
4. **Host Binding:** Ensure your application server is bound to `0.0.0.0` (all network interfaces) and not hardcoded to `127.0.0.1` (localhost), which prevents the load balancer's private IP from reaching the socket.
</details>

<details>
<summary><b>Q10: Scenario: What is the difference between a Launch Configuration and a Launch Template in AWS Auto Scaling? Why does AWS recommend migrating to Launch Templates?</b></summary>
<b>Answer:</b>
- **Launch Configurations:** Legacy templates. They are immutable (cannot be modified after creation; you must create a new one for changes) and do not support newer AWS features.
- **Launch Templates:** Modern replacements. 
  - **Why migrate to Launch Templates:**
    1. **Versioning:** Launch templates support versions, allowing you to roll back changes or track alterations.
    2. **Advanced Features:** Required to use newer features like T3 Unlimited instances, Spot Instance allocation strategies, mixed instances policies (combining Spot and On-Demand in one ASG), and Capacity Reservations.
    3. **Metadata Options:** Enforce IMDSv2 configurations globally at template level.
</details>
