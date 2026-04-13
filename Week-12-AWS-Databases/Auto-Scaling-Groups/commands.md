[![Sector](https://img.shields.io/badge/SECTOR-SCALABILITY-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ ASG — Commands Cheat Sheet

> **Week:** 12
> **Folder:** Auto-Scaling-Groups
> **Topic:** CLI Operations for Scaling Infrastructure

---

## ✦ AWS CLI — Auto Scaling Operations

### ⚡ Launch Template Management
```bash
# Create a Launch Template for EC2 instances
aws ec2 create-launch-template \
  --launch-template-name MyWebServerTemplate \
  --version-description "v1" \
  --launch-template-data '{
    "ImageId": "ami-0abcdef1234567890",
    "InstanceType": "t2.micro",
    "KeyName": "MyKeyPair",
    "SecurityGroupIds": ["sg-0123456789abcdef0"],
    "UserData": "IyEvYmluL2Jhc2gKeXVtIHVwZGF0ZSAteQp5dW0gaW5zdGFsbCAteSBodHRwZA=="
  }'

# List active launch templates
aws ec2 describe-launch-templates

# Check version details of a template
aws ec2 describe-launch-template-versions \
  --launch-template-name MyWebServerTemplate
```

### ⚡ Auto Scaling Group Lifecycle
```bash
# Create the ASG with specific boundaries
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-web-asg \
  --launch-template LaunchTemplateName=MyWebServerTemplate,Version='$Latest' \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-111aaa,subnet-222bbb,subnet-333ccc" \
  --target-group-arns arn:aws:elasticloadbalancing:us-east-1:12345678:targetgroup/my-tg/abc \
  --health-check-type ELB \
  --health-check-grace-period 300

# Inspect the ASG state
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names my-web-asg

# List instances currently managed by ASGs
aws autoscaling describe-auto-scaling-instances
```

### ⚡ Manual & Policy Scaling
```bash
# Manually adjust capacity
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name my-web-asg \
  --desired-capacity 4

# Update group boundaries
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-web-asg \
  --min-size 2 \
  --max-size 10

# Attach a Target Tracking Policy (CPU at 50%)
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-web-asg \
  --policy-name cpu-target-50 \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50.0
  }'
```

### ⚡ Instance Control
```bash
# Terminate and automatically replace an instance
aws autoscaling terminate-instance-in-auto-scaling-group \
  --instance-id i-1234567890abcdef0 \
  --should-decrement-desired-capacity

# Detach an instance for investigation (Enter Standby)
aws autoscaling enter-standby \
  --instance-ids i-1234567890abcdef0 \
  --auto-scaling-group-name my-web-asg \
  --should-decrement-desired-capacity

# Return instance to service
aws autoscaling exit-standby \
  --instance-ids i-1234567890abcdef0 \
  --auto-scaling-group-name my-web-asg

## 🔥 Stress Test — Trigger Scaling

```bash
# SSH into an EC2 instance in your ASG
ssh -i key.pem ec2-user@<instance-ip>

# Install stress tool
sudo yum install -y stress   # Amazon Linux
sudo apt install -y stress   # Ubuntu

# Stress CPU to trigger scale-out
stress --cpu 4 --timeout 300

# Watch ASG activity in another terminal
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name my-web-asg
```

---

## 📝 My Notes

| Command | What it does | Notes |
|---|---|---|
| | | |
