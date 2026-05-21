# ✦ Terraform IaC Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Infrastructure as Code (IaC) with Terraform, State Management, Resource Lifecycles, Modules, Troubleshooting, and Enterprise Best Practices.

---

## ✦ Section 1: State Management & Backends (Questions 1-20)

<details>
<summary><b>Q1: Scenario: Two developers run `terraform apply` concurrently, causing state file corruption risks. How does Terraform prevent this, and what backend configuration is required?</b></summary>
Terraform uses **State Locking** to prevent concurrent executions. For S3 backends, you must configure a DynamoDB table for state locking:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
```
If another apply is running, Terraform locks the state in DynamoDB, and the second execution is blocked until the lock is released.
</details>

<details>
<summary><b>Q2: Scenario: An apply was interrupted (e.g., CI/CD job timed out), and subsequent commands fail with "Error acquiring the state lock". How do you resolve this?</b></summary>
First, verify that no other developer or pipeline is actually running the apply. Obtain the **Lock ID** from the error message. Run `terraform force-unlock <LOCK_ID>` to release the lock manually. Alternatively, if using AWS DynamoDB, you can delete the item containing the Lock ID from the DynamoDB lock table.
</details>

<details>
<summary><b>Q3: Scenario: You accidentally committed your `terraform.tfstate` file to a public GitHub repository. What are the immediate recovery steps?</b></summary>
1. Rotate all secrets, passwords, API keys, and IAM credentials contained in the state file.
2. Remove the state file from Git history using `git filter-repo` or `BFG Repo-Cleaner`.
3. Add `*.tfstate`, `*.tfstate.backup`, and `.terraform/` to `.gitignore`.
4. Migrate to a secure remote backend (e.g., AWS S3, Terraform Cloud) to store the state securely moving forward.
</details>

<details>
<summary><b>Q4: Scenario: You need to migrate your existing local state file to an AWS S3 remote backend. How do you do this safely without losing resource tracking?</b></summary>
Define the `backend "s3"` configuration block in your code. Run `terraform init`. Terraform will detect the change in backend configuration and prompt: *"Do you want to copy existing state to the new backend?"*. Type `yes`. Verify the state file is uploaded to the S3 bucket, and then delete the local `terraform.tfstate` file.
</details>

<details>
<summary><b>Q5: Scenario: A resource was deleted manually via the AWS Console. How does Terraform handle this on the next `terraform plan`?</b></summary>
During the planning phase, Terraform performs a refresh (queries the AWS API for the actual state of resources). Since the resource no longer exists, Terraform updates its in-memory representation of the state and plans to **recreate** the resource to align with the configurations.
</details>

<details>
<summary><b>Q6: Scenario: You need to run a plan without querying the cloud provider (refreshing state) because the API calls are taking too long. What flag do you use?</b></summary>
Run `terraform plan -refresh=false`. This compares the configuration files directly against the local cached state (`terraform.tfstate`) without making outbound API requests to verify actual resource status.
</details>

<details>
<summary><b>Q7: Scenario: A developer wants to inspect the state file to check a resource attribute but doesn't want to open the raw JSON file. What command should they use?</b></summary>
Run `terraform show` to view a human-readable representation of the state file, or use `terraform state show <RESOURCE_ADDRESS>` (e.g., `terraform state show aws_instance.web`) to inspect the state attributes of a specific resource.
</details>

<details>
<summary><b>Q8: Scenario: You renamed a resource block in your HCL code from `aws_instance.web` to `aws_instance.prod_web`. If you run apply, Terraform will destroy the old instance and create a new one. How do you prevent this?</b></summary>
You can use a `moved` block in your HCL configurations (Terraform 1.1+):
```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.prod_web
}
```
Alternatively, run the CLI state command:
```bash
terraform state mv aws_instance.web aws_instance.prod_web
```
This updates the reference in the state file without disrupting the physical resource.
</details>

<details>
<summary><b>Q9: Scenario: You no longer want to manage a specific S3 bucket with Terraform, but you do not want the bucket to be deleted. How do you handle this?</b></summary>
Remove the S3 bucket configuration block from your HCL files. Before running apply, remove the resource from the state file tracking using:
```bash
terraform state rm aws_s3_bucket.my_bucket
```
This untracks the resource from Terraform, leaving the physical bucket intact.
</details>

<details>
<summary><b>Q10: Scenario: Your remote backend is configured in S3, but you want to test some config changes locally without affecting the remote state. How can you override the backend?</b></summary>
Use the `-state` flag or migrate to local state temporarily by commenting out the backend block and running `terraform init -migrate-state`. Alternatively, create a separate **Terraform Workspace** to work on an isolated state file linked to the same configuration files.
</details>

<details>
<summary><b>Q11: Scenario: You need to inspect a sensitive database password stored in the remote state file. How can you query it directly via CLI?</b></summary>
Run `terraform output -json` to extract outputs, or run `terraform state pull` to fetch the complete state file raw JSON to stdout, and parse it using `jq` (e.g., `terraform state pull | jq '.resources[] | select(.type=="aws_db_instance")'`).
</details>

<details>
<summary><b>Q12: Scenario: Your Terraform state file is corrupted or contains invalid JSON. You have a backup file `terraform.tfstate.backup`. How do you restore it?</b></summary>
Rename `terraform.tfstate.backup` to `terraform.tfstate` (if using local state). If using a remote S3 backend, download the version history of the S3 object, find the last working version, and restore it to be the latest version of the state object.
</details>

<details>
<summary><b>Q13: Scenario: How do you configure a backend to store state files for multiple environments (Dev, Staging, Prod) in the same S3 bucket?</b></summary>
Use dynamic paths using **Terraform Workspaces** (state is stored at `env:/<workspace_name>/path/to/file.tfstate` in the bucket), or use distinct directory structures (e.g., `environments/dev/backend.tf`, `environments/prod/backend.tf`) with unique `key` configurations. The directory structure layout is preferred for production environments because it enforces strict isolation.
</details>

<details>
<summary><b>Q14: Scenario: You are using workspace workspaces. How do you write a conditional statement to deploy a larger EC2 instance type in `prod` and a smaller one in `dev`?</b></summary>
Use the ternary operator with `terraform.workspace`:
```hcl
instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
```
</details>

<details>
<summary><b>Q15: Scenario: You want to list all resources currently tracked by your state file. What command do you run?</b></summary>
Run:
```bash
terraform state list
```
</details>

<details>
<summary><b>Q16: Scenario: An S3 bucket state key is configured with versioning. Why is versioning critical for remote backends?</b></summary>
Versioning allows you to roll back to a previous state file version in case of corruption, accidental resource deletion via state manipulation commands (`state rm`), or bad manual apply operations.
</details>

<details>
<summary><b>Q17: Scenario: A resource creation fails halfway through. What happens to the state file?</b></summary>
Terraform saves the state of all successfully created resources up to that point. The state file is updated immediately before the process exits, allowing subsequent runs to resume building from the point of failure.
</details>

<details>
<summary><b>Q18: Scenario: Why is storing secrets in Terraform state security-sensitive, and how can you mitigate risks?</b></summary>
Secrets (passwords, private keys, API tokens) are stored in plaintext inside the state JSON file. Mitigation steps: Restrict access permissions to the S3 bucket using IAM, enable KMS server-side encryption for the S3 bucket, and avoid outputting sensitive values unless marked as `sensitive = true` (which hides it from CLI output but not the state file).
</details>

<details>
<summary><b>Q19: Scenario: You are planning an architecture where team A manages core networking and team B manages application servers. How does team B reference networking outputs?</b></summary>
Team A configures outputs in their state file. Team B uses the `terraform_remote_state` data source to fetch those outputs:
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "company-terraform-states"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Reference it:
subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
```
</details>

<details>
<summary><b>Q20: Scenario: What is the purpose of `.terraform.lock.hcl` and should you commit it to version control?</b></summary>
It is the **dependency lock file** that tracks the exact versions and hashes of the providers used in the configurations. Yes, it must be committed to version control to guarantee that every developer and CI/CD agent installs identical provider versions, ensuring build reproducibility.
</details>

---

## ✦ Section 2: HCL Syntax, Expressions & Functions (Questions 21-40)

<details>
<summary><b>Q21: Scenario: You need to create 5 subnets, each with a different CIDR block. How do you calculate them dynamically?</b></summary>
Use the `cidrsubnet` function combined with `count`:
```hcl
resource "aws_subnet" "subnets" {
  count             = 5
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
}
```
This generates subnets: `10.0.0.0/24`, `10.0.1.0/24`, `10.0.2.0/24`, etc.
</details>

<details>
<summary><b>Q22: Scenario: You want to deploy a resource conditionally. If `var.create_db` is true, create an RDS instance; if false, do not create it. How?</b></summary>
Use `count` with a conditional expression:
```hcl
resource "aws_db_instance" "db" {
  count               = var.create_db ? 1 : 0
  allocated_storage   = 20
  engine              = "mysql"
  # ... other params ...
}
```
</details>

<details>
<summary><b>Q23: Scenario: How do you loop through a map of objects containing subnet settings and assign name tags dynamically using `for_each`?</b></summary>
Use `for_each` on the map:
```hcl
variable "subnets" {
  type = map(object({ cidr = string, zone = string }))
  default = {
    sub-1 = { cidr = "10.0.1.0/24", zone = "us-east-1a" }
    sub-2 = { cidr = "10.0.2.0/24", zone = "us-east-1b" }
  }
}

resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.zone
  tags = {
    Name = each.key
  }
}
```
</details>

<details>
<summary><b>Q24: Scenario: What is the difference between `count` and `for_each` when deleting an item from the middle of a list/map?</b></summary>
If you use `count` (list-based) and delete the second item, all subsequent items shift indexes. Terraform will detect index changes and destroy/recreate resources. If you use `for_each` (map/key-based), deleting a key only removes that specific resource without affecting others.
</details>

<details>
<summary><b>Q25: Scenario: You have a list of strings `["web-1", "web-2", "db-1"]` and want to create a new list containing only items starting with "web". How?</b></summary>
Use a `for` expression with an `if` condition:
```hcl
web_servers = [for s in var.server_names : s if startswith(s, "web")]
```
</details>

<details>
<summary><b>Q26: Scenario: How do you merge two maps of tags (e.g., global tags and resource-specific tags) into a single map in HCL?</b></summary>
Use the `merge` function:
```hcl
tags = merge(
  var.global_tags,
  {
    Environment = "Production"
    Role        = "WebServer"
  }
)
```
</details>

<details>
<summary><b>Q27: Scenario: You have a template file `userdata.sh.tpl` and want to inject a database hostname variable into it. How is this configured?</b></summary>
Use the `templatefile` function:
```hcl
user_data = templatefile("${path.module}/userdata.sh.tpl", {
  db_host = aws_db_instance.db.address
})
```
Inside the template, reference it as `${db_host}`.
</details>

<details>
<summary><b>Q28: Scenario: You want to ensure a variable is always a positive number and meets certain criteria. How do you implement custom validation rules?</b></summary>
Add a `validation` block within the variable declaration:
```hcl
variable "port" {
  type = number
  validation {
    condition     = var.port > 0 && var.port <= 65535
    error_message = "The port must be a valid TCP/UDP port between 1 and 65535."
  }
}
```
</details>

<details>
<summary><b>Q29: Scenario: How do you format a string to look like "env-app-01", "env-app-02" dynamically inside a loop?</b></summary>
Use the `format` function:
```hcl
Name = format("%s-%s-%02d", var.env, var.app, count.index + 1)
```
</details>

<details>
<summary><b>Q30: Scenario: What are HCL Local Values (`locals`) used for, and how do they differ from variables?</b></summary>
Variables are parameters passed into Terraform modules (input parameters). Locals are internal temporary variables/expressions computed within the module to reduce redundancy and simplify complex expressions. They cannot be overwritten from outside the module.
</details>

<details>
<summary><b>Q31: Scenario: You need to extract all IP addresses from a list of security group rules, flatten them into a single list, and remove duplicates. How?</b></summary>
Use `distinct` and `flatten` functions:
```hcl
all_ips = distinct(flatten(var.security_group_rules[*].cidr_blocks))
```
</details>

<details>
<summary><b>Q32: Scenario: How do you handle secrets so they do not show up as cleartext in your CLI stdout when running `terraform apply`?</b></summary>
Set `sensitive = true` in the variable definition or output configuration:
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```
Terraform will mask this value as `(sensitive value)` in all CLI plans and outputs.
</details>

<details>
<summary><b>Q33: Scenario: You need to parse a JSON configuration file `config.json` locally and use its attributes. How do you do this?</b></summary>
Use the `file` and `jsondecode` functions:
```hcl
locals {
  config = jsondecode(file("${path.module}/config.json"))
}

# Reference: local.config.database_port
```
</details>

<details>
<summary><b>Q34: Scenario: What does the `lookup` function do, and how do you specify a default fallback value?</b></summary>
`lookup(map, key, default)` retrieves the value of a key in a map. If the key does not exist, it returns the specified default value instead of raising an error.
```hcl
instance_type = lookup(var.ami_map, "us-east-1", "ami-default123")
```
</details>

<details>
<summary><b>Q35: Scenario: You want to split a comma-separated string `"sub1,sub2,sub3"` into a list of strings. What function do you use?</b></summary>
Use the `split` function:
```hcl
subnet_list = split(",", var.subnet_csv)
```
</details>

<details>
<summary><b>Q36: Scenario: How do you find the length of a list or map dynamically in HCL?</b></summary>
Use the `length` function:
```hcl
subnet_count = length(aws_subnet.main)
```
</details>

<details>
<summary><b>Q37: Scenario: What is the difference between `path.module`, `path.root`, and `path.cwd`?</b></summary>
- `path.module`: The path where the current module configuration file resides.
- `path.root`: The path of the root module (where terraform was run).
- `path.cwd`: The current working directory of the execution process.
</details>

<details>
<summary><b>Q38: Scenario: You have a nested list of lists `[[1, 2], [3, 4]]`. You need to convert this to `[1, 2, 3, 4]`. What function do you run?</b></summary>
Use the `flatten` function:
```hcl
flat_list = flatten([[1, 2], [3, 4]])
```
</details>

<details>
<summary><b>Q39: Scenario: How do you convert a string to lowercase or uppercase in Terraform?</b></summary>
Use the `lower()` and `upper()` functions:
```hcl
env_tag = upper(var.environment) # "dev" -> "DEV"
```
</details>

<details>
<summary><b>Q40: Scenario: You want to verify if a specific key exists in a map. What function or syntax do you use?</b></summary>
Use the `contains` function with `keys()`:
```hcl
has_key = contains(keys(var.my_map), "target_key")
```
</details>

---

## ✦ Section 3: Terraform Commands, Lifecycle & Operations (Questions 41-60)

<details>
<summary><b>Q41: Scenario: You run `terraform init` and get a connection timeout error downloading the AWS provider. How do you troubleshoot?</b></summary>
Check internet routing and proxy configurations. Verify if corporate firewalls block access to `registry.terraform.io`. You can configure a local provider directory cache (`plugin_cache_dir` in `.terraformrc`) or run `terraform init -plugin-dir=/path/to/local/cache` to use offline provider binaries.
</details>

<details>
<summary><b>Q42: Scenario: You want to format all `.tf` files in your repository to standard indentation. What command do you use?</b></summary>
Run:
```bash
terraform fmt -recursive
```
This automatically updates files to HCL style standards recursively from the current directory.
</details>

<details>
<summary><b>Q43: Scenario: How do you check if your HCL syntax is valid without attempting to connect to a cloud provider or refresh state?</b></summary>
Run:
```bash
terraform validate
```
This checks syntax correctness, configuration consistency, and structural validity of HCL files.
</details>

<details>
<summary><b>Q44: Scenario: You have a large codebase with 200 resources, but you only want to recreate one specific database resource `aws_db_instance.prod`. What command do you run?</b></summary>
Use the `-replace` flag (Terraform 1.0+):
```bash
terraform apply -replace="aws_db_instance.prod"
```
(Replaces the deprecated `-taint` command workflow).
</details>

<details>
<summary><b>Q45: Scenario: You want to target a single module block during apply, ignoring changes in other parts of the configurations. What flag do you use?</b></summary>
Use the `-target` flag:
```bash
terraform apply -target=module.vpc
```
*Note: Use `-target` only for troubleshooting, as it can cause state inconsistencies between resource dependencies.*
</details>

<details>
<summary><b>Q46: Scenario: How does `terraform plan -out=tfplan` improve production deployment safety in CI/CD pipelines?</b></summary>
It saves the calculated execution plan to a file. Running `terraform apply tfplan` guarantees that **only** the exact changes inspected and approved in the planning phase are applied, preventing race conditions where configurations are modified in version control between plan and apply phases.
</details>

<details>
<summary><b>Q47: Scenario: What is the difference between `terraform destroy` and modifying resource code blocks to delete them?</b></summary>
`terraform destroy` tears down **all** resources managed by that state file. Modifying code to delete specific blocks cleanses the architecture target and applies deletion only to those specific resources, which is the correct workflow for standard updates.
</details>

<details>
<summary><b>Q48: Scenario: You want to view your resource dependency graph visually. What command output is required?</b></summary>
Run:
```bash
terraform graph | dot -Tpng > graph.png
```
(Requires `Graphviz` package installed to convert the DOT language syntax into an image).
</details>

<details>
<summary><b>Q49: Scenario: How do you prevent an critical S3 bucket resource from being accidentally destroyed during any future `terraform apply`?</b></summary>
Add a `prevent_destroy = true` lifecycle rule inside the resource block:
```hcl
lifecycle {
  prevent_destroy = true
}
```
If Terraform calculates a plan that would destroy this resource, the execution aborts with an error immediately.
</details>

<details>
<summary><b>Q50: Scenario: You are updating an Auto Scaling Group launch configuration. To avoid downtime, you need to spin up the new resources before destroying the old ones. How?</b></summary>
Configure the `create_before_destroy` lifecycle rule:
```hcl
lifecycle {
  create_before_destroy = true
}
```
This changes the default creation order of HCL resource replacements.
</details>

<details>
<summary><b>Q51: Scenario: You are deploying an EC2 instance, but you want Terraform to ignore manual changes to its Name tag made by administrators via the AWS console. How?</b></summary>
Use the `ignore_changes` lifecycle rule:
```hcl
lifecycle {
  ignore_changes = [
    tags["Name"],
  ]
}
```
</details>

<details>
<summary><b>Q52: Scenario: What is the purpose of the `provisioner "local-exec"` block, and when does it execute?</b></summary>
It runs a command on the machine executing Terraform (e.g., your laptop or CI runner) immediately after the resource is created (by default).
```hcl
provisioner "local-exec" {
  command = "echo ${self.private_ip} > ip.txt"
}
```
</details>

<details>
<summary><b>Q53: Scenario: A provisioner fails during resource creation. What happens to the resource tracking?</b></summary>
Terraform marks the resource as **tainted** in the state file. On the next plan/apply run, Terraform will plan to destroy and recreate it, as its provisioning cycle was not successfully completed.
</details>

<details>
<summary><b>Q54: Scenario: What is the difference between creation-time provisioners and destruction-time provisioners?</b></summary>
Creation-time provisioners run when a resource is created. Destruction-time provisioners run **before** the resource is destroyed. You configure destruction provisioners using `when = destroy`:
```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Destroying resource'"
}
```
</details>

<details>
<summary><b>Q55: Scenario: You want to override the default path to locate provider credentials or plugins. What environment variables can you configure?</b></summary>
Use variables like `TF_LOG` for debugging levels, `TF_VAR_variable_name` to pass input values, and `TF_DATA_DIR` to change the local data store location.
</details>

<details>
<summary><b>Q56: Scenario: How do you configure detailed debug logging in Terraform, and where does it save?</b></summary>
Set the environment variable `TF_LOG=DEBUG` or `TF_LOG=TRACE`. To redirect this log output to a file, set `TF_LOG_PATH=terraform.log`.
</details>

<details>
<summary><b>Q57: Scenario: What does `terraform refresh` do, and is it run automatically?</b></summary>
It queries the provider APIs to update the state file metadata to match real-world settings. Yes, it is run automatically as a pre-requisite step during `plan` and `apply` unless disabled.
</details>

<details>
<summary><b>Q58: Scenario: You want to see the details of outputs without running plan/apply. What command do you run?</b></summary>
Run:
```bash
terraform output
```
This queries the state file for defined outputs and displays them.
</details>

<details>
<summary><b>Q59: Scenario: How do you verify if the provider versions configured in your `.tf` files are compatible with the CLI version?</b></summary>
Run `terraform version` to check CLI and provider metadata. Set strict version requirements inside the HCL configuration blocks to prevent issues:
```hcl
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```
</details>

<details>
<summary><b>Q60: Scenario: How does the `~>` operator function inside the provider constraints list?</b></summary>
It represents the pessimistic constraint operator. For example, `~> 4.15.0` allows updates to `4.15.1` up to any patch version under `4.16.0`, blocking minor or major version changes.
</details>

---

## ✦ Section 4: Modules, Import & Refactoring (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You have existing EC2 instances created manually in AWS. You need to import them into your new Terraform codebase. What are the steps?</b></summary>
1. Write a resource block matching the resource target in HCL:
```hcl
resource "aws_instance" "my_vm" {}
```
2. Run the import command referencing the state address and actual AWS Instance ID:
```bash
terraform import aws_instance.my_vm i-0abcd1234efgh5678
```
3. Run `terraform plan` and modify the HCL code attributes until the plan shows **0 changes**, ensuring code matches reality.
</details>

<details>
<summary><b>Q62: Scenario: How do you use the new `import` block in Terraform 1.5+ to generate HCL configurations automatically?</b></summary>
Write an `import` block:
```hcl
import {
  to = aws_instance.my_vm
  id = "i-0abcd1234efgh5678"
}
```
Run the generate config command:
```bash
terraform plan -generate-config-out=generated_instances.tf
```
This imports the state and creates the matching HCL code blocks automatically.
</details>

<details>
<summary><b>Q63: Scenario: You want to share a module across multiple repositories. How do you reference a module from a private GitHub repository over SSH?</b></summary>
Specify the Git URL with the `git@` scheme in the `source` parameter:
```hcl
module "vpc" {
  source = "git@github.com:my-org/terraform-aws-vpc.git?ref=v2.1.0"
}
```
The `?ref=v2.1.0` part pins the module to a specific release tag or branch.
</details>

<details>
<summary><b>Q64: Scenario: You run `terraform get`. What is the purpose of this command?</b></summary>
It downloads and updates registry or Git-based modules defined in your HCL files into the local `.terraform/modules/` directory without running provider initialization steps.
</details>

<details>
<summary><b>Q65: Scenario: You created a module and want to restrict who can edit its internal variables. Can a parent module edit the local values (`locals`) inside a child module?</b></summary>
No. Child module variables must be explicitly defined as input variables `variable` blocks to be passed down. Locals are completely private to the module they are defined in, ensuring encapsulation.
</details>

<details>
<summary><b>Q66: Scenario: How do you reference outputs from a child module inside your root module `main.tf`?</b></summary>
Reference them using `module.<MODULE_NAME>.<OUTPUT_NAME>`:
```hcl
resource "aws_route53_record" "dns" {
  zone_id = var.dns_zone_id
  name    = "app.example.com"
  type    = "A"
  records = [module.application_server.public_ip]
}
```
</details>

<details>
<summary><b>Q67: Scenario: You want to pass a provider configuration block with a specific alias to a module. How do you do this?</b></summary>
Declare the aliases in the provider configurations, and pass them inside the `providers` map block of the module declaration:
```hcl
provider "aws" {
  alias  = "usw2"
  region = "us-west-2"
}

module "vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.usw2
  }
}
```
</details>

<details>
<summary><b>Q68: Scenario: You want to convert a resource `aws_security_group.sg` inside a module to a list of resources. How can you map them to avoid destroying the resource during refactoring?</b></summary>
Use `moved` HCL blocks to map the change from a single resource target to a list indexing key:
```hcl
moved {
  from = aws_security_group.sg
  to   = aws_security_group.sg["default"]
}
```
This moves the state address to the new key without deleting the security group.
</details>

<details>
<summary><b>Q69: Scenario: Why is it recommended to pin versions for both provider configurations and module sources?</b></summary>
Pinning guarantees that future runs of `terraform init` or CI/CD pipelines will not pull down breaking API changes or backward-incompatible module updates, ensuring infrastructure updates are deliberate and predictable.
</details>

<details>
<summary><b>Q70: Scenario: How do you verify what files are downloaded for modules inside your directory?</b></summary>
Inspect the local directory path `.terraform/modules/modules.json`. This tracks the manifest details mapping the logical module structures to their download paths on the filesystem.
</details>

<details>
<summary><b>Q71: Scenario: Can you run `terraform apply` inside a child module directory?</b></summary>
No, HCL modules are designed to define reusable structures. Running plan or apply is only valid in directories containing provider and backend blocks, known as the **root module**.
</details>

<details>
<summary><b>Q72: Scenario: You need to pass a list of subnets created in a parent module to a child module. How do you configure HCL inputs/outputs?</b></summary>
In the parent module, output the IDs:
```hcl
output "subnet_ids" { value = aws_subnet.main[*].id }
```
In the child module, define an input variable:
```hcl
variable "subnet_ids" { type = list(string) }
```
In the root module, link them:
```hcl
module "app" {
  source     = "./modules/app"
  subnet_ids = module.vpc.subnet_ids
}
```
</details>

<details>
<summary><b>Q73: Scenario: How does the dry-run command `terraform plan` differ from policy evaluation using `Open Policy Agent` (OPA) or HashiCorp `Sentinel`?</b></summary>
`terraform plan` calculates functional resource CRUD changes. Policy tools evaluate the generated JSON execution plan against security and compliance rules (e.g., checking if ports like 22 are open or if root logins are disabled) before allowing the apply command to execute.
</details>

<details>
<summary><b>Q74: Scenario: What is Terraform Cloud and how does it handle State Lock storage compared to S3?</b></summary>
Terraform Cloud handles backend state management, locking, and run executions natively in a centralized SaaS platform. It does not require separate configurations for locking mechanisms (like S3/DynamoDB) since it handles state storage and locking internally.
</details>

<details>
<summary><b>Q75: Scenario: You are publishing a module to the public Terraform Registry. What naming convention must you follow?</b></summary>
The repository name must follow the template: `terraform-<PROVIDER>-<NAME>`. For example, `terraform-aws-secure-vpc`.
</details>

<details>
<summary><b>Q76: Scenario: How do you use the `tfr://` protocol to reference modules?</b></summary>
This references the Terraform Registry protocol (available in modern CLI versions) to pull modules from the registry:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"
}
```
</details>

<details>
<summary><b>Q77: Scenario: What is a "monolithic" HCL structure versus a "multi-tier" structure, and why do large teams split state files?</b></summary>
Monolithic structures put all infrastructure components (VPC, DB, VM, DNS) in one directory with one state file, which increases blast radius and run times. Multi-tier structures split components into separate state files (directories), ensuring that database changes do not risk destroying critical networking components.
</details>

<details>
<summary><b>Q78: Scenario: You need to clean up all cached provider binaries in your local development directory to free up space. What folders can you safely delete?</b></summary>
You can safely delete the `.terraform/` directory. Running `terraform init` will recreate this directory and download required plugins on demand.
</details>

<details>
<summary><b>Q79: Scenario: How do you enforce custom metadata checks on variables to check for IP format correctness?</b></summary>
Combine HCL functions like `can()` and `regex()` inside a validation block:
```hcl
variable "ip_address" {
  type = string
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.ip_address))
    error_message = "IP address must match standard IPv4 dot-decimal format."
  }
}
```
</details>

<details>
<summary><b>Q80: Scenario: How do you configure a Terraform module to require a specific provider version range without restricting developer workspace versions?</b></summary>
Configure requirements inside the `required_providers` nested block inside the module’s `versions.tf` configuration, specifying standard bounds (e.g. `version = ">= 3.0, < 5.0"`).
</details>

---

## ✦ Section 5: Troubleshooting, Best Practices & Security (Questions 81-100)

<details>
<summary><b>Q81: Scenario: You get an error: "Error: Cycle: aws_security_group.web depends on aws_instance.db; aws_instance.db depends on aws_security_group.web". How do you resolve this?</b></summary>
This is a **Dependency Cycle (Circular Dependency)**. Break the cycle by extracting the dependencies into a separate, independent resource. For example, instead of defining inline security rules inside the security group block, use standalone `aws_security_group_rule` resources to link the security groups and instances independently.
</details>

<details>
<summary><b>Q82: Scenario: You run apply and get "ResourceNotFoundException" during creation because a dependent resource is not ready yet, even though HCL knows about it. How do you enforce ordering?</b></summary>
Terraform manages implicit dependencies automatically. If a dependency is hidden (e.g. dynamic scripts), use `depends_on` to enforce creation ordering explicitly:
```hcl
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
  depends_on = [
    aws_iam_role_policy_attachment.attach
  ]
}
```
</details>

<details>
<summary><b>Q83: Scenario: How do you check if your configurations comply with AWS Security Best Practices (e.g. no open SSH ports) before deploying?</b></summary>
Integrate static analysis scanners into your pre-commit hooks or CI/CD pipelines. Popular open-source security scanners for Terraform include `tfsec`, `trivy`, or `checkov`.
</details>

<details>
<summary><b>Q84: Scenario: A terraform apply operation is hanging indefinitely on resource creation. How do you find what API call it is stuck on?</b></summary>
Run the execution command with logs enabled: `TF_LOG=TRACE terraform apply`. Analyze the output logs to see which API call is pending or retry-looping.
</details>

<details>
<summary><b>Q85: Scenario: You need to specify dynamic blocks in HCL to create multiple ingress rules in a Security Group. How do you configure this?</b></summary>
Use a `dynamic` block:
```hcl
resource "aws_security_group" "allow_ports" {
  name = "allow-ports"
  dynamic "ingress" {
    for_each = [80, 443, 8080]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```
</details>

<details>
<summary><b>Q86: Scenario: How do you manage infrastructure deployments across multiple cloud providers (e.g., AWS and Azure) in the same HCL file?</b></summary>
Define multiple provider configuration blocks:
```hcl
provider "aws" { region = "us-east-1" }
provider "azurerm" { features {} }

resource "aws_s3_bucket" "b" { ... }
resource "azurerm_storage_account" "s" { ... }
```
Terraform maps resources to their respective provider configuration automatically based on the resource name prefix.
</details>

<details>
<summary><b>Q87: Scenario: You want to ensure that developers only configure instance types from an approved list. How can you write a validation check for this?</b></summary>
Use HCL’s `contains()` inside a variable validation block:
```hcl
variable "instance_type" {
  type = string
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "The instance type must be one of the approved types: t3.micro, t3.small, t3.medium."
  }
}
```
</details>

<details>
<summary><b>Q88: Scenario: Why is the `local-exec` provisioner considered a last resort in production-ready Terraform configurations?</b></summary>
Provisioners are not integrated into the declarative lifecycle of Terraform. They do not support drift detection, their success depend on the execution runner machine's environment (binaries, CLI tool versions, permissions), and they are not automatically rolled back on failure.
</details>

<details>
<summary><b>Q89: Scenario: How does Terraform define target updates? What is the difference between "Update in-place" and "Destroy and recreate"?</b></summary>
Update in-place changes resource parameters without destroying it (denoted by `~` in `terraform plan`). Destroy and recreate happens when changing immutable parameters (e.g., AWS EC2 AMI or VPC CIDR), denoted by `-/+` in `terraform plan`.
</details>

<details>
<summary><b>Q90: Scenario: What is the purpose of Terraform provider registry prefixes like `hashicorp/aws` versus `digitalocean/digitalocean`?</b></summary>
The prefix denotes the publisher in the registry. `hashicorp/` represents official providers built and maintained by HashiCorp. Other prefixes represent verified third-party partners (e.g., cloud providers or SaaS tools) or community publishers.
</details>

<details>
<summary><b>Q91: Scenario: You updated a variable file but the CLI outputs are not showing changes. What did you configure wrong?</b></summary>
Check if you loaded the correct variable file. By default, Terraform only auto-loads variables defined in `terraform.tfvars`, `terraform.tfvars.json`, or files ending in `.auto.tfvars`. For other filenames, you must pass them explicitly using the `-var-file` flag.
</details>

<details>
<summary><b>Q92: Scenario: What does the HCL function `try()` do, and how is it used during variable assignments?</b></summary>
`try()` evaluates a sequence of expressions and returns the first one that does not produce an error. This is useful for handling complex, deeply-nested data structures where intermediate keys might be missing:
```hcl
db_port = try(local.config.database.port, 3306)
```
</details>

<summary><b>Q93: Scenario: How do you verify if code formatting compliance is met within a Git branch pre-commit or CI workflow?</b></summary>
Run:
```bash
terraform fmt -check
```
This returns a non-zero exit code if any HCL files do not match styling guidelines, which fails the CI runner step automatically.
</details>

<details>
<summary><b>Q94: Scenario: What is drift detection in IaC, and how does Terraform find changes made outside of its configurations?</b></summary>
Drift is when resources are modified manually in the console or via external APIs. Terraform identifies drift by running a refresh (querying the cloud provider's API during the planning phase) and comparing the real-world status against the state file.
</details>

<details>
<summary><b>Q95: Scenario: You want to deploy infrastructure to multiple AWS accounts. How do you configure provider blocks for this?</b></summary>
Define multiple provider configurations with different aliases:
```hcl
provider "aws" {
  alias   = "dev_account"
  profile = "dev"
}

provider "aws" {
  alias   = "prod_account"
  profile = "prod"
}

resource "aws_instance" "dev" {
  provider = aws.dev_account
  # ...
}
```
</details>

<details>
<summary><b>Q96: Scenario: How do you configure resource metadata tags dynamically based on the Git commit hash inside a CI pipeline?</b></summary>
Define an input variable:
```hcl
variable "git_commit" {
  type    = string
  default = "local"
}
```
Pass the value inside the pipeline using environment variables:
```bash
export TF_VAR_git_commit=$(git rev-parse --short HEAD)
terraform apply -auto-approve
```
</details>

<details>
<summary><b>Q97: Scenario: What is the purpose of the `terraform workspace select` command?</b></summary>
It switches the active state context to a different workspace (e.g. from `default` to `dev` or `prod`), pointing the configuration execution at an isolated state file.
</details>

<details>
<summary><b>Q98: Scenario: Can you run Terraform without internet access? What is required to run completely offline?</b></summary>
Yes. You must pre-populate the local plugin directory with the required provider binaries and configurations, and run:
```bash
terraform init -plugin-dir=/path/to/local/plugins
```
This forces Terraform to run locally without querying the public registry.
</details>

<details>
<summary><b>Q99: Scenario: How do you enforce compliance where all infrastructure must have a standard set of tags?</b></summary>
Implement Sentinel policies or use third-party tools like `tfsec` / `checkov` to analyze files in the CI pipeline, rejecting configurations that do not define standard tags. Alternatively, configure the root provider's `default_tags` block (AWS specific):
```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  }
}
```
</details>

<details>
<summary><b>Q100: Scenario: You want to completely delete all local cache files downloaded by Terraform. What command cleans up the workspace directory?</b></summary>
Run:
```bash
rm -rf .terraform/ .terraform.lock.hcl terraform.tfstate*
```
This deletes provider cache, dependency locks, and local state files, returning the directory to a clean slate.
</details>

---

## Week 16: Terraform IaC Basics

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform core concepts, backend configurations, state locking, variable structures, and workflows.

<details>
<summary><b>Q101: Scenario: You are setting up Terraform for a team of 10 engineers. How do you configure a secure remote backend using Amazon S3 for state storage and DynamoDB for state locking? Provide HCL configuration examples.</b></summary>
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
<summary><b>Q102: Scenario: An engineer's local machine lost internet connectivity halfway through running a `terraform apply`. The next time team members attempt to run a plan, they get a "State Lock Error" pointing to a DynamoDB lock ID. How do you resolve this?</b></summary>
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
<summary><b>Q103: Scenario: Terraform state files often contain sensitive information in plaintext (such as database master passwords or API tokens). How do you secure the state file, and what are the best practices for secret management in Terraform?</b></summary>
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
<summary><b>Q104: Scenario: You have variables defined in multiple locations: a default value in `variables.tf`, a setting in `terraform.tfvars`, an environment variable (`TF_VAR_db_pass`), and a command-line flag `-var="db_pass=xyz"`. What is the evaluation order (precedence) of these values?</b></summary>
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
<summary><b>Q105: Scenario: You want to ensure that developers only pass valid inputs to your Terraform variables. For instance, the `environment` variable must only accept "dev", "stage", or "prod", and the `ami_id` variable must start with "ami-". How do you enforce this?</b></summary>
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
<summary><b>Q106: Scenario: How do HCL Local Values (`locals`) differ from standard Input Variables (`variable`)? In what architectural scenarios would you choose one over the other?</b></summary>
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
<summary><b>Q107: Scenario: Your CI/CD server runs in an offline environment with no access to the public internet. Running `terraform init` fails because it cannot fetch the AWS provider from the HashiCorp registry. How do you configure Terraform to handle this?</b></summary>
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
<summary><b>Q108: Scenario: You have a database resource defined in your HCL code. You want to remove this database from Terraform's tracking and management so that running `terraform destroy` will not delete it from AWS. How do you do this?</b></summary>
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
<summary><b>Q109: Scenario: Why is it critical to commit the `.terraform.lock.hcl` file to your Git repository? What happens if you add it to your `.gitignore`?</b></summary>
<b>Answer:</b>
- **What is the lock file:** The `.terraform.lock.hcl` file (Dependency Lock File) locks the exact provider versions and their cryptographic checksums used in your project.
- **Why commit it:** Committing it guarantees **reproducibility**. When other developers or CI/CD pipelines run `terraform init`, they will download the exact same provider versions, preventing unexpected breaking changes caused by automatic updates to minor or major provider releases.
- **If ignored:** If ignored, different developers might initialize with different provider versions, causing compilation errors or unintended modifications to state schemas.
</details>

<details>
<summary><b>Q110: Scenario: Describe the best practice directory file structure for separating "Development", "Staging", and "Production" environments in Terraform. Why is using Terraform Workspaces not recommended for separating distinct environments?</b></summary>
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

---

## Week 17: Terraform Advanced Concepts

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform loops (`count` vs `for_each`), lifecycle attributes, dynamic blocks, provisioners, and HCL debugging.

<details>
<summary><b>Q111: Scenario: You need to deploy 3 subnets in AWS. A developer suggests using `count` with a list of CIDR blocks: `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`. What happens if you remove the second CIDR block (`10.0.2.0/24`) from the list later, and why is `for_each` a safer choice?</b></summary>
<b>Answer:</b>
- **What happens with `count`:**
  - Terraform maps resources created with `count` as an array indexed by integer (e.g. `aws_subnet.my_subnet[0]`, `aws_subnet.my_subnet[1]`, `aws_subnet.my_subnet[2]`).
  - If you remove the second element, the list becomes `["10.0.1.0/24", "10.0.3.0/24"]`.
  - The subnet at index `0` remains unchanged.
  - The subnet at index `1` (previously `10.0.2.0/24`) is modified to `10.0.3.0/24`, causing Terraform to **destroy and recreate** it.
  - The subnet at index `2` (previously `10.0.3.0/24`) is deleted.
  - This causes accidental downtime for resources running in subnet index 1.
- **Why `for_each` is safer:**
  - `for_each` maps resources to unique string keys (e.g. `aws_subnet.my_subnet["10.0.2.0/24"]`).
  - If you remove `"10.0.2.0/24"` from the map, Terraform only deletes that specific resource without affecting the others, ensuring stability.
</details>

<details>
<summary><b>Q112: Scenario: You updated the Launch Template for an Auto Scaling Group in Terraform. When you run `terraform apply`, it fails with a dependency error: the Launch Template cannot be deleted because it is currently in use by the ASG. How do you resolve this using Lifecycle rules?</b></summary>
<b>Answer:</b>
By default, Terraform destroys the old resource before creating the replacement. If another resource depends on it (like an ASG depending on a Launch Template), the deletion fails.
- **Resolution:**
  Use the **`create_before_destroy`** lifecycle setting within the Launch Template resource block:
  ```hcl
  resource "aws_launch_template" "my_app" {
    name_prefix = "app-template-"
    # ... configurations ...

    lifecycle {
      create_before_destroy = true
    }
  }
  ```
- **How it works:** Terraform will first create the new Launch Template version, update the ASG to point to the new version, and then safely delete the old Launch Template without causing dependency locks or application downtime.
</details>

<details>
<summary><b>Q113: Scenario: You need to create a Security Group where the inbound rules are highly dynamic. Developers should be able to pass a list of port mappings (e.g. `[{port = 80, cidr = "0.0.0.0/0"}, {port = 443, cidr = "192.168.1.0/24"}]`), and the Security Group should render the corresponding ingress blocks automatically. How do you write this in HCL?</b></summary>
<b>Answer:</b>
Use **Dynamic Blocks** (`dynamic`):
```hcl
variable "ingress_rules" {
  type = list(object({
    port = number
    cidr = string
  }))
}

resource "aws_security_group" "dynamic_sg" {
  name        = "app-sg"
  description = "Dynamic security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }
}
```
The `dynamic "ingress"` block iterates over the list in `var.ingress_rules`, generating a separate `ingress` block for each item in the array at runtime.
</details>

<details>
<summary><b>Q114: Scenario: An engineer has written a `remote-exec` provisioner to SSH into a newly created EC2 instance and run `apt-get install nginx` to configure the web server. Why is this considered a Terraform anti-pattern, and what are the recommended alternatives?</b></summary>
<b>Answer:</b>
- **Why it is an anti-pattern:**
  1. **Lack of State Tracking:** Terraform does not track the state of the software installed by provisioners. If Nginx is uninstalled manually, `terraform plan` will not detect it.
  2. **Brittleness:** Provisioners rely on network availability, SSH key configurations, and OS state. If SSH fails, the entire resource creation fails.
  3. **Tightly Coupled:** It violates the separation of concerns. Terraform is an *Infrastructure Provisioning* tool, not a *Configuration Management* tool.
- **Alternatives:**
  1. **User Data (Cloud-init):** Pass shell scripts to the `user_data` parameter of the EC2 instance to let the OS boot script install software.
  2. **Image Baking (Packer):** Pre-bake the virtual machine image with Nginx installed using HashiCorp Packer, and deploy that custom AMI using Terraform.
  3. **Configuration Management:** Use Terraform to boot the raw instance, and trigger **Ansible**, Chef, or Puppet to configure the OS software.
</details>

<details>
<summary><b>Q115: Scenario: You have an Auto Scaling Group configured in Terraform. Outside of Terraform, an AWS Auto Scaling policy dynamically adjusts the `desired_capacity` of the group between 2 and 10 instances depending on CPU load. Every time you run `terraform apply`, Terraform attempts to revert the `desired_capacity` back to 2 (the initial template value). How do you prevent this?</b></summary>
<b>Answer:</b>
Use the **`ignore_changes`** lifecycle meta-argument:
```hcl
resource "aws_autoscaling_group" "my_asg" {
  name             = "app-asg"
  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  # ... configuration details ...

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}
```
- **How it works:** This tells Terraform to ignore any modifications made to the `desired_capacity` attribute during plans and applies, allowing the external AWS Auto Scaling policies to manage the group scaling without state conflicts.
</details>

<details>
<summary><b>Q116: Scenario: How do you protect a critical storage resource (such as a production RDS database or an S3 bucket containing financial audits) from being accidentally destroyed if someone runs `terraform destroy` or makes a code change that forces a resource replacement?</b></summary>
<b>Answer:</b>
Use the **`prevent_destroy`** lifecycle setting:
```hcl
resource "aws_db_instance" "prod_database" {
  allocated_storage = 100
  engine            = "mysql"
  # ... configuration details ...

  lifecycle {
    prevent_destroy = true
  }
}
```
- **How it works:** If anyone runs `terraform destroy` or runs `terraform apply` with changes that require a resource replacement (recreation), Terraform will immediately throw an error and abort the execution, saving the resource from destruction.
- *Caveat:* This only blocks destruction triggered via Terraform. It does not protect the resource from being deleted manually in the AWS Console (use AWS IAM restrictions or RDS Deletion Protection for that).
</details>

<details>
<summary><b>Q117: Scenario: Your Terraform code has a map of AMIs per region: `{"us-east-1" = "ami-01", "us-west-2" = "ami-02"}`. How do you write an expression that automatically selects the correct AMI based on the active provider region, and falls back to a default AMI if the region is not found?</b></summary>
<b>Answer:</b>
Use the **`lookup`** built-in function:
```hcl
variable "ami_map" {
  type = map(string)
  default = {
    "us-east-1" = "ami-01"
    "us-west-2" = "ami-02"
  }
}

variable "default_ami" {
  type    = string
  default = "ami-fallback"
}

resource "aws_instance" "my_server" {
  # aws_region data source provides the current region name
  ami           = lookup(var.ami_map, data.aws_region.current.name, var.default_ami)
  instance_type = "t3.micro"
}
```
- **How it works:** `lookup(map, key, default)` queries the map using the active region key. If the key exists, it returns the mapped AMI ID. If the key is missing (e.g. `eu-west-1`), it returns the third parameter (`var.default_ami`).
</details>

<details>
<summary><b>Q118: Scenario: You want to run a local python script (`cleanup.py`) on your CI/CD runner *only* when a configuration template file (`config.tpl`) changes. Since the script is not an AWS resource, how do you model this in Terraform?</b></summary>
<b>Answer:</b>
Use a **`null_resource`** (or the modern `terraform_data` resource) combined with a **`local-exec` provisioner** and **`triggers`**:
```hcl
resource "null_resource" "run_cleanup" {
  triggers = {
    # Re-run the script if the md5 hash of the template file changes
    template_hash = filemd5("${path.module}/config.tpl")
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/cleanup.py"
  }
}
```
- **How it works:** The `triggers` block takes a map of arbitrary values. If any value in the triggers map changes (in this case, the file hash), Terraform treats the `null_resource` as needing replacement. It destroys the old resource, creates a new one, and re-executes the provisioner.
</details>

<details>
<summary><b>Q119: Scenario: When running complex HCL functions, you want to test and dry-run your string interpolations and map merges without waiting for a full `terraform plan`. How do you do this?</b></summary>
<b>Answer:</b>
Use the **`terraform console`** command:
1. Open your terminal in the directory containing your Terraform files.
2. Run `terraform console`. This opens an interactive CLI wrapper.
3. Type any HCL expression, variable name, or built-in function to evaluate it immediately:
   ```hcl
   > merge({a="b"}, {c="d"})
   {
     "a" = "b"
     "c" = "d"
   }
   > keys(var.ami_map)
   [
     "us-east-1",
     "us-west-2",
   ]
   ```
4. This is highly useful for validating complex data manipulations before applying them to resources.
</details>

<details>
<summary><b>Q120: Scenario: Your Terraform apply is failing with a generic error from the AWS API, but the error message lacks details. How do you enable verbose debugging to see the raw HTTP request/response payloads sent to AWS?</b></summary>
<b>Answer:</b>
Use the **`TF_LOG`** environment variable:
1. Set the log level to `DEBUG` or `TRACE` (options: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`):
   - **Linux/macOS:** `export TF_LOG=DEBUG`
   - **Windows PowerShell:** `$env:TF_LOG="DEBUG"`
2. Set a path to write the logs to a file:
   - **Linux/macOS:** `export TF_LOG_PATH=terraform-debug.log`
   - **Windows:** `$env:TF_LOG_PATH="terraform-debug.log"`
3. Run `terraform apply`. Terraform will output highly detailed logs, including raw JSON payloads sent to and received from the AWS endpoints, allowing you to trace permission errors or API validation faults.
</details>

---

## Week 18: Terraform Data and Modules

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform data sources, custom modules, state refactoring (`moved` blocks), resources import, and dependency graphs.

<details>
<summary><b>Q121: Scenario: You want to deploy an EC2 instance, but you do not want to hardcode the AMI ID. You want Terraform to automatically fetch the latest active Amazon Linux 2 AMI ID owned by Amazon in the target region. How do you write this?</b></summary>
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
<summary><b>Q122: Scenario: You refactored your Terraform code to group resources. You moved a resource `aws_instance.web` from the root directory into a new child module named `web_server` (so its new address is `module.web_server.aws_instance.web`). If you run `terraform apply`, Terraform will destroy the running server and create a new one. How do you prevent this?</b></summary>
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
<summary><b>Q123: Scenario: An engineer manually launched an S3 bucket named `prod-billing-reports-2026` via the AWS Console. You want to bring this existing bucket under Terraform's management without destroying it. Walk through the steps to import it.</b></summary>
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
<summary><b>Q124: Scenario: Describe the design principles of building a reusable Terraform Module. What files are required, and how do you version-lock modules for different environments?</b></summary>
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
<summary><b>Q125: Scenario: You have a database module (`modules/rds`) and an application module (`modules/ecs`). The application module needs the database endpoint to start. How do you pass output parameters between these modules in your root directory?</b></summary>
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
<summary><b>Q126: Scenario: An engineer runs a plan, and it is taking over 15 minutes to complete due to complex dependency trees. How do you generate and visualize the resource dependency graph in Terraform to find bottlenecks?</b></summary>
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
<summary><b>Q127: Scenario: Your remote S3 state file has become corrupted due to a manual edit, and you need to perform raw edits to repair a resource address. What is the safe workflow to edit the raw state?</b></summary>
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
<summary><b>Q128: Scenario: When and why would you use the `-target` flag during a `terraform apply`? What are the operational dangers of using it in production?</b></summary>
<b>Answer:</b>
- **Why use it:** The `-target=resource_address` flag limits Terraform's execution to a specific resource and its dependencies, ignoring changes to all other resources. It is used in disaster recovery to fix a specific degraded resource without triggering modifications on unrelated changes.
- **Operational Dangers:**
  1. **State Divergence:** It bypasses the holistic model of infrastructure, potentially leading to configuration drift or state inconsistency.
  2. **Implicit Dependency Corruption:** If target resource A depends on resource B, and B was modified in code but not applied, targeting A might force updates to B that you did not want to apply yet.
  3. **Technical Debt:** It leaves the workspace in a "partially applied" state, complicating future pipeline runs.
</details>

<details>
<summary><b>Q129: Scenario: You run `terraform init` and notice that a third-party module from the registry has a bug. You want to modify a small portion of the module's code locally without hosting a private registry. How do you achieve this?</b></summary>
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
<summary><b>Q130: Scenario: You are migrating your Terraform remote backend from an old AWS Account S3 bucket to a new AWS Account S3 bucket. What is the process to migrate the state safely without losing resource tracking?</b></summary>
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
