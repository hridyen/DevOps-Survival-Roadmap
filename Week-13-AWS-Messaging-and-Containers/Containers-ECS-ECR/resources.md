[![Sector](https://img.shields.io/badge/SECTOR-CONTAINERS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# 📚 Container & Orchestration Resources

| Category | Resource | Type | Level | Link |
|---|---|---|---|---|
| **Workshop** | Official ECS Workshop | Interactive | All Levels | [Visit](https://ecsworkshop.com/) |
| **CLI Tool** | AWS Copilot CLI | Guide | Intermediate | [Visit](https://aws.github.io/copilot-cli/) |
| **Best Practices** | ECS Task Definition Best Practices | Docs | Advanced | [Visit](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html) |
| **Networking** | ECS Networking Deep Dive | Video | Advanced | [Visit](https://www.youtube.com/watch?v=7M0f_UAb-0A) |
| **Security** | ECR Image Scanning Guide | Technical | Intermediate | [Visit](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html) |

---

## ✦ Industrial Labs & Challenges

### 🧪 Lab 1: The Zero-Downtime Deployment
- **Goal:** Update an ECS Service without dropping a single request.
- **Workflow:** 
    1. Deploy a "V1" nginx image to an ECS Service behind an ALB.
    2. Update the Task Definition to "V2."
    3. Update the Service and observe the **Rolling Update** behavior.
- **Validation:** Run a `curl` loop and verify you see both V1 and V2 responses during the transition.

### 🧪 Lab 2: Multi-Container Tasks (Sidecar Pattern)
- **Goal:** Deploy a main application container with a logging sidecar.
- **Workflow:** 
    1. Create a Task Definition with two containers.
    2. Container 1: Simple web app.
    3. Container 2: Fluent-bit or Logspout (Sidecar).
    4. Link them via shared volumes or `localhost` networking.
- **Validation:** Verify that logs from Container 1 are being captured and processed by Container 2.

### 🧪 Lab 3: Fargate "Spot" Savings
- **Goal:** Run a batch processing job using Fargate Spot to save 70% cost.
- **Workflow:** 
    1. Create an ECS Cluster with a **Fargate Spot** Capacity Provider.
    2. Run a standalone task using the Spot provider.
- **Validation:** Check the ECS console/CLI to confirm the task is running on Spot infrastructure.

