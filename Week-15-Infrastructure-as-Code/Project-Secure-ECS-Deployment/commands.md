# ✦ Module: Secure ECS Project Commands

> **Commands for deploying a secure, private ECS cluster using VPC Endpoints.**

---

### Managing VPC Endpoints

**Create the ECR API Interface Endpoint:**
```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-12345678 \
  --vpc-endpoint-type Interface \
  --service-name com.amazonaws.us-east-1.ecr.api \
  --subnet-ids subnet-private1 subnet-private2 \
  --security-group-ids sg-endpoint \
  --private-dns-enabled
```

**Create the S3 Gateway Endpoint:**
```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-12345678 \
  --vpc-endpoint-type Gateway \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids rtb-private
```

---

### ECS Orchestration

**Force a new deployment of an ECS service:**
```bash
aws ecs update-service \
  --cluster my-secure-cluster \
  --service my-fargate-service \
  --force-new-deployment
```

**Describe tasks (useful when debugging tasks stuck in "Pending"):**
```bash
aws ecs describe-tasks \
  --cluster my-secure-cluster \
  --tasks arn:aws:ecs:us-east-1:123456789012:task/my-secure-cluster/abc123def456 \
  --query 'tasks[*].{Status:lastStatus,Reason:stoppedReason}'
```
