[![Sector](https://img.shields.io/badge/SECTOR-AWS_Traffic_Management-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Load_Balancing_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Industrial AWS Load Balancing — Advanced CLI

---

## ✦ ⚖️ ALB — Multi-Condition Routing

### ✦ Create a Listener Rule (Priority 10)

```bash
# Complex Routing Rule: 
# IF Path == '/api/*' AND Header 'User-Agent' contains 'Mobile'
# THEN Forward to Target Group 'api-mobile-targets'

aws elbv2 create-rule \
  --listener-arn arn:aws:elasticloadbalancing:xxx:listener/app/prod-alb/xxx \
  --priority 10 \
  --conditions '[
    {
      "Field": "path-pattern",
      "Values": ["/api/*"]
    },
    {
      "Field": "http-header",
      "HttpHeaderConfig": {
        "HttpHeaderName": "User-Agent",
        "Values": ["*Mobile*"]
      }
    }
  ]' \
  --actions Type=forward,TargetGroupArn=arn:aws:elbv2:xxx:targetgroup/api-mobile-targets/xxx
```

---

## ✦ 🛡️ Maintenance & Tunneling (NLB)

### ✦ NLB with Elastic IP (Static Endpoint)

```bash
# Create an NLB with a specific Elastic IP for Whitelisting
aws elbv2 create-load-balancer \
  --name prod-nlb-static \
  --type network \
  --subnet-mappings SubnetId=subnet-111,AllocationId=eipalloc-xxxx
```

### ✦ Adjusting Deregistration Delay (Connection Draining)

```bash
# Reduce draining time to 60s for faster CI/CD testing (Default: 300s)
aws elbv2 modify-target-group-attributes \
  --target-group-arn arn:aws:elbv2:xxx:targetgroup/web-targets/xxx \
  --attributes Key=deregistration_delay.timeout_seconds,Value=60
```

---

## ✦ 📝 My Advanced Performance Snippets

| Operation | Command | Why it's used? |
|---|---|---|
| `describe-target-health` | `aws elbv2 describe-target-health` | Real-time debugging of "Unhealthy" instances. |
| `SSL-Cert-Update` | `aws elbv2 modify-listener` | Replacing the SSL certificate on a production ALB listener. |
| `EIP-Whitelisting` | `aws elbv2 describe-load-balancers` | Finding the static IPs of an NLB for corporate firewall access. |
