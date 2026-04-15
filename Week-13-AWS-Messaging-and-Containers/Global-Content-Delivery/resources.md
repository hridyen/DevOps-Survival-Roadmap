[![Sector](https://img.shields.io/badge/SECTOR-NETWORK-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Global Content Resources

| Resource | Description | Link |
|---|---|---|
| **CloudFront Developer Guide** | Deep dive into CDN configuration | [Official Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html) |
| **Global Accelerator Explained** | Why use Anycast IP? | [AWS Deep Dive](https://aws.amazon.com/global-accelerator/features/) |
| **CDN Performance Testing** | Testing your edge speeds | [KeyCDN Tools](https://tools.keycdn.com/performance) |
| **Origin Access Control (OAC)** | Securing S3 origins | [AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-cloudfront-introduces-origin-access-control-oac/) |

---

## ✦ Recommended Labs
1. **Static Site CDN:** Host a static website on S3, put CloudFront in front of it, and configure OAC so people can't access the S3 link directly.
2. **Invalidation Test:** Change a file in your S3 bucket, verify the CDN still shows the old one, then run an invalidation and see the change.
