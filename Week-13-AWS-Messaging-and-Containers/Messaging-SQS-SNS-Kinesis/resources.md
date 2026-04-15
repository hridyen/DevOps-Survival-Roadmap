[![Sector](https://img.shields.io/badge/SECTOR-MESSAGING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Messaging Resources

| Resource | Description | Link |
|---|---|---|
| **AWS SQS Documentation** | Official developer guide for SQS | [Official Docs](https://docs.aws.amazon.com/sqs/) |
| **SNS Pub/Sub Patterns** | Understanding communication patterns | [AWS Blog](https://aws.amazon.com/getting-started/hands-on/send-fan-out-notifications-sns-sqs/) |
| **Kinesis vs SQS** | In-depth comparison of streaming vs queuing | [Article](https://aws.amazon.com/sqs/faqs/) |
| **AWS SDK for Python (Boto3)** | Using Messaging services in scripts | [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) |

---

## ✦ Recommended Labs
1. **Fan-Out Pattern:** Create an SNS topic and subscribe two SQS queues. Publish a message to the topic and verify it arrives in both queues.
2. **Dead Letter Queue:** Create an SQS queue with a retry limit of 2. Send a message, "receive" it but don't delete it (multiple times), and watch it move to the DLQ.
