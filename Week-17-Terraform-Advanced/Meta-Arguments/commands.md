# ✦ Commands: Terraform Meta-Arguments & State

> **Advanced State Manipulation.** When using `count` and `for_each`, you need to know how to interact with the individual instances they create within your state file.

---

## ✦ Targeting Specific Instances

When using `count` or `for_each`, the resources are indexed in the state file. You can target them specifically for plans or applies.

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform state list` | List all resources in the state file. | `terraform state list` |
| `terraform plan -target` | Plan changes for a specific instance created by `count`. | `terraform plan -target="aws_instance.web[1]"` |
| `terraform apply -target` | Apply changes to a specific instance created by `for_each`. | `terraform apply -target="aws_iam_user.accounts[\"alice\"]"` |

## ✦ State Manipulation for Iterators

If you change a resource from using `count` to `for_each`, Terraform will want to destroy and recreate the resources. You can prevent this by manually moving them in the state file.

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform state mv` | Rename a resource in the state file. | `terraform state mv "aws_instance.web[0]" "aws_instance.web[\"us-east-1a\"]"` |
| `terraform state rm` | Stop managing a specific instance. | `terraform state rm "aws_instance.web[2]"` |
