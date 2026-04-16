[![Sector](https://img.shields.io/badge/SECTOR-NETWORK-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Global Delivery Resources

| Category | Resource | Type | Level | Link |
|---|---|---|---|---|
| **Workshop** | CloudFront & Edge Workshop | Interactive | All Levels | [Visit](https://github.com/aws-samples/amazon-cloudfront-edge-workshop) |
| **Deep Dive** | Global Accelerator Whitepaper | Document | Advanced | [Visit](https://d1.awsstatic.com/whitepapers/aws-global-accelerator-performance-benefits.pdf) |
| **Security** | Securing S3 with CloudFront (OAC) | Technical | Intermediate | [Visit](https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-cloudfront-introduces-origin-access-control-oac/) |
| **Speed** | CloudFront Performance Monitoring | Guide | Intermediate | [Visit](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/monitoring-using-cloudwatch.html) |
| **Comparison** | Anycast vs Unicast Explained | Educational | Beginner | [Visit](https://www.cloudflare.com/learning/network-layer/what-is-anycast/) |

---

## ✦ Industrial Labs & Challenges

### 🧪 Lab 1: Origin Failover Resilience
- **Goal:** Build a website that stays up even if the primary S3 bucket is deleted (simulated).
- **Workflow:** 
    1. Create two S3 buckets in different regions (e.g., `us-east-1` and `eu-west-1`).
    2. Upload the same `index.html` to both.
    3. Configure a **CloudFront Origin Group** with the first bucket as Primary.
- **Validation:** Delete the file in the Primary bucket and verify CloudFront serves it from the Secondary after a short delay (or based on error code config).

### 🧪 Lab 2: Geo-Restricted Marketing
- **Goal:** Allow only specific countries to access a "Regional Sale" page.
- **Workflow:** 
    1. Create a CloudFront distribution.
    2. Enable **Geo-Restriction** (Whitelist approach).
    3. Use a VPN to test access from allowed vs. blocked countries.
- **Validation:** Verify you get a `403 Forbidden` from restricted IPs.

### 🧪 Lab 3: Edge Logic with CF Functions
- **Goal:** Implement a simple URL rewrite at the Edge.
- **Workflow:** 
    1. Write a CloudFront Function to append `.html` to requests that don't have an extension.
    2. Associate it with the Viewer Request event.
- **Validation:** Request `example.com/about` and verify it serves `about.html`.

