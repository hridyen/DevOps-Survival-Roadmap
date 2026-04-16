[![Sector](https://img.shields.io/badge/SECTOR-CONTAINERS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 🐳 Containers on AWS (ECS & ECR)

> **Week:** 13
> **Folder:** Containers-ECS-ECR
> **Topic:** Elastic Container Service & Registry

---

## ✦ Introduction to AWS Containers

While running Docker on EC2 is possible, it's not "Cloud Native." **Amazon ECS** provides a managed control plane to orchestrate your containers at scale, handling placement, health checks, and lifecycle management.

---

## ✦ 1. Amazon ECR: Elastic Container Registry

ECR is your private Docker Hub. It stores, manages, and deploys Docker images.

### ⚡ Industrial Workflows
- **Image Scanning:** Automatically scan images for vulnerabilities upon push (integrated with Clair).
- **Lifecycle Policies:** Automatically clean up old images (e.g., "Keep only the last 10 tagged images") to save costs.
- **Cross-Region Replication:** Sync images across regions for multi-region disaster recovery.

```mermaid
graph LR
    classDef local fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF;
    classDef cloud fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF;
    classDef deploy fill:#0A0A0A,stroke:#39FF14,stroke-width:2px,color:#FFFFFF;

    A[CI/CD: docker build]:::local --> B[AWS ECR: Scan & Store]:::cloud
    B --> C[AWS ECS: Pull & Deploy]:::deploy
```

---

## ✦ 2. Amazon ECS: Elastic Container Service

ECS consists of three main components: **Task Definitions**, **Tasks**, and **Services**.

### ⚡ The Blueprint: Task Definition
A JSON file that describes how your container should run:
- **Execution Role:** Allows ECS agent to pull from ECR and log to CloudWatch.
- **Task Role:** IAM role for the application code *inside* the container to access S3, DynamoDB, etc.
- **Network Mode:**
    - `awsvpc` (Default for Fargate): Every task gets its own ENI and private IP.
    - `bridge`: Docker's classic virtual network.
    - `host`: Bypasses Docker's network, uses the host's IP directly.

### ⚡ Task Placement Strategies (EC2 Launch Type)
How ECS decides *where* to put your container:
- **Binpack:** Place on the instance with the least available CPU/RAM (Minimizes cost).
- **Spread:** Place across different instances or AZs (Maximizes availability).
- **Random:** Randomized placement.

---

## ✦ 3. Fargate vs. EC2 Launch Types

| Feature | ECS on EC2 | **AWS Fargate** |
|---|---|---|
| **Underlying Host** | You manage EC2 instances | **Serverless** (No hosts) |
| **Effort** | High (Patching, Scaling) | Low (Focus on Code) |
| **Isolation** | Shared OS kernel | Dedicated VM-level isolation |
| **Cost** | Fixed cost of EC2 runtime | Pay-per-use (vCPU/RAM) |

---

## ✦ 🐳 Personal Notes & Interview Tips

- **Dynamic Port Mapping:** When using an ALB with `bridge` or `host` mode, you don't need to specify a host port. ECS assigns a random port (32768-65535) and updates the Target Group automatically.
- **Capacity Providers:** The best practice for scaling. They link an ECS cluster to an ASG, ensuring that if you need more tasks, the underlying EC2 instances are launched automatically.
- **Service Connect:** AWS's native service mesh (based on Envoy). Simplifies service-to-service communication with retries, timeouts, and metrics without a complex setup.
- **Blue/Green Deployment:** Integrated with **AWS CodeDeploy**. It creates a new set of tasks, shifts traffic gradually, and rolls back if health checks fail.

