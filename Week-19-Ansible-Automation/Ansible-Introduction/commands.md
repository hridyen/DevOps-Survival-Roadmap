# ✦ Commands & Setup: Ansible Fundamentals

> **Bootstrap and Execute.** Step-by-step procedures to install Ansible, establish SSH trust relationships, run ad-hoc command utilities, and run your first playbook checks.

---

## ✦ 1. Preparing the Host & Node Systems

Execute these commands on **both** the Control (Master) Node and all Managed (Slave) Nodes to establish the `ansible` system account.

### Create the Ansible System User & Password
```bash
# Add the user
sudo useradd ansible

# Assign a password to the user
sudo passwd ansible
```

### Configure Sudoers Access (Passwordless Privileges)
Open the sudoers configuration file:
```bash
sudo visudo
```
Add the following line at the end of the file (typically around line 100) to grant passwordless sudo privilege to the `ansible` user:
```text
ansible ALL=(ALL) NOPASSWD: ALL
```

### Enable Password Authentication over SSH
By default, cloud VM instances might disable password login. Open the SSH daemon configuration:
```bash
sudo vi /etc/ssh/sshd_config
```
Modify these entries:
```text
# Ensure PasswordAuthentication is set to yes
PasswordAuthentication yes
```
Restart the SSH service to apply the change:
```bash
sudo systemctl restart sshd
```

---

## ✦ 2. Installing Ansible (Control Node Only)

Execute these packages commands only on the Control Node server.

### Install Ansible & Dependencies
```bash
# On Amazon Linux / CentOS
sudo amazon-linux-extras install ansible2 -y
sudo yum install python python-pip openssl -y

# Verify the installation and dependencies version
ansible --version
python --version
```

---

## ✦ 3. Establish Passwordless SSH Trust

Run these actions on the **Control Node** as the `ansible` user to log in to all target nodes without keying in a password.

### Keygen & Propagation
```bash
# 1. Switch to the ansible user account
sudo su - ansible

# 2. Generate RSA Key Pair (press Enter 3 times to accept default paths)
ssh-keygen

# 3. Propagate public key to the remote managed nodes
ssh-copy-id ansible@<managed_node_ip_address>
```

### Test SSH Connection
```bash
ssh ansible@<managed_node_ip_address>
# Should drop you into the remote shell immediately without a password prompt. Type 'exit' to log out.
exit
```

---

## ✦ 4. Configure Inventory & Ansible Settings

### Declare Managed Nodes in Inventory File
Edit the default inventory:
```bash
sudo vi /etc/ansible/hosts
```
Add ungrouped or grouped node IP definitions:
```ini
# Ungrouped Hosts
172.31.41.168

# Grouped Web Servers
[webserver]
172.31.41.168
172.31.41.169
```

### Update Ansible Configuration Permissions
Edit `/etc/ansible/ansible.cfg` to confirm the default inventory path and executor permissions:
```ini
[defaults]
inventory      = /etc/ansible/hosts
sudo_user      = root
```

---

## ✦ 5. Ad-Hoc Command Examples

Ad-hoc commands are one-liners used for immediate execution on target nodes.
Syntax: `ansible <all/groupName/IP> [-b] -m <moduleName> -a <arguments>`

```bash
# Ping all host nodes to verify Ansible connectivity
ansible all -m ping

# List all configured hosts in the inventory
ansible all --list-hosts

# Run a simple shell command on the 'webserver' group
ansible webserver -a "ls -al"

# Get server system uptime using command module
ansible all -m command -a "uptime"

# Check disk space utilization using shell module (supports pipes)
ansible all -m shell -a "df -h | grep /dev/"

# Copy a local file to all managed servers
ansible all -m copy -a "src=/home/ansible/test.txt dest=/tmp/test.txt"

# Install Apache (httpd) on all servers (become root)
ansible all -b -m yum -a "name=httpd state=present"

# Restart Apache daemon
ansible all -b -m service -a "name=httpd state=restarted"
```

---

## ✦ 6. Playbook Validation & Execution

### Basic Playbook Example (`ping-playbook.yml`)
```yaml
---
- hosts: all
  become: yes
  connection: ssh

  tasks:
    - name: Ping All Host Nodes
      ping:
```

### Execute Playbook Utilities
```bash
# Validate playbook syntax for errors
ansible-playbook ping-playbook.yml --syntax-check

# Perform a dry-run check (simulates changes without applying them)
ansible-playbook ping-playbook.yml --check

# Run the playbook
ansible-playbook ping-playbook.yml

# Execute the playbook in verbose debug mode
ansible-playbook ping-playbook.yml -v    # basic
ansible-playbook ping-playbook.yml -vv   # moderate
ansible-playbook ping-playbook.yml -vvv  # complete debug log

# Run step-by-step, confirming each task before execution
ansible-playbook ping-playbook.yml --step
```

---

## ✦ 7. Initialize Ansible Roles
Initialize a standard, modular directory structure for complex playbooks:
```bash
ansible-galaxy role init my_role_name
```
