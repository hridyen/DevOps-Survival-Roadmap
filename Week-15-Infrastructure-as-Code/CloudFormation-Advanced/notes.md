# ✦ Module: Advanced CloudFormation

> **Scaling IaC with Nested Stacks, StackSets, and Policy-as-Code.**

---

## ✦ Nested Stacks

For large, complex architectures, breaking templates into smaller, modular **nested stacks** is best practice. 

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

**Benefits:**
- Reuse common baseline components (VPC, IAM).
- Bypass the 51,200 byte template size limit.
- Separation of concerns across engineering teams.

---

## ✦ StackSets

Deploy the **same stack across multiple AWS accounts and regions** simultaneously.

- Used heavily in AWS Organizations.
- Great for enforcing security guardrails (e.g., enabling CloudTrail, standardizing IAM roles) across all member accounts.

---

## ✦ CloudFormation Guard (cfn-guard)

An open-source **policy-as-code** tool. It validates CloudFormation templates against compliance rules locally before you even attempt a deployment.

```bash
# Example guard rule: ensure S3 buckets are not public
rule s3_bucket_no_public_access {
  AWS::S3::Bucket {
    Properties.PublicAccessBlockConfiguration.BlockPublicAcls == true
  }
}
```

> [!TIP]
> Integrate `cfn-guard` and `cfn-lint` into your Jenkins CI/CD pipeline to ensure developers cannot deploy non-compliant infrastructure.

---

## ✦ CloudFormation Hooks

Hooks let you execute custom validation logic within the CloudFormation execution engine itself (server-side). If a developer tries to provision a non-compliant resource, the hook intercepts the deployment and can **Fail** or **Warn** the user.
