[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Edge & Integration CLI Reference

> **Implementation:** AWS CLI (v2)
> **Goal:** Coordinate edge logic and scheduled triggers.

---

## ✦ 1. CloudFront Edge Associations

### Associate a Lambda@Edge Function
Note: You must specify the exact function ARN version.
```bash
aws cloudfront update-distribution \
    --id EXMAPLE123 \
    --default-cache-behavior '{"LambdaFunctionAssociations": {"Items": [{"LambdaFunctionARN": "arn:aws:lambda:us-east-1:123:function:my-function:1", "EventType": "viewer-request"}]}}'
```

### Associate a CloudFront Function
```bash
aws cloudfront update-distribution \
    --id EXMAPLE123 \
    --default-cache-behavior '{"FunctionAssociations": {"Items": [{"FunctionARN": "arn:aws:cloudfront::123:function/my-func", "EventType": "viewer-request"}]}}'
```

---

## ✦ 2. EventBridge (Serverless CRON)

### Create a Rule
```bash
aws events put-rule \
    --name "EveryOneHour" \
    --schedule-expression "rate(1 hour)" \
    --state ENABLED
```

### Add Lambda as Target
```bash
aws events put-targets \
    --rule "EveryOneHour" \
    --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:123:function:my-function"
```

---

## ✦ 3. RDS Proxy Management

### Create an RDS Proxy
```bash
aws rds create-db-proxy \
    --db-proxy-name my-proxy \
    --engine-family MYSQL \
    --auth UserName=admin,SecretArn=arn:aws:secretsmanager:us-east-1:123:secret:db-creds \
    --vpc-subnet-ids subnet-123 subnet-456
```

---

## ✦ 🍟 Industrial Tips
- **Lambda@Edge Region:** Lambda@Edge functions MUST be created in the `us-east-1` (N. Virginia) region, regardless of where your other resources are.
- **Log Management:** CloudFront Functions log to CloudWatch in the region where they executed. Be sure to check logs in different regions if you have global traffic.
