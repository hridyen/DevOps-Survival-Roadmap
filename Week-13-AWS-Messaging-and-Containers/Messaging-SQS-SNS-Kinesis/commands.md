[![Sector](https://img.shields.io/badge/SECTOR-MESSAGING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ AWS Messaging CLI Reference

## ✦ 1. Amazon SQS Commands

### ✦ Queue Management
```bash
# Create a Standard Queue
aws sqs create-queue --queue-name devops-roadmap-queue

# Create a FIFO Queue (Must end in .fifo)
aws sqs create-queue --queue-name orders.fifo --attributes FifoQueue=true,ContentBasedDeduplication=true

# Get Queue URL
aws sqs get-queue-url --queue-name devops-roadmap-queue
```

### ✦ Message Operations
```bash
# Send a Message with Attributes
aws sqs send-message --queue-url <URL> --message-body "Deploy V2" --message-attributes '{"Priority": { "DataType": "Number", "StringValue": "1" }}'

# Receive Message (Long Polling)
aws sqs receive-message --queue-url <URL> --wait-time-seconds 20

# Change Message Visibility (Extend processing time)
aws sqs change-message-visibility --queue-url <URL> --receipt-handle <HANDLE> --visibility-timeout 60

# Purge a Queue (Delete all messages)
aws sqs purge-queue --queue-url <URL>
```

---

## ✦ 2. Amazon SNS Commands

### ✦ Topic & Subscription
```bash
# Create SNS Topic
aws sns create-topic --name prod-alerts

# Subscribe SQS Queue to SNS (Fan-out)
aws sns subscribe --topic-arn <TOPIC_ARN> --protocol sqs --notification-endpoint <SQS_ARN>

# Set Subscription Filter Policy (Only receive high priority)
aws sns set-subscription-attributes --subscription-arn <SUB_ARN> --attribute-name FilterPolicy --attribute-value '{"priority": ["high"]}'
```

### ✦ Publishing
```bash
# Publish Message to Topic
aws sns publish --topic-arn <TOPIC_ARN> --message "CRITICAL: Server Down" --subject "Urgent Alert"
```

---

## ✦ 3. Amazon Kinesis Commands

### ✦ Stream Operations
```bash
# Create Stream with 2 Shards
aws kinesis create-stream --stream-name web-traffic --shard-count 2

# List Streams
aws kinesis list-streams

# Put Record into Stream
aws kinesis put-record --stream-name web-traffic --partition-key user_1 --data "user_clicked_home"
```

### ✦ Reading Data
```bash
# Get Shard Iterator
aws kinesis get-shard-iterator --stream-name web-traffic --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON

# Get Records using Iterator
aws kinesis get-records --shard-iterator <ITERATOR_ID>
```
