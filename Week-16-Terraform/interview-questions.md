# ⚡ Week 16 — Terraform IaC Basics Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform core concepts, backend configurations, state locking, variable structures, and workflows.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You are setting up Terraform for a team of 10 engineers. How do you configure a secure remote backend using Amazon S3 for state storage and DynamoDB for state locking? Provide HCL configuration examples.</b></summary>
<b>Answer:</b>
1. **S3 Bucket:** Stores the `terraform.tfstate` file. You must enable versioning (to recover from accidental corruption) and KMS encryption (since tfstate contains plaintext secrets).
2. **DynamoDB Table:** Handles state locking. The table must have a primary partition key named `LockID` of type String.
3. **HCL Configuration:**
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-company-terraform-state-bucket"
       key            = "production/infrastructure.tfstate"
       region         = "us-east-1"
       encrypt        = true
       dynamodb_table = "terraform-state-locking-table"
     }
   }
   ```
4. **Operation:** When an engineer runs `terraform apply`, Terraform writes an entry containing their execution details into the DynamoDB table. If another engineer tries to run a plan/apply simultaneously, Terraform detects the lock and blocks execution, preventing state file corruption.
</details>

<details>
<summary><b>Q2: Scenario: An engineer's local machine lost internet connectivity halfway through running a `terraform apply`. The next time team members attempt to run a plan, they get a "State Lock Error" pointing to a DynamoDB lock ID. How do you resolve this?</b></summary>
<b>Answer:</b>
When an apply fails abruptly, Terraform fails to release the lock in DynamoDB.
- **Resolution Steps:**
  1. **Identify Lock Info:** The error message will display a **Lock ID** (a long UUID).
  2. **Verify Process Status:** Ensure that the original apply run has indeed stopped and is not still running in a CI/CD agent or background terminal (otherwise, forcing a release will corrupt the state).
  3. **Force Unlock:** Run the `force-unlock` command passing the Lock ID:
     ```bash
     terraform force-unlock <LOCK_ID>
     ```
  4. **Alternative manual fix:** If the CLI command fails, navigate to the DynamoDB console, search for the lock entry in the locking table matching the Lock ID, and delete the row.
</details>

<details>
<summary><b>Q3: Scenario: Terraform state files often contain sensitive information in plaintext (such as database master passwords or API tokens). How do you secure the state file, and what are the best practices for secret management in Terraform?</b></summary>
<b>Answer:</b>
- **State Security:**
  1. **Access Control:** Restrict access to the S3 remote backend bucket using bucket policies, ensuring only administrators and CI/CD IAM roles have access.
  2. **Encryption:** Enforce KMS encryption on the S3 bucket using a Customer Managed Key (CMK), allowing access auditing via CloudTrail.
- **Secret Management Best Practices:**
  1. **Never Hardcode:** Do not hardcode credentials in `.tf` files.
  2. **SSM/Secrets Manager Integration:** Reference secrets dynamically from AWS Secrets Manager or SSM Parameter Store using data sources:
     ```hcl
     data "aws_secretsmanager_secret_version" "db_password" {
       secret_id = "prod-db-credentials"
     }
     ```
  3. **Mark as Sensitive:** Mark inputs variables containing secrets as `sensitive = true`. This prevents Terraform from outputting them in plaintext to the console terminal during plans/applies.
</details>

<details>
<summary><b>Q4: Scenario: You have variables defined in multiple locations: a default value in `variables.tf`, a setting in `terraform.tfvars`, an environment variable (`TF_VAR_db_pass`), and a command-line flag `-var="db_pass=xyz"`. What is the evaluation order (precedence) of these values?</b></summary>
<b>Answer:</b>
Terraform evaluates input variables in the following order of precedence (from **lowest to highest**; later values override earlier ones):
1. **Environment variables** (e.g. `TF_VAR_variable_name`).
2. **The `terraform.tfvars` file**.
3. **The `terraform.tfvars.json` file**.
4. **Any `*.auto.tfvars` or `*.auto.tfvars.json` files**, evaluated in alphabetical order of their filenames.
5. **Command-line flags** `-var` or `-var-file` (in the order they are specified).

*In this scenario, the value provided via the command-line flag `-var="db_pass=xyz"` has the highest precedence and will be used.*
</details>

<details>
<summary><b>Q5: Scenario: You want to ensure that developers only pass valid inputs to your Terraform variables. For instance, the `environment` variable must only accept "dev", "stage", or "prod", and the `ami_id` variable must start with "ami-". How do you enforce this?</b></summary>
<b>Answer:</b>
Use **Variable Validation Blocks** with HCL custom conditions:
```hcl
variable "environment" {
  type        = string
  description = "Target deployment environment"
  
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "The environment variable must be one of: dev, stage, or prod."
  }
}

variable "ami_id" {
  type        = string
  description = "The target AWS AMI ID"

  validation {
    condition     = can(regex("^ami-[a-f0-9]+$", var.ami_id))
    error_message = "The ami_id value must start with 'ami-' followed by a valid hexadecimal hash."
  }
}
```
If a developer runs `terraform plan` with an invalid parameter, Terraform throws the `error_message` immediately before modifying or assessing infrastructure.
</details>

<details>
<summary><b>Q6: Scenario: How do HCL Local Values (`locals`) differ from standard Input Variables (`variable`)? In what architectural scenarios would you choose one over the other?</b></summary>
<b>Answer:</b>
- **Input Variables (`variable`):**
  - Act as parameters or arguments for a module. They allow users to customize the behavior of the configurations dynamically (from command-line, files, or environment).
  - *When to use:* For any setting that changes depending on the environment (e.g., region, instance count, database name).
- **Local Values (`locals`):**
  - Act as local temporary variables or constants inside the module. They are defined internally and cannot be set or overridden from outside the module.
  - They can contain complex expressions or string interpolations combining variables, data sources, and resources.
  - *When to use:* To avoid repeating the same complex expression multiple times (DRY principle), or for naming conventions:
    ```hcl
    locals {
      resource_prefix = "${var.project}-${var.environment}"
    }
    ```
</details>

<details>
<summary><b>Q7: Scenario: Your CI/CD server runs in an offline environment with no access to the public internet. Running `terraform init` fails because it cannot fetch the AWS provider from the HashiCorp registry. How do you configure Terraform to handle this?</b></summary>
<b>Answer:</b>
Configure a **Provider Mirror** or **Local Provider Cache**:
1. **Download Providers:** Pre-download the required provider zip files for your target OS from a machine with internet access.
2. **Provider Directory:** Place them in a shared directory on the CI/CD agent (e.g. `/opt/terraform/providers/`).
3. **Configure CLI config (`.terraformrc`):** Create a configuration file on the CI/CD agent's user directory (`~/.terraformrc` or `%APPDATA%\terraform.rc` on Windows) telling the Terraform CLI to look in the local filesystem mirror instead of the registry:
   ```hcl
   provider_installation {
     filesystem_mirror {
       path    = "/opt/terraform/providers"
       include = ["registry.terraform.io/*/*"]
     }
     direct {
       exclude = ["*"]
     }
   }
   ```
4. Running `terraform init` will now pull the providers from the filesystem location.
</details>

<details>
<summary><b>Q8: Scenario: You have a database resource defined in your HCL code. You want to remove this database from Terraform's tracking and management so that running `terraform destroy` will not delete it from AWS. How do you do this?</b></summary>
<b>Answer:</b>
Use the **`terraform state rm`** command:
1. **Locate resource address:** Run `terraform state list` to get the HCL address of the resource (e.g., `aws_db_instance.prod_mysql`).
2. **Remove from state:** Run the state removal command:
   ```bash
   terraform state rm aws_db_instance.prod_mysql
   ```
3. **Outcome:** This command modifies the remote `.tfstate` file, deleting the tracking record for the database.
4. **Code cleanup:** You must now manually delete the corresponding `resource "aws_db_instance" "prod_mysql"` block from your `.tf` files. If you do not delete the code, the next `terraform plan` will treat the database as a brand new resource and attempt to recreate it.
</details>

<details>
<summary><b>Q9: Scenario: Why is it critical to commit the `.terraform.lock.hcl` file to your Git repository? What happens if you add it to your `.gitignore`?</b></summary>
<b>Answer:</b>
- **What is the lock file:** The `.terraform.lock.hcl` file (Dependency Lock File) locks the exact provider versions and their cryptographic checksums used in your project.
- **Why commit it:** Committing it guarantees **reproducibility**. When other developers or CI/CD pipelines run `terraform init`, they will download the exact same provider versions, preventing unexpected breaking changes caused by automatic updates to minor or major provider releases.
- **If ignored:** If ignored, different developers might initialize with different provider versions, causing compilation errors or unintended modifications to state schemas.
</details>

<details>
<summary><b>Q10: Scenario: Describe the best practice directory file structure for separating "Development", "Staging", and "Production" environments in Terraform. Why is using Terraform Workspaces not recommended for separating distinct environments?</b></summary>
<b>Answer:</b>
- **Best Practice (Directory Isolation):** Create separate folders for each environment, referencing common modules:
  ```
  ├── modules/
  │   ├── vpc/
  │   └── web_app/
  └── environments/
      ├── dev/
      │   ├── main.tf (calls modules, uses dev backend.tfvars)
      │   └── variables.tf
      └── prod/
          ├── main.tf (calls modules, uses prod backend.tfvars)
          └── variables.tf
  ```
  - *Why Directory Isolation:* Provides complete separation of state files, credentials, configurations, and permissions. You can test new module updates in `dev` without affecting `prod`.
- **Why Workspaces are not recommended for environment isolation:**
  - Workspaces share the same backend, the same variable configurations, and the same root code files.
  - It is easy to accidentally run `terraform destroy` on the wrong workspace (e.g. thinking you are in `dev` but actually in `prod`).
  - Workspaces are best suited for testing temporary feature branches, not for managing distinct environments with different configurations.
</details>
