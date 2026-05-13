# ✦ Commands: Terraform Functions

> **Test Before You Deploy.** Use the Terraform console to safely test your functions and expressions before writing them into your `.tf` files.

---

## ✦ The Terraform Console

The `terraform console` command provides an interactive REPL (Read-Eval-Print Loop) for evaluating Terraform expressions.

| Command | Description |
|---|---|
| `terraform console` | Opens the interactive console. Type `exit` or press `Ctrl+C` to leave. |

### How to use it:

1. **Test basic functions:**
   ```bash
   > max(5, 12, 9)
   12
   
   > split(",", "foo,bar,baz")
   [
     "foo",
     "bar",
     "baz",
   ]
   ```

2. **Test local variables or data sources** (Requires running `terraform init` and `terraform plan` or having an existing state):
   ```bash
   > local.common_tags
   {
     "Environment" = "prod"
     "Project"     = "Alpha"
   }
   
   > merge(local.common_tags, { "Name" = "WebServer" })
   {
     "Environment" = "prod"
     "Name"        = "WebServer"
     "Project"     = "Alpha"
   }
   ```
