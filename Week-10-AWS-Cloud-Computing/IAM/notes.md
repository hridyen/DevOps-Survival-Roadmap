# ⚡ IAM — Identity & Access Management

> **Week:** 10
> **Folder:** IAM
> **Importance:** Critical — IAM is used in every single AWS task

---

## ✦ 1. Why IAM Matters for DevOps

In every AWS project, you need to answer:
- Which developer can launch EC2 instances?
- Can Jenkins access S3 without storing a password in code?
- If a password is stolen, can the attacker still get in?
- Who accessed what resource, and when?

**IAM answers all of these.** It is the security foundation of everything in AWS.

```mermaid
graph LR
    subgraph Without IAM
        Usr[All Users] -->|Full Access| AWSA[All AWS Resources]
    end

    subgraph With IAM
        DevA[Developer A] -->|EC2 only| EC2[EC2 Instances]
        DevB[Developer B] -->|S3 read only| S3[S3 Buckets]
        Jnk[Jenkins] -->|ECR push only| ECR[ECR Repositories]
        Int[Intern] -->|Read-only| AWSR[AWS Resources]
    end
```

---

## ✦ 1. IAM — Core Components

IAM manages three things:

| Component | What It Is | Real Example |
|---|---|---|
| **Users** | A person or app that needs AWS access | A developer on your team |
| **Groups** | A collection of users | "Developers" group, "Admins" group |
| **Roles** | Permissions for AWS services — not people | EC2 instance reading from S3 |

---

## ✦ 2. Users & Groups

### ✦ Users
An IAM User is an identity for a **real person** or **application**. Each user has:
- Unique username
- Password (for Console access)
- Access keys (for CLI/SDK access)
- Permissions via policies

### ✦ Groups
A Group is a collection of users. Assign permissions to the group — all members inherit them automatically.

```mermaid
graph TD
    subgraph Without Groups
        A1[Alice] --> P1[Policy Set]
        B1[Bob] --> P2[Policy Set]
        C1[Carol] --> P3[Policy Set]
    end
    
    subgraph With Groups
        G[Developers Group] --> GP[Policy Set]
        A2[Alice] --> G
        B2[Bob] --> G
        C2[Carol] --> G
    end
```

### ✦ Key Rules

| Rule | Example |
|---|---|
| User does NOT have to be in any group | Contractor with one-time custom permissions |
| User CAN belong to multiple groups | Alice is in both "Developers" AND "QA" |
| Groups cannot be nested | Cannot put a group inside another group |
| All group policies combine | Alice inherits Developer + QA permissions |

---

## ✦ 3. IAM Permissions & Policies

### ✦ What Is a Policy?
A **policy** is a **JSON document** that defines what actions are allowed or denied on which resources.

### ✦ Policy Structure — Every Field Explained

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example-bucket"
    }
  ]
}
```

| Field | What It Means | Values |
|---|---|---|
| `Version` | Policy language version — always use this | `"2012-10-17"` |
| `Statement` | Array of permission rules | `[{...}, {...}]` |
| `Effect` | Allow or block the action | `"Allow"` or `"Deny"` |
| `Action` | Which AWS API action | `"s3:ListBucket"`, `"ec2:*"`, `"*"` |
| `Resource` | Which specific resource | `"arn:aws:s3:::my-bucket"` or `"*"` |

### ✦ ARN — Amazon Resource Name
Every AWS resource has a unique ID:
```
arn:aws:s3:::my-bucket
 │   │   │       │
 │   │   │       └── Resource name
 │   │   └────────── Service (s3, ec2, iam...)
 │   └────────────── AWS partition
 └────────────────── Prefix — always "arn"
```

### ✦ Policy Examples

```json
// Allow full S3 access
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "s3:*", "Resource": "*" }]
}
```

```json
// EC2 read-only — describe but cannot start/stop/terminate
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "ec2:Describe*", "Resource": "*" }]
}
```

```json
// Explicitly DENY delete — overrides any Allow
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Deny", "Action": "s3:DeleteObject", "Resource": "*" }]
}
```

> ⚠️ **Critical rule:** An explicit `Deny` **ALWAYS overrides** an `Allow`. If one policy allows and another denies — result is always **denied**.

### ✦ Types of Policies

| Type | What It Is | When to Use |
|---|---|---|
| **AWS Managed** | Pre-built by AWS, maintained by AWS | Standard cases — `AmazonS3ReadOnlyAccess` |
| **Customer Managed** | You create and maintain it | Custom business requirements |
| **Inline** | Directly attached to one user/role, not reusable | One-off specific permissions |

### ✦ Policy Inheritance — How Permissions Stack

```mermaid
graph TD
    User[IAM User: Alice]
    
    User --> Direct[Direct Policy]
    User --> DevGroup[Developers Group]
    User --> QAGroup[QA Group]
    
    Direct --> DP[Allow ec2:DescribeInstances]
    DevGroup --> DevP[Allow s3:GetObject, s3:PutObject]
    QAGroup --> QAP[Allow s3:ListBucket]
    
    DP -.-> Final[Final Permissions]
    DevP -.-> Final
    QAP -.-> Final
```

---

## ✦ 4. IAM Roles

### ✦ What Is a Role?
A Role is like a user but for **AWS services** — not for people.

```mermaid
graph LR
    subgraph Vulnerable Approach
        EC2A[EC2 Instance] -->|Hardcoded Keys| S3A[S3 Bucket]
    end
    
    subgraph Secure Approach
        Role[IAM Role] -->|Grants Access| S3B[S3 Bucket]
        EC2B[EC2 Instance] -.->|Assumes| Role
    end
```

**If the server is compromised with hardcoded keys → attacker gets permanent access.**
**With Roles → temporary credentials, auto-rotated, no exposure.**

### ✦ Common Role Use Cases

| Service | Why It Needs a Role | What the Role Allows |
|---|---|---|
| **EC2** | Server needs to read/write S3 | `s3:GetObject`, `s3:PutObject` |
| **Lambda** | Function writes to DynamoDB | `dynamodb:PutItem` |
| **Jenkins on EC2** | Pipeline pushes to ECR | `ecr:PutImage`, `ecr:GetAuthorizationToken` |
| **CodeBuild** | Build job reads S3, writes logs | `s3:GetObject`, `logs:CreateLogGroup` |

> 💡 **DevOps Rule:** Never store AWS credentials in code, config files, or environment variables on a server. **Always use IAM Roles.**

---

## ✦ 5. IAM Password Policy

| Setting | Recommended Value |
|---|---|
| Minimum length | 12+ characters |
| Require uppercase | ✅ |
| Require lowercase | ✅ |
| Require numbers | ✅ |
| Require symbols | ✅ |
| Password expiration | 90 days |
| Prevent reuse | Last 5 passwords |
| Enforce MFA | ✅ Always for admins |

---

## ✦ 6. Multi-Factor Authentication (MFA)

```mermaid
graph LR
    subgraph Single Factor
        pwd1[Username + Password] --> Access1[AWS Access]
    end
    
    subgraph Multi-Factor
        pwd2[Username + Password] --> MFA[MFA Code]
        MFA --> Access2[AWS Access]
    end
```

### ✦ MFA Device Types

| Type | How It Works | Example |
|---|---|---|
| **Virtual MFA** | App generates 6-digit code every 30s | Google Authenticator, Authy |
| **Hardware Token** | Physical key fob generates codes | Gemalto token |
| **U2F Security Key** | USB key — press button to authenticate | YubiKey |

> 💡 Enable MFA on your **root account immediately** after creating AWS account. Root = unlimited access.

---

## ✦ 7. How to Access AWS — 3 Methods

| Method | What It Is | Best For |
|---|---|---|
| **Management Console** | Web browser UI | Beginners, visual tasks |
| **AWS CLI** | Terminal commands | Automation, scripting, DevOps |
| **AWS SDK** | Code (Python, JS, Java) | Applications, automation in code |

### ✦ AWS CLI Setup
```bash
# Install (Linux)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Configure
aws configure
# AWS Access Key ID:     AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG...
# Default region:        ap-south-1
# Output format:         json

# Verify
aws iam get-user
```

### ✦ AWS SDK (Python boto3)
```python
import boto3

# List S3 buckets
s3 = boto3.client('s3')
response = s3.list_buckets()
for bucket in response['Buckets']:
    print(bucket['Name'])
```

---

## ✦ 8. IAM Security Tools

| Tool | What It Does | Use It For |
|---|---|---|
| **IAM Credentials Report** | CSV listing all users + password/key status | Monthly security audit |
| **IAM Access Advisor** | Shows last time each permission was actually used | Find and remove unused permissions |
| **IAM Policy Simulator** | Test what a user/role can do before applying | Validate policies before going live |

```bash
# Generate Credentials Report via CLI
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d
```

---

## ✦ 9. IAM Best Practices

| Practice | Why It Matters |
|---|---|
| Never use root account for daily work | Root = unlimited access — lock it away after setup |
| One physical person = one IAM user | Shared accounts make auditing impossible |
| Assign users to groups | Easier to manage, less error-prone |
| Apply least privilege | Users should have only what they need |
| Enable MFA for all users | Passwords alone are not enough |
| Use Roles for services, never users | Avoids hardcoded credentials |
| Rotate access keys regularly | Old keys are a liability |
| Audit with Access Advisor | Find and remove permissions nobody uses |
| **Never commit access keys to Git** | Bots scan GitHub 24/7 — keys found = exploited in minutes |

---

## ✦ 10. Shared Responsibility for IAM

| AWS Handles | You Handle |
|---|---|
| IAM service availability | Creating users, groups, roles |
| Physical IAM infrastructure | Setting strong password policies |
| AWS managed policies | Enabling MFA |
| IAM service patches | Applying least privilege |
| | Auditing with Credentials Report + Access Advisor |
| | Never sharing credentials or committing keys |

---

## ✦ Summary — Interview Ready

| Concept | One-Line Answer |
|---|---|
| IAM | Controls who can do what on which AWS resource |
| User | Identity for a person or app |
| Group | Collection of users sharing same permissions |
| Role | Permissions for an AWS service — no password needed |
| Policy | JSON defining Allow/Deny on specific actions |
| Least Privilege | Give only the minimum permissions needed |
| MFA | Second factor (phone/token) beyond password |
| Root account | Never use for daily tasks — lock it away |
| Access Keys | For CLI/SDK — treat like a password, rotate regularly |
| Credentials Report | Lists all users + password/key status |
| Access Advisor | Shows last time permissions were used |
| Deny vs Allow | Explicit Deny always wins |

---

## ✦ Practice Exercises

- [ ] Log in to AWS Console and create your first IAM user (not root!)
- [ ] Create a group `Developers` and attach `AmazonS3ReadOnlyAccess`
- [ ] Add your IAM user to the group and verify S3 access
- [ ] Enable MFA on root account and your IAM user
- [ ] Install AWS CLI and run `aws configure`
- [ ] Run `aws iam list-users` and `aws s3 ls`
- [ ] Write a custom policy allowing only `s3:ListBucket` and `s3:GetObject`
- [ ] Create an IAM Role for EC2 with S3 read access and attach it to an instance
- [ ] Generate a Credentials Report and review it
- [ ] Use Access Advisor to find unused permissions

---

## ✦ Common IAM Mistakes

| Mistake | Consequence | Fix |
|---|---|---|
| Using root account daily | Full account compromise if stolen | Create IAM admin user, lock root |
| Storing access keys in `.env` committed to Git | Credentials exposed publicly within minutes | Use IAM Roles, add `.env` to `.gitignore` |
| Giving `AdministratorAccess` to everyone | Any user compromise = full account access | Apply least privilege |
| Not enabling MFA | Password theft = account access | Enable MFA immediately |
| Never rotating access keys | Old compromised keys stay valid | Rotate every 90 days |
| Ignoring Credentials Report | Unused accounts with active keys go unnoticed | Monthly audit |

---

## ✦ Personal Notes

<!-- Add your IAM observations, things you tried in the console, errors you hit -->

---

## ✦ Resources

See [resources.md](./resources.md)
