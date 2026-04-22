[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ AWS Lambda CLI Commands

> **Implementation:** AWS CLI (v2)
> **Goal:** Manage serverless functions from the terminal.

---

## ✦ 1. Lifecycle Operations

### Create a Function
```bash
aws lambda create-function \
    --function-name my-serverless-app \
    --runtime python3.9 \
    --role arn:aws:iam::123456789012:role/lambda-role \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://function.zip
```

### Invoke a Function
```bash
aws lambda invoke \
    --function-name my-serverless-app \
    --payload '{"key": "value"}' \
    output.json
```

### Update Function Code
```bash
aws lambda update-function-code \
    --function-name my-serverless-app \
    --zip-file fileb://new-function.zip
```

---

## ✦ 2. Configuration & Permissions

### Add Trigger Permissions
Allow S3 to invoke the function:
```bash
aws lambda add-permission \
    --function-name my-serverless-app \
    --statement-id s3-trigger \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::my-bucket
```

### Configure VPC Access
```bash
aws lambda update-function-configuration \
    --function-name my-serverless-app \
    --vpc-config SubnetIds=subnet-12345,subnet-67890,SecurityGroupIds=sg-abcdef
```

---

## ✦ 3. Monitoring & Meta

### List Functions
```bash
aws lambda list-functions --max-items 10
```

### Get Function Details
```bash
aws lambda get-function --function-name my-serverless-app
```

---

## ✦ 🍟 Industrial Tips
- **Aliases:** Always use Aliases (e.g., `DEV`, `PROD`) to point to specific versions of your Lambda. Never point your API Gateway directly to `$LATEST`.
- **Dry Run:** Use the `--invocation-type DryRun` flag to verify if the function can be invoked without actually running the code.
