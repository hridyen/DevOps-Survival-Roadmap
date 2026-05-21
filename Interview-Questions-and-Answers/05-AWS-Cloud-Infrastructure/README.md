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

---

## Week 10: AWS Fundamentals and IAM

This document compiles **10 advanced, scenario-based interview questions and answers** on AWS Identity & Access Management (IAM), Policy Evaluation, Cross-Account Access, and Organizations.

<details>
<summary><b>Q101: Scenario: You have an IAM user who has an identity-based policy allowing `s3:*` on all resources. However, there is a Service Control Policy (SCP) blocking S3 deletions, and a Permission Boundary attached to the user that only allows EC2 and RDS actions. Can this user delete an S3 bucket? Explain the IAM policy evaluation logic.</b></summary>
<b>Answer:</b>
**No**, the user cannot delete the S3 bucket.
AWS IAM policy evaluation follows a strict decision flow:
1. **Default Deny:** By default, all requests are denied (Implicit Deny).
2. **Explicit Deny:** If any policy (Identity-based, Resource-based, SCP, Boundary) contains an explicit `Deny` for the action, the final decision is immediately **Deny** (Explicit Deny overrides everything).
3. **Intersection of Permissions:** For an action to be allowed, it must be allowed across all applicable policy types:
   - **SCP:** Allows S3 delete? No (explicit or implicit deny).
   - **Permission Boundary:** Allows S3 actions? No (it only allows EC2/RDS).
   - **Identity-based Policy:** Allows S3 delete? Yes.
   
Since the permission boundary does not include S3 actions, the effective permissions are limited to the intersection. Hence, the user is denied S3 deletion.
</details>

<details>
<summary><b>Q102: Scenario: You need to allow a third-party SaaS security tool running in AWS Account B to run read-only security audits on resources inside your AWS Account A. How do you design this securely without sharing any IAM access keys?</b></summary>
<b>Answer:</b>
Use **IAM Cross-Account Roles with an External ID**:
1. **In Account A (Target):** Create an IAM Role (e.g. `SaaS_Security_Audit_Role`) with a **Trust Policy** that allows the IAM principal in Account B (the SaaS tool's account) to assume it.
2. **External ID Enforcement:** In the trust policy, enforce an `sts:ExternalID` condition. This prevents the "confused deputy" problem, ensuring Account B can only assume the role if they pass the unique identifier allocated to your company.
3. **Attach Permissions:** Attach AWS managed policy `SecurityAudit` or `ReadOnlyAccess` to this role.
4. **In Account B:** The SaaS tool will call the AWS Security Token Service (STS) `AssumeRole` API, passing the ARN of the role in Account A and the External ID to retrieve temporary credentials.
```json
// Trust Policy in Account A
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::ACCOUNT_B_ID:root" },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": { "sts:ExternalId": "UNIQUE_SECRET_EXTERNAL_ID" }
      }
    }
  ]
}
```
</details>

<details>
<summary><b>Q103: Scenario: You want to delegate IAM administration permissions to a group of Junior Administrators. However, you must prevent them from elevating their own permissions or creating Administrator users. How do you enforce this restriction?</b></summary>
<b>Answer:</b>
Use an **IAM Permission Boundary**:
1. Create a "Boundary Policy" that allows standard developer permissions but explicitly excludes the ability to modify boundaries, organizations, or administrator roles.
2. Attach a policy to the Junior Administrators that allows them to create users (`iam:CreateUser`, `iam:CreateRole`) and attach policies, but **only** if they specify the boundary policy ARN in the request.
3. If they try to create a user/role without attaching that boundary, the action is denied.
```json
// Policy attached to Junior Administrators
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "iam:CreateUser", "iam:PutUserPolicy", "iam:AttachUserPolicy" ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:aws:iam::ACCOUNT_ID:policy/DeveloperBoundary"
        }
      }
    }
  ]
}
```
</details>

<details>
<summary><b>Q104: Scenario: An EC2 instance hosting an application needs to read from an S3 bucket. A junior developer suggests configuring access keys directly inside the application's configuration files. Explain why this is a security risk and how to implement this using IAM Instance Profiles and IMDSv2.</b></summary>
<b>Answer:</b>
- **Security Risks:** Hardcoding AWS credentials makes rotation difficult. If the server is compromised or the source code is pushed to Git, the credentials are exposed.
- **The Secure Solution:** Use **IAM Roles for EC2 (Instance Profiles)**:
  1. Create an IAM Role with an S3 read policy.
  2. Attach this role to the EC2 Instance via an **Instance Profile**.
  3. The AWS SDK or CLI inside the application will automatically query the **Instance Metadata Service (IMDS)** to retrieve temporary, short-lived credentials.
- **Enforcing IMDSv2:** IMDSv2 is session-oriented and uses a token-based handshake, protecting against Server-Side Request Forgery (SSRF) vulnerabilities where IMDSv1 headers could be leaked. You should disable IMDSv1 on the instance:
  ```bash
  aws ec2 modify-instance-metadata-options --instance-id i-1234567890abcdef0 --http-tokens required
  ```
</details>

<details>
<summary><b>Q105: Scenario: You need to allow 200 developers to upload files to an S3 bucket. However, each developer must only be allowed to read and write to their own dedicated directory (e.g. `s3://company-shared-bucket/home/username/`). How do you implement this with a single IAM policy?</b></summary>
<b>Answer:</b>
Use **IAM Policy Variables** (e.g., `${aws:username}`). This variable is evaluated at runtime when the user makes the request:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::company-shared-bucket"],
      "Condition": {
        "StringLike": { "s3:prefix": ["home/${aws:username}/*", "home/${aws:username}"] }
      }
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": ["arn:aws:s3:::company-shared-bucket/home/${aws:username}/*"]
    }
  ]
}
```
This single policy can be attached to a Group (e.g. `Developers`). When `alice` signs in, the variable resolves to `alice/`, allowing her access to `home/alice/*` but denying her access to `home/bob/*`.
</details>

<details>
<summary><b>Q106: Scenario: How do Service Control Policies (SCPs) differ from standard IAM policies, and how do they impact the Root user of a member account in an AWS Organization?</b></summary>
<b>Answer:</b>
- **Standard IAM Policies:** Applied to identities (users, groups, roles) or resources inside a single AWS account.
- **Service Control Policies (SCPs):** Applied at the AWS Organizations level (Root, OU, or individual Member Account). SCPs establish permission guardrails by defining the maximum permissions available to accounts.
- **Impact on Root User:** Unlike standard IAM policies, **SCPs apply to all users in the member account, including the root user**. Even if the root user has full permissions, if an SCP explicitly denies an action (like `rds:DeleteDBInstance`), the root user cannot perform that action. (SCPs do not apply to the Management/Master account of the organization).
</details>

<details>
<summary><b>Q107: Scenario: Your security audit reveals that several IAM user access keys are active but have not been used for over 180 days. How do you automate the discovery of these credentials, and what are the best practices for rotation?</b></summary>
<b>Answer:</b>
1. **Discovery:**
   - Use the **IAM Credential Report** to get a CSV of all users, their MFA status, password usage, and access key rotation age. Generate this via CLI or script:
     ```bash
     aws iam generate-credential-report
     aws iam get-credential-report --query 'Content' --output text | base64 -d > report.csv
     ```
   - Alternatively, query **IAM Access Advisor** to check when the credentials last called any AWS service.
2. **Best Practices for Rotation:**
   - **Rotate keys every 90 days.**
   - **Multi-step rotation:** Generate a new key, update the application config, verify application health, disable the old key, and then delete the old key after confirming no issues occur.
   - Limit users to a maximum of 2 active keys during the rotation phase.
</details>

<details>
<summary><b>Q108: Scenario: When configuring a trust relationship for an IAM Role, what is the difference between the "Trust Policy" and the "Permission Policy"? Provide an example of how a misconfigured trust policy causes a "Failed to Assume Role" error.</b></summary>
<b>Answer:</b>
- **Trust Policy (Who can assume it):** A resource-based policy attached to the role that defines which external principals (IAM users, services like EC2/Lambda, or other AWS accounts) are trusted to assume the role.
- **Permission Policy (What it can do):** An identity-based policy attached to the role that defines the actions the principal can perform once they assume the role.
- **Troubleshooting "Failed to Assume Role":** If a Lambda function tries to assume a role but returns an access denied error during invocation, it is usually because the trust policy does not list `lambda.amazonaws.com` as a trusted service:
```json
// Correct trust policy for Lambda
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```
</details>

<details>
<summary><b>Q109: Scenario: You have a requirement to enforce Multi-Factor Authentication (MFA) for all console and API actions. If MFA is not active, the user should be denied all access. How do you implement this policy?</b></summary>
<b>Answer:</b>
Attach a global Deny policy containing a condition checking if MFA was used to authenticate:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllExceptIfMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" }
      }
    }
  ]
}
```
The `aws:MultiFactorAuthPresent` condition checks if MFA was part of the login session. If false, it blocks everything except the IAM steps required to set up MFA.
</details>

<details>
<summary><b>Q110: Scenario: S3 Bucket Policies vs IAM Identity-based Policies: When should you use a S3 Bucket Policy instead of an IAM policy to secure bucket contents?</b></summary>
<b>Answer:</b>
- **Use S3 Bucket Policies (Resource-based) when:**
  1. **Cross-Account Access:** You need to grant access to users in other AWS accounts without requiring them to assume a role.
  2. **Anonymity/Public Access:** You want to make objects publicly readable (e.g. hosting a static website).
  3. **Strict Ingress Filtering:** You want to enforce network constraints (e.g. only allow traffic originating from a specific VPC Endpoint or corporate IP CIDR block).
- **Use IAM Policies (Identity-based) when:**
  1. You want to manage permissions from a user-centric perspective (e.g., managing what "Developer Alice" can do across S3, EC2, and RDS).
  2. You hit the S3 bucket policy size limit (20 KB).
</details>

---

## Week 11: AWS Compute and Storage

This document compiles **10 advanced, scenario-based interview questions and answers** on EC2, EBS, EFS, Load Balancers, and launch templates.

<details>
<summary><b>Q111: Scenario: You run a stateless web application that experiences highly predictable traffic during business hours, but also gets brief, unpredictable surges. How do you design a cost-optimized EC2 hosting strategy using Spot Instances, On-Demand, and Savings Plans?</b></summary>
<b>Answer:</b>
1. **Baseline Load (Savings Plans):** Determine the absolute minimum compute required to run 24/7. Purchase an **EC2 Instance Savings Plan** or **Compute Savings Plan** to cover this baseline capacity, offering up to 72% discounts compared to On-Demand rates.
2. **Predictable Growth (Auto Scaling with On-Demand):** Use Auto Scaling Groups (ASG) to handle normal business hours traffic.
3. **Surges & Cost Optimization (Spot Instances in ASG):** Configure the ASG using a **Mixed Instances Policy**:
   - Set the baseline to run on On-Demand/Savings Plans (to guarantee uptime for core services).
   - Configure the scale-out capacity to allocate up to 70% Spot Instances.
   - Use Spot Instance allocation strategies like **capacity-optimized** to minimize the probability of Spot interruptions, and implement graceful termination handling by listening for the 2-minute Spot Interruption Notice via Amazon EventBridge.
</details>

<details>
<summary><b>Q112: Scenario: Your database is running on an EC2 instance with a `gp2` EBS volume. It is starting to run out of storage space, and latency has spiked due to disk IOPS exhaustion. How do you resolve this with zero downtime?</b></summary>
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
<summary><b>Q113: Scenario: You have an encrypted EBS snapshot in AWS Account A that you want to share with AWS Account B. How do you share it securely, and how do you launch a volume from it in Account B?</b></summary>
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
<summary><b>Q114: Scenario: You are deploying a high-availability WordPress site across three Availability Zones. The web servers need concurrent read-write access to a shared directory (`/var/www/html/uploads`) to store user-uploaded media. Do you use EBS or EFS, and how do you configure it?</b></summary>
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
<summary><b>Q115: Scenario: Under what technical conditions would you choose a Network Load Balancer (NLB) over an Application Load Balancer (ALB)?</b></summary>
<b>Answer:</b>
Choose a **Network Load Balancer (NLB)** when:
1. **Extreme Performance:** The workload must handle millions of requests per second with ultra-low latency (single-digit milliseconds), whereas ALB is slower due to layer 7 request parsing.
2. **Static/Elastic IP Allocation:** You require the load balancer to present a single static IP address (or Elastic IP) per Availability Zone. ALB only provides DNS names, and its underlying IPs change dynamically.
3. **Layer 4 Protocols:** You need to load balance non-HTTP/HTTPS traffic (raw TCP, UDP, TLS, or WebSockets).
4. **Source IP Preservation:** You require the client's original source IP and port to be preserved at the TCP packet level without relying on HTTP headers (like `X-Forwarded-For`).
</details>

<details>
<summary><b>Q116: Scenario: You have an Application Load Balancer hosting multiple microservices. You want to direct traffic to different target groups depending on the URL path: `/api/users/*` goes to the Users Service, and `/api/products/*` goes to the Products Service. How do you configure this on the ALB?</b></summary>
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
<summary><b>Q117: Scenario: You launched an EC2 instance with a complex User Data shell script to install and launch your app. However, when the instance boots up, the application is not running. How do you troubleshoot this?</b></summary>
<b>Answer:</b>
1. **Check execution logs:** Log in to the instance via SSH or Systems Manager Session Manager, and view the cloud-init logs:
   - `/var/log/cloud-init.log` (logs the high-level stages of instance initialization).
   - `/var/log/cloud-init-output.log` (captures the raw stdout/stderr output of your User Data script).
2. **Verify run frequency:** Remember that User Data scripts **only execute once** by default during the first boot cycle. If the instance was restarted, the script will not run again unless configured using cloud-init mime multipart configs.
3. **Check permissions:** Ensure the script starts with a valid shebang (e.g., `#!/bin/bash`). If it lacks a shebang, the OS will not execute it.
4. **Common issue (non-interactive blocks):** Ensure there are no prompts in the script (like `apt-get install` without the `-y` flag) that block the script indefinitely waiting for terminal input.
</details>

<details>
<summary><b>Q118: Scenario: You are hosting three distinct web applications with three separate domains (`app1.domain.com`, `app2.domain.com`, `app3.domain.com`) on a single EC2 instance fleet behind a single Application Load Balancer. How do you implement this cost-effectively?</b></summary>
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
<summary><b>Q119: Scenario: Your ALB target group shows that all EC2 instances are in an "Unhealthy" state, and users are getting 502 Bad Gateway errors. However, you can access the application fine when calling it on localhost inside the EC2 instance. What is wrong?</b></summary>
<b>Answer:</b>
This is a common configuration mismatch. Check the following:
1. **Security Groups:** Verify that the Security Group attached to the EC2 instances has an inbound rule permitting TCP traffic on the application port (e.g., 80 or 8080) originating from the **Security Group of the ALB**.
2. **Port/Protocol Mismatch:** Check that the ALB Target Group is configured with the correct protocol and port that your web server is listening on.
3. **Health Check Path:** Ensure the health check path (e.g., `/healthz` or `/`) exists, returns a `200 OK` status, and does not require authentication.
4. **Host Binding:** Ensure your application server is bound to `0.0.0.0` (all network interfaces) and not hardcoded to `127.0.0.1` (localhost), which prevents the load balancer's private IP from reaching the socket.
</details>

<details>
<summary><b>Q120: Scenario: What is the difference between a Launch Configuration and a Launch Template in AWS Auto Scaling? Why does AWS recommend migrating to Launch Templates?</b></summary>
<b>Answer:</b>
- **Launch Configurations:** Legacy templates. They are immutable (cannot be modified after creation; you must create a new one for changes) and do not support newer AWS features.
- **Launch Templates:** Modern replacements. 
  - **Why migrate to Launch Templates:**
    1. **Versioning:** Launch templates support versions, allowing you to roll back changes or track alterations.
    2. **Advanced Features:** Required to use newer features like T3 Unlimited instances, Spot Instance allocation strategies, mixed instances policies (combining Spot and On-Demand in one ASG), and Capacity Reservations.
    3. **Metadata Options:** Enforce IMDSv2 configurations globally at template level.
</details>

---

## Week 12: AWS Databases and Services

This document compiles **10 advanced, scenario-based interview questions and answers** on RDS, Aurora, ElastiCache, S3, Route 53, and Auto Scaling scaling logic.

<details>
<summary><b>Q121: Scenario: You have a MySQL database on RDS experiencing severe performance degradation due to a surge in read queries. Additionally, you need to ensure the database can survive an Availability Zone outage with zero data loss. What is your architectural solution?</b></summary>
<b>Answer:</b>
Implement **RDS Multi-AZ** for disaster recovery and deploy **Read Replicas** for read scaling:
1. **Disaster Recovery (Multi-AZ):** Enable Multi-AZ. AWS will provision a standby database instance in a different Availability Zone and perform **synchronous replication** from the primary database. If the primary AZ goes down, RDS performs automatic DNS failover to the standby instance with zero data loss (RPO = 0, RTO = minutes).
2. **Read Performance (Read Replicas):** Create one or more Read Replicas. RDS uses **asynchronous replication** to update them. Point read traffic in your application configuration to the Read Replica endpoints, offloading read IOPS from the primary database. Read Replicas can also cross regions if global read access is required.
</details>

<details>
<summary><b>Q122: Scenario: Your application uses AWS Lambda functions that scale rapidly to handle surges. Each Lambda function opens a new database connection to RDS. During spikes, the database crashes because it runs out of connection slots. How do you resolve this?</b></summary>
<b>Answer:</b>
Implement **Amazon RDS Proxy**:
1. **Connection Pooling:** RDS Proxy is a fully managed database proxy that pools and shares established database connections. Instead of each Lambda instance opening a new database connection, they connect to the RDS Proxy.
2. **Pinning Mitigation:** RDS Proxy multiplexes connection requests, reducing database connection overhead by up to 90%.
3. **Failover Efficiency:** If an RDS failover occurs, RDS Proxy maintains active connections from the application and automatically routes queries to the new primary instance, reducing database failover times by up to 66%.
</details>

<details>
<summary><b>Q123: Scenario: You are hosting a static web application in S3. The security team demands that all uploaded files must be encrypted at rest, and that objects must be protected from accidental deletion or ransomware modification for a regulatory period of 7 years. How do you implement this?</b></summary>
<b>Answer:</b>
1. **Encryption at Rest:** Enforce Default Bucket Encryption using SSE-KMS (Server-Side Encryption with AWS KMS customer-managed keys) and attach a bucket policy that denies any `s3:PutObject` request that doesn't include header `"x-amz-server-side-encryption": "aws:kms"`.
2. **Delete/Modification Protection (WORM):**
   - Enable **S3 Versioning** on the bucket.
   - Enable **S3 Object Lock** in **Compliance Mode** (not Governance Mode) with a default retention period of 7 years.
   - *Why Compliance Mode:* Under compliance mode, the retention period cannot be bypassed, shortened, or overridden by any user, including the root user. This prevents ransomware from deleting old versions or overwriting objects.
</details>

<details>
<summary><b>Q124: Scenario: You run a video hosting platform where users upload raw video files (sizes up to 5 GB). Processing these uploads on your EC2 backend servers saturates network bandwidth and exhausts compute. How do you architect a solution where users upload directly to S3 securely?</b></summary>
<b>Answer:</b>
Use S3 **Pre-signed URLs** with **Multipart Uploads**:
1. **Authorization:** The client browser requests an upload token from your backend API.
2. **Generate URL:** The backend validates the user's session, calls the S3 API (`generate_presigned_url` or `CreateMultipartUpload`), and returns a temporary pre-signed URL containing authorization signatures valid for a short window (e.g. 15 minutes).
3. **Direct Upload:** The client browser uploads the file directly to the generated S3 endpoint using an HTTP PUT request. This bypasses your backend application servers, saving network bandwidth and EC2 compute resources.
4. **Multipart:** For files larger than 100 MB, the client uses S3 Multipart Upload APIs via pre-signed URLs to upload chunks in parallel and calls `CompleteMultipartUpload` to merge them at the end.
</details>

<details>
<summary><b>Q125: Scenario: You have a database cache in ElastiCache Redis. During traffic spikes, the database experiences "Cache Stampede" (cache missing triggers massive concurrent database reads). How do you configure and design the cache to prevent this?</b></summary>
<b>Answer:</b>
1. **Cache Warming / Pre-populating:** Pre-warm the cache during deployment or low-traffic periods before launching campaigns.
2. **Locking (Mutex):** Implement distributed locks in the application logic using Redis (e.g. Redlock). If a cache miss occurs, only the first application worker acquires the lock to query the database and update the cache; other workers wait or back off, preventing database saturation.
3. **Background Invalidation / Soft Expiration:** Set a logical TTL in the object metadata that is shorter than the physical Redis TTL. When an application thread reads an object near its logical expiration, it asynchronously triggers a background job to update the database cache while serving the slightly stale cached value to current users.
</details>

<details>
<summary><b>Q126: Scenario: You need to set up a multi-region active-passive disaster recovery site. If the primary region (us-east-1) goes down, traffic must fail over automatically to the secondary region (us-west-2). How do you configure Route 53 to handle this?</b></summary>
<b>Answer:</b>
Use **Route 53 Failover Routing Policy with Health Checks**:
1. **Configure Health Checks:** Create a Route 53 Health Check pointing to the primary region's Application Load Balancer endpoint. Configure it to query a health endpoint `/healthz` and set failure thresholds (e.g., 3 consecutive failures).
2. **DNS Records:** Create two records for the same domain name (e.g., `app.domain.com`):
   - **Primary Record:** Routing Policy: **Failover**, Record Type: **Alias** pointing to `us-east-1` ALB, Associate with Health Check: Yes, Failover Record Type: **Primary**.
   - **Secondary Record:** Routing Policy: **Failover**, Record Type: **Alias** pointing to `us-west-2` ALB, Failover Record Type: **Secondary**.
3. **TTL Adjustment:** If using non-alias records, ensure the TTL is set low (e.g., 60 seconds) to ensure recursive DNS servers purge the cached primary record and query Route 53 for the secondary IP quickly during failover.
</details>

<details>
<summary><b>Q127: Scenario: Your S3 bucket accumulates millions of build logs daily. Storage costs are growing rapidly. How do you implement a tiering strategy to minimize cost while retaining logs for 1 year for audits?</b></summary>
<b>Answer:</b>
Create an **S3 Lifecycle Policy** with the following transitions:
1. **0–30 Days:** Keep in **S3 Standard** (logs are actively accessed by developers for troubleshooting).
2. **Day 30:** Transition to **S3 Standard-IA (Infrequent Access)**. (Cheaper storage cost, but incurs retrieval fees).
3. **Day 90:** Transition to **Amazon S3 Glacier Flexible Retrieval** (for audit compliance, retrieval takes minutes to hours, storage cost drops significantly).
4. **Day 365:** Permanently delete the objects.
5. **Additional rule:** Enable a rule to **AbortIncompleteMultipartUpload** after 7 days. This automatically purges fragments of failed uploads that otherwise incur persistent storage charges.
</details>

<details>
<summary><b>Q128: Scenario: You want to route users to the fastest environment. If a user is in Europe, they should be directed to the Frankfurt region. If they are in Asia, they should go to Singapore. How do you configure Route 53, and what happens if a region goes down?</b></summary>
<b>Answer:</b>
1. **Routing Policy:** Use **Route 53 Latency-Based Routing** or **Geolocation Routing**:
   - *Latency-Based:* Route 53 measures network latency from the client's network to AWS regions and automatically returns the IP of the region with the lowest latency.
   - *Geolocation:* Explicitly maps geographic locations (e.g. Continent: Europe) to specific endpoints.
2. **Health Checks Integration:** Associate Route 53 health checks with each regional record.
3. **Failover behavior:** If the Frankfurt region is marked unhealthy by the health checks, Route 53 will bypass that record and route European users to the next best active region (e.g. London or N. Virginia) based on latency profiles.
</details>

<details>
<summary><b>Q129: Scenario: In Auto Scaling Groups, how does Target Tracking Scaling differ from Step Scaling? In what scenarios would you choose one over the other?</b></summary>
<b>Answer:</b>
- **Target Tracking Scaling:** You choose a metric (e.g., Average CPU Utilization) and set a target value (e.g., 60%). Auto Scaling automatically creates CloudWatch alarms and adjust instance counts to keep the metric near the target.
  - *When to use:* For standard workloads where traffic scales linearly and metrics change smoothly.
- **Step Scaling:** You define specific scaling steps based on alarm thresholds. (e.g., If CPU is 50-70%, add 1 instance; if CPU is >70%, add 4 instances).
  - *When to use:* For workloads with steep, sudden spikes where target tracking might not scale out fast enough. Step scaling allows you to trigger aggressive scaling actions immediately.
</details>

<details>
<summary><b>Q130: Scenario: You have a global app where European users access data stored in a central RDS database in the US, causing slow page loads. How does Amazon Aurora Global Databases solve this latency, and how does failover work?</b></summary>
<b>Answer:</b>
- **Aurora Global Database Architecture:** Aurora provisions a primary database cluster in one region and replicates data to up to 5 secondary read-only clusters in other regions. It uses dedicated storage-level transport infrastructure, achieving replication lags of less than 1 second.
- **Solving Latency:** European users are pointed to the local Aurora Reader endpoint in the EU region, serving reads with sub-millisecond latencies.
- **Failover (Promoting secondary):** If the primary US region suffers an outage:
  1. You can perform a **planned failover** (with no data loss) or an **unplanned failover** (promoting one of the secondary read-only regional clusters to be the new primary master write cluster).
  2. The promoted cluster immediately begins accepting write queries, and you update your application configuration to point to the new regional writer.
</details>

---

## Week 13: AWS Messaging and Containers

This document compiles **10 advanced, scenario-based interview questions and answers** on SQS, SNS, ECS Fargate, ECR, CloudFront, Global Accelerator, and Hybrid Storage.

<details>
<summary><b>Q131: Scenario: You are building an e-commerce checkout system where payments must be processed exactly once and in the precise order they were placed. How do you implement this using AWS SQS?</b></summary>
<b>Answer:</b>
Use an **SQS FIFO (First-In-First-Out) Queue**:
1. **Ordering:** SQS FIFO queues guarantee that messages are processed in the exact order they are sent (using a Message Group ID).
2. **Exactly-Once Processing:** Enable **Message Deduplication**:
   - You can provide a **Message Deduplication ID** (e.g., a hash of the transaction ID) or enable **Content-Based Deduplication** (where SQS hashes the message body).
   - If a duplicate message is sent within the 5-minute deduplication window, SQS accepts it but does not deliver it to the consumer, avoiding duplicate payments.
3. **Message Grouping:** Set the `MessageGroupId` parameter. Messages within the same group are processed sequentially, allowing you to parallelize processing across different users (different groups) while keeping order within a single user session.
</details>

<details>
<summary><b>Q132: Scenario: Your backend consumers are reading from an SQS queue. A few "poison pill" messages are malformed, causing the consumer to crash and restart every time it reads them. These messages return to the queue, creating an infinite processing loop. How do you prevent this?</b></summary>
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
<summary><b>Q133: Scenario: When an order is placed, three downstream services need to receive the event: Billing, Inventory, and Shipping. Additionally, the Shipping service only cares about orders destined for the United States. How do you architect this efficiently?</b></summary>
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
<summary><b>Q134: Scenario: You need to deploy a Docker containerized microservice on AWS ECS. Under what conditions would you choose the AWS Fargate launch type over hosting the container fleet on EC2?</b></summary>
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
<summary><b>Q135: Scenario: An application running inside an ECS Fargate task needs to retrieve a configuration file from an S3 bucket. However, when the container starts, it exits with an "Access Denied" error when calling the S3 API. How do you troubleshoot this, and what ECS roles are involved?</b></summary>
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
<summary><b>Q136: Scenario: You deployed an updated frontend bundle to your S3 bucket, but users globally still see the old webpage when hitting your CloudFront domain. How do you resolve this immediately, and what is the best practice for future deployments?</b></summary>
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
<summary><b>Q137: Scenario: You are designing a global real-time multiplayer gaming backend that communicates via UDP. How do you optimize latency and route users to the nearest game server globally? Do you use CloudFront or AWS Global Accelerator?</b></summary>
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
<summary><b>Q138: Scenario: Your company has 150 TB of local database backup files on-premises that must be migrated to AWS S3. Your corporate network connection is a shared 50 Mbps broadband line. How do you migrate this data?</b></summary>
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
<summary><b>Q139: Scenario: You have legacy Windows file share applications on-premises that need access to cloud storage. You need a solution that caches active files locally for low latency but offloads cold data to S3. What storage service do you choose?</b></summary>
<b>Answer:</b>
Use **AWS Storage Gateway (File Gateway / Amazon S3 File Gateway)**:
1. **Deployment:** Deploy the Storage Gateway virtual appliance on-premises (on VMware ESXi or Hyper-V).
2. **Access Protocol:** Expose the file share using the SMB (Server Message Block) protocol for Windows clients.
3. **Caching & S3 sync:** The gateway caches frequently accessed files locally on its local VM disk, providing low-latency access to the local office.
4. **Offloading:** It asynchronously syncs all files and directories directly to an S3 bucket in your AWS account, translating SMB directory structures to S3 object keys.
</details>

<details>
<summary><b>Q140: Scenario: Your production Docker containers in ECR have been flagged by the security team as having critical CVE vulnerabilities. How do you automate vulnerability scanning and prevent these images from being deployed?</b></summary>
<b>Answer:</b>
1. **ECR Image Scanning:** Configure ECR repositories to enable **"Scan on Push"**. This automatically runs a vulnerability scan using Amazon Inspector whenever a new image is pushed.
2. **Vulnerability Alerting:** Use Amazon EventBridge to listen for ECR scan completion events. Route critical findings to an SNS Topic to alert the security team.
3. **CI/CD Pipeline Gate:** In your Jenkins pipeline, after pushing the image to ECR, run a CLI command to poll the ECR scan status and fail the build if any "CRITICAL" vulnerabilities are detected:
   ```bash
   aws ecr describe-image-scan-findings --repository-name my-app --image-id imageTag=latest --query 'imageScanFindings.findings[?severity==`CRITICAL`]'
   ```
4. **Tag Immutability:** Enable **Tag Immutability** in ECR. This prevents developers from overwriting tags (like `prod` or `latest`) with un-scanned or modified images.
</details>

---

## Week 14: Serverless Architecture

This document compiles **10 advanced, scenario-based interview questions and answers** on AWS Lambda, API Gateway, DynamoDB, Cognito, and edge scripting.

<details>
<summary><b>Q141: Scenario: You have a Java-based Lambda function behind API Gateway that experiences significant latency spikes (up to 5 seconds) when it is first invoked or after a period of inactivity. How do you troubleshoot and mitigate this cold start issue?</b></summary>
<b>Answer:</b>
This is caused by **Lambda Cold Starts** (the time AWS takes to provision the execution environment, download the code, and initialize the runtime/JVM).
- **Mitigation Strategies:**
  1. **Provisioned Concurrency:** Pre-warms a specified number of execution environments, keeping them ready to respond instantly. This completely eliminates cold starts but incurs a persistent cost.
  2. **AWS Lambda SnapStart:** For Java (specifically Java 11/17/21 runtimes), enable SnapStart. AWS initializes the function during deployment, takes a snapshot of the encrypted firecracker VM state, and caches it. On invocation, it restores the VM state from the snapshot, reducing cold starts to sub-second levels at no extra cost.
  3. **Runtime Choice:** Use lightweight runtimes (Node.js, Python, Go, Rust) if possible, which have significantly faster startup times compared to Java/JVM.
  4. **Code Optimization:** Minimize package size, reduce framework usage (e.g., avoid full Spring Boot, use Spring Cloud Function or Quarkus/Micronaut), and instantiate database clients outside the handler method so they are cached across warm invocations.
</details>

<details>
<summary><b>Q142: Scenario: Your Lambda function processes files from an S3 bucket. You notice that when processing large files, it runs out of memory and crashes. When you increase the memory from 128 MB to 3008 MB, the file is processed 10x faster, and the overall execution cost decreases. Why does this happen?</b></summary>
<b>Answer:</b>
AWS allocates **CPU power proportionally to the memory provisioned** for a Lambda function:
1. **CPU Scaling:** At 1,769 MB of memory, a Lambda function is allocated exactly 1 full vCPU. Below this, it gets a fraction of a vCPU; above this, it gets multiple vCPUs (up to 10 GB memory / 6 vCPUs).
2. **Performance Boost:** By increasing memory from 128 MB to 3008 MB, the function is allocated full vCPU processing cores. Compute-bound tasks (like processing/parsing files) execute significantly faster.
3. **Cost Efficiency:** Lambda is billed based on GB-seconds (memory allocated * execution duration). If an increase in memory reduces the execution time by a larger factor than the memory increase, the overall cost of the run is actually lower.
4. **Optimization:** Use **AWS Lambda Power Tuning** (an open-source state machine tool) to run your function at different memory levels, automatically plotting a chart to find the sweet spot between cost and execution speed.
</details>

<details>
<summary><b>Q143: Scenario: What is the difference between an API Gateway Lambda Proxy Integration and a Lambda Custom (Non-Proxy) Integration? When would you use one over the other?</b></summary>
<b>Answer:</b>
- **Lambda Proxy Integration (Recommended):**
  - *Mechanism:* API Gateway passes the raw HTTP request (headers, query parameters, path variables, request context, and body) directly to the Lambda function as a single JSON object. The Lambda function must format its output exactly in JSON (containing `statusCode`, `headers`, and `body`).
  - *When to use:* Standard setups where the backend code handles all routing, request validation, and response construction.
- **Lambda Custom Integration:**
  - *Mechanism:* You write **VTL (Velocity Template Language) Mapping Templates** in API Gateway to transform the incoming request body/parameters before passing it to Lambda. You also define response mappings to transform Lambda outputs into HTTP codes.
  - *When to use:* Legacy integrations where you want to expose a REST API but keep the Lambda function input clean of HTTP metadata, or when you are integrating API Gateway directly with other AWS services (like S3 or DynamoDB) without using a Lambda function at all.
</details>

<details>
<summary><b>Q144: Scenario: You need to implement user authentication and authorize authenticated users to upload files directly to an S3 bucket. How do you integrate AWS Cognito User Pools and Identity Pools to accomplish this?</b></summary>
<b>Answer:</b>
Use the combination of **Cognito User Pools** and **Cognito Identity Pools (Federated Identities)**:
1. **Authentication (User Pools):**
   - The user registers and logs in via Cognito User Pools.
   - Cognito User Pools validates the credentials and returns a set of JWT tokens (ID Token, Access Token, Refresh Token) to the client.
2. **Authorization (Identity Pools):**
   - The client takes the JWT ID Token and sends a request to **Cognito Identity Pools** (`AssumeRoleWithWebIdentity`).
   - Cognito Identity Pools validates the token, maps the user to an IAM role (e.g. `Cognito_Authorized_User_S3_Upload_Role`), and issues temporary, short-lived AWS IAM Credentials (Access Key, Secret Key, Session Token) to the client.
3. **S3 Upload:**
   - The client browser uses these temporary IAM credentials directly to call the S3 `PutObject` API to upload the file to S3.
</details>

<details>
<summary><b>Q145: Scenario: You are designing a database schema in DynamoDB for an order-tracking application. A customer has many orders, and you need to query: (a) All orders for a specific customer, and (b) A specific order by its unique Order ID. How do you design this using DynamoDB keys?</b></summary>
<b>Answer:</b>
Use a **Single-Table Design** with composite primary keys (Partition Key `PK` and Sort Key `SK`):
1. **Entities mapping:**
   - **Customer Record:** `PK` = `CUSTOMER#<CustomerID>`, `SK` = `METADATA#<CustomerID>` (stores customer profile info).
   - **Order Record:** `PK` = `CUSTOMER#<CustomerID>`, `SK` = `ORDER#<OrderID>` (stores order details).
2. **Querying Patterns:**
   - **Query (a) All orders for a specific customer:** Run a `Query` operation where `PK = CUSTOMER#<CustomerID>` and `SK begins_with("ORDER#")`. This retrieves all order records for that customer in a single round-trip.
   - **Query (b) A specific order by Order ID:** If you only have `OrderID` and not `CustomerID`, searching using the partition key above is not possible. You must create a **Global Secondary Index (GSI)** where the GSI Partition Key `GSI1PK` is `ORDER#<OrderID>` and `GSI1SK` is `ORDER#<OrderID>`. Querying this GSI retrieves the order details instantly.
</details>

<details>
<summary><b>Q146: Scenario: What is the difference between a Local Secondary Index (LSI) and a Global Secondary Index (GSI) in DynamoDB? How do they affect write throughput capacity (WCU) and database scale?</b></summary>
<b>Answer:</b>
- **Local Secondary Index (LSI):**
  - Must share the **same Partition Key** as the base table, but has a **different Sort Key**.
  - Must be created during **table creation time** (cannot be added later).
  - Uses the **WCU/RCU capacity of the parent table**.
  - Limits the total size of items with the same partition key to **10 GB** (item collection limit).
- **Global Secondary Index (GSI):**
  - Can have a **different Partition Key and different Sort Key** than the base table.
  - Can be created or deleted **at any time**.
  - Has its **own provisioned throughput (WCU/RCU)**.
  - Has no size limit; it can scale infinitely across partitions.
- **WCU Impact:** When you write to a table with an LSI or GSI, DynamoDB automatically updates the index. For GSIs, if the index has insufficient WCUs, writes to the base table will be **throttled** (Backpressure), so index capacity must be scaled to match the write rate of the parent table.
</details>

<details>
<summary><b>Q147: Scenario: Every time a customer updates their email address in DynamoDB, you need to automatically update a third-party CRM system and send a confirmation email. How do you implement this asynchronously?</b></summary>
<b>Answer:</b>
Use **DynamoDB Streams** integrated with **AWS Lambda**:
1. **Enable Streams:** Enable DynamoDB Streams on the base table. Choose the stream view type: `NEW_AND_OLD_IMAGES` (so you can compare what changed).
2. **Lambda Trigger:** Create an AWS Lambda function and configure the DynamoDB Stream as its event source.
3. **Asynchronous Execution:** 
   - When a row updates, DynamoDB writes a change log record to the stream.
   - The AWS Lambda service polls the stream and invokes the function with a batch of stream records.
   - The Lambda function checks the record: if the email changed (`oldImage.email != newImage.email`), it triggers the API calls to the third-party CRM and invokes Amazon SES (Simple Email Service) to send the confirmation.
   - If the Lambda run fails, it will retry until success or until the records expire in the stream (24-hour retention).
</details>

<details>
<summary><b>Q148: Scenario: You want to rewrite request URLs (e.g. changing `domain.com/docs` to `domain.com/documentation/index.html`) at the edge before sending them to your origin. Would you use Lambda@Edge or CloudFront Functions? Explain your choice.</b></summary>
<b>Answer:</b>
Use **CloudFront Functions** for this scenario.
- **Comparison & Selection:**
  - **CloudFront Functions:** 
    - Optimized for lightweight, sub-millisecond execution (written in JavaScript).
    - Executes at the Edge Location closest to the user.
    - Extremely cost-effective (1/6th the cost of Lambda@Edge).
    - Perfect for header manipulation, URL rewrites, and simple redirects.
  - **Lambda@Edge:**
    - Full Node.js/Python runtimes executing at Regional Edge Caches.
    - Supports network calls, file system access, and larger packages.
    - Incurs higher cold-start times and higher execution cost.
- **Decision:** Since URL rewriting does not require database querying or external API requests, CloudFront Functions is the optimal, lowest-latency, and most cost-effective choice.
</details>

<details>
<summary><b>Q149: Scenario: Under what traffic conditions would you choose DynamoDB On-Demand capacity mode over Provisioned capacity mode?</b></summary>
<b>Answer:</b>
- **Choose On-Demand Capacity Mode when:**
  1. The workload experiences **unpredictable, highly spikey traffic** (e.g. apps that remain idle and suddenly jump to thousands of queries).
  2. You do not want to configure auto-scaling policies or manage capacity parameters.
  3. You are launching a new product where the read/write load profile is completely unknown.
- **Choose Provisioned Capacity Mode (with Auto Scaling) when:**
  1. Traffic is **predictable and consistent**, or fluctuates gradually over time.
  2. You want to control and cap costs to prevent budget overruns during DDoS attacks.
  3. You run a high-volume application where provisioning capacity is cheaper (usually 50-70% savings compared to On-Demand unit costs).
</details>

<details>
<summary><b>Q150: Scenario: Your Serverless application consists of a Lambda function and a DynamoDB table. How do you configure local testing so developers can run and debug the entire stack on their local machines before deploying to AWS?</b></summary>
<b>Answer:</b>
1. **Serverless Offline Plugin:** Install the `serverless-offline` plugin into your `serverless.yml` config. This launches a local Node.js server that emulates API Gateway and runs your Lambda functions locally.
2. **Local DynamoDB:** Use the `serverless-dynamodb-local` plugin or run DynamoDB Local as a Docker container:
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```
3. **Application Configuration:** Update your Lambda function's database client initialization code to check for a local environment flag and point the endpoint to the local container:
   ```javascript
   const docClient = new AWS.DynamoDB.DocumentClient(
     process.env.IS_OFFLINE 
       ? { endpoint: 'http://localhost:8000', region: 'localhost' } 
       : {}
   );
   ```
</details>

---

## Week 15: Infrastructure as Code

This document compiles **10 advanced, scenario-based interview questions and answers** on AWS CloudFormation, StackSets, Nested Stacks, drift management, custom resources, and security constraints.

<details>
<summary><b>Q151: Scenario: You need to deploy a security audit baseline (IAM Roles, Config rules, GuardDuty setup) across 50 AWS Accounts in 4 different regions. Do you use Nested Stacks or StackSets? Explain your choice and implementation flow.</b></summary>
<b>Answer:</b>
Use **AWS CloudFormation StackSets**:
- **Why StackSets:** Nested Stacks are used to modularize templates within a *single* account and region. StackSets allow you to deploy a single CloudFormation template across *multiple* AWS accounts and regions in one operation.
- **Implementation Flow:**
  1. Set up an administrator account (or use AWS Organizations integration).
  2. Write the base security baseline template.
  3. Create a StackSet in the administrator account.
  4. Define target accounts (using account IDs or target Organizational Units [OUs]) and regions (e.g. us-east-1, eu-west-1).
  5. StackSets automatically creates stack instances in the target accounts and executes deployment.
  6. Enable **automatic deployment** so new accounts added to target OUs in the future inherit this stack baseline automatically.
</details>

<details>
<summary><b>Q152: Scenario: A developer manually modified a Security Group rule in the AWS Console. How do you locate this drift using CloudFormation, and how do you remediate it?</b></summary>
<b>Answer:</b>
1. **Detection:**
   - In the CloudFormation console or via CLI, select the stack and run **Drift Detection**:
     ```bash
     aws cloudformation detect-stack-drift --stack-name production-network-stack
     ```
   - CloudFormation compares the live resource configurations with the template's expected properties.
   - Run `describe-stack-resource-drifts` to see the exact properties that changed. It will flag the resource status as `MODIFIED` or `DELETED` and list the exact difference (e.g. manual IP block added).
2. **Remediation:**
   - **Manual Reversion:** Manually change the security group rule back in the console to match the template values.
   - **Template Alignment:** If the change was desired, update the CloudFormation template to match the manual configuration, then run a stack update.
   - *Note:* CloudFormation does not have an automatic "self-heal/revert" button like Kubernetes/GitOps; remediation is a manual restore or template update.
</details>

<details>
<summary><b>Q153: Scenario: You need CloudFormation to perform an action that is not natively supported by a resource provider (for example, executing a SQL database migration script, fetching a security token from a third-party API, or seeding files into an S3 bucket). How do you achieve this?</b></summary>
<b>Answer:</b>
Use a **Lambda-Backed Custom Resource**:
1. **Declare Custom Resource:** Define a resource in the CloudFormation template with type `Custom::MyDatabaseMigration` and specify the ARN of an AWS Lambda function:
   ```yaml
   MyCustomAction:
     Type: "Custom::DatabaseMigration"
     Properties:
       ServiceToken: !GetAtt MigrationLambda.Arn
       DbEndpoint: !Ref DBEndpoint
   ```
2. **Lambda Logic:** When CloudFormation processes this resource, it invokes the Lambda function, passing a request object containing the action type (`Create`, `Update`, or `Delete`) and target properties.
3. **Response Handling:** The Lambda function runs the SQL script, and must send an HTTP PUT request containing `Status: SUCCESS` or `FAILED` to a pre-signed S3 URL generated by CloudFormation. If the Lambda fails to send this response, the stack hangs and fails after a 1-hour timeout.
</details>

<details>
<summary><b>Q154: Scenario: When a CloudFormation stack is deleted, you want to ensure that critical DynamoDB tables and S3 backups are not deleted, while temporary EC2 instances are terminated. How do you configure this?</b></summary>
<b>Answer:</b>
Use the **`DeletionPolicy`** attribute in the resource declarations:
1. **For DynamoDB/S3/RDS:** Set `DeletionPolicy: Retain` on these resources. When the stack is deleted, CloudFormation detaches the resources from the stack but does not delete them, keeping the database and buckets active in your account.
2. **Backup Alternative:** For resources that support it (like RDS databases), you can set `DeletionPolicy: Snapshot`. CloudFormation will create a final database snapshot before deleting the physical instance.
3. **EC2 instances:** Do not specify a DeletionPolicy (or set it to `Delete` which is default), allowing CloudFormation to terminate the instances when the stack is deleted.
```yaml
MyProductionDatabaseTable:
  Type: AWS::DynamoDB::Table
  DeletionPolicy: Retain
  Properties:
    ...
```
</details>

<details>
<summary><b>Q155: Scenario: You want to block developers from deploying CloudFormation templates that violate corporate security standards (such as exposing port 22 to the public, or launching unencrypted EBS volumes). How do you enforce this policy in your CI/CD pipeline?</b></summary>
<b>Answer:</b>
Use **AWS CloudFormation Guard (`cfn-guard`)**:
1. **Define Rules:** Write validation rules using cfn-guard's declarative policy language:
   ```cfn-guard
   # Enforce EBS encryption
   rule check_ebs_encryption {
     AWS::EC2::Volume {
       Properties.Encrypted == true
     }
   }
   ```
2. **Pipeline Integration:** In your Jenkins/GitHub Actions pipeline, before calling the deploy step, run the cfn-guard validation CLI tool against the template:
   ```bash
   cfn-guard validate --rules security_rules.guard --data template.yaml
   ```
3. **Build Gating:** If the check fails (returns non-zero exit code), abort the pipeline, preventing the stack from launching.
</details>

<details>
<summary><b>Q156: Scenario: How do you pass the outputs of one independent CloudFormation stack (e.g. a VPC ID from a networking stack) to another independent stack (e.g. a database stack)? What are the limitations of this method?</b></summary>
<b>Answer:</b>
Use **Export/Import Values**:
1. **Export (VPC Stack):** In the Outputs section of the VPC stack, export the VPC ID:
   ```yaml
   Outputs:
     ExportedVpcId:
       Value: !Ref MyVPC
       Export:
         Name: !Sub "${AWS::StackName}-VpcId"
   ```
2. **Import (DB Stack):** In the database template, use the `Fn::ImportValue` intrinsic function:
   ```yaml
   Properties:
     VpcId: !ImportValue "production-vpc-stack-VpcId"
   ```
3. **Limitations:**
   - **Cross-Region Limitation:** Exports and imports only work within the **same AWS Account and same Region**.
   - **Locking Constraint:** Once a stack imports an exported value, the exporting stack **cannot be deleted or modified** in a way that changes or removes the exported output. You must update all importing stacks to remove the `ImportValue` reference before you can modify the exporter.
</details>

<details>
<summary><b>Q157: Scenario: Your CloudFormation update fails, and the stack gets stuck in the `UPDATE_ROLLBACK_FAILED` state. You cannot delete the stack because it contains resources you must keep, and you cannot update it. How do you resolve this?</b></summary>
<b>Answer:</b>
When a stack is in `UPDATE_ROLLBACK_FAILED`, it means CloudFormation tried to roll back changes, but failed because a resource was modified outside of CloudFormation (drift) or permission was denied.
- **Resolution:**
  1. In the console or via CLI, execute **`ContinueUpdateRollback`**:
     ```bash
     aws cloudformation continue-update-rollback --stack-name my-stuck-stack --resources-to-skip LogicalResourceIdOfFailedResource
     ```
  2. **Resources to Skip:** You must specify the logical ID of the resource(s) that caused the rollback failure. This tells CloudFormation to mark those resources as rolled back and bypass them, continuing the rollback operation.
  3. Once the stack returns to a healthy `UPDATE_ROLLBACK_COMPLETE` or `ROLLBACK_COMPLETE` status, update the template or permissions to fix the underlying issue, or manually sync the bypassed resources.
</details>

<details>
<summary><b>Q158: Scenario: You have a nested stack configuration. What is the difference between a nested stack and a standard cross-stack reference? When should you use nested stacks?</b></summary>
<b>Answer:</b>
- **Nested Stacks (Child Stacks):**
  - Managed under a single **root parent stack**. When you update the parent stack, it automatically updates all child nested stacks.
  - Declared inside the parent template using the `AWS::CloudFormation::Stack` resource type pointing to a template stored in S3.
  - *When to use:* To modularize massive templates (avoiding the 1 MB template size limit), and to build reusable sub-templates (like a standard RDS setup or standard ALB target) that should be lifecycle-managed together with the main stack.
- **Cross-Stack Reference:**
  - Independent stacks with separate lifecycles. They communicate outputs via `Export` and `ImportValue`.
  - *When to use:* When resources have different lifecycles. For example, a VPC stack is deployed once and rarely changed, while application microservices are redeployed daily.
</details>

<details>
<summary><b>Q159: Scenario: How do you prevent users from accidentally deleting or modifying critical production resources (like your master database) during a CloudFormation stack update, even if the users have IAM policies that allow full access?</b></summary>
<b>Answer:</b>
Use a **CloudFormation Stack Policy**:
1. **Stack Policy Definition:** A Stack Policy is a JSON document that defines what update actions can be performed on specific resources. By default, attaching a stack policy protects all resources from updates unless explicitly allowed.
2. **Policy Configuration:**
   ```json
   {
     "Statement": [
       {
         "Effect": "Allow",
         "Action": "Update:*",
         "Principal": "*",
         "Resource": "*"
       },
       {
         "Effect": "Deny",
         "Action": [ "Update:Modify", "Update:Replace", "Update:Delete" ],
         "Principal": "*",
         "Resource": "LogicalResourceId/MyMasterDatabase"
       }
     ]
   }
   ```
3. **Application:** Apply this stack policy to the stack. Even if an IAM user has `AdministratorAccess`, any update command that targets or replaces the database resource will be blocked by CloudFormation.
</details>

<details>
<summary><b>Q160: Scenario: Your CloudFormation stack deletion fails because the stack contains an S3 bucket that still has objects inside it. How do you configure CloudFormation to handle S3 bucket deletions cleanly?</b></summary>
<b>Answer:</b>
CloudFormation cannot delete an S3 bucket that contains files (to prevent data loss); the API request will fail.
- **Solutions:**
  1. **DeletionPolicy:** Set `DeletionPolicy: Retain`. CloudFormation will delete the stack and bypass deleting the bucket, leaving the bucket and its objects intact.
  2. **Custom Lambda Cleaner:** If you want the bucket to be deleted automatically:
     - Write a Lambda-backed custom resource.
     - In the Lambda code, listen for the `Delete` request type.
     - When received, let the Lambda list and delete all versions of all objects inside the S3 bucket using the AWS SDK, then return success.
     - CloudFormation will then proceed to delete the empty S3 bucket successfully.
</details>
