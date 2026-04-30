# ✦ Module: CloudFormation Commands

> **AWS CLI reference for managing CloudFormation stacks.**

---

### Deploying Stacks

**Create a new stack from a local template:**
```bash
aws cloudformation create-stack \
  --stack-name my-app-prod \
  --template-body file://template.yaml \
  --parameters ParameterKey=Env,ParameterValue=prod \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
```
> *Note: The `--capabilities` flag is required if your template creates IAM roles or policies.*

**Update an existing stack:**
```bash
aws cloudformation update-stack \
  --stack-name my-app-prod \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM
```

---

### Managing Stacks

**Delete a stack (destroys all associated resources):**
```bash
aws cloudformation delete-stack \
  --stack-name my-app-prod
```

**Describe stack events (useful for debugging failures):**
```bash
aws cloudformation describe-stack-events \
  --stack-name my-app-prod \
  --query 'StackEvents[*].{Time:Timestamp,Resource:LogicalResourceId,Status:ResourceStatus,Reason:ResourceStatusReason}' \
  --output table
```

**Validate a template before deploying:**
```bash
aws cloudformation validate-template \
  --template-body file://template.yaml
```

**List all active stacks:**
```bash
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```
