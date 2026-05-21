# ⚡ Week 10 — AWS Fundamentals & IAM Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on AWS Identity & Access Management (IAM), Policy Evaluation, Cross-Account Access, and Organizations.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You have an IAM user who has an identity-based policy allowing `s3:*` on all resources. However, there is a Service Control Policy (SCP) blocking S3 deletions, and a Permission Boundary attached to the user that only allows EC2 and RDS actions. Can this user delete an S3 bucket? Explain the IAM policy evaluation logic.</b></summary>
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
<summary><b>Q2: Scenario: You need to allow a third-party SaaS security tool running in AWS Account B to run read-only security audits on resources inside your AWS Account A. How do you design this securely without sharing any IAM access keys?</b></summary>
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
<summary><b>Q3: Scenario: You want to delegate IAM administration permissions to a group of Junior Administrators. However, you must prevent them from elevating their own permissions or creating Administrator users. How do you enforce this restriction?</b></summary>
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
<summary><b>Q4: Scenario: An EC2 instance hosting an application needs to read from an S3 bucket. A junior developer suggests configuring access keys directly inside the application's configuration files. Explain why this is a security risk and how to implement this using IAM Instance Profiles and IMDSv2.</b></summary>
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
<summary><b>Q5: Scenario: You need to allow 200 developers to upload files to an S3 bucket. However, each developer must only be allowed to read and write to their own dedicated directory (e.g. `s3://company-shared-bucket/home/username/`). How do you implement this with a single IAM policy?</b></summary>
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
<summary><b>Q6: Scenario: How do Service Control Policies (SCPs) differ from standard IAM policies, and how do they impact the Root user of a member account in an AWS Organization?</b></summary>
<b>Answer:</b>
- **Standard IAM Policies:** Applied to identities (users, groups, roles) or resources inside a single AWS account.
- **Service Control Policies (SCPs):** Applied at the AWS Organizations level (Root, OU, or individual Member Account). SCPs establish permission guardrails by defining the maximum permissions available to accounts.
- **Impact on Root User:** Unlike standard IAM policies, **SCPs apply to all users in the member account, including the root user**. Even if the root user has full permissions, if an SCP explicitly denies an action (like `rds:DeleteDBInstance`), the root user cannot perform that action. (SCPs do not apply to the Management/Master account of the organization).
</details>

<details>
<summary><b>Q7: Scenario: Your security audit reveals that several IAM user access keys are active but have not been used for over 180 days. How do you automate the discovery of these credentials, and what are the best practices for rotation?</b></summary>
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
<summary><b>Q8: Scenario: When configuring a trust relationship for an IAM Role, what is the difference between the "Trust Policy" and the "Permission Policy"? Provide an example of how a misconfigured trust policy causes a "Failed to Assume Role" error.</b></summary>
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
<summary><b>Q9: Scenario: You have a requirement to enforce Multi-Factor Authentication (MFA) for all console and API actions. If MFA is not active, the user should be denied all access. How do you implement this policy?</b></summary>
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
<summary><b>Q10: Scenario: S3 Bucket Policies vs IAM Identity-based Policies: When should you use a S3 Bucket Policy instead of an IAM policy to secure bucket contents?</b></summary>
<b>Answer:</b>
- **Use S3 Bucket Policies (Resource-based) when:**
  1. **Cross-Account Access:** You need to grant access to users in other AWS accounts without requiring them to assume a role.
  2. **Anonymity/Public Access:** You want to make objects publicly readable (e.g. hosting a static website).
  3. **Strict Ingress Filtering:** You want to enforce network constraints (e.g. only allow traffic originating from a specific VPC Endpoint or corporate IP CIDR block).
- **Use IAM Policies (Identity-based) when:**
  1. You want to manage permissions from a user-centric perspective (e.g., managing what "Developer Alice" can do across S3, EC2, and RDS).
  2. You hit the S3 bucket policy size limit (20 KB).
</details>
