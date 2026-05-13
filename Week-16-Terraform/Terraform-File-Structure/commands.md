# ✦ Terraform Commands: File Structure & Formatting

> **Clean Code.** Commands to keep your Terraform file structure clean, valid, and properly formatted.

---

## ✦ Core Formatting Commands

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform fmt` | Formats all `.tf` files in the current directory to canonical standard. | `terraform fmt` |
| `terraform fmt -recursive` | Formats files in the current directory and all subdirectories. | `terraform fmt -recursive` |
| `terraform fmt -check` | Checks if files are formatted correctly (useful in CI/CD). Returns non-zero exit code if not. | `terraform fmt -check` |

---

## ✦ Validation Commands

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform validate` | Validates syntax, variable references, and configuration validity without hitting APIs. | `terraform validate` |

---

## ✦ Workspaces (Environment Management)

Commands for managing separate state files within the same directory structure.

| Command | Description |
|---|---|
| `terraform workspace show` | Display the current active workspace. |
| `terraform workspace list` | List all available workspaces. |
| `terraform workspace new <name>` | Create a new workspace and switch to it. |
| `terraform workspace select <name>` | Switch to an existing workspace. |
| `terraform workspace delete <name>` | Delete an empty workspace. |

> [!TIP]
> **Workspace Interpolation:** You can use `${terraform.workspace}` in your HCL code to dynamically change names based on the workspace (e.g., `name = "web-${terraform.workspace}"`).
