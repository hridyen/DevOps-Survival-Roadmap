[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ API Gateway & Cognito CLI Reference

> **Implementation:** AWS CLI (v2)
> **Goal:** Manage identity pools and API deployments.

---

## ✦ 1. AWS API Gateway Operations

### Get All APIs
```bash
aws apigateway get-rest-apis
```

### Create a Deployment
```bash
aws apigateway create-deployment \
    --rest-api-id abc1234567 \
    --stage-name prod \
    --description "Production deployment v1"
```

### Get Stage Information
```bash
aws apigateway get-stage \
    --rest-api-id abc1234567 \
    --stage-name prod
```

---

## ✦ 2. Amazon Cognito Operations

### List User Pools
```bash
aws cognito-idp list-user-pools --max-results 10
```

### Get User Pool Details
```bash
aws cognito-idp describe-user-pool --user-pool-id us-east-1_abcdefgh
```

### List Identity Pools
```bash
aws cognito-identity list-identity-pools --max-results 10
```

---

## ✦ 3. Advanced Integrations

### Create an API Key (for throttling)
```bash
aws apigateway create-api-key \
    --name "ExternalAppKey" \
    --enabled \
    --description "Key for 3rd party integration"
```

### Associate Key with Usage Plan
```bash
aws apigateway create-usage-plan-key \
    --usage-plan-id usage-plan-123 \
    --key-id api-key-456 \
    --key-type "API_KEY"
```

---

## ✦ 🍟 Industrial Tips
- **Exporting Swagger/OpenAPI:** You can export your entire API definition to a Swagger file using the CLI for documentation or migration purposes.
- **Cognito Admin Commands:** Use `admin-initiate-auth` for backend-driven login flows (e.g., automated tests) to bypass MFA or CAPTCHA if needed in controlled environments.
