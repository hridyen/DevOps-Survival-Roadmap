# ✦ Module: Terraform Practical Examples

> **Real-World Terraform Configurations.** Hands-on examples of local and cloud resources managed by Terraform.

---

## ✦ Example 1: Create a Local File

The simplest possible Terraform resource — creates a file on your local machine. Great for learning the workflow without needing cloud credentials.

**`variables.tf`**
```hcl
variable "filename" {
  description = "Path where the file will be created"
  type        = string
  default     = "/tmp/demo-var.txt"
}

variable "content" {
  description = "Content to write into the file"
  type        = string
  default     = "Hello from Terraform variables!"
}
```

**`main.tf`**
```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "demo" {
  filename = var.filename
  content  = var.content
}
```

**Run it:**
```bash
terraform init
terraform plan
terraform apply
cat /tmp/demo-var.txt    # Verify file was created
terraform destroy
```

---

## ✦ Example 2: AWS EC2 Instance

Core AWS provisioning example with variables and outputs.

**`variables.tf`**
```hcl
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "Must be one of: t2.micro, t2.small, t2.medium."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
```

**`main.tf`**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "devops-training"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  tags = merge(local.common_tags, {
    Name = "web-server-${var.environment}"
  })
}
```

**`outputs.tf`**
```hcl
output "instance_id" {
  description = "The EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "The public IP address"
  value       = aws_instance.web_server.public_ip
}
```

**`terraform.tfvars`**
```hcl
aws_region    = "us-east-1"
instance_type = "t2.micro"
environment   = "dev"
```

---

## ✦ Example 3: Remote State with S3 Backend

Production-grade setup: state stored remotely with locking.

**`backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-company-terraform-state"
    key            = "devops-training/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

**Create the S3 bucket and DynamoDB table first (one-time setup):**
```bash
aws s3 mb s3://my-company-terraform-state --region us-east-1

aws s3api put-bucket-versioning \
  --bucket my-company-terraform-state \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

> [!IMPORTANT]
> Always enable versioning on the S3 state bucket to preserve state history and recover from accidental deletions.

---

## ✦ Recommended Project Structure

```
my-terraform-project/
├── main.tf            ← Core resources
├── variables.tf       ← All variable declarations
├── outputs.tf         ← All output declarations
├── locals.tf          ← All local values
├── providers.tf       ← Provider + backend config
├── terraform.tfvars   ← Default variable values (don't commit secrets)
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    └── web-server/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
