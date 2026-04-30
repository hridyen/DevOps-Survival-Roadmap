# ✦ Module: Event-Driven Project Commands

> **Commands to deploy and test the Event-Driven File Processing system.**

---

### Docker & ECR

**Build and push the backend API:**
```bash
docker build -t aegis-backend ./backend

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com

docker tag aegis-backend:latest <account_id>.dkr.ecr.us-east-1.amazonaws.com/aegis-backend:latest
docker push <account_id>.dkr.ecr.us-east-1.amazonaws.com/aegis-backend:latest
```

### Serverless Trigger

**Test the Lambda function locally (assuming a mock `event.json` is configured):**
```bash
aws lambda invoke \
  --function-name S3-Metadata-Extractor \
  --payload fileb://event.json \
  output.txt
```

**Query DynamoDB to verify records are written:**
```bash
aws dynamodb scan \
  --table-name files-data \
  --query 'Items[*].[id.S, filename.S, timestamp.S]' \
  --output table
```
