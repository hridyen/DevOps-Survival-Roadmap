[![Sector](https://img.shields.io/badge/SECTOR-CONTAINERS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Containers CLI Reference (ECS/ECR)

## ✦ 1. Amazon ECR Commands

### ✦ Lifecycle & Auth
```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region <REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com

# Create Repository with Image Scanning
aws ecr create-repository --repository-name prod-app --image-scanning-configuration scanOnPush=true

# List Images in Repository
aws ecr list-images --repository-name prod-app
```

### ✦ Image Operations
```bash
# Tag and Push Image
docker tag local-app:latest <REPO_URL>:v1
docker push <REPO_URL>:v1

# Multi-arch Tagging (Simulated)
docker buildx build --platform linux/amd64,linux/arm64 -t <REPO_URL>:multi-arch --push .
```

---

## ✦ 2. Amazon ECS Commands

### ✦ Task Definitions
```bash
# Register a Task Definition from JSON
aws ecs register-task-definition --cli-input-json file://task-def.json

# List Task Definition Families
aws ecs list-task-definition-families

# Describe a specific Task Definition
aws ecs describe-task-definition --task-definition my-app:1
```

### ✦ Cluster & Service Management
```bash
# Create a Cluster
aws ecs create-cluster --cluster-name devops-cluster

# Update Service (Scale Out)
aws ecs update-service --cluster devops-cluster --service my-service --desired-count 5

# Force New Deployment (Pulls latest image)
aws ecs update-service --cluster devops-cluster --service my-service --force-new-deployment
```

### ✦ Debugging & Troubleshooting
```bash
# List Tasks in Cluster
aws ecs list-tasks --cluster devops-cluster

# Describe Task (Check status/errors)
aws ecs describe-tasks --cluster devops-cluster --tasks <TASK_ID>

# Execute Command (SSH into Container)
# Requires 'enableExecuteCommand=true' on the Service/Task
aws ecs execute-command --cluster devops-cluster --task <TASK_ID> --container app-container --interactive --command "/bin/sh"
```

---

## ✦ 3. Copilot CLI (Pro Tip)
AWS Copilot is the recommended way to manage containers for standard web patterns.
```bash
copilot init       # Initializes a container app (sets up VPC, ECS, ALB)
copilot deploy     # Deploys current code to Fargate
copilot svc show   # Shows status and logs of your service
```
