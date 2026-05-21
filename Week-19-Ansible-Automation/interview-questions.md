# ⚡ Week 19 — Ansible Automation Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on Ansible inventories, playbooks, Vault encryption, handlers, rolling updates, and execution scaling.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You are running Ansible against dynamic AWS EC2 fleets where instances are launched and terminated constantly. Storing static IP addresses in an `/etc/ansible/hosts` file is impossible. How do you configure Ansible to query EC2 instances dynamically?</b></summary>
<b>Answer:</b>
Use the **Ansible `aws_ec2` dynamic inventory plugin**:
1. **Enable Plugin:** In your `ansible.cfg` file, ensure the plugin is enabled:
   ```ini
   [defaults]
   inventory = inventory/
   [inventory]
   enable_plugins = aws_ec2
   ```
2. **Configure Inventory File:** Create a configuration file named `hosts.aws_ec2.yml` (must end with `aws_ec2.yml` or `aws_ec2.yaml`):
   ```yaml
   plugin: amazon.aws.aws_ec2
   regions:
     - us-east-1
   keyed_groups:
     # Group instances by their "Environment" tag
     - key: tags.Environment
       separator: ""
       prefix: env_
   hostnames:
     # Use private IP addresses to connect
     - private-ip-address
   ```
3. **Execution:** Run Ansible commands passing the directory of the YAML config. Ansible will query the AWS EC2 API, fetch running instances, and group them dynamically (e.g. `env_Production`).
</details>

<details>
<summary><b>Q2: Scenario: Your playbook needs to configure a database password on your application servers. You do not want to store this password in plaintext in Git. How do you use Ansible Vault to encrypt this secret, and how do you run the playbook in CI/CD?</b></summary>
<b>Answer:</b>
1. **Create Encrypted File:** Use `ansible-vault` to create an encrypted variable file:
   ```bash
   ansible-vault create vars/secrets.yml
   ```
   - Provide a vault password and define variables:
     ```yaml
     db_password: "SuperSecretPassword123"
     ```
2. **Reference in Playbook:** Load the variables in your playbook:
   ```yaml
   - name: Deploy App
     hosts: webservers
     vars_files:
       - vars/secrets.yml
     tasks:
       - name: Configure App
         template:
           src: app_config.j2
           dest: /etc/app/config.ini
   ```
3. **Execution in CI/CD:**
   - In Jenkins/GitHub Actions, store the vault password in a secret credential provider.
   - Write the password to a temporary file (e.g. `.vault_pass`) or read it from an environment variable.
   - Execute the playbook passing the password file flag:
     ```bash
     ansible-playbook -i inventory/ play playbook.yml --vault-password-file .vault_pass
     ```
</details>

<details>
<summary><b>Q3: Scenario: You have a task in a playbook that copies an updated Nginx configuration file. You want Nginx to restart only when the configuration file actually changes. How do you implement this, and what happens if multiple tasks notify the same restart handler?</b></summary>
<b>Answer:</b>
- **Implementation:** Use a **Handler** with a `notify` statement:
  ```yaml
  tasks:
    - name: Copy Nginx Config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
  ```
- **Handler Execution Rules:**
  1. Handlers only run if the task notifying them returns a status of `changed`. If the template matches the destination file exactly, no restart occurs.
  2. Handlers run **at the very end** of the play, after all tasks have finished.
  3. If 5 different tasks notify the "Restart Nginx" handler during a play, the handler will **only execute once** at the end, preventing redundant service recycles.
  4. *Override:* If you need a handler to run immediately mid-play, run the flush handlers meta step:
     ```yaml
     - meta: flush_handlers
     ```
</details>

<details>
<summary><b>Q4: Scenario: You need to install software packages. If the target server is a Debian/Ubuntu system, you must use `apt`. If the server is RedHat/CentOS, you must use `yum`. How do you write a single playbook to handle this?</b></summary>
<b>Answer:</b>
Use **Ansible Facts** combined with **Conditionals** (`when`):
```yaml
- name: Install Nginx
  hosts: all
  tasks:
    - name: Install on Debian systems
      apt:
        name: nginx
        state: present
        update_cache: yes
      when: ansible_facts['os_family'] == "Debian"

    - name: Install on RedHat systems
      yum:
        name: nginx
        state: present
      when: ansible_facts['os_family'] == "RedHat"
```
During the initialization phase of a play, Ansible automatically executes the `setup` module to gather facts (system metadata like OS family, IP address, CPU details) from remote nodes. The `when` statement evaluates these facts to decide whether to execute the task.
</details>

<details>
<summary><b>Q5: Scenario: What is the standard file structure of an Ansible Role? Explain the purpose of `defaults/`, `vars/`, and `meta/` directories.</b></summary>
<b>Answer:</b>
An Ansible Role has the following structured subdirectories under its name (e.g. `roles/webserver/`):
- `tasks/main.yml`: The primary list of tasks to execute.
- `handlers/main.yml`: Handlers triggered by notify statements.
- `templates/`: Jinja2 templates (`.j2`) used by the template module.
- `files/`: Static files to be copied directly to remote hosts.
- `defaults/main.yml`: Default variable values for the role. These have the **lowest priority** of all variables and are easily overridden by users.
- `vars/main.yml`: Static variable values for the role. These have **high priority** and should not be overridden by module callers.
- `meta/main.yml`: Metadata about the role (author, platforms, and dependencies on other roles).
</details>

<details>
<summary><b>Q6: Scenario: An engineer wrote a task using the `command` module: `command: create_user.sh --user admin`. Every time the playbook runs, it flags the status as "changed=1", even if the user already exists. How do you make this task idempotent?</b></summary>
<b>Answer:</b>
The `command` and `shell` modules are not natively idempotent; they run the command on every execution and report `changed`.
- **Method 1 (Using `creates`):** Tell Ansible to bypass the task if a specific file already exists.
  ```yaml
  - name: Create Admin User
    command: create_user.sh --user admin
    creates: /home/admin/.profile
  ```
- **Method 2 (Using `changed_when`):** Register the output and override the change status manually.
  ```yaml
  - name: Check user status
    command: check_user_exists.sh admin
    register: user_check
    changed_when: false # Never flag this check task as changed

  - name: Run script only if user is missing
    command: create_user.sh --user admin
    when: user_check.rc != 0
  ```
</details>

<details>
<summary><b>Q7: Scenario: You are running Ansible against 100 new EC2 instances for the first time. The playbook halts on each server prompting: "The authenticity of host ... can't be established. Are you sure you want to continue connecting?". How do you bypass this prompt safely in automation?</b></summary>
<b>Answer:</b>
This is SSH Host Key Checking. You can bypass this prompt using two methods:
- **Method 1 (Ansible configuration - Recommended for CI/CD):**
  In your project `ansible.cfg` file, disable host key checking:
  ```ini
  [defaults]
  host_key_checking = False
  ```
  Or set the environment variable:
  ```bash
  export ANSIBLE_HOST_KEY_CHECKING=False
  ```
- **Method 2 (SSH arguments):** Pass SSH parameters in `ansible.cfg` to ignore host key authentication and write keys to `/dev/null`:
  ```ini
  [ssh_connection]
  ssh_args = -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
  ```
</details>

<details>
<summary><b>Q8: Scenario: You have 50 web servers behind a load balancer. You want to run a software update using Ansible. If you deploy to all 50 at once, you will cause total application downtime. How do you orchestrate a rolling deployment where Ansible only updates 5 servers at a time?</b></summary>
<b>Answer:</b>
Use the **`serial`** keyword at the play level:
```yaml
- name: Rolling Deployment of Web App
  hosts: webservers
  serial: 5
  max_fail_percentage: 20%
  tasks:
    - name: Remove Server from Load Balancer
      command: deregister_instance.sh

    - name: Update Application Code
      git:
        repo: git@github.com:org/app.git
        dest: /var/www/app

    - name: Add Server to Load Balancer
      command: register_instance.sh
```
- **How it works:** Ansible will split the 50 hosts into batches of 5. It will execute the entire play on the first 5 hosts. Once they finish successfully, it proceeds to the next 5 hosts.
- **`max_fail_percentage`:** If more than 20% of the active batch (e.g. 1 out of 5) fails, Ansible will abort the entire playbook run immediately, preventing a buggy release from taking down the remaining 45 servers.
</details>

<details>
<summary><b>Q9: Scenario: You log in to your target instances using a non-root ssh user (`ubuntu`). However, you need to install system software which requires root permissions. How do you configure privilege escalation in your playbooks?</b></summary>
<b>Answer:</b>
Use the **`become`** directive:
1. **Playbook Level:** Enforce it globally for the play:
   ```yaml
   - name: Install System Packages
     hosts: webservers
     become: yes # Enables sudo
     become_user: root # Runs as root (default)
     become_method: sudo # Use sudo escalation (default)
     tasks:
       - name: Install Apache
         apt:
           name: apache2
           state: present
   ```
2. **Task Level:** Enable it only for specific tasks:
   ```yaml
   - name: Read config file (non-root)
     cat:
       path: /home/ubuntu/config
       
   - name: Modify system configuration (requires root)
     lineinfile:
       path: /etc/sysctl.conf
       line: "net.ipv4.ip_forward=1"
     become: yes
   ```
</details>

<details>
<summary><b>Q10: Scenario: Your playbook fails immediately on a group of servers with the error: `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Permission denied (publickey)."}`. How do you troubleshoot this?</b></summary>
<b>Answer:</b>
This indicates an SSH authentication failure. Troubleshoot in order:
1. **Verify SSH Key:** Ensure the correct private SSH key is loaded in your SSH agent (`ssh-add my_key.pem`) or pass the key path directly in your Ansible inventory or command line:
   ```bash
   ansible-playbook -i hosts playbook.yml --private-key=my_key.pem
   ```
2. **Verify SSH Username:** Ensure you are using the correct OS username. AWS instances use different default users depending on the AMI:
   - Amazon Linux: `ec2-user`
   - Ubuntu: `ubuntu`
   - CentOS: `centos`
   - RedHat: `root` or `ec2-user`
   Specify this via CLI: `-u ec2-user` or in inventory variables: `ansible_user=ec2-user`.
3. **Check Network Ingress:** Ensure target instance security groups allow inbound TCP port 22 traffic from the IP address of your Ansible control machine.
4. **Ansible Debug Connection:** Run the playbook with verbose connection logs enabled to see the exact SSH execution commands:
   ```bash
   ansible-playbook -i hosts playbook.yml -vvvv
   ```
</details>
