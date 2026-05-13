# ✦ Module: Terraform Functions

> **Data Transformation.** Terraform includes built-in functions to transform and combine values dynamically. Unlike general-purpose languages, Terraform does not support user-defined functions; you must use the built-in ones.

---

## ✦ Core Functions Overview

Functions in Terraform follow standard syntax: `function_name(arg1, arg2)`. You can test functions easily using the `terraform console`.

---

## ✦ 1. String Functions

Manipulate and evaluate strings.

| Function | Description | Example | Result |
|---|---|---|---|
| `upper()` | Converts string to uppercase. | `upper("devops")` | `"DEVOPS"` |
| `lower()` | Converts string to lowercase. | `lower("PROD")` | `"prod"` |
| `split()` | Splits a string into a list by a separator. | `split(",", "a,b,c")` | `["a", "b", "c"]` |
| `join()` | Joins a list into a string with a separator. | `join("-", ["web", "prod"])` | `"web-prod"` |
| `replace()` | Replaces substrings within a string. | `replace("hello world", "world", "terraform")` | `"hello terraform"` |

---

## ✦ 2. Numeric Functions

Perform mathematical operations.

| Function | Description | Example | Result |
|---|---|---|---|
| `max()` | Returns the greatest number from a set. | `max(12, 54, 3)` | `54` |
| `min()` | Returns the smallest number from a set. | `min(12, 54, 3)` | `3` |
| `ceil()` | Rounds up to the nearest whole number. | `ceil(5.1)` | `6` |
| `floor()` | Rounds down to the nearest whole number. | `floor(5.9)` | `5` |

---

## ✦ 3. Collection Functions

Work with lists, maps, and sets.

| Function | Description | Example | Result |
|---|---|---|---|
| `length()` | Returns the number of elements in a list, map, or string. | `length(["a", "b"])` | `2` |
| `concat()` | Combines two or more lists into a single list. | `concat(["a"], ["b"])` | `["a", "b"]` |
| `contains()` | Checks if a list contains a specific value. | `contains(["a", "b"], "a")` | `true` |
| `merge()` | Combines two or more maps. | `merge({a=1}, {b=2})` | `{a=1, b=2}` |
| `keys()` | Returns a list of keys from a map. | `keys({a=1, b=2})` | `["a", "b"]` |
| `values()` | Returns a list of values from a map. | `values({a=1, b=2})` | `[1, 2]` |

---

## ✦ 4. File and Hash Functions

Read files from disk and calculate hashes (useful for detecting file changes).

| Function | Description | Example Use Case |
|---|---|---|
| `file()` | Reads the contents of a file as a string. | `user_data = file("init.sh")` |
| `filebase64()` | Reads a file and returns its base64 encoded string. | Useful for passing scripts to AWS EC2 User Data if base64 is required. |
| `templatefile()` | Reads a file and renders its content using variables. | `templatefile("policy.json.tpl", { port = 8080 })` |
| `md5()` / `sha256()` | Calculates the hash of a string. | Checking if an AWS Lambda deployment package has changed. |

---

## ✦ 5. IP Network Functions

Handle CIDR blocks and IP routing (critical for VPC creation).

| Function | Description | Example | Result |
|---|---|---|---|
| `cidrsubnet()` | Calculates a subnet address within a given IP network address prefix. | `cidrsubnet("10.0.0.0/16", 8, 1)` | `"10.0.1.0/24"` |
| `cidrhost()` | Calculates a full host IP address within a given IP network prefix. | `cidrhost("10.0.0.0/16", 4)` | `"10.0.0.4"` |

**Real-world Example: Generating Subnets Dynamically**
```hcl
variable "vpc_cidr" { default = "10.0.0.0/16" }

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  # Creates: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
}
```

---

## ✦ The Conditional Expression

While not technically a function, the conditional expression (ternary operator) is heavily used alongside functions.

**Syntax:** `condition ? true_val : false_val`

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  # Use t3.large in prod, t2.micro everywhere else
  instance_type = var.env == "prod" ? "t3.large" : "t2.micro"
}
```
