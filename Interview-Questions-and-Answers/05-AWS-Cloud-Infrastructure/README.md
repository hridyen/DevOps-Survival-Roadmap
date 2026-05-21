# ✦ AWS Cloud Infrastructure Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering AWS Identity and Access Management (IAM), EC2 Compute, VPC Networking, RDS Databases, S3 Storage, Serverless architectures, and ECS container orchestration.

---

## ✦ Section 1: IAM, Security & Core Governance (Questions 1-20)

<details>
<summary><b>Q1: Scenario: A developer needs temporary read access to a production S3 bucket. What is the most secure way to grant this?</b></summary>
Do not create IAM user credentials or share keys. Instead, define an **IAM Role** with a read-only policy on the specific S3 bucket. Configure the developer's IAM user or active session to assume this role using **AWS STS (Security Token Service)** to receive temporary security credentials.
</details>

<details>
<summary><b>Q2: Scenario: You suspect an IAM user's Access Key has been compromised. How do you disable it and audit its activity?</b></summary>
1. Go to IAM console, locate the user, and change status of the Access Key to "Inactive" immediately.
2. Search **AWS CloudTrail** logs filtering by the Access Key ID to identify what API calls were made.
3. Delete the key once rotated, and check if any resource policies were modified.
</details>

<details>
<summary><b>Q3: Scenario: An application running on an EC2 instance needs to read from DynamoDB. How do you authenticate the instance securely?</b></summary>
Create an **IAM Role** with DynamoDB read permissions and attach it to the EC2 instance via an **Instance Profile**. The AWS SDK on the instance will automatically fetch credentials from the instance metadata endpoint (`IMDSv2`).
</details>

<details>
<summary><b>Q4: Scenario: You want to enforce a security policy where all API requests from an IAM user must originate from your company's corporate IP range. How?</b></summary>
Add a condition block containing the `aws:SourceIp` key to the IAM user's policy:
```json
"Condition": {
    "NotIpAddress": {
        "aws:SourceIp": ["203.0.113.0/24"]
    }
}
```
Set the effect to `Deny` for actions if they occur outside this block.
</details>

<details>
<summary><b>Q5: Scenario: How do you verify which IAM policies are granting a user access to a specific action?</b></summary>
Use the **IAM Policy Simulator** tool to evaluate permissions, or run `aws iam simulate-principal-policy` via the AWS CLI.
</details>

<details>
<summary><b>Q6: Scenario: You need to grant a partner AWS account access to read data from your S3 bucket. How do you configure this?</b></summary>
Set up a cross-account role:
1. Create an IAM Role in your account.
2. Set the Trust Policy to allow the partner's account ID as the principal.
3. Attach permissions to read the S3 bucket to the role.
4. Have the partner assume the role using STS.
</details>

<details>
<summary><b>Q7: Scenario: What is the difference between an IAM Group and an IAM Role?</b></summary>
- **IAM Group:** A collection of IAM users. Used to simplify permission management (e.g. `SysAdmins` group gets AdministratorAccess).
- **IAM Role:** An identity with permission policies that can be assumed by anyone or anything (users, applications, EC2, Lambda) temporarily. It does not have long-term credentials.
</details>

<details>
<summary><b>Q8: Scenario: You want to prevent any administrator in a member account of an AWS Organization from deleting CloudTrail logs. How do you enforce this centrally?</b></summary>
Configure a **Service Control Policy (SCP)** at the Organization root level that explicitly denies the `cloudtrail:DeleteTrail` action. SCPs override local administrator permissions.
</details>

<details>
<summary><b>Q9: Scenario: How do you track who modified an EC2 security group rules list yesterday?</b></summary>
Look up the event `AuthorizeSecurityGroupIngress` in the **AWS CloudTrail** event history.
</details>

<details>
<summary><b>Q10: Scenario: What is the metadata service endpoint IP address accessible from inside EC2 instances?</b></summary>
`169.254.169.254`.
</details>

<details>
<summary><b>Q11: Scenario: How do you protect your AWS root account?</b></summary>
Enable MFA immediately, do not create access keys for the root account, delete root passwords if not needed, and use IAM administrator users for daily operations.
</details>

<details>
<summary><b>Q12: Scenario: You want to delegate administration of AWS resources to team members based on their tags (e.g., allow modifications only to resources where tag `Project=Billing`). What is this method?</b></summary>
**Attribute-Based Access Control (ABAC)**. Configure IAM policy conditions comparing request tags to resource tags.
</details>

<details>
<summary><b>Q13: Scenario: How do you generate a report listing all IAM users, their active keys, and MFA statuses?</b></summary>
Generate a **Credential Report** via IAM console or run `aws iam generate-credential-report`.
</details>

<details>
<summary><b>Q14: Scenario: An IAM policy has an explicit `Deny` and an `Allow` on the same action. Which takes precedence?</b></summary>
The explicit `Deny` takes precedence.
</details>

<details>
<summary><b>Q15: Scenario: How do you configure users to change their AWS console password every 90 days?</b></summary>
Define a custom **Password Policy** in IAM account settings.
</details>

<details>
<summary><b>Q16: Scenario: What is AWS KMS and how does it secure data?</b></summary>
AWS Key Management Service (KMS) manages cryptographic keys used to encrypt data at rest across AWS services (EBS, S3, RDS) using hardware security modules (HSMs).
</details>

<details>
<summary><b>Q17: Scenario: What is the difference between AWS KMS symmetric and asymmetric keys?</b></summary>
- **Symmetric:** Uses the same key for encryption and decryption. Kept inside KMS.
- **Asymmetric:** Uses a public/private key pair. You can download the public key to encrypt data outside AWS, while decryption must take place inside KMS using the private key.
</details>

<details>
<summary><b>Q18: Scenario: You want to audit permissions to see which IAM roles have not been used in the last 90 days. How?</b></summary>
Use **IAM Access Analyzer** or inspect the "Last Accessed" tab of IAM roles in the console.
</details>

<details>
<summary><b>Q19: Scenario: How do you verify if resource-based policies (like S3 bucket policies) grant public access to resources?</b></summary>
Enable **AWS IAM Access Analyzer** to automatically alert on public or cross-account access paths.
</details>

<details>
<summary><b>Q20: Scenario: What is AWS Shield and how does it differ from WAF?</b></summary>
- **Shield:** Protection against DDoS attacks at layer 3 and 4 (network/transport).
- **WAF:** Web Application Firewall to mitigate web exploits (SQL injection, XSS) at layer 7 (application).
</details>

---

## ✦ Section 2: EC2, Load Balancing & Auto Scaling (Questions 21-40)

<details>
<summary><b>Q21: Scenario: Your web application gets sudden traffic spikes. How do you design an Auto Scaling Group (ASG) that responds quickly to CPU usage metrics?</b></summary>
Configure **Target Tracking Scaling Policies** tracking average CPU utilization at 70%. Ensure the **Instance Warmup** period is set short (e.g. 60s), and configure launch templates with optimized AMIs that start applications instantly.
</details>

<details>
<summary><b>Q22: Scenario: How do you configure an Application Load Balancer (ALB) to route traffic to `/api/*` to a specific target group of Node.js instances?</b></summary>
Configure **Listener Rules** on the ALB. Add a path-based routing rule matching path `/api/*` and point it to the designated Node.js target group.
</details>

<details>
<summary><b>Q23: Scenario: An instance in an Auto Scaling Group fails its ALB health check. What does the ASG do?</b></summary>
The ASG marks the instance as unhealthy, terminates it automatically, and provisions a new replacement instance to maintain the desired capacity.
</details>

<details>
<summary><b>Q24: Scenario: You want to run a batch job on EC2 for 4 hours at the absolute lowest cost, but the job can survive interruptions. What billing model?</b></summary>
Use **Spot Instances** (saves up to 90% compared to On-Demand prices).
</details>

<details>
<summary><b>Q25: Scenario: An EC2 instance has an Elastic IP. If you stop and start the instance, does the Elastic IP change?</b></summary>
No. An Elastic IP is a static public IPv4 address associated with your AWS account that remains unchanged until you release it manually.
</details>

<details>
<summary><b>Q26: Scenario: How do you configure an ALB to forward client IP addresses to web servers since reverse proxies hide them?</b></summary>
The ALB appends the client IP to the HTTP header **`X-Forwarded-For`**. Configure your web server (Nginx/Apache) to read this header.
</details>

<details>
<summary><b>Q27: Scenario: What is the difference between a Security Group and a Network ACL (NACL)?</b></summary>
- **Security Group:** Statefully operates at the instance level. Allows only permit rules (denies are implicit).
- **NACL:** Statelessly operates at the subnet level. Evaluates rule numbers sequentially and supports both allow and deny rules.
</details>

<details>
<summary><b>Q28: Scenario: You cannot connect to your EC2 instance over SSH. What are the top 3 network things to check?</b></summary>
1. Check if the Security Group allows inbound TCP port 22.
2. Verify if the instance has a public IP and sits in a public subnet with a route to an Internet Gateway (`0.0.0.0/0` via igw).
3. Check if Network ACLs (NACL) allow inbound and outbound traffic.
</details>

<details>
<summary><b>Q29: Scenario: How do you configure a sticky session (session affinity) on an ALB?</b></summary>
Configure target group properties to enable stickiness, choosing duration-based or application-based cookies.
</details>

<details>
<summary><b>Q30: Scenario: What is the difference between Application Load Balancer (ALB) and Network Load Balancer (NLB)?</b></summary>
- **ALB:** Routes at layer 7 (HTTP/HTTPS). Supports path-based, host-based, and query parameter routing.
- **NLB:** Routes at layer 4 (TCP/UDP/TLS). Extremely high throughput (millions of requests/sec) with ultra-low latency.
</details>

<details>
<summary><b>Q31: Scenario: You want to mount a network filesystem that can scale to petabytes and be accessed by 100 EC2 instances simultaneously. What service?</b></summary>
**Amazon EFS** (Elastic File System).
</details>

<details>
<summary><b>Q32: Scenario: What is the difference between EBS General Purpose SSD (gp3) and Provisioned IOPS (io2) volume types?</b></summary>
- **gp3:** Baseline performance with ability to scale IOPS and throughput independently. Cost-effective for standard database workloads.
- **io2:** Guarantees provisioned IOPS up to 256,000 per volume. Crucial for high-performance databases requiring absolute consistency.
</details>

<details>
<summary><b>Q33: Scenario: How do you take a backup of an EBS volume? Is it incremental?</b></summary>
Create an **EBS Snapshot**. Yes, EBS snapshots are incremental; only blocks modified since the last backup are stored in S3.
</details>

<details>
<summary><b>Q34: Scenario: What is Instance Store and how does it differ from EBS?</b></summary>
- **Instance Store:** Physically attached disk drives on the host server. High speed, but ephemeral (data is lost if instance is stopped or terminated).
- **EBS:** Network-attached virtual block storage. Persistent (data survives instance stop/start).
</details>

<details>
<summary><b>Q35: Scenario: You want to copy an AMI from `us-east-1` to `eu-west-1`. Can you do this?</b></summary>
Yes. Go to AMIs console, select the AMI, click Action -> Copy AMI, and choose the target region `eu-west-1`.
</details>

<details>
<summary><b>Q36: Scenario: How do you execute bootstrap configuration scripts automatically when an EC2 instance launches?</b></summary>
Add the commands to the **User Data** field during instance creation or launch template definitions.
</details>

<details>
<summary><b>Q37: Scenario: An auto-scaling group scales out, but shortly after terminates the new instances, repeating this cycle. What is this behavior?</b></summary>
**ASG Thrashing (Flapping)**. Can be caused by misconfigured metric thresholds or cooling down periods set too short.
</details>

<details>
<summary><b>Q38: Scenario: You want to distribute EC2 instances across different hardware racks within an Availability Zone to reduce correlated failures. What placement group?</b></summary>
Use a **Spread Placement Group**.
</details>

<details>
<summary><b>Q39: Scenario: How do you encrypt an existing unencrypted EBS volume?</b></summary>
1. Take a snapshot of the unencrypted volume.
2. Copy the snapshot, checking the "Encrypt this snapshot" option.
3. Create a new volume from the encrypted snapshot and mount it.
</details>

<details>
<summary><b>Q40: Scenario: What is the default grace period duration on ASG health checks?</b></summary>
300 seconds (5 minutes), allowing instances to finish booting before checks begin.
</details>

---

## ✦ Section 3: Databases & Storage (Questions 41-60)

<details>
<summary><b>Q41: Scenario: Your RDS MySQL database runs out of storage space. Can you scale it up without downtime?</b></summary>
Yes. Enable **Storage Autoscaling** in RDS settings or modify the storage capacity allocated. RDS expands storage allocations on the fly without interrupting DB operations.
</details>

<details>
<summary><b>Q42: Scenario: What is the difference between RDS Multi-AZ and Read Replicas?</b></summary>
- **Multi-AZ:** Synchronously replicates data to a standby instance in another AZ. Used for disaster recovery and automatic failover.
- **Read Replicas:** Asynchronously replicates data to read-only instances. Used to scale read performance and can be promoted to independent databases.
</details>

<details>
<summary><b>Q43: Scenario: How do you protect a production S3 bucket from accidental file deletion?</b></summary>
Enable **S3 Versioning**, configure **MFA Delete** policies, and enable **S3 Object Lock** in write-once-read-many (WORM) mode.
</details>

<details>
<summary><b>Q44: Scenario: An S3 bucket contains millions of objects that are rarely accessed after 30 days. How do you automate moving them to Glacier to save costs?</b></summary>
Create an **S3 Lifecycle Policy**. Define a transition rule: move objects from Standard class to Glacier Flexible Retrieval 30 days after object creation.
</details>

<details>
<summary><b>Q45: Scenario: You want to cache frequent SQL database queries to reduce database load and latency. What AWS caching service?</b></summary>
**Amazon ElastiCache** (using Redis or Memcached engines).
</details>

<details>
<summary><b>Q46: Scenario: How does Amazon Aurora differ from RDS MySQL?</b></summary>
Aurora is a cloud-native relational database engine. It replicates data across 3 Availability Zones (6 copies), auto-scales storage up to 128TB, and features faster replication lag compared to standard RDS engines.
</details>

<details>
<summary><b>Q47: Scenario: You want to host a static website containing HTML, CSS, and JS files with no backend server. What is the cheapest option?</b></summary>
Upload files to an **S3 Bucket**, enable "Static website hosting" in bucket properties, and make the objects public or configure CloudFront.
</details>

<details>
<summary><b>Q48: Scenario: You need to transfer 100TB of database backup data from your local datacenter to S3, but your internet bandwidth is only 50Mbps. How?</b></summary>
Order an **AWS Snowball Edge Storage Optimized** device. Load the data locally onto the device, and ship it back to AWS to load directly into S3.
</details>

<details>
<summary><b>Q49: Scenario: How do you encrypt data transit to S3 using bucket policies?</b></summary>
Create a bucket policy that denies `s3:PutObject` if the request header `aws:SecureTransport` is false (enforcing HTTPS connections).
```json
"Condition": {
    "Bool": { "aws:SecureTransport": "false" }
}
```
</details>

<details>
<summary><b>Q50: Scenario: What is DynamoDB and what is its primary scaling capability?</b></summary>
DynamoDB is a fully managed NoSQL key-value database. It features single-digit millisecond latency at any scale and supports both on-demand scaling and provisioned capacity scaling.
</details>

<details>
<summary><b>Q51: Scenario: You need to perform complex analytical SQL queries (OLAP) on petabytes of structured data. What database service?</b></summary>
**Amazon Redshift** (data warehousing service).
</details>

<details>
<summary><b>Q52: Scenario: What is DynamoDB Accelerator (DAX)?</b></summary>
A fully managed, highly available, in-memory cache for DynamoDB that reduces response times from milliseconds to microseconds.
</details>

<details>
<summary><b>Q53: Scenario: How do you restore an RDS database to the state it was in exactly 2 hours ago?</b></summary>
Use **Point-in-Time Recovery (PITR)**. RDS stores transaction logs along with daily snapshots, allowing you to restore to a new DB instance at any second within the retention period.
</details>

<details>
<summary><b>Q54: Scenario: What is S3 Transfer Acceleration?</b></summary>
Uses Amazon CloudFront's globally distributed edge locations to route uploads to S3 buckets over AWS backbone network routes.
</details>

<details>
<summary><b>Q55: Scenario: You want to restrict access to objects in an S3 bucket using short-lived URLs. How?</b></summary>
Generate **S3 Presigned URLs** specifying expiration times.
</details>

<details>
<summary><b>Q56: Scenario: How do you mount AWS storage in an on-premises datacenter using a local virtual appliance?</b></summary>
Use **AWS Storage Gateway** (e.g., File Gateway, Volume Gateway).
</details>

<details>
<summary><b>Q57: Scenario: What is the maximum storage file size of a single object in S3?</b></summary>
5TB.
</details>

<details>
<summary><b>Q58: Scenario: You want to upload a 50GB file to S3. What is the recommended upload mechanism?</b></summary>
**Multipart Upload API** (compulsory for files larger than 5GB).
</details>

<details>
<summary><b>Q59: Scenario: How do you sync files from local server `/data` to an S3 bucket using AWS CLI?</b></summary>
Run:
```bash
aws s3 sync /data s3://my-bucket-name
```
</details>

<details>
<summary><b>Q60: Scenario: Can you run SQL queries directly on CSV/JSON data files stored in S3 without moving them?</b></summary>
Yes. Use **Amazon Athena**.
</details>

---

## ✦ Section 4: VPC Networking & DNS (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You have instances in a private subnet that need to download package updates from the internet. How do you configure network egress?</b></summary>
1. Deploy a **NAT Gateway** in a public subnet.
2. Update the Private Subnet's route table to direct target internet traffic (`0.0.0.0/0`) to the NAT Gateway.
</details>

<details>
<summary><b>Q62: Scenario: How do you allow two VPCs (`VPC-A` and `VPC-B`) in the same region to route traffic to each other securely?</b></summary>
Create a **VPC Peering Connection**. Accept the connection in the second VPC, and update the route tables of both VPC subnets to route traffic through the peering connection ID (`pcx-xxxx`).
</details>

<details>
<summary><b>Q63: Scenario: You want to secure database instances so they only accept traffic from web server instances. How do you configure Security Groups?</b></summary>
Do not use IP addresses. In the Database Security Group, add an Inbound Rule allowing MySQL port 3306 and select the **Web Server Security Group ID** (e.g., `sg-web`) as the source.
</details>

<details>
<summary><b>Q64: Scenario: How do you cache global static assets (images/videos) close to users globally to decrease website load times?</b></summary>
Create a **CloudFront Distribution** pointing to your S3 bucket or load balancer as the origin.
</details>

<details>
<summary><b>Q65: Scenario: You want to configure Route 53 to route 80% of traffic to version 1 web servers and 20% to version 2 servers. What routing policy?</b></summary>
Use a **Weighted Routing Policy**.
</details>

<details>
<summary><b>Q66: Scenario: How do you connect an on-premises datacenter network to your AWS VPC over a dedicated private high-speed connection (bypassing the public internet)?</b></summary>
Configure **AWS Direct Connect**.
</details>

<details>
<summary><b>Q67: Scenario: What is a VPC Endpoint and what problem does it solve?</b></summary>
A VPC Endpoint (Interface or Gateway type) allows instances in private subnets to communicate with AWS public services (like S3 or DynamoDB) privately without going through NAT Gateways or the public internet.
</details>

<details>
<summary><b>Q68: Scenario: You want to capture all IP traffic details flowing in and out of your VPC network interfaces for security auditing. What?</b></summary>
Enable **VPC Flow Logs** and output them to CloudWatch logs or S3.
</details>

<details>
<summary><b>Q69: Scenario: What is Route 53 Latency Routing Policy?</b></summary>
Routes user requests to the AWS region that provides the lowest network latency for the client.
</details>

<details>
<summary><b>Q70: Scenario: How do you redirect traffic to a backup static page in S3 automatically if your primary EC2 server crashes?</b></summary>
Configure Route 53 **Failover Routing Policy** with active/passive configurations using health check metrics.
</details>

<details>
<summary><b>Q71: Scenario: What is the CIDR block size limit of a VPC?</b></summary>
Permits block masks between `/16` (65,536 IPs) and `/28` (16 IPs).
</details>

<details>
<summary><b>Q72: Scenario: How many IP addresses does AWS reserve by default in every subnet CIDR block?</b></summary>
5 IP addresses (e.g. `.0`, `.1`, `.2`, `.3`, and `.255`).
</details>

<details>
<summary><b>Q73: Scenario: How does an Internet Gateway (IGW) differ from a NAT Gateway?</b></summary>
- **IGW:** Allows bidirectional traffic (both ingress/egress) for public instances.
- **NAT Gateway:** Allows unidirectional traffic (egress only, blocking inbound connections) for private instances.
</details>

<details>
<summary><b>Q74: Scenario: You want to configure Route 53 to point `example.com` to an ALB. Should you use a CNAME or an Alias record?</b></summary>
Use an **Alias Record**. Alias records map root domains (`example.com` without `www`) directly to AWS resources and do not incur additional DNS query charges.
</details>

<details>
<summary><b>Q75: Scenario: How do you allow instances in a private subnet to download package updates without deploying a NAT Gateway to save costs?</b></summary>
Deploy a NAT Instance (a small EC2 instance running NAT software) or use VPC Endpoints if the packages are hosted on S3.
</details>

<details>
<summary><b>Q76: Scenario: What is AWS Transit Gateway?</b></summary>
Acts as a cloud router to connect hundreds of VPCs and on-premises networks hub-and-spoke style, avoiding complex peering meshes.
</details>

<details>
<summary><b>Q77: Scenario: How do you configure CloudFront to restrict access to content based on the user's geographic country?</b></summary>
Enable **Geographic Restriction** in CloudFront settings (allowlist/denylist).
</details>

<details>
<summary><b>Q78: Scenario: What is a public subnet in AWS?</b></summary>
A subnet whose route table has a route destination pointing to an Internet Gateway (`0.0.0.0/0` -> `igw-xxxx`).
</details>

<details>
<summary><b>Q79: Scenario: What is a Bastion Host?</b></summary>
A hardened EC2 instance situated in a public subnet used as a proxy bridge to connect and run SSH/RDP commands securely on private instances.
</details>

<details>
<summary><b>Q80: Scenario: How do you check if a DNS record has updated using Route 53 check tools?</b></summary>
Use the "Get TXT/NS records" search, or run `dig` commands targeting the Route 53 hosted zone nameservers.
</details>

---

## ✦ Section 5: Messaging, Containers & Serverless (Questions 81-100)

<details>
<summary><b>Q81: Scenario: You want to process image uploads. When a file lands in S3, you need to run a resize script instantly without maintaining servers. How?</b></summary>
Configure an **S3 Event Notification** to trigger an **AWS Lambda** function. The function runs the script inside a short-lived microsecond environment and shuts down automatically.
</details>

<details>
<summary><b>Q82: Scenario: How do you decouple a high-throughput transaction frontend from a backend processing service to prevent bottlenecks?</b></summary>
Insert an **Amazon SQS (Simple Queue Service)** queue in between. The frontend pushes order messages to SQS, and backend workers pull and process messages at their own pace.
</details>

<details>
<summary><b>Q83: Scenario: You want to send a single email and SMS notification to 10 different subscribers simultaneously when an alert is raised. What service?</b></summary>
**Amazon SNS (Simple Notification Service)**. Publish messages to an SNS Topic with subscribers.
</details>

<details>
<summary><b>Q84: Scenario: What is the difference between AWS Lambda and AWS ECS Fargate?</b></summary>
- **Lambda:** Event-driven serverless functions. Max execution limit of 15 minutes. Great for microservices.
- **Fargate:** Serverless container orchestration engine for ECS/EKS. Runs containers of any duration without management limits. Great for long-running processes.
</details>

<details>
<summary><b>Q85: Scenario: A Lambda function needs to connect to an RDS database in a private subnet. How do you configure its networking?</b></summary>
Configure the Lambda function to connect to the target **VPC**. Assign the private subnets and database security groups to the Lambda settings.
</details>

<details>
<summary><b>Q86: Scenario: How does a standard SQS queue differ from a FIFO SQS queue?</b></summary>
- **Standard:** Unlimited throughput. Guarantees "at-least-once" delivery, but messages might occasionally arrive out of order.
- **FIFO (First-In-First-Out):** Limited to 3,000 messages/sec. Guarantees exact order delivery and "exactly-once" processing.
</details>

<details>
<summary><b>Q87: Scenario: What is Amazon Elastic Container Registry (ECR)?</b></summary>
A fully managed Docker container registry to store, manage, and deploy Docker container images safely.
</details>

<details>
<summary><b>Q88: Scenario: You want to expose a Lambda function as an HTTP API endpoint. What fronting service?</b></summary>
**Amazon API Gateway** or use **Lambda Function URLs**.
</details>

<details>
<summary><b>Q89: Scenario: A Lambda function is experiencing "cold starts" that increase user latency. How do you mitigate this?</b></summary>
Enable **Provisioned Concurrency** to keep a specified number of execution environments warm and ready.
</details>

<details>
<summary><b>Q90: Scenario: What is a Task Definition in Amazon ECS?</b></summary>
A blueprint YAML/JSON file defining container settings (image, CPU, memory, environment variables, port mappings, log groups) required to launch container tasks.
</details>

<details>
<summary><b>Q91: Scenario: What is Amazon Cognito and when do you use it?</b></summary>
A user identity and access control management service to add user sign-up, sign-in, and authentication features to mobile and web apps.
</details>

<details>
<summary><b>Q92: Scenario: How do you configure a Dead Letter Queue (DLQ) for an SQS queue?</b></summary>
Create a secondary SQS queue as the DLQ. In the primary queue settings, specify the DLQ ARN and set the `maxReceiveCount` threshold.
</details>

<details>
<summary><b>Q93: Scenario: How do you schedule a Lambda function to run every 10 minutes (like a cron job)?</b></summary>
Create an **Amazon EventBridge (CloudWatch Events)** rule with schedule expression `rate(10 minutes)` and set the Lambda function as the target.
</details>

<details>
<summary><b>Q94: Scenario: What is the maximum execution time of a Lambda function?</b></summary>
15 minutes (900 seconds).
</details>

<details>
<summary><b>Q95: Scenario: You want to capture real-time streaming data from thousands of IoT devices and process it instantly. What service?</b></summary>
**Amazon Kinesis Data Streams**.
</details>

<details>
<summary><b>Q96: Scenario: How do you manage secrets (API tokens, DB credentials) dynamically inside ECS containers without saving them in code?</b></summary>
Save the secrets in **AWS Secrets Manager** or **Systems Manager (SSM) Parameter Store**. Reference their ARNs in the ECS Task Definition.
</details>

<details>
<summary><b>Q97: Scenario: What is the maximum size of a message payload in SQS?</b></summary>
256KB (can scale higher using the SQS Extended Client library pointing to S3).
</details>

<details>
<summary><b>Q98: Scenario: How does ECS Service differ from ECS Task?</b></summary>
- **ECS Task:** Launches a single instance of containers (like a transient batch job).
- **ECS Service:** Manages task scaling, integrates with load balancers, and restarts failed tasks automatically to maintain the desired count.
</details>

<details>
<summary><b>Q99: Scenario: What is AWS Step Functions?</b></summary>
A serverless orchestration service to coordinate multiple Lambda functions and AWS services into visual state machines.
</details>

<details>
<summary><b>Q100: Scenario: How do you trace and debug microservices latency issues across SQS, Lambda, and API Gateway?</b></summary>
Enable **AWS X-Ray** tracing.
</details>
