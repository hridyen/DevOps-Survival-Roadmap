# ☁️ Week 10 — Introduction to AWS & Cloud Computing

> **Duration:** Week 10 — Ongoing
> **Status:** 🟡 In Progress
> **Goal:** Understand what cloud computing is, how AWS is structured globally, and how security responsibilities are divided between AWS and the customer.

---

## 📌 Why Cloud Computing in DevOps?

Everything we built so far — Jenkins, Docker, pipelines — needs somewhere to **run in production**. That "somewhere" is the cloud.

As a DevOps engineer, the cloud is not optional. It is your production environment. AWS is the most widely used cloud provider in the industry, holding over 30% of the global cloud market.

```
Local Machine (Dev)  →  Docker / Jenkins (CI/CD)  →  AWS (Production)
     Your laptop            Your pipeline               The real world
```

---

## 📚 Section 1 — What is Cloud Computing?

### Simple Definition

Cloud computing is the **on-demand delivery** of IT resources — servers, storage, databases, networking, software — over the internet, with **pay-as-you-go pricing**.

Before cloud computing, if you needed a server:
1. Buy physical hardware (weeks to arrive, thousands of dollars)
2. Set it up in a data center
3. Pay for it whether you use it or not
4. Upgrade manually when you needed more capacity

With cloud computing:
1. Go to AWS console
2. Click "Launch Instance"
3. Server is ready in 60 seconds
4. Pay only for the hours you use it

---

### The Three Deployment Models

| Model | What It Means | Who Uses It | Example |
|---|---|---|---|
| **Private Cloud** | Your own cloud, only for your organization | Banks, Governments, Healthcare | OpenStack on your own data center |
| **Public Cloud** | Cloud owned by a provider, shared infrastructure | Startups, most companies | AWS, Azure, Google Cloud |
| **Hybrid Cloud** | Mix of private + public cloud | Enterprises with compliance needs | On-prem database + AWS for compute |

> 💡 **For DevOps work, Public Cloud (AWS) is the most common setup.** Most companies start here because it requires zero infrastructure investment.

---

### The Five Characteristics of Cloud Computing

These are the official NIST definitions — important for interviews and certifications:

| # | Characteristic | What It Means in Practice |
|---|---|---|
| 1 | **On-demand self-service** | Spin up a server at 2am without calling anyone |
| 2 | **Broad network access** | Access your servers from anywhere via internet |
| 3 | **Resource pooling** | AWS's hardware serves thousands of customers simultaneously (multi-tenant) |
| 4 | **Rapid elasticity** | Scale from 1 server to 100 in minutes, scale back when done |
| 5 | **Measured service** | Every byte, every CPU hour is tracked and billed — you see exactly what you pay for |

---

### Six Advantages of Cloud Computing

| Advantage | Traditional IT Problem | Cloud Solution |
|---|---|---|
| **Trade capital for operating expense** | Buy servers upfront (huge cost) | Pay monthly only for what you use |
| **Benefit from economies of scale** | You buy 1 server at retail price | AWS buys millions of servers — passes savings to you |
| **Stop guessing capacity** | Buy too much → waste money. Buy too little → downtime | Scale up/down on demand |
| **Increase speed and agility** | New server takes weeks | New server takes 60 seconds |
| **Stop spending on data centers** | Pay rent, power, security, cooling | AWS handles all of that |
| **Go global in minutes** | Opening in a new country = new data center | Deploy to AWS Asia region in minutes |

---

### Problems the Cloud Solves

```
Traditional IT Pain Points          Cloud Solution
────────────────────────────────    ────────────────────────────────
High upfront hardware costs      →  Pay-as-you-go, no upfront cost
Can't scale quickly              →  Auto Scaling — done in seconds
Hardware fails unexpectedly      →  Multi-AZ redundancy built in
Limited to one geography         →  33+ AWS Regions worldwide
Slow to provision new resources  →  API/Console — ready in minutes
High maintenance overhead        →  AWS manages physical infrastructure
```

---

## 📚 Section 2 — Types of Cloud Computing (IaaS, PaaS, SaaS)

This is one of the most important concepts for interviews. Think of it as a spectrum of **how much control you have vs how much AWS manages for you**.

```
You manage everything ◄──────────────────────────► AWS manages everything
        │                    │                              │
      IaaS                 PaaS                           SaaS
  (Infrastructure)       (Platform)                    (Software)
   AWS EC2             Elastic Beanstalk              AWS Chime / Gmail
```

### Detailed Comparison

| | **IaaS** | **PaaS** | **SaaS** |
|---|---|---|---|
| **Full name** | Infrastructure as a Service | Platform as a Service | Software as a Service |
| **What AWS provides** | Virtual machines, storage, networking | Runtime, OS, middleware, database | Complete application |
| **What YOU manage** | OS, runtime, app, data | Application code + data | Just use the software |
| **Control level** | Maximum | Medium | Minimum |
| **AWS example** | EC2, EBS, VPC | Elastic Beanstalk, RDS | Chime, WorkMail |
| **Other examples** | Azure VMs, GCP Compute, DigitalOcean | Heroku, Google App Engine | Gmail, Dropbox, Zoom |
| **Best for** | DevOps engineers who need full control | Developers who just want to deploy code | End users who need software |

> 💡 **As a DevOps engineer, you will mostly work with IaaS** — EC2, VPC, S3, EBS — because you need full control over the infrastructure.

---

### Real-World Analogy

Think of it like a restaurant:

| Model | Analogy |
|---|---|
| **On-premise (no cloud)** | You buy land, build a kitchen, buy all equipment, hire chefs |
| **IaaS** | You rent a commercial kitchen — building and equipment provided, you bring ingredients and cook |
| **PaaS** | You rent a kitchen with chefs — you just bring the recipe |
| **SaaS** | You go to a restaurant — you just eat, someone else does everything |

---

## 📚 Section 3 — AWS Cloud Pricing

AWS pricing is based on three fundamentals — **pay only for what you use**:

| Pricing Dimension | What You Pay For | Example |
|---|---|---|
| **Compute** | Time your servers are running | EC2 instance running for 5 hours = pay for 5 hours |
| **Storage** | Amount of data you store | 100 GB in S3 for a month = pay for 100 GB/month |
| **Data Transfer OUT** | Data leaving AWS to internet | Sending 10 GB to users = pay for 10 GB outbound |

> 💡 **Important:** Data transfer **INTO** AWS is **FREE**. You only pay for data going **OUT**.

### How This Solves Traditional IT Problems

```
Old Way:                              AWS Way:
────────                              ────────
Buy a server for $10,000         →   Pay $0.10/hour for EC2
Pay whether used or not          →   Stop it = stop paying
Need more capacity → buy more    →   Click "scale" → done in seconds
Underutilize hardware → waste    →   Scale down when traffic drops
```

---

## 📚 Section 4 — AWS Cloud Use Cases

As a DevOps engineer, you will encounter all of these:

| Use Case | What It Means | AWS Services Used |
|---|---|---|
| **Web Hosting** | Host websites that scale automatically | EC2, ELB, Auto Scaling, S3 |
| **Big Data Analytics** | Process massive datasets | EMR, Redshift, Athena |
| **Application Hosting** | Deploy and run applications | EC2, ECS, Lambda, Elastic Beanstalk |
| **Disaster Recovery** | Backup and restore business systems | S3, Glacier, Route 53 |
| **Backup and Storage** | Durable, secure storage | S3, EBS, EFS |

---

## 📚 Section 5 — AWS Global Infrastructure

Understanding how AWS is physically built helps you make better architecture decisions.

### The Three Layers of AWS Infrastructure

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS REGIONS                          │
│  (e.g., us-east-1, ap-south-1, eu-west-1)                   │
│                                                             │
│   ┌──────────────────────────────────────────────────┐      │
│   │           AVAILABILITY ZONES (AZs)               │      │
│   │  (e.g., us-east-1a, us-east-1b, us-east-1c)      │      │ 
│   │                                                  │      │
│   │   ┌──────────┐  ┌──────────┐  ┌──────────┐       │      │
│   │   │Data      │  │Data      │  │Data      │       │      │
│   │   │Center 1  │  │Center 2  │  │Center 3  │       │      │
│   │   └──────────┘  └──────────┘  └──────────┘       │      │
│   └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘

                    EDGE LOCATIONS
        (Closer to users — content delivery only)
```

---

### AWS Regions

- A **Region** is a physical geographic area (e.g., Mumbai, Virginia, Frankfurt)
- AWS has **33+ Regions** worldwide as of 2026
- Each Region is **completely independent** — a failure in one Region does not affect others
- You choose which Region to deploy your application in

**How to Choose an AWS Region — The 4 Factors:**

| Factor | Question to Ask | Example |
|---|---|---|
| **Compliance** | Does local law require data to stay in a specific country? | Indian financial data may need to stay in India → ap-south-1 (Mumbai) |
| **Latency** | Where are my users? | Users in Europe → eu-west-1 (Ireland) for low latency |
| **Service Availability** | Is the AWS service I need available in this Region? | Not all services launch in all Regions simultaneously |
| **Pricing** | What is the cost difference? | us-east-1 (Virginia) is often the cheapest Region |

> 💡 **For most DevOps projects:** Start with `us-east-1` (N. Virginia) — it has every AWS service, lowest pricing, and largest documentation community.

---

### AWS Availability Zones (AZs)

- An AZ is one or more **physical data centers** within a Region
- Each Region has **minimum 3 AZs** (some have 6)
- Each AZ has **independent power, cooling, and networking**
- AZs in the same Region are connected with **high-bandwidth, ultra-low latency** fiber
- If one AZ goes down (fire, flood, power failure), others continue working

```
Region: ap-south-1 (Mumbai)
│
├── AZ: ap-south-1a  → Data Center building A
├── AZ: ap-south-1b  → Data Center building B
└── AZ: ap-south-1c  → Data Center building C

(Each building is physically separate — different power grid, different flood zone)
```

**Why AZs matter for DevOps:**
When you launch EC2 instances, you choose which AZ. For high availability, you spread instances across multiple AZs. If one AZ fails, your app still runs in the others.

```
Bad (single AZ):          Good (multi-AZ):
──────────────────        ──────────────────
EC2 in AZ-1a only   →    EC2 in AZ-1a
                          EC2 in AZ-1b
AZ-1a goes down?          EC2 in AZ-1c
→ app is down ❌          AZ-1a goes down? → still running ✅
```

---

### AWS Points of Presence (Edge Locations)

- There are **400+ Edge Locations** worldwide — far more than Regions
- They are **not for running your servers** — they are for **delivering content faster**
- Used by: **Amazon CloudFront** (CDN), **AWS Global Accelerator**, **Route 53**

**How Edge Locations work:**

```
Without Edge Location:
User in Mumbai → request travels to → Server in US → back to Mumbai
(high latency — long distance)

With CloudFront + Edge Location:
User in Mumbai → request goes to → Edge Location in Mumbai (cached content)
(low latency — content is already nearby)
```

**Summary:**

| Infrastructure | Count | Purpose |
|---|---|---|
| Regions | 33+ | Deploy your applications |
| Availability Zones | 100+ | High availability within a Region |
| Edge Locations | 400+ | Content delivery — CDN and DNS |

---

## 📚 Section 6 — AWS Shared Responsibility Model

This is one of the **most important concepts in AWS** — and one of the most common interview and certification questions.

### The Core Idea

```
AWS is responsible for security OF the cloud
You are responsible for security IN the cloud
```

Think of it like renting an apartment:
- **Landlord (AWS)** is responsible for the building's security — locks on the main door, security cameras, structural safety
- **Tenant (You)** is responsible for what's inside your apartment — locking your own door, what you store inside, who you give keys to

---

### What AWS Is Responsible For (Security OF the Cloud)

AWS secures the **physical and foundational layers**:

```
Physical Data Centers
    ↓
Hardware (servers, networking equipment)
    ↓
Hypervisor (virtualization layer)
    ↓
AWS Global Network
    ↓
Managed service software (e.g., RDS database engine)
```

Specifically:
- Physical security of data centers (guards, cameras, biometric access)
- Hardware maintenance and replacement
- Network infrastructure and DDoS protection
- Hypervisor security (the software that runs virtual machines)
- Global network operations and monitoring

**You cannot see or touch any of this** — AWS handles it completely.

---

### What YOU Are Responsible For (Security IN the Cloud)

You are responsible for everything you **put on top** of AWS's infrastructure:

| Your Responsibility | Examples |
|---|---|
| **Data protection** | Encrypt your S3 buckets, encrypt your RDS databases |
| **IAM (Identity & Access Management)** | Who has access to what — users, roles, policies |
| **OS security** | Patch your EC2 operating system, don't leave SSH open to the world |
| **Application security** | Your app's code, authentication, input validation |
| **Network configuration** | Security group rules, NACLs, VPC settings |
| **Firewall rules** | What ports are open, who can connect |
| **Compliance** | Your data must meet regulations — AWS gives you tools, you implement them |

---

### Responsibility Changes by Service Type

This is the nuanced part — the more managed a service is, the more AWS takes responsibility:

| Service | Type | AWS Manages | You Manage |
|---|---|---|---|
| **EC2** | IaaS | Physical hardware, hypervisor, network | OS patches, app security, firewall, data |
| **RDS** | PaaS | Database engine, backups, OS patches | DB access control, encryption, IAM roles |
| **S3** | SaaS-like | Storage infrastructure, durability | Bucket policies, access permissions, encryption settings |
| **Lambda** | Serverless | Everything except your code | Your function's code and the data it processes |

> 💡 **Rule of thumb:** The more AWS manages, the less you control — but also the less you have to secure yourself. Shared responsibility shifts as you move from IaaS → PaaS → SaaS.

---

### Visual Summary

```
┌─────────────────────────────────────────────────────────┐
│                    CUSTOMER                             │
│  Data · IAM · OS · App · Network Config · Firewall      │
├─────────────────────────────────────────────────────────┤
│                      AWS                                │
│  Compute · Storage · Database · Networking services     │
├─────────────────────────────────────────────────────────┤
│                 AWS FOUNDATION                          │
│  Regions · AZs · Edge Locations                         │
├─────────────────────────────────────────────────────────┤
│              PHYSICAL INFRASTRUCTURE                    │
│  Data Centers · Hardware · Power · Cooling · Network    │
└─────────────────────────────────────────────────────────┘
     ↑ AWS is responsible for everything below the line
     ↑ You are responsible for everything above the line
```

---

## 🧠 Key Concepts Summary — Interview Ready

| Concept | One-Line Answer |
|---|---|
| What is cloud computing? | On-demand IT resources over the internet with pay-as-you-go pricing |
| IaaS vs PaaS vs SaaS | Control vs convenience spectrum — IaaS = most control, SaaS = least control |
| AWS Region | Geographic area with multiple data centers |
| Availability Zone | Isolated data center(s) within a Region — used for high availability |
| Edge Location | Content delivery point — used by CloudFront for low latency |
| Shared Responsibility | AWS secures the cloud infrastructure; you secure what you put in it |
| Why multi-AZ? | If one data center fails, your app still runs in others |
| Data Transfer pricing | Inbound to AWS = free. Outbound to internet = you pay |

---

## 🏃 Practice Exercises

- [ ] Create a free AWS account and explore the console
- [ ] Identify which Region is closest to you and lowest latency
- [ ] Launch a free-tier EC2 instance in `us-east-1`
- [ ] Create an S3 bucket and upload a file
- [ ] Set up a Security Group that allows only SSH (port 22) and HTTP (port 80)
- [ ] Create an IAM user with limited permissions (not root)
- [ ] Explore the AWS Pricing Calculator: https://calculator.aws

---

## 🐛 Common Mistakes Beginners Make

| Mistake | Why It's Dangerous | Fix |
|---|---|---|
| Using root account for everything | Root has unlimited access — if compromised, game over | Create IAM users for daily work |
| Leaving EC2 SSH open to `0.0.0.0/0` | Anyone on the internet can attempt login | Restrict SSH to your IP only |
| Forgetting to turn off EC2 | Running instances cost money even when idle | Stop instances when not in use |
| Not encrypting S3 buckets | Data at rest is unprotected | Enable default encryption on all buckets |
| Deploying everything in one AZ | Single point of failure | Always use multi-AZ for production |
| Ignoring IAM policies | Over-permissive access is a security risk | Apply principle of least privilege |

---

## 📝 Personal Notes

<!-- Add your own AWS observations, things you discovered in the console, errors you hit -->

> 💬 *Note which services you explored, what confused you, and what clicked.*

---

## 🔗 Resources

| Resource | Link |
|---|---|
| AWS Free Tier | https://aws.amazon.com/free |
| AWS Global Infrastructure map | https://infrastructure.aws |
| AWS Pricing Calculator | https://calculator.aws |
| AWS Shared Responsibility Model | https://aws.amazon.com/compliance/shared-responsibility-model |
| AWS Documentation | https://docs.aws.amazon.com |
| AWS Skill Builder (free courses) | https://skillbuilder.aws |
| Stephane Maarek AWS course | *[Udemy — highly recommended for AWS certifications]* |
