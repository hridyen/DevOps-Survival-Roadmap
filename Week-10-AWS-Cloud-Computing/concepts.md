# ☁️ Week 10 — AWS Concepts Cheat Sheet

> Quick reference for all AWS and Cloud Computing concepts from Week 10.

---

## ☁️ Cloud Deployment Models

| Model | Definition | Use Case |
|---|---|---|
| **Private** | Cloud for one organization only | Banks, hospitals, government |
| **Public** | Shared cloud (AWS, Azure, GCP) | Startups, most businesses |
| **Hybrid** | Mix of private + public | Enterprises with compliance needs |

---

## 🧱 Service Models (IaaS / PaaS / SaaS)

```
IaaS → PaaS → SaaS
More control ←────────────────────→ More managed by AWS
```

| Model | AWS Example | Other Examples | You Manage |
|---|---|---|---|
| IaaS | EC2, EBS, VPC | Azure VMs, GCP Compute, DigitalOcean | OS, runtime, app, data |
| PaaS | Elastic Beanstalk, RDS | Heroku, Google App Engine | App code + data |
| SaaS | Chime, WorkMail | Gmail, Dropbox, Zoom | Just use the software |

---

## 🌍 AWS Global Infrastructure

```
Regions (33+)
  └── Availability Zones (3-6 per Region)
        └── Data Centers (1-3 per AZ)

Edge Locations (400+) — separate from Regions — for CDN only
```

| Component | Count | Purpose |
|---|---|---|
| Regions | 33+ | Deploy applications |
| Availability Zones | 100+ | High availability |
| Edge Locations | 400+ | CloudFront CDN, DNS |

---

## 🔑 How to Choose a Region — 4 Factors

```
1. Compliance    → Does law require data to stay in a country?
2. Latency       → How close is the Region to your users?
3. Services      → Is the AWS service available in this Region?
4. Pricing       → Which Region is most cost-effective?
```

---

## 💰 AWS Pricing Model

| Pay For | Free |
|---|---|
| Compute (EC2 hours, Lambda invocations) | Data transfer IN to AWS |
| Storage (S3 GB/month, EBS GB/month) | — |
| Data transfer OUT (to internet) | — |

---

## 🔐 Shared Responsibility Model

```
YOU are responsible for:          AWS is responsible for:
────────────────────────          ───────────────────────
Your data                         Physical data centers
IAM users and policies            Hardware and networking
OS patches on EC2                 Hypervisor
App security                      Global network
Security group rules              Managed service software
Encryption settings               DDoS protection
```

**Quick rule:**
- **EC2** → You patch the OS, AWS secures the hardware
- **RDS** → AWS patches the database engine, you manage access
- **S3** → AWS stores it durably, you manage permissions

---

## 🌐 Key AWS Services Mentioned

| Service | What It Does |
|---|---|
| **EC2** | Virtual servers in the cloud (IaaS) |
| **S3** | Object storage — files, images, backups |
| **RDS** | Managed relational databases |
| **VPC** | Your private network in AWS |
| **CloudFront** | Content Delivery Network (CDN) — uses Edge Locations |
| **Route 53** | DNS service |
| **IAM** | Users, roles, permissions management |
| **EBS** | Block storage for EC2 (like a hard drive) |
| **Elastic Beanstalk** | PaaS — deploy apps without managing servers |
| **Lambda** | Serverless — run code without any server |

---

## 📝 My Notes

<!-- Add your own key points and things to remember -->

| Concept | My Understanding | Questions I Have |
|---|---|---|
| | | |
