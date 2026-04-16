[![Sector](https://img.shields.io/badge/SECTOR-STORAGE-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Storage & Migration Resources

| Category | Resource | Type | Level | Link |
|---|---|---|---|---|
| **Workshop** | AWS Hybrid Storage Workshop | Interactive | Intermediate | [Visit](https://hybrid-storage.workshop.aws/) |
| **Deep Dive** | Snowball Edge Decision Guide | Guide | Intermediate | [Visit](https://docs.aws.amazon.com/snowball/latest/developer-guide/what-is-snowball-edge.html) |
| **Technical** | FSx for Lustre Scaling | Technical | Advanced | [Visit](https://docs.aws.amazon.com/fsx/latest/LustreGuide/performance.html) |
| **Video** | Storage Gateway Architecture | Video | Intermediate | [Visit](https://www.youtube.com/watch?v=F_I9S-R3Q8M) |
| **Dashboard** | AWS Migration Hub | Tool | All Levels | [Visit](https://aws.amazon.com/migration-hub/) |

---

## ✦ Industrial Labs & Challenges

### 🧪 Lab 1: Hybrid File Gateway (S3 Mapping)
- **Goal:** Access S3 objects as local files.
- **Workflow:** 
    1. Deploy a **Storage Gateway** (VMware/EC2 instance).
    2. Configure an **S3 File Gateway** linked to an S3 bucket.
    3. Mount the S3 bucket onto a Linux system using NFS.
- **Validation:** Copy a file to the mount point and verify it appears in the S3 console immediately.

### 🧪 Lab 2: DataSync Migration Speedtest
- **Goal:** Move 1000 small files from an EFS volume to an S3 bucket using DataSync.
- **Workflow:** 
    1. Create an EFS file system and an S3 bucket.
    2. Set up a **DataSync Task**.
    3. Execute the sync and monitor performance.
- **Validation:** Compare the "S3 sync" performance vs. standard `aws s3 cp --recursive` to see the speedup.

### 🧪 Lab 3: Snowball Edge Compute (Simulation)
- **Goal:** Understand how to run a container on a Snowball device.
- **Workflow:** 
    1. Research the **AWS OpsHub** for Snow Family.
    2. Document the steps to register an AMI for Snowball.
    3. Understand how to launch an EC2 instance on the physical device.
- **Validation:** Detail the exact CLI command used to launch an instance on Snowball.

