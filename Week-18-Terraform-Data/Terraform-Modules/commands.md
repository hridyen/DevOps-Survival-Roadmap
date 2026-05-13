# ✦ Commands: Terraform Modules

> **Initializing and Managing Modules.** How to download modules and interact with resources inside a child module.

---

## ✦ Getting Modules

When you add a new `module` block to your configuration, Terraform does not automatically download it. You must initialize it.

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform get` | Downloads and installs modules needed for the configuration. | `terraform get` |
| `terraform get -update` | Checks the source and downloads the newest versions of the modules. | `terraform get -update` |
| `terraform init` | Also runs `terraform get` under the hood. You usually just run `init`. | `terraform init` |

Where do they go? Terraform downloads child modules into the `.terraform/modules/` directory.

---

## ✦ Targeting Resources in Modules

If you want to plan or apply a change to *only* a specific resource that lives inside a module, you have to use a specific syntax.

**Syntax:** `module.<MODULE_NAME>.<RESOURCE_TYPE>.<RESOURCE_NAME>`

| Command | Description | Example / Use Case |
|---|---|---|
| `terraform state list` | See how module resources are named in state. | `terraform state list` |
| `terraform plan -target` | Target the entire module. | `terraform plan -target="module.production_vpc"` |
| `terraform apply -target` | Target a specific resource inside the module. | `terraform apply -target="module.production_vpc.aws_vpc.main"` |
