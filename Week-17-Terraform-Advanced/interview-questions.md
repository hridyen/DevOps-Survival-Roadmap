# ⚡ Week 17 — Terraform Advanced Concepts Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on Terraform loops (`count` vs `for_each`), lifecycle attributes, dynamic blocks, provisioners, and HCL debugging.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You need to deploy 3 subnets in AWS. A developer suggests using `count` with a list of CIDR blocks: `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`. What happens if you remove the second CIDR block (`10.0.2.0/24`) from the list later, and why is `for_each` a safer choice?</b></summary>
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
<summary><b>Q2: Scenario: You updated the Launch Template for an Auto Scaling Group in Terraform. When you run `terraform apply`, it fails with a dependency error: the Launch Template cannot be deleted because it is currently in use by the ASG. How do you resolve this using Lifecycle rules?</b></summary>
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
<summary><b>Q3: Scenario: You need to create a Security Group where the inbound rules are highly dynamic. Developers should be able to pass a list of port mappings (e.g. `[{port = 80, cidr = "0.0.0.0/0"}, {port = 443, cidr = "192.168.1.0/24"}]`), and the Security Group should render the corresponding ingress blocks automatically. How do you write this in HCL?</b></summary>
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
<summary><b>Q4: Scenario: An engineer has written a `remote-exec` provisioner to SSH into a newly created EC2 instance and run `apt-get install nginx` to configure the web server. Why is this considered a Terraform anti-pattern, and what are the recommended alternatives?</b></summary>
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
<summary><b>Q5: Scenario: You have an Auto Scaling Group configured in Terraform. Outside of Terraform, an AWS Auto Scaling policy dynamically adjusts the `desired_capacity` of the group between 2 and 10 instances depending on CPU load. Every time you run `terraform apply`, Terraform attempts to revert the `desired_capacity` back to 2 (the initial template value). How do you prevent this?</b></summary>
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
<summary><b>Q6: Scenario: How do you protect a critical storage resource (such as a production RDS database or an S3 bucket containing financial audits) from being accidentally destroyed if someone runs `terraform destroy` or makes a code change that forces a resource replacement?</b></summary>
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
<summary><b>Q7: Scenario: Your Terraform code has a map of AMIs per region: `{"us-east-1" = "ami-01", "us-west-2" = "ami-02"}`. How do you write an expression that automatically selects the correct AMI based on the active provider region, and falls back to a default AMI if the region is not found?</b></summary>
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
<summary><b>Q8: Scenario: You want to run a local python script (`cleanup.py`) on your CI/CD runner *only* when a configuration template file (`config.tpl`) changes. Since the script is not an AWS resource, how do you model this in Terraform?</b></summary>
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
<summary><b>Q9: Scenario: When running complex HCL functions, you want to test and dry-run your string interpolations and map merges without waiting for a full `terraform plan`. How do you do this?</b></summary>
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
<summary><b>Q10: Scenario: Your Terraform apply is failing with a generic error from the AWS API, but the error message lacks details. How do you enable verbose debugging to see the raw HTTP request/response payloads sent to AWS?</b></summary>
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
