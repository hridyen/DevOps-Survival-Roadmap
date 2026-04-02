# 🔐 IAM — Commands & Policy Cheat Sheet

---

## ⚙️ AWS CLI — IAM Commands

```bash
# ── Users ───────────────────────────────────────────────
aws iam list-users
aws iam get-user
aws iam create-user --user-name alice
aws iam delete-user --user-name alice
aws iam create-login-profile --user-name alice \
  --password P@ssw0rd123 --password-reset-required

# ── Groups ──────────────────────────────────────────────
aws iam list-groups
aws iam create-group --group-name Developers
aws iam add-user-to-group --group-name Developers --user-name alice
aws iam remove-user-from-group --group-name Developers --user-name alice
aws iam list-groups-for-user --user-name alice

# ── Policies ────────────────────────────────────────────
aws iam list-policies --scope AWS               # AWS managed policies
aws iam list-policies --scope Local             # Your custom policies
aws iam attach-group-policy \
  --group-name Developers \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam detach-group-policy \
  --group-name Developers \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam list-attached-group-policies --group-name Developers

# ── Roles ───────────────────────────────────────────────
aws iam list-roles
aws iam create-role --role-name MyEC2Role \
  --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name MyEC2Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam list-attached-role-policies --role-name MyEC2Role

# ── Access Keys ─────────────────────────────────────────
aws iam create-access-key --user-name alice
aws iam list-access-keys --user-name alice
aws iam delete-access-key --user-name alice \
  --access-key-id AKIAIOSFODNN7EXAMPLE

# ── Audit ───────────────────────────────────────────────
aws iam generate-credential-report
aws iam get-credential-report \
  --query 'Content' --output text | base64 -d
```

---

## 📄 Policy Templates

### S3 Full Access
```json
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "s3:*", "Resource": "*" }]
}
```

### S3 Read-Only
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": "*"
  }]
}
```

### EC2 Read-Only
```json
{
  "Version": "2012-10-17",
  "Statement": [{ "Effect": "Allow", "Action": "ec2:Describe*", "Resource": "*" }]
}
```

### Deny Delete on S3
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": ["s3:DeleteObject", "s3:DeleteBucket"],
    "Resource": "*"
  }]
}
```

### EC2 Trust Policy (for Role)
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
```

### Jenkins ECR Push Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ],
    "Resource": "*"
  }]
}
```

---

## 🔑 Common AWS Managed Policies

| Policy Name | What It Allows |
|---|---|
| `AdministratorAccess` | Full access — only for admin users |
| `ReadOnlyAccess` | Read-only across all services |
| `AmazonS3FullAccess` | Full S3 access |
| `AmazonS3ReadOnlyAccess` | S3 read only |
| `AmazonEC2FullAccess` | Full EC2 access |
| `AmazonEC2ReadOnlyAccess` | EC2 read only |
| `AmazonRDSFullAccess` | Full RDS access |
| `AWSLambdaFullAccess` | Full Lambda access |
| `CloudWatchFullAccess` | Full logging and monitoring access |
| `IAMFullAccess` | Manage IAM — give carefully |

---

## 🐍 boto3 — Python Examples

```python
import boto3

iam = boto3.client('iam')

# List all users
for user in iam.list_users()['Users']:
    print(user['UserName'], user['CreateDate'])

# Create a user
iam.create_user(UserName='alice')

# Attach a policy to a user
iam.attach_user_policy(
    UserName='alice',
    PolicyArn='arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess'
)

# List groups for a user
for group in iam.list_groups_for_user(UserName='alice')['Groups']:
    print(group['GroupName'])

# Create access key — save the output, secret shown ONCE only
key = iam.create_access_key(UserName='alice')['AccessKey']
print("Access Key:", key['AccessKeyId'])
print("Secret Key:", key['SecretAccessKey'])
```

---

## 📝 My Notes

| Command | What it does | Notes |
|---|---|---|
| | | |
