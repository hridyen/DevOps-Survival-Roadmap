[![Sector](https://img.shields.io/badge/SECTOR-CONTAINERS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Containers CLI Reference (ECS/ECR)

## ✦ 1. Amazon ECR Commands

### ✦ Authenticate Docker to ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### ✦ Create a Repository
```bash
aws ecr create-repository --repository-name devops-roadmap-app
```

### ✦ Tag and Push Image
```bash
docker tag my-local-app:latest <REPO_URL>:latest
docker push <REPO_URL>:latest
```

---

## ✦ 2. Amazon ECS Commands

### ✦ List Clusters
```bash
aws ecs list-clusters
```

### ✦ List tasks in a Cluster
```bash
aws ecs list-tasks --cluster <CLUSTER_NAME>
```

### ✦ Update a Service (Force new deployment)
```bash
aws ecs update-service --cluster <CLUSTER_NAME> --service <SERVICE_NAME> --force-new-deployment
```
---

## ✦ 3. Copilot CLI (Pro Tip)
AWS Copilot is the modern way to manage containers.
```bash
copilot init # Initializes a container app
copilot deploy # Deploys to ECS/Fargate
```
