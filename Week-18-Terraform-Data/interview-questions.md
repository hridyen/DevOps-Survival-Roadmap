# ⚡ Week 18 — Terraform Data & Modules Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform data sources, custom modules, state refactoring (`moved` blocks), resources import, and dependency graphs.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You want to deploy an EC2 instance, but you do not want to hardcode the AMI ID. You want Terraform to automatically fetch the latest active Amazon Linux 2 AMI ID owned by Amazon in the target region. How do you write this?</b></summary>
<b>Answer:</b>
Use the **`aws_ami` Data Source**:
```hcl
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
}
```
- **How it works:** Data sources query the cloud provider API during the `plan` stage. The `data.aws_ami` block filters Amazon's AMIs, picks the matching record with the latest date, and exposes its ID. This guarantees that your configuration always launches the newest patched OS image.
</details>

<details>
<summary><b>Q2: Scenario: You refactored your Terraform code to group resources. You moved a resource `aws_instance.web` from the root directory into a new child module named `web_server` (so its new address is `module.web_server.aws_instance.web`). If you run `terraform apply`, Terraform will destroy the running server and create a new one. How do you prevent this?</b></summary>
<b>Answer:</b>
Use a **`moved` block** (available in Terraform 1.1+):
1. **Declare the Moved block:** In your root `.tf` files, add a `moved` statement mapping the old resource address to the new address:
   ```hcl
   moved {
     from = aws_instance.web
     to   = module.web_server.aws_instance.web
   }
   ```
2. **Execute plan:** Run `terraform plan`.
3. **Outcome:** Instead of showing 1 deletion and 1 creation, Terraform reads the moved block and shifts the resource inside the state file without touching the physical server in AWS. This allows zero-downtime refactoring of your codebase.
</details>

<details>
<summary><b>Q3: Scenario: An engineer manually launched an S3 bucket named `prod-billing-reports-2026` via the AWS Console. You want to bring this existing bucket under Terraform's management without destroying it. Walk through the steps to import it.</b></summary>
<b>Answer:</b>
To perform a **`terraform import`**:
1. **Declare Code:** Write the corresponding resource block in your `.tf` files matching the configuration of the bucket:
   ```hcl
   resource "aws_s3_bucket" "billing_bucket" {
     bucket = "prod-billing-reports-2026"
   }
   ```
2. **Execute Import Command:** Run the import command, passing the HCL resource address and the real-world resource identifier (in this case, the S3 bucket name):
   ```bash
   terraform import aws_s3_bucket.billing_bucket prod-billing-reports-2026
   ```
3. **Verify Configuration:** Run `terraform plan`. If there are configuration differences, Terraform will show them. Update your HCL attributes (e.g. tags, versioning) until the plan outputs: `No changes. Infrastructure is up-to-date.`
4. *(Optional) Modern import block (TF 1.5+):* Declare an `import` block directly in HCL:
   ```hcl
   import {
     to = aws_s3_bucket.billing_bucket
     id = "prod-billing-reports-2026"
   }
   ```
   Then run `terraform plan -generate-config-out=generated.tf` to generate code templates automatically.
</details>

<details>
<summary><b>Q4: Scenario: Describe the design principles of building a reusable Terraform Module. What files are required, and how do you version-lock modules for different environments?</b></summary>
<b>Answer:</b>
- **Directory Layout:** A standard module requires:
  - `variables.tf`: Declares input arguments (parameters for customization).
  - `outputs.tf`: Declares return values (allowing other resources to consume its values).
  - `main.tf`: The primary HCL declarations.
  - `README.md`: Explaining usage, requirements, and configurations.
- **Design Principles:**
  - **Encapsulation:** Hide internal details. Do not expose internal provider variables; keep input variables simple.
  - **Idempotence & Reusability:** Ensure variables have defaults where appropriate to simplify usage.
- **Module Versioning:** Source modules using a Git repository registry, specifying a tag/version constraint:
  ```hcl
  module "vpc" {
    source = "git::git@github.com:company/tf-modules.git//vpc?ref=v2.1.0"
    # input variables here
  }
  ```
  This prevents changes made to the module repository from breaking active configurations until the application team updates the `ref` tag.
</details>

<details>
<summary><b>Q5: Scenario: You have a database module (`modules/rds`) and an application module (`modules/ecs`). The application module needs the database endpoint to start. How do you pass output parameters between these modules in your root directory?</b></summary>
<b>Answer:</b>
Use **Module Output Chaining**:
1. **Define Output in RDS Module (`modules/rds/outputs.tf`):**
   ```hcl
   output "db_address" {
     value       = aws_db_instance.db.address
     description = "The database endpoint URL"
   }
   ```
2. **Define Variable in ECS Module (`modules/ecs/variables.tf`):**
   ```hcl
   variable "database_host" {
     type        = string
     description = "Database server endpoint"
   }
   ```
3. **Chain in Root Module (`main.tf`):**
   ```hcl
   module "database" {
     source = "./modules/rds"
     # variables
   }

   module "application" {
     source        = "./modules/ecs"
     database_host = module.database.db_address # Chaining output to input
   }
   ```
</details>

<details>
<summary><b>Q6: Scenario: An engineer runs a plan, and it is taking over 15 minutes to complete due to complex dependency trees. How do you generate and visualize the resource dependency graph in Terraform to find bottlenecks?</b></summary>
<b>Answer:</b>
1. **Generate Dot Code:** Run the `terraform graph` command. This parses your configuration and outputs a Graphviz DOT format representation of the dependency tree:
   ```bash
   terraform graph > graph.dot
   ```
2. **Convert to Image:** Use **Graphviz** utility to convert the dot file to an image (PNG/SVG):
   ```bash
   dot -Tpng graph.dot -o graph.png
   ```
3. **Analyze:** Open `graph.png`. Look for:
   - **Circular references** (preventing compilation).
   - **Unnecessary serialization** (where resources wait on each other due to implicit dependencies like using `depends_on` when not needed). Removing explicit `depends_on` blocks allowing Terraform to build unrelated resources concurrently.
</details>

<details>
<summary><b>Q7: Scenario: Your remote S3 state file has become corrupted due to a manual edit, and you need to perform raw edits to repair a resource address. What is the safe workflow to edit the raw state?</b></summary>
<b>Answer:</b>
Never download the state file and edit it manually via file editor without locking. Follow this safe workflow:
1. **Pull State:** Export the latest state from the remote backend to a local file:
   ```bash
   terraform state pull > backup.tfstate
   ```
2. **Create Backup:** Make a copy of `backup.tfstate` as a fallback.
3. **Modify Local State:** Edit `backup.tfstate` using a text editor to fix the corrupted properties.
4. **Increment Serial:** In the JSON structure of the `.tfstate` file, increment the `"serial"` number by 1 (or more) to ensure the remote backend recognizes it as a newer state revision.
5. **Push State:** Upload the repaired state back to the remote S3 backend:
   ```bash
   terraform state push backup.tfstate
   ```
</details>

<details>
<summary><b>Q8: Scenario: When and why would you use the `-target` flag during a `terraform apply`? What are the operational dangers of using it in production?</b></summary>
<b>Answer:</b>
- **Why use it:** The `-target=resource_address` flag limits Terraform's execution to a specific resource and its dependencies, ignoring changes to all other resources. It is used in disaster recovery to fix a specific degraded resource without triggering modifications on unrelated changes.
- **Operational Dangers:**
  1. **State Divergence:** It bypasses the holistic model of infrastructure, potentially leading to configuration drift or state inconsistency.
  2. **Implicit Dependency Corruption:** If target resource A depends on resource B, and B was modified in code but not applied, targeting A might force updates to B that you did not want to apply yet.
  3. **Technical Debt:** It leaves the workspace in a "partially applied" state, complicating future pipeline runs.
</details>

<details>
<summary><b>Q9: Scenario: You run `terraform init` and notice that a third-party module from the registry has a bug. You want to modify a small portion of the module's code locally without hosting a private registry. How do you achieve this?</b></summary>
<b>Answer:</b>
1. **Fork/Copy locally:** Copy the module source code into a local folder in your repository (e.g. `./local_modules/thirdparty-module`).
2. **Update Source Path:** Change the `source` parameter in your root `module` block to point to the local filesystem path instead of the public registry:
   ```hcl
   module "thirdparty" {
     source = "./local_modules/thirdparty-module"
     # variables...
   }
   ```
3. **Apply modifications:** Edit the local files directly. Run `terraform init` to let Terraform register the new local source configuration.
</details>

<details>
<summary><b>Q10: Scenario: You are migrating your Terraform remote backend from an old AWS Account S3 bucket to a new AWS Account S3 bucket. What is the process to migrate the state safely without losing resource tracking?</b></summary>
<b>Answer:</b>
1. **Initialize Old Backend:** Ensure the current code is initialized with the old backend and there are no pending changes (`terraform plan` shows no changes).
2. **Update Backend Configuration:** Modify the `backend "s3"` block in your HCL code to point to the new bucket name, new key location, or new account region.
3. **Re-initialize:** Run the initialization command:
   ```bash
   terraform init -migrate-state
   ```
4. **Confirm Migration:** Terraform will detect the change in backend configuration and ask: *"Do you want to copy existing state to the new backend?"*. Type `yes`.
5. **Verify:** Run `terraform plan` to confirm that the new state file matches the live resources with zero modifications shown.
</details>
