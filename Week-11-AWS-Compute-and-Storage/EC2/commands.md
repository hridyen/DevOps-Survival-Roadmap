[![Sector](https://img.shields.io/badge/SECTOR-EC2-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ EC2 — Commands Cheat Sheet

---

## ✦ ⚙️ AWS CLI — EC2 Commands

```bash
# ── Instances ────────────────────────────────────────────
aws ec2 describe-instances                          # List all instances
aws ec2 describe-instances --region ap-south-1      # Specific region
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" # Only running instances

aws ec2 start-instances --instance-ids i-1234567890
aws ec2 stop-instances --instance-ids i-1234567890
aws ec2 reboot-instances --instance-ids i-1234567890
aws ec2 terminate-instances --instance-ids i-1234567890  # ⚠️ Permanent delete

# ── Launch Instance ──────────────────────────────────────
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --key-name MyKeyPair \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --count 1

# ── Key Pairs ────────────────────────────────────────────
aws ec2 create-key-pair --key-name MyKeyPair \
  --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem                             # Required for SSH
aws ec2 describe-key-pairs                          # List key pairs
aws ec2 delete-key-pair --key-name MyKeyPair

# ── Security Groups ──────────────────────────────────────
aws ec2 describe-security-groups                    # List all SGs
aws ec2 create-security-group \
  --group-name MyWebSG \
  --description "Web server security group"

# Add inbound rule — allow HTTP from anywhere
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

# Add inbound rule — allow SSH from your IP only
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp --port 22 --cidr YOUR_IP/32

# Remove a rule
aws ec2 revoke-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

# ── AMIs (Machine Images) ────────────────────────────────
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*"     # Find Amazon Linux 2 AMIs

# ── Elastic IPs ──────────────────────────────────────────
aws ec2 allocate-address                            # Get a static IP
aws ec2 associate-address \
  --instance-id i-1234567890 \
  --allocation-id eipalloc-0123456789abcdef0        # Attach to instance
aws ec2 release-address \
  --allocation-id eipalloc-0123456789abcdef0        # Release (stop billing)
```

---

## ✦ 🔑 SSH into EC2

```bash
# Linux / Mac
chmod 400 MyKeyPair.pem
ssh -i MyKeyPair.pem ec2-user@<PUBLIC_IP>       # Amazon Linux
ssh -i MyKeyPair.pem ubuntu@<PUBLIC_IP>         # Ubuntu
ssh -i MyKeyPair.pem root@<PUBLIC_IP>           # Some other distros

# With specific port (if changed from 22)
ssh -i MyKeyPair.pem -p 2222 ec2-user@<PUBLIC_IP>

# Copy file to EC2 (SCP)
scp -i MyKeyPair.pem myfile.txt ec2-user@<PUBLIC_IP>:/home/ec2-user/

# Copy file FROM EC2
scp -i MyKeyPair.pem ec2-user@<PUBLIC_IP>:/home/ec2-user/file.txt ./
```

---

## ✦ 📜 User Data Script Templates

### ✦ Install Nginx (Amazon Linux 2)
```bash
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Hello from EC2!</h1>" > /usr/share/nginx/html/index.html
```

### ✦ Install Docker
```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
```

### ✦ Install Jenkins
```bash
#!/bin/bash
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -y java-11-openjdk jenkins
systemctl start jenkins
systemctl enable jenkins
```

### ✦ Install Docker + Docker Compose
```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

---

## ✦ 🔍 Instance Metadata (from inside the instance)

```bash
# Access metadata endpoint (only works from inside EC2)
curl http://169.254.169.254/latest/meta-data/

# Useful metadata fields
curl http://169.254.169.254/latest/meta-data/instance-id
curl http://169.254.169.254/latest/meta-data/public-ipv4
curl http://169.254.169.254/latest/meta-data/instance-type
curl http://169.254.169.254/latest/meta-data/placement/availability-zone
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

## ✦ My Notes

| Command | What it does | Notes |
|---|---|---|
| `aws ec2 get-console-output --instance-id i-1234` | Fetches raw boot logs | Extremely useful for debugging User Data scripts that fail. |
| `aws ec2 copy-image` | Copies an AMI to another region | Useful for cross-region disaster recovery preparations. |
