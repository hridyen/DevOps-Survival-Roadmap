[![Sector](https://img.shields.io/badge/SECTOR-MESSAGING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Messaging & Streaming Resources

| Category | Resource | Type | Level | Link |
|---|---|---|---|---|
| **Documentation** | SQS Developer Guide | Docs | Beginner | [Visit](https://docs.aws.amazon.com/sqs/) |
| **Patterns** | SNS Fan-out Architectures | Guide | Intermediate | [Visit](https://aws.amazon.com/getting-started/hands-on/send-fan-out-notifications-sns-sqs/) |
| **Deep Dive** | Kinesis Scaling & Sharding | Technical | Advanced | [Visit](https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html) |
| **Comparison** | SQS vs SNS vs Kinesis | Article | All Levels | [Visit](https://aws.amazon.com/sqs/faqs/) |
| **Automation** | Boto3 Messaging Client | SDK | Intermediate | [Visit](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sqs.html) |

---

## ✦ Industrial Labs & Challenges

### 🧪 Lab 1: Reliable Event Processor (Fan-Out)
- **Goal:** Build a system where an image upload triggers both a thumbnail generator and an analytics tracker.
- **Workflow:** S3 Event → SNS Topic → (SQS Queue 1 & SQS Queue 2).
- **Validation:** Upload a file and verify two separate messages appear in the respective queues.

### 🧪 Lab 2: The "Chaos" Consumer (DLQ Logic)
- **Goal:** Test error handling and message persistence.
- **Workflow:** 
    1. Create a "Source Queue" and a "Dead Letter Queue."
    2. Configure a Redrive Policy (Max Receive Count: 3).
    3. Use the CLI to receive a message without deleting it 3 times.
- **Validation:** Verify the message automatically moves to the DLQ on the 4th attempt.

### 🧪 Lab 3: Kinesis Real-time Log Stream
- **Goal:** Ingest simulated web logs into S3 using Kinesis Data Firehose.
- **Workflow:** KDS → Firehose → S3.
- **Validation:** Use the Kinesis Data Generator to pump data and check S3 for partitioned output.

