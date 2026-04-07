[![Sector](https://img.shields.io/badge/SECTOR-AWS_Storage-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-EBS_EFS_Storage_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 💾 Industrial AWS Storage — Multi-Tier Architectures

> **Architectural Goal:** Transition from "General Storage" to "Performance-Optimized & Cost-Efficient" block and file systems.

---

## ✦ 1. Elastic Block Store (EBS) Fundamentals

### ✦ What is an EBS Volume?
An **EBS (Elastic Block Store) Volume** is a network drive you can attach to your instances while they run.

- **Network-Attached Persistence**: Data persists even after the instance is terminated.
- **Single Mounting (CCP Level)**: Mounted to one instance at a time.
- **AZ-Bound**: Locked to a specific Availability Zone (e.g., `us-east-1a`).
- **Analogy**: Think of it as a **"Network USB Stick"**.

> [!TIP]
> **Performance Catch**: Because it is a network drive, not physical, there might be a bit of latency, but it can be detached and reattached to another instance in the same AZ instantly.

---

## ✦ 2. EBS Volume Types Performance Matrix

| Storage Category | Volume Type | Use Case | Performance Caps | Cost/GB |
|---|---|---|---|---|
| **SSD (Gen Purpose)** | **gp3** | Wide variety of workloads | 3k IOPS (Baseline), 125 MiB/s | **$0.08** |
| **SSD (Gen Purpose)** | **gp2** | Dev/Test, Boot volumes | 3 IOPS/GiB, Max 16k IOPS | **$0.10** |
| **SSD (Provisioned)** | **io2** | Mission-critical, SQL/NoSQL | 64k IOPS (sub-ms latency) | **$0.125** |
| **SSD (Provisioned)** | **io1** | Business-critical, High I/O | 32k IOPS (Consistent) | **$0.125** |
| **HDD (Optimized)** | **st1** | Big Data, Log processing | 500 IOPS, 500 MiB/s | **$0.045** |
| **HDD (Cold)** | **sc1** | Frequently accessed datasets | 250 IOPS, 250 MiB/s | **$0.025** |

### ✦ Multi-Attach (io1/io2)
Allows attaching a single volume to multiple instances in the same AZ.
- **Use Case**: Concurrent write applications (Database clusters).
- **Hard Requirement**: Must be built on the **AWS Nitro System**.

---

## ✦ 3. Advanced Snapshot Ecosystem

### ✦ Key Snapshot Features:
- **EBS Snapshot Archive**: Moves snapshots to a cold, cost-effective tier (Restore takes 24-72 hrs).
- **Recycle Bin**: Lifecycle rules to recover accidentally deleted snapshots (1 day to 1 year retention).
- **Fast Snapshot Restore (FSR)**: Provisioned capacity on a snapshot to eliminate initial latency for first-touch IOPS.

### ✦ Encryption Workflow (Standard Practice)
To encrypt an unencrypted EBS volume:
1. **Snapshot** the unencrypted volume.
2. **Encrypted Copy**: Copy the snapshot and tick the "Encrypt" box.
3. **Instance Deployment**: Create a new EBS volume from the encrypted snapshot.
4. **Volume Swap**: Attach the newly encrypted volume to the instance.

---

## ✦ 4. AMI (Amazon Machine Image) Lifecycle

An **AMI** is a pre-packaged customization of an EC2 instance, containing your software, configuration, and OS state.

```mermaid
graph TD
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef highlight fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;

    Step1[Start & Customize Instance]
    Step2[Stop Instance <br/>(Ensure Data Integrity)]
    Step3[Build AMI <br/>(Creates Snapshots)]:::highlight
    Step4[Launch New Instances <br/>From AMI]
    
    Step1 --> Step2 --> Step3 --> Step4
```

- **Boot Speed**: Dramatic reduction in boot time since software is pre-loaded.
- **Regional Bound**: AMIs are built for a specific region (but can be copied).
- **AMI Sources**: Public (AWS), Personal (Owned), or AWS Marketplace (Commercial).

---

## ✦ 5. Amazon EFS (Elastic File System)

A shared, scalable, pay-as-you-go file system using the **NFSv4** protocol.

- **Multi-AZ Awareness**: Accessible by instances across different AZs simultaneously.
- **Access Control**: Managed strictly via **Security Groups**.
- **Tiering**: 
  - **EFS Infrequent Access (EFS IA)**: Cost-optimized for files not accessed daily (serverless savings).
  - **EFS One Zone**: Stores data in a single AZ (higher risk, lower cost).

> [!IMPORTANT]
> **Compatibility**: EFS is compatible with both Linux-based AMIs and Windows. Encryption is supported at-rest (KMS) and in-transit (TLS).

---

## ✦ Technical Deep-Dive Checklist
- [ ] Migrate a **GP2 (bundled)** instance to **GP3 (decoupled)** using CLI.
- [ ] Implement an **Encryption Swap** for a production root volume.
- [ ] Create a **Custom AMI** and verify boot time improvements.
- [ ] Mount an **EFS share** across two instances in different subnets.
