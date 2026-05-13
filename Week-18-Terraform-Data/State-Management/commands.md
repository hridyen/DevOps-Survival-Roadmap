# ✦ Commands: Terraform State Management

> **Handle with Care.** Commands to safely view and manipulate your remote state.

---

## ✦ State Manipulation Commands

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform state list` | List all resources tracked in the current state file. | `terraform state list` |
| `terraform state show <address>` | Show the attributes of a single resource in the state file. | `terraform state show aws_instance.web` |
| `terraform state mv <old> <new>` | Move an item in the state. Used for renaming resources without destroying them. | `terraform state mv aws_instance.web aws_instance.frontend` |
| `terraform state rm <address>` | Remove an item from the state. Terraform will no longer manage it, but it remains in AWS. | `terraform state rm aws_instance.web` |
| `terraform state pull > state.json` | Download the remote state file locally and output to a JSON file. Useful for debugging. | `terraform state pull > state.json` |
| `terraform state push <file>` | Manually upload a local state file to the remote backend. **Highly dangerous.** | `terraform state push state.json` |

## ✦ Importing Existing Infrastructure

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform import <address> <id>` | Find existing infrastructure and add it to Terraform state. | `terraform import aws_s3_bucket.bucket my-bucket-name` |

> [!WARNING]
> Before running `terraform import`, you **must** write the empty `resource` block in your `.tf` file. Import only maps the cloud resource to the state file; it does not automatically generate the HCL code for you (unless you use third-party tools like Terraformer or the new `import` block in Terraform 1.5+).
