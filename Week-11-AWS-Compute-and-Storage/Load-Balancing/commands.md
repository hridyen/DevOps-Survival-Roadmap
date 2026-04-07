[![Sector](https://img.shields.io/badge/SECTOR-AWS_Traffic_Management-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Load_Balancing_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Load Balancer CLI — Management Blocks

---

## ✦ ⚖️ Elastic Load Balancing (V2)

### ✦ Audit & Inventory

```bash
# Renders all Load Balancer ARNs across the region
aws elbv2 describe-load-balancers

# List all Target Groups (Clusters of EC2s)
aws elbv2 describe-target-groups
```

### ✦ Create ALB Infrastructure

```bash
# 1. Generate the Application Load Balancer (ALB)
aws elbv2 create-load-balancer \
  --name prod-alb \
  --subnets subnet-111 subnet-222 \
  --security-groups sg-xxx

# 2. Configure the Target Group (Destination)
aws elbv2 create-target-group \
  --name web-targets \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-xxx \
  --health-check-path /health

# 3. Register Instances to the Target Group
aws elbv2 register-targets \
  --target-group-arn arn:aws:elasticloadbalancing:xxx:targetgroup/web-targets/xxx \
  --targets Id=i-xxxx Id=i-yyyy
```

---

## ✦ 🛡️ SSL/TLS Integration (ACM)

### ✦ Certificate Lifecycle

```bash
# Request a public SSL certificate for your domain
aws acm request-certificate \
  --domain-name example.com \
  --validation-method DNS

# List all certificates waiting for approval
aws acm list-certificates --certificate-statuses PENDING_VALIDATION
```

---

## ✦ 📝 My Implementation Checklist

| Command | Real-World Use |
|---|---|
| `describe-target-health` | Debugging why an instance is "Unhealthy" (Timeout vs Connection Refused). |
| `modify-listener` | Updating the SSL certificate directly on a production Load Balancer. |
| `githubPush()` | Triggering a build that eventually deploys to an ALB target group. |
