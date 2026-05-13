# ✦ Module: Terraform Data Sources

> **Query Existing Infrastructure.** Fetch real-time data about resources created outside of your current Terraform configuration.

---

## ✦ What is a Data Source?

While `resource` blocks are used to **create** and **manage** infrastructure, `data` blocks are used to **read** and **query** infrastructure that already exists. 

This could be infrastructure managed by another Terraform workspace, managed manually via the AWS Console, or simply a query for an AWS Managed resource (like an AMI ID).

**Syntax:**
```hcl
data "provider_type" "local_name" {
  # Query filters go here
}
```

---

## ✦ Why use Data Sources?

1. **Decoupling:** You don't have to put all your infrastructure in one giant state file. You can have a "Networking" workspace that creates VPCs, and an "App" workspace that queries the VPC using a data source.
2. **Dynamic Queries:** Hardcoding an Amazon Machine Image (AMI) ID is dangerous because AWS frequently updates them. A data source dynamically finds the latest AMI.
3. **Safety:** Data sources are strictly **read-only**. They will never create, update, or delete infrastructure.

---

## ✦ Common AWS Data Source Examples

### 1. Fetching the Latest Ubuntu AMI

This is the most common use case. Instead of hardcoding `ami-0c55b159cbfafe1f0`, query it dynamically:

```hcl
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id  # Reference the data source
  instance_type = "t3.micro"
}
```

### 2. Querying an Existing VPC

If the Networking team already created a VPC, you can fetch its ID by querying its tags:

```hcl
data "aws_vpc" "production" {
  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}

# Fetch subnets within that VPC
data "aws_subnets" "prod_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.production.id]
  }
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnets.prod_public.ids[0]
}
```

### 3. Fetching AWS Account Info

Sometimes you need your AWS Account ID or current Region for IAM Policies or ARNs.

```hcl
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region_name" {
  value = data.aws_region.current.name
}
```

---

## ✦ Best Practices

> [!TIP]
> **Combine Data Sources with `terraform_remote_state`**
> If you have distinct Terraform projects, you can use the `terraform_remote_state` data source to read the `outputs` of another Terraform state file directly.

```hcl
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state-bucket"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"
  # Pulling the VPC ID exported as an output in the networking state
  subnet_id     = data.terraform_remote_state.networking.outputs.public_subnet_id
}
```
