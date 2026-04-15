[![Sector](https://img.shields.io/badge/SECTOR-MESSAGING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ AWS Messaging CLI Reference

## ✦ 1. Amazon SQS Commands

### ✦ Create a Standard Queue
```bash
aws sqs create-queue --queue-name devops-roadmap-queue
```

### ✦ Send a Message
```bash
aws sqs send-message --queue-url <QUEUE_URL> --message-body "Deploy Version 2.0"
```

### ✦ Receive a Message
```bash
aws sqs receive-message --queue-url <QUEUE_URL>
```

### ✦ Delete a Message (Process complete)
```bash
aws sqs delete-message --queue-url <QUEUE_URL> --receipt-handle <HANDLE_FROM_RECEIVE>
```

---

## ✦ 2. Amazon SNS Commands

### ✦ Create a Topic
```bash
aws sns create-topic --name production-alerts
```

### ✦ Subscribe an Email to Topic
```bash
aws sns subscribe --topic-arn <TOPIC_ARN> --protocol email --notification-endpoint yourname@example.com
```

### ✦ Publish a Message
```bash
aws sns publish --topic-arn <TOPIC_ARN> --message "Build Successful! Deploying to Staging..."
```

---

## ✦ 3. Amazon Kinesis Commands

### ✦ Create a Stream
```bash
aws kinesis create-stream --stream-name server-logs --shard-count 1
```

### ✦ Describe Stream
```bash
aws kinesis describe-stream --stream-name server-logs
```
