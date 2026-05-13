# ✦ Module: Terraform File Structure

> **Organize Your Code.** A well-structured repository makes Terraform code maintainable, readable, and scalable across teams.

---

## ✦ The Standard File Layout

While Terraform doesn't strictly enforce a directory structure (it combines all `.tf` files in a directory into a single configuration), adhering to a standard file layout is a critical best practice for team collaboration.

A typical industrial-grade Terraform project structure:

```text
my-terraform-project/
├── main.tf                 # Core resource declarations
├── variables.tf            # Input variables and type constraints
├── outputs.tf              # Exported values
├── providers.tf            # Provider configurations and versions
├── terraform.tfvars        # Values for your variables (do not commit sensitive data)
├── backend.tf              # Remote state configuration (S3, Terraform Cloud)
├── locals.tf               # Local computed values (optional, often kept in main.tf if small)
└── README.md               # Project documentation
```

---

## ✦ Core Files Deep Dive

### 1. `main.tf`
The entry point of your configuration. It should primarily contain the **resources** and **data sources** you are provisioning.
- If your configuration grows beyond 200-300 lines, consider splitting `main.tf` into logically grouped files (e.g., `vpc.tf`, `ec2.tf`, `rds.tf`).

### 2. `variables.tf`
Contains all `variable` blocks. 
- Always define a `type` and `description` for each variable.
- Include `validation` blocks for critical inputs.

### 3. `outputs.tf`
Contains all `output` blocks.
- Outputs expose information about the created infrastructure (e.g., public IPs, DNS names, resource ARNs).
- These are essential when your project is used as a module by another Terraform configuration.

### 4. `providers.tf`
Separating provider configurations from `main.tf` keeps your code clean.
- Define `required_providers` with strict version constraints to avoid breaking changes.

```hcl
terraform {
  required_version = ">= 1.5.0"
  
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
```

### 5. `terraform.tfvars`
The default file Terraform automatically loads to populate variables.
- You can have multiple tfvars files for different environments (e.g., `dev.tfvars`, `prod.tfvars`) and load them explicitly using `terraform apply -var-file="dev.tfvars"`.

> [!WARNING]
> Never commit `.tfvars` files containing secrets (like passwords or API keys) to version control. Use `.gitignore` to exclude them, or manage secrets via AWS Secrets Manager/HashiCorp Vault.

---

## ✦ Multi-Environment Strategies

As your project scales across Development, Staging, and Production, you need a strategy to manage state and configurations per environment.

### Strategy 1: Workspaces (Simple)
Terraform Workspaces allow you to use the **same code** with **different state files**.

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select prod
```
*Best for:* Identical infrastructure across environments.

### Strategy 2: Directory Separation (Industrial Standard)
The most robust way to manage multiple environments is by separating them into physical directories, using a shared modules directory.

```text
infrastructure/
├── modules/
│   ├── vpc/
│   └── web_server/
├── environments/
│   ├── dev/
│   │   ├── main.tf        # Calls modules with dev variables
│   │   ├── variables.tf
│   │   └── dev.tfvars
│   └── prod/
│       ├── main.tf        # Calls modules with prod variables
│       ├── variables.tf
│       └── prod.tfvars
```
*Best for:* When prod and dev have structural differences, and to blast-radius isolate environments.
