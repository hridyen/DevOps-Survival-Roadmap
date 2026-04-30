# AWS CloudFormation

## What is CloudFormation?

AWS CloudFormation is an Infrastructure as Code (IaC) service that lets you model, provision, and manage AWS resources using template files (YAML or JSON). Instead of manually clicking through the console, you define your entire infrastructure in a template — and CloudFormation handles creating, updating, and deleting everything in the right order.

> "You define what you want. CloudFormation figures out how to build it."

---

## Core Concepts

### Template
A YAML or JSON file that describes the AWS resources you want to create.

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: Simple EC2 web server

Parameters:
  InstanceType:
    Type: String
    Default: t2.micro

Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ami-0c55b159cbfafe1f0
      Tags:
        - Key: Name
          Value: WebServer

Outputs:
  PublicIP:
    Value: !GetAtt WebServer.PublicIp
```

### Stack
A **stack** is a single unit of AWS resources created from a template. You create, update, or delete a stack — and CloudFormation manages all the resources inside it together.

- One template → one or more stacks
- Deleting a stack deletes all its resources (unless you set deletion policies)

### Resources
The actual AWS infrastructure defined in the template — EC2 instances, RDS databases, VPCs, S3 buckets, Lambda functions, IAM roles, etc.

### Parameters
Inputs that let you customize a template at deployment time (e.g. instance type, environment name, DB password).

### Outputs
Values that CloudFormation exports after a stack is created — e.g. an EC2 public IP, an S3 bucket name, a load balancer DNS.

### Mappings
Static lookup tables inside a template (e.g. map region → AMI ID).

### Conditions
Logic inside templates to conditionally create resources (e.g. only create a bastion host in production).

---

## Template Anatomy

```yaml
AWSTemplateFormatVersion: "2010-09-09"  # Always this version

Description: What this stack does

Metadata:
  # Optional extra info about the template

Parameters:
  # User inputs at deploy time

Mappings:
  # Static key-value lookups

Conditions:
  # Boolean logic for conditional resources

Resources:          # REQUIRED — the actual AWS resources
  MyBucket:
    Type: AWS::S3::Bucket

Outputs:
  # Values to export after stack creation
```

---

## Intrinsic Functions

CloudFormation provides built-in functions to make templates dynamic:

| Function | Purpose | Example |
|---|---|---|
| `!Ref` | Reference a parameter or resource | `!Ref InstanceType` |
| `!GetAtt` | Get an attribute of a resource | `!GetAtt MyBucket.Arn` |
| `!Sub` | String substitution | `!Sub "arn:aws:s3:::${BucketName}/*"` |
| `!Join` | Join strings with a delimiter | `!Join [",", [a, b, c]]` |
| `!Select` | Select item from a list | `!Select [0, !GetAZs ""]` |
| `!If` | Conditional value | `!If [IsProd, t3.large, t3.micro]` |
| `!ImportValue` | Import output from another stack | `!ImportValue VpcId` |

---

## Lifecycle: How CloudFormation Works

```
Write Template (YAML/JSON)
        │
        ▼
Upload to S3 or paste in console
        │
        ▼
CloudFormation validates template
        │
        ▼
Create / Update / Delete Stack
        │
        ▼
CloudFormation provisions resources in dependency order
        │
        ▼
Stack status: CREATE_COMPLETE / UPDATE_COMPLETE / ROLLBACK
```

### Stack Update Behaviors
| Change Type | Behavior |
|---|---|
| No interruption | Resource updated in place |
| Some interruption | Resource restarts (brief downtime) |
| Replacement | Resource deleted and recreated |

---

## Key Benefits

### 1. Infrastructure as Code
- Version control your infrastructure alongside your application code
- Review changes via pull requests before applying
- Full audit trail of who changed what and when

### 2. Consistency & Repeatability
- Every environment (dev, staging, prod) is created from the same template
- Eliminates config drift and manual errors
- One CLI command provisions an entire stack

```bash
# Deploy a stack
aws cloudformation create-stack \
  --stack-name my-app-prod \
  --template-body file://template.yaml \
  --parameters ParameterKey=Env,ParameterValue=prod

# Update a stack
aws cloudformation update-stack \
  --stack-name my-app-prod \
  --template-body file://template.yaml

# Delete a stack (removes all resources)
aws cloudformation delete-stack \
  --stack-name my-app-prod
```

### 3. Cost Optimization
- Easily replicate stacks across regions with one command
- Right-size resources by updating a single parameter
- Tear down non-production stacks when not in use

### 4. Documentation
- The template is living documentation of your architecture
- New team members can read the template to understand the entire infrastructure
- Combine with tools like **CloudCraft** or **cfn-diagram** for visual architecture diagrams

### 5. Rollback on Failure
- If a stack creation or update fails, CloudFormation automatically rolls back to the last known good state
- No partial deployments left in broken states

---

## Nested Stacks

Large templates can be broken into smaller, reusable **nested stacks**:

```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/mybucket/network.yaml

  AppStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/mybucket/app.yaml
      Parameters:
        VpcId: !GetAtt NetworkStack.Outputs.VpcId
```

Benefits:
- Reuse common components (VPC, IAM roles) across projects
- Easier to manage and test smaller templates
- Cleaner separation of concerns

---

## Stack Sets

Deploy the **same stack to multiple AWS accounts and regions** simultaneously.

Use cases:
- Multi-account organization governance (e.g. enforce CloudTrail in all accounts)
- Deploy to all regions for a global app
- Enforce security baselines across an AWS Organization

---

## CloudFormation vs Terraform

| Feature | CloudFormation | Terraform |
|---|---|---|
| Provider | AWS only | Multi-cloud (AWS, Azure, GCP…) |
| Language | YAML / JSON | HCL (HashiCorp Config Language) |
| State management | Managed by AWS | Managed by you (S3 + DynamoDB) |
| Rollback | Automatic | Manual |
| Cost | Free (pay for resources) | Free (OSS) / Paid (Enterprise) |
| Best for | AWS-only shops | Multi-cloud environments |

---

## AWS Services CloudFormation Supports

CloudFormation can provision virtually any AWS service:

- **Compute:** EC2, Lambda, ECS, EKS, Batch
- **Networking:** VPC, Subnets, Security Groups, Route Tables, ELB, CloudFront
- **Storage:** S3, EBS, EFS
- **Database:** RDS, DynamoDB, ElastiCache, Redshift
- **Security:** IAM users, roles, policies, KMS keys
- **Messaging:** SQS, SNS, Kinesis
- **Monitoring:** CloudWatch alarms, dashboards, log groups
- **Serverless:** Lambda, API Gateway, DynamoDB

---

## CloudFormation Guard (cfn-guard)

An open-source **policy-as-code** tool that validates CloudFormation templates against compliance rules before deployment.

```bash
# Example guard rule: ensure S3 buckets are not public
rule s3_bucket_no_public_access {
  AWS::S3::Bucket {
    Properties.PublicAccessBlockConfiguration.BlockPublicAcls == true
  }
}

# Validate a template
cfn-guard validate -d template.yaml -r rules/s3_rules.guard
```

---

## CloudFormation Hooks

Hooks let you run **custom validation logic** before resources are provisioned or updated. If a resource is non-compliant, CloudFormation can:
- **Fail** the operation and block provisioning
- **Warn** but allow the operation to continue

Use case: Enforce that all EC2 instances use approved AMIs, or that all S3 buckets have encryption enabled.

---

## Official Documentation

| Resource | Link |
|---|---|
| User Guide | https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/ |
| Template Reference | https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/ |
| AWS CLI Reference | https://docs.aws.amazon.com/cli/latest/reference/cloudformation/ |
| API Reference | https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/ |
| Hooks User Guide | https://docs.aws.amazon.com/cloudformation-cli/latest/hooks-userguide/ |
| Guard User Guide | https://docs.aws.amazon.com/cfn-guard/latest/ug/ |
| CFN CLI User Guide | https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/ |
