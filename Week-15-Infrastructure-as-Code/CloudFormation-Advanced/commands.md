# ✦ Module: Advanced CloudFormation Commands

> **Managing StackSets and validating infrastructure code.**

---

### Managing StackSets

**Create a StackSet:**
```bash
aws cloudformation create-stack-set \
  --stack-set-name my-global-guardrails \
  --template-body file://guardrails.yaml \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false
```

**Deploy StackSet Instances to specific OUs and Regions:**
```bash
aws cloudformation create-stack-instances \
  --stack-set-name my-global-guardrails \
  --deployment-targets OrganizationalUnitIds='ou-1234-5678' \
  --regions 'us-east-1' 'eu-west-1'
```

---

### CFN-Guard Validation

**Validate a template against a rule file locally:**
```bash
cfn-guard validate \
  -d template.yaml \
  -r rules/s3_rules.guard
```
