# ✦ Commands: Terraform Data Sources

> **Query Before You Code.** How to fetch and inspect the state of data sources using the CLI.

---

## ✦ Inspecting Data Sources

While data sources are automatically fetched during a `terraform plan` or `terraform apply`, you can also inspect them directly using the console or state commands.

| Command | Description |
|---|---|
| `terraform console` | Opens the interactive console. Useful for testing if a data source resolves correctly. |
| `terraform state show data.aws_ami.ubuntu` | Displays the full output of a data source currently saved in your state file. |
| `terraform refresh` | Updates the local state file against real-world resources (including refreshing data sources). *Note: In modern Terraform, this happens automatically during plan.* |

**Using the Console with Data Sources:**
If you have `data "aws_region" "current" {}` in your config, you can evaluate it in the console:

```bash
> data.aws_region.current.name
"us-east-1"
```
