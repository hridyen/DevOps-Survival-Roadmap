[![Sector](https://img.shields.io/badge/SECTOR-NETWORK-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Global Content CLI Reference

## ✦ 1. Amazon CloudFront Commands

### ✦ List Distributions
```bash
aws cloudfront list-distributions
```

### ✦ Create a Cache Invalidation
Forces CloudFront to refresh content from the origin.
```bash
aws cloudfront create-invalidation --distribution-id <DIST_ID> --paths "/*"
```

---

## ✦ 2. AWS Global Accelerator Commands

### ✦ List Accelerators
```bash
aws globalaccelerator list-accelerators
```

### ✦ Describe Accelerator
```bash
aws globalaccelerator describe-accelerator --accelerator-arn <ARN>
```
