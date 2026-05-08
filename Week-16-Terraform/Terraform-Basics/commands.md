# ✦ Terraform CLI Commands

> **Core Terraform Workflow.** The essential commands to initialize, validate, plan, apply, and destroy infrastructure.

---

## ✦ Core Workflow Commands

### `terraform init`
**Initializes** the working directory. Always the first command to run.

What it does:
- Downloads provider plugins specified in your config
- Sets up the backend (local or remote state)
- Initializes modules

```bash
terraform init

# Re-initialize after changing providers or backend
terraform init -upgrade

# Initialize with a specific backend config file
terraform init -backend-config="backend.hcl"
```

---

### `terraform validate`
**Validates** the syntax and logic of your configuration files. Does not contact cloud APIs.

```bash
terraform validate
```

> [!TIP]
> Good for catching typos, missing required arguments, and type errors before planning.

---

### `terraform plan`
**Previews** what Terraform will do. No changes are made to real infrastructure.

```bash
terraform plan

# Save the plan to a file (for use in apply)
terraform plan -out=tfplan

# Plan with a specific var file
terraform plan -var-file="prod.tfvars"

# Plan targeting a specific resource only
terraform plan -target=aws_instance.web_server
```

**Output symbols:**
| Symbol | Meaning |
|---|---|
| `+` green | Resource will be **created** |
| `~` yellow | Resource will be **updated in place** |
| `-` red | Resource will be **destroyed** |
| `-/+` | Resource will be **destroyed and recreated** |

---

### `terraform apply`
**Executes** the changes shown in the plan. Prompts for confirmation by default.

```bash
terraform apply

# Skip confirmation prompt (use in CI/CD)
terraform apply -auto-approve

# Apply a saved plan file (no re-planning)
terraform apply tfplan

# Apply with specific variables
terraform apply -var="instance_type=t2.large"
```

---

### `terraform destroy`
**Destroys** all resources tracked in the state file.

```bash
terraform destroy

# Skip confirmation prompt
terraform destroy -auto-approve
```

> [!WARNING]
> Use with care in production. Always run `terraform plan` first to review what will be deleted.

---

## ✦ State Management Commands

### `terraform show`
Display the current state or a saved plan in human-readable format.

```bash
terraform show             # Show current state
terraform show tfplan      # Show contents of a saved plan file
```

---

### `terraform state list`
List all resources currently tracked in the state file.

```bash
terraform state list

# Filter by resource type
terraform state list aws_instance.*
```

---

### `terraform state show`
Show detailed attributes of a specific resource in state.

```bash
terraform state show aws_instance.web_server
```

---

### `terraform state mv`
Move/rename a resource in the state file (does not affect real infrastructure).

```bash
# Rename a resource
terraform state mv aws_instance.web aws_instance.web_server
```

---

### `terraform state rm`
Remove a resource from state without destroying the real resource. Useful when you want Terraform to stop managing something.

```bash
terraform state rm aws_instance.web_server
```

---

### `terraform refresh`
Syncs the state file with the actual state of real-world infrastructure. Detects manual changes made outside Terraform.

```bash
terraform refresh
```

> [!IMPORTANT]
> In modern Terraform (v0.15+), `terraform apply -refresh-only` is the preferred approach.

---

### `terraform import`
Import an existing cloud resource into Terraform state so it can be managed going forward.

```bash
# Syntax: terraform import <resource_type.name> <real_resource_id>
terraform import aws_instance.web_server i-0abcd1234efgh5678
```

> [!NOTE]
> After importing, you still need to write the matching `resource` block in your `.tf` files.

---

## ✦ Utility Commands

### `terraform output`
Display output values defined in your config.

```bash
terraform output                         # All outputs
terraform output instance_public_ip      # Specific output
terraform output -json                   # JSON format
```

---

### `terraform fmt`
**Formats** all `.tf` files to the canonical HCL style.

```bash
terraform fmt          # Format current directory
terraform fmt -recursive  # Format all subdirectories
terraform fmt -check   # Check only (exit 1 if unformatted — good for CI)
```

---

### `terraform console`
Opens an **interactive REPL** for evaluating Terraform expressions and testing functions.

```bash
terraform console

# Inside the console:
> var.instance_type
"t2.micro"

> cidrsubnet("10.0.0.0/16", 8, 1)
"10.0.1.0/24"
```

---

### `terraform workspace`
Manage multiple named workspaces (isolated state environments).

```bash
terraform workspace list              # List all workspaces
terraform workspace new staging       # Create a new workspace
terraform workspace select staging    # Switch to a workspace
```
