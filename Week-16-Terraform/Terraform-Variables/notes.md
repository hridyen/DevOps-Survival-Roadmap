# ✦ Module: Terraform Variables & Data Types

> **Dynamic Configurations.** Eliminate hardcoded values to make Terraform configurations reusable, flexible, and secure.

---

## ✦ Why Variables?

Variables eliminate hardcoded values from your Terraform code, making configurations:
- **Reusable** across environments (dev, staging, prod)
- **Flexible** — change one value, update everything
- **Secure** — sensitive values stay out of code

Instead of this:
```hcl
instance_type = "t2.micro"   # hardcoded — bad
```

Do this:
```hcl
instance_type = var.instance_type   # dynamic — good
```

---

## ✦ Declaring Variables

Variables are declared using a `variable` block, typically in a `variables.tf` file:

```hcl
variable "instance_type" {
  description = "EC2 instance type to use"
  type        = string
  default     = "t2.micro"
}
```

| Argument | Required | Purpose |
|---|---|---|
| `description` | Recommended | Documents what the variable is for |
| `type` | Recommended | Enforces the expected data type |
| `default` | Optional | Used when no value is provided |
| `sensitive` | Optional | Hides value from CLI output |
| `validation` | Optional | Enforce allowed values/formats |

---

## ✦ Assigning Variable Values

Variables can be set in multiple ways (in order of precedence, highest first):

| Method | Example |
|---|---|
| `-var` flag | `terraform apply -var="instance_type=t2.large"` |
| `-var-file` flag | `terraform apply -var-file="prod.tfvars"` |
| `terraform.tfvars` file | Auto-loaded if present |
| `*.auto.tfvars` file | Auto-loaded if present |
| Environment variable | `export TF_VAR_instance_type=t2.large` |
| Default value | Defined in `variable` block |
| Interactive prompt | Asked at runtime if no value and no default |

---

## ✦ Variable Types

### String
Stores a single text value.

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```

### Number
Stores a numeric value (integer or float).

```hcl
variable "instance_count" {
  type    = number
  default = 2
}
```

### Boolean
Stores `true` or `false` — useful for feature flags.

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}
```

### List
An **ordered** collection of values of the **same type**. Access by index (0-based).

```hcl
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
# Usage: var.availability_zones[0]
```

### Map
A collection of **key-value pairs** where keys are strings. Access by key name.

```hcl
variable "instance_types" {
  type = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t3.medium"
  }
}
# Usage: var.instance_types["prod"]
```

### Object
A **structured type** with named attributes, each with its own type. Used for grouping related settings.

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    disk_size_gb  = number
    enable_backup = bool
  })
  default = {
    instance_type = "t2.micro"
    disk_size_gb  = 20
    enable_backup = true
  }
}
# Usage: var.server_config.instance_type
```

### Set
An **unordered** collection of **unique** values of the same type. No duplicates, no index access.

```hcl
variable "security_groups" {
  type    = set(string)
  default = ["sg-0692abc123", "sg-04fg5ca004"]
}
```

---

## ✦ Variable Validation

Enforce rules on variable values before Terraform runs:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "instance_type must be one of: t2.micro, t2.small, t2.medium."
  }
}
```

---

## ✦ Sensitive Variables

Mark variables as sensitive to hide their values from CLI output and logs:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

> [!WARNING]
> Never store sensitive values in `.tfvars` files that are committed to Git. Use environment variables or a secrets manager.

---

## ✦ Using `.tfvars` Files

Keep environment-specific values separate from code:

**`terraform.tfvars`** (auto-loaded):
```hcl
instance_type  = "t2.medium"
region         = "us-west-2"
```

**`prod.tfvars`** (explicit):
```hcl
instance_type  = "t3.large"
region         = "us-east-1"
```

---

## ✦ Locals (Computed Values)

Locals are internal computed values — not user inputs, not outputs. They're calculated from other values.

```hcl
locals {
  environment = var.env
  name_prefix = "myapp-${local.environment}"
  common_tags = {
    Project     = "devops-training"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  tags          = local.common_tags
}
```

> [!TIP]
> Use `locals` for repeated expressions to keep your code DRY (Don't Repeat Yourself).
