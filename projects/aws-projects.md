[![Sector](https://img.shields.io/badge/SECTOR-projects-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-aws_projects-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ ☁️ AWS Cloud Projects

> Production-grade cloud architectures and deployments built during AWS Cloud Training.

---

## ✦ Project 1: Event-Driven File Processing System

**Description:** An automated, event-driven cloud architecture built on AWS that leverages serverless and containerized services to process and serve file metadata with a secure, private networking design. 

This architecture utilizes an **Event-Driven Pattern** where storage directly triggers compute, eliminating polling and manual backend tracking.

**Stack:**
- AWS Lambda, S3, DynamoDB
- Amazon ECS (Fargate), ECR, ALB
- Node.js (Lambda) / Node.js Express (ECS Backend)
- Docker
- Amazon CloudWatch

**What I learned:**
- **Event Persistence:** Handling asynchronous S3 events and ensuring idempotent writes to DynamoDB.
- **Private Connectivity:** Interfacing ECS Tasks in private subnets with DynamoDB and S3 using VPC Gateway Endpoints to avoid NAT Gateway data costs.
- **IAM Granularity:** Separating ECS Task Roles (for querying DynamoDB) from Execution Roles (for pulling ECR images).

**GitHub Repo:** https://github.com/hridyen/Event-Driven-File-Processing

---

## ✦ Project 2: Secure ECS Fargate Deployment

**Description:** A production-grade deployment strategy for containerized Node.js applications on AWS ECS Fargate, featuring a custom VPC architecture, private subnets, and VPC Endpoints for enhanced security and cost efficiency.

Deploying containers in public subnets exposes them to the internet, while relying on NAT Gateways for private subnet outbound traffic incurs heavy data transfer costs. This project implements a **Fully Private Architecture** using **VPC Endpoints** (PrivateLink).

**Stack:**
- AWS ECS (Fargate), ECR, ALB
- Custom VPC (Private Subnets, Interface & Gateway Endpoints)
- Docker & Node.js
- AWS CloudWatch

**What I learned:**
- **Zero-Trust Network:** Running ECS Fargate tasks in completely isolated Private Subnets with no internet access.
- **Cost Optimization:** Replacing expensive NAT Gateways with VPC Endpoints for ECR, S3, and CloudWatch.
- **VPC Endpoint Routing:** Configuring security groups to allow private internal pulling of Docker images from ECR.
- **Debugging:** Troubleshooting tasks stuck in "Pending" by analyzing route tables and endpoint policies.

**GitHub Repo:** https://github.com/hridyen/Secure-ECS-Fargate-Deployment-with-Private-Networking-AWS-

---

## ✦ 📝 Notes

Will be adding more cloud projects on the way.
