[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Edge & Integration Resources

> Advanced guides for distributed logic and resilient data access.

---

### ✦ Core Learning Path

| Type | Resource Name | Description | Key Focus |
|---|---|---|---|
| **Doc** | [Edge Computing Comparison](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-choosing.html) | Official choice matrix for CloudFront logic. | CloudFront Functions |
| **Tutorial** | [Serverless Image Handler](https://aws.amazon.com/solutions/implementations/serverless-image-handler/) | Real-world thumbnail solution architecture. | Event-Driven Apps |
| **Guide** | [Managing RDS Connections](https://aws.amazon.com/blogs/compute/using-amazon-rds-proxy-with-aws-lambda/) | Best practices for SQL in a serverless world. | RDS Proxy |
| **Workshop** | [EventBridge Patterns](https://github.com/aws-samples/amazon-eventbridge-resource-policy-samples) | Cross-account event routing and security. | EventBridge |

---

### ✦ Practical Demos
- **[A/B Testing at the Edge](https://aws.amazon.com/blogs/networking-and-content-delivery/leveraging-lambdaedge-for-ab-testing/):** How to shift traffic without redeploying your frontend.
- **[Dynamic Content Personalization](https://aws.amazon.com/blogs/networking-and-content-delivery/personalizing-content-at-the-edge-with-lambdaedge/):** Serving user-specific content from CloudFront.

---

### ✦ Optimization Tools
- **[CloudFront Log Analyzer](https://github.com/awslabs/aws-cloudfront-log-analyzer):** Parse edge logs to find performance bottlenecks.

---

> [!NOTE]
> **Industrial Standard:** For basic header security (HSTS, CSP), always prefer **CloudFront Functions** over Lambda@Edge for the lowest cost and latency impact.
