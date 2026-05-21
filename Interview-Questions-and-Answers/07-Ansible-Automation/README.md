# ✦ Ansible Automation Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Ansible Configuration Management, Inventory Management, Playbooks, Roles, Ansible Vault, and Enterprise Automation.

---

## ✦ Section 1: Ansible Basics, Inventory & Ad-hoc Commands (Questions 1-20)

<details>
<summary><b>Q1: Scenario: You need to verify connectivity to 50 target servers without writing a playbook. What command do you execute?</b></summary>
Run the `ping` module using an ad-hoc command:
```bash
ansible all -i inventory.ini -m ping
```
This tests ssh connectivity, python availability, and authorization on the hosts.
</details>

<details>
<summary><b>Q2: Scenario: You want to execute a free-form shell command to inspect disk space (`df -h`) on all application servers. Which module do you use?</b></summary>
Use the `shell` or `command` module:
```bash
ansible app_servers -i inventory.ini -m shell -a "df -h"
```
Use the `command` module if you do not require environment variables or shell redirection/pipes. Use `shell` when pipelines or variables are necessary.
</details>

<details>
<summary><b>Q3: Scenario: How does Ansible's architecture differ from Chef or Puppet regarding agents?</b></summary>
Ansible is **agentless**. It does not require installing or managing custom agent daemons on target nodes. It communicates over standard SSH (or WinRM for Windows) and executes tasks by transferring temporary Python scripts to the target machine and executing them.
</details>

<details>
<summary><b>Q4: Scenario: You want to run an ad-hoc command as `sudo` because the operation requires root permissions. What flags do you add?</b></summary>
Use the privilege escalation flags `-b` (become) and `--become-user`:
```bash
ansible webservers -i inventory.ini -m service -a "name=nginx state=restarted" -b
```
</details>

<details>
<summary><b>Q5: Scenario: You need to specify a custom SSH private key for your Ansible command. How do you pass this via CLI?</b></summary>
Use the `--private-key` flag:
```bash
ansible all -i inventory.ini -m ping --private-key=/path/to/id_rsa
```
Alternatively, configure `private_key_file` in `/etc/ansible/ansible.cfg`.
</details>

<details>
<summary><b>Q6: Scenario: How do you define a group of groups (nested groups) in an INI-style inventory file?</b></summary>
Use the `:children` suffix:
```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com

[production:children]
webservers
dbservers
```
</details>

<details>
<summary><b>Q7: Scenario: You want to define host-specific variables directly inside your INI inventory file. How is this formatted?</b></summary>
Assign variables directly inline with the host definition:
```ini
web1.example.com http_port=8080 max_clients=200
```
</details>

<details>
<summary><b>Q8: Scenario: You want to define variables for an entire group inside an INI inventory file. How do you do this?</b></summary>
Use the `:vars` suffix:
```ini
[webservers]
web1.example.com
web2.example.com

[webservers:vars]
ntp_server=pool.ntp.org
http_port=80
```
</details>

<details>
<summary><b>Q9: Scenario: How does Ansible locate inventory configuration if no `-i` flag is specified on the command line?</b></summary>
Ansible checks configuration sources in this order:
1. Environment variable `ANSIBLE_INVENTORY`
2. `inventory` setting in `ansible.cfg` in the current working directory
3. `inventory` setting in `~/.ansible.cfg`
4. The system default path `/etc/ansible/hosts`
</details>

<details>
<summary><b>Q10: Scenario: You want to check the syntax of your inventory file without running commands against target servers. How?</b></summary>
Run:
```bash
ansible-inventory -i inventory.ini --list
```
This parses the inventory and prints it in JSON structure, failing if syntax errors exist.
</details>

<details>
<summary><b>Q11: Scenario: You need to run commands on target hosts that are listening on a non-standard SSH port 2222. How do you configure this in inventory?</b></summary>
Set the `ansible_port` variable for the host:
```ini
web1.example.com ansible_port=2222
```
</details>

<details>
<summary><b>Q12: Scenario: How do you configure your SSH username dynamically for a specific host in the inventory file?</b></summary>
Assign `ansible_user` to the target host:
```ini
target-server ansible_user=deployer
```
</details>

<details>
<summary><b>Q13: Scenario: You want to limit an Ansible execution command to run on only one specific host `web1` from your `webservers` group. What flag do you run?</b></summary>
Use the `--limit` flag:
```bash
ansible-playbook site.yml --limit web1
```
</details>

<details>
<summary><b>Q14: Scenario: You need to copy a local file `/tmp/config.conf` to a target server at `/etc/app/config.conf` using an ad-hoc command. How?</b></summary>
Use the `copy` module:
```bash
ansible app_servers -m copy -a "src=/tmp/config.conf dest=/etc/app/config.conf owner=root mode=0644" -b
```
</details>

<details>
<summary><b>Q15: Scenario: You want to fetch a file from a remote managed node to your control node. What module do you use?</b></summary>
Use the `fetch` module:
```bash
ansible database -m fetch -a "src=/var/log/mysql/slow.log dest=/tmp/backup/"
```
This fetches the file and stores it organized by remote hostnames.
</details>

<details>
<summary><b>Q16: Scenario: How do you verify what version of Python is running on the managed nodes using an ad-hoc command?</b></summary>
Run:
```bash
ansible all -m setup | grep ansible_python_version
```
</details>

<details>
<summary><b>Q17: Scenario: What is the purpose of the `ansible.cfg` file and where is it searched for in order of priority?</b></summary>
It configures settings like defaults, connection settings, and privilege escalations. Search priority:
1. `ANSIBLE_CONFIG` environment variable
2. `ansible.cfg` in the current working directory
3. `~/.ansible.cfg` in the user home directory
4. `/etc/ansible/ansible.cfg`
</details>

<details>
<summary><b>Q18: Scenario: You want to disable Host Key Checking for SSH connections because you are spinning up dynamic testing nodes. How do you do this?</b></summary>
In `ansible.cfg`, under the `[defaults]` section, add:
```ini
host_key_checking = False
```
Alternatively, set the environment variable `export ANSIBLE_HOST_KEY_CHECKING=False`.
</details>

<details>
<summary><b>Q19: Scenario: How do you test SSH connectivity using password authentication instead of SSH keys?</b></summary>
Use the `--ask-pass` flag or `-k`:
```bash
ansible all -m ping -k
```
</details>

<details>
<summary><b>Q20: Scenario: You want to execute a command as a different user `nginx` using privilege escalation. What flags do you specify?</b></summary>
Run:
```bash
ansible webservers -m shell -a "whoami" -b --become-user=nginx
```
</details>

---

## ✦ Section 2: Playbooks, Variables & Facts (Questions 21-40)

<details>
<summary><b>Q21: Scenario: You write a playbook that installs Apache. How do you prevent it from gathering system facts to speed up execution?</b></summary>
Set `gather_facts: false` at the play level:
```yaml
- name: Install Apache
  hosts: webservers
  gather_facts: false
  tasks:
    # tasks here...
```
</details>

<details>
<summary><b>Q22: Scenario: How do you filter and view a single specific fact (like IP address of `eth0`) from the gathered system facts using CLI?</b></summary>
Run the `setup` module with the `filter` argument:
```bash
ansible database -m setup -a "filter=ansible_eth0"
```
</details>

<details>
<summary><b>Q23: Scenario: How do you declare and reference a variable inside an Ansible playbook?</b></summary>
Define variables under the `vars` block and reference them using Jinja2 syntax (with double curly braces):
```yaml
- hosts: all
  vars:
    app_version: "1.2.0"
  tasks:
    - name: Print Version
      debug:
        msg: "The version is {{ app_version }}"
```
</details>

<details>
<summary><b>Q24: Scenario: When referencing a variable at the start of a value, why does Ansible throw a YAML syntax parsing error, and how do you fix it?</b></summary>
If a value starts with double curly braces `{{`, YAML parser assumes it is an inline map instead of a string. To fix it, you must wrap the entire expression in quotes:
```yaml
# Error:
# msg: {{ my_var }}
# Correct:
msg: "{{ my_var }}"
```
</details>

<details>
<summary><b>Q25: Scenario: You need to pass variables directly into a playbook run from the command line. What flag do you use?</b></summary>
Use the extra variables flag `-e` or `--extra-vars`:
```bash
ansible-playbook site.yml -e "env_type=prod app_version=2.0"
```
Extra variables have the highest precedence in Ansible.
</details>

<details>
<summary><b>Q26: Scenario: How do you register the output of a task so you can inspect it in a subsequent task?</b></summary>
Use the `register` keyword:
```yaml
- name: Check system uptime
  command: uptime
  register: uptime_result

- name: Print Uptime
  debug:
    msg: "Output was: {{ uptime_result.stdout }}"
```
</details>

<details>
<summary><b>Q27: Scenario: What are local facts (`ansible_local`), and how do you define custom facts on a managed node?</b></summary>
Local facts are custom facts defined on managed nodes. Create executable scripts or files returning JSON/INI data inside `/etc/ansible/facts.d/` ending in `.fact`. When Ansible runs, it collects these facts and populates the `ansible_local` variable.
</details>

<details>
<summary><b>Q28: Scenario: You want to check what variables are defined for a host by running a task. What debug task can you write?</b></summary>
Print the `hostvars` dictionary for the current host:
```yaml
- name: Print Host Variables
  debug:
    var: hostvars[inventory_hostname]
```
</details>

<details>
<summary><b>Q29: Scenario: How do variables defined in `group_vars/` and `host_vars/` directories get loaded automatically by Ansible?</b></summary>
Ansible scans for `group_vars/` and `host_vars/` directories in the same directory as the inventory file or the playbook file. If it finds files named after a group (e.g., `group_vars/webservers.yml`) or a host (e.g., `host_vars/web1.yml`), it loads the variables automatically.
</details>

<details>
<summary><b>Q30: Scenario: What is the rule of thumb regarding variable precedence in Ansible? If a variable is defined in `group_vars/all` and also passed via `-e`, which wins?</b></summary>
Variables passed via the command line `-e` (extra variables) always win. Variable precedence is strict (with 22 levels). The order goes from lowest (role defaults) to highest (extra-vars).
</details>

<details>
<summary><b>Q31: Scenario: You want to capture the IP address of the node running Ansible (the control node) instead of the managed node. What fact variable holds this?</b></summary>
Facts hold managed node statistics. To reference control node details, use lookup plugin environment variables or gather local facts on the localhost using `hostvars['localhost']`.
</details>

<details>
<summary><b>Q32: Scenario: How do you define list variables and map variables in Ansible HCL/YAML configurations?</b></summary>
Use standard YAML lists and maps:
```yaml
# List
dns_servers:
  - 8.8.8.8
  - 8.8.4.4

# Map
database_config:
  host: "db.local"
  port: 3306
```
</details>

<details>
<summary><b>Q33: Scenario: How do you set default fallback values for variables if they are undefined in Jinja2 templates?</b></summary>
Use the `default` filter:
```jinja2
max_connections = {{ max_conn | default(100) }}
```
</details>

<details>
<summary><b>Q34: Scenario: You want to prompt the user for input during playbook execution (e.g. asking for database username). How?</b></summary>
Use `vars_prompt` at the play level:
```yaml
- hosts: dbservers
  vars_prompt:
    - name: db_user
      prompt: "Enter DB Username"
      private: false
```
</details>

<details>
<summary><b>Q35: Scenario: You want to configure the output format of `ansible-playbook` stdout to be cleaner or format as JSON. How?</b></summary>
Change the `stdout_callback` setting in `ansible.cfg`:
```ini
stdout_callback = yaml
```
(Supported options: `default`, `yaml`, `json`, `minimal`).
</details>

<details>
<summary><b>Q36: Scenario: How do you convert a string variable `"123"` into an integer in an Ansible task?</b></summary>
Use the Jinja2 `int` filter:
```yaml
port: "{{ port_str | int }}"
```
</details>

<details>
<summary><b>Q37: Scenario: What is the difference between `set_fact` and `vars` block?</b></summary>
Variables defined in the `vars` block are static and scoped to that specific play or task. `set_fact` dynamically computes a variable during runtime, which is stored in host configurations and available to other plays running within the same playbook lifecycle.
</details>

<details>
<summary><b>Q38: Scenario: You need to extract the current date and time on the managed node during play execution. What variable holds this?</b></summary>
Use `ansible_date_time` (e.g., `ansible_date_time.date` or `ansible_date_time.time`), which is gathered automatically.
</details>

<details>
<summary><b>Q39: Scenario: How do you reference variables defined in host `db1` while executing tasks on host `web1`?</b></summary>
Access the `hostvars` dictionary:
```yaml
db_ip: "{{ hostvars['db1']['ansible_default_ipv4']['address'] }}"
```
</details>

<details>
<summary><b>Q40: Scenario: How do you check if a variable is defined or not inside an Ansible conditional?</b></summary>
Use the `is defined` or `is undefined` check:
```yaml
when: my_variable is defined
```
</details>

---

## ✦ Section 3: Control Flow, Loops, Conditionals & Handlers (Questions 41-60)

<details>
<summary><b>Q41: Scenario: You need to install 5 packages (nginx, git, curl, zip, htop) using a loop instead of writing 5 tasks. What loop syntax do you use?</b></summary>
Use the `loop` keyword:
```yaml
- name: Install utility packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - curl
    - zip
    - htop
```
</details>

<details>
<summary><b>Q42: Scenario: What is the difference between `with_items` and `loop` in Ansible?</b></summary>
`loop` is the modern, recommended syntax that performs flat iterations. `with_items` implicitly flattens nested lists of lists. In modern playbooks, prefer `loop` combined with the `flatten` filter.
</details>

<details>
<summary><b>Q43: Scenario: How do you iterate over a dictionary map of users and their respective shell configurations in a loop?</b></summary>
Use `dict2items` filter to convert the map into a list of key/value pairs:
```yaml
- name: Create users
  user:
    name: "{{ item.key }}"
    shell: "{{ item.value.shell }}"
  loop: "{{ users_dict | dict2items }}"
```
</details>

<details>
<summary><b>Q44: Scenario: You want to run a task only if the OS family of the target node is Debian. How do you configure the conditional?</b></summary>
Use the `when` keyword referencing gathered facts:
```yaml
- name: Install APT updates
  apt:
    update_cache: yes
  when: ansible_os_family == "Debian"
```
</details>

<details>
<summary><b>Q45: Scenario: You want to restart Nginx *only* if the configuration template changes. How do you implement this?</b></summary>
Use a `notify` block pointing to a `handler`:
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
</details>

<details>
<summary><b>Q46: Scenario: How does Ansible determine if a handler should run? If two distinct tasks notify "Restart Nginx", how many times does Nginx restart?</b></summary>
Handlers only execute if a task registers a status of **changed**. If multiple tasks notify the same handler, the handler executes **exactly once** at the very end of the play.
</details>

<details>
<summary><b>Q47: Scenario: You need to force all notified handlers to execute immediately in the middle of a play instead of waiting until the end. How?</b></summary>
Use the `meta: flush_handlers` task directive:
```yaml
- name: Flush Handlers Immediately
  meta: flush_handlers
```
</details>

<details>
<summary><b>Q48: Scenario: You want to run a loop but print the loop execution item details in a customized format in stdout. How?</b></summary>
Use `loop_control` with the `label` attribute:
```yaml
- name: Copy configurations
  copy:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
  loop: "{{ config_files }}"
  loop_control:
    label: "{{ item.dest }}"
```
This hides long source paths from logging output.
</details>

<details>
<summary><b>Q49: Scenario: You want to stop executing tasks on the current host if a command output contains "CRITICAL". How do you fail a play manually?</b></summary>
Use the `fail` module with a conditional check:
```yaml
- name: Verify health check status
  fail:
    msg: "System state is CRITICAL!"
  when: "'CRITICAL' in check_result.stdout"
```
</details>

<details>
<summary><b>Q50: Scenario: A command returns a non-zero exit code but you want Ansible to treat it as a success and continue execution. How?</b></summary>
Set `ignore_errors: true` on the task:
```yaml
- name: Check database connection
  command: ping -c 1 db-host
  ignore_errors: true
```
</details>

<details>
<summary><b>Q51: Scenario: You run a diagnostic command that always reports as "changed" in Ansible, but it only reads data. How do you prevent it from reporting changes?</b></summary>
Set `changed_when: false` on the task:
```yaml
- name: Get service status
  command: systemctl is-active app
  register: app_status
  changed_when: false
```
</details>

<details>
<summary><b>Q52: Scenario: A database migration task needs to run 3 retries with a 10-second delay between attempts until the database becomes healthy. How?</b></summary>
Use `until`, `retries`, and `delay` attributes:
```yaml
- name: Wait for database readiness
  command: mysqladmin ping -h db-host
  register: result
  until: result.rc == 0
  retries: 3
  delay: 10
```
</details>

<details>
<summary><b>Q53: Scenario: How do you group multiple tasks together to apply a shared conditional or error-handling block?</b></summary>
Use the `block` directive:
```yaml
- block:
    - name: Install package
      apt: name=nginx state=present
    - name: Start service
      service: name=nginx state=started
  when: ansible_os_family == "Debian"
```
</details>

<details>
<summary><b>Q54: Scenario: How do you implement Try/Catch/Finally logic in Ansible using blocks?</b></summary>
Combine `block`, `rescue`, and `always`:
```yaml
- block:
    - name: Attempt DB update
      command: /opt/update_db.sh
  rescue:
    - name: Rollback changes
      command: /opt/rollback_db.sh
  always:
    - name: Cleanup temp files
      file: path=/tmp/db_lock state=absent
```
</details>

<details>
<summary><b>Q55: Scenario: You want to run a task on a remote server, but delegate its execution to run on the Ansible control node instead. How?</b></summary>
Use the `delegate_to: localhost` directive:
```yaml
- name: Log deployment state
  uri:
    url: https://api.monitoring.com/deploy
    method: POST
  delegate_to: localhost
```
</details>

<details>
<summary><b>Q56: Scenario: How does the `local_action` directive differ from `delegate_to: localhost`?</b></summary>
They are functionally identical. `local_action` is a shortcut syntax:
```yaml
- name: Local action log
  local_action: command echo "Deployment starting"
```
</details>

<details>
<summary><b>Q57: Scenario: You need to run a configuration task once on a single host in a play, even if the play targets 50 hosts. How?</b></summary>
Use the `run_once: true` directive:
```yaml
- name: Initialize database schema
  command: flask db upgrade
  run_once: true
```
</details>

<details>
<summary><b>Q58: Scenario: You want to loop through a list of items and access both the index number and the value inside the loop. How?</b></summary>
Use `loop_control` with `index_var`:
```yaml
- name: Loop with index
  debug:
    msg: "Index: {{ my_index }}, Value: {{ item }}"
  loop: ["a", "b", "c"]
  loop_control:
    index_var: my_index
```
</details>

<details>
<summary><b>Q59: Scenario: How do you conditionally import a task file during playbook execution dynamically?</b></summary>
Use the `include_tasks` directive:
```yaml
- name: Load OS-specific tasks
  include_tasks: "{{ ansible_os_family }}.yml"
```
</details>

<details>
<summary><b>Q60: Scenario: What is the difference between `import_tasks` and `include_tasks`?</b></summary>
`import_tasks` is static and parsed at playbook compilation time (before execution begins). `include_tasks` is dynamic and evaluated at runtime, allowing variable interpolation inside the filename.
</details>

---

## ✦ Section 4: Roles, Collections, Templates & Ansible Vault (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You need to create a new Ansible Role named `webserver` using the standard directory structure. What command do you run?</b></summary>
Run:
```bash
ansible-galaxy role init webserver
```
This generates the standard directory layout including `tasks/`, `handlers/`, `templates/`, `files/`, `vars/`, `defaults/`, and `meta/`.
</details>

<details>
<summary><b>Q62: Scenario: What is the difference between variables defined in a role's `defaults/main.yml` and those in `vars/main.yml`?</b></summary>
`defaults/main.yml` has the lowest precedence of all variables in Ansible, allowing users of the role to easily override them. `vars/main.yml` has a high precedence and is intended for internal role constants that should not be overridden.
</details>

<details>
<summary><b>Q63: Scenario: How do you reuse a role inside a playbook, passing custom variable overrides to it?</b></summary>
Include the role under the `roles` block:
```yaml
- hosts: webservers
  roles:
    - role: webserver
      vars:
        http_port: 8080
        max_clients: 500
```
</details>

<details>
<summary><b>Q64: Scenario: You want to encrypt a sensitive password file `secrets.yml` so it can be safely committed to Git. What command do you use?</b></summary>
Use Ansible Vault:
```bash
ansible-vault encrypt secrets.yml
```
You will be prompted to enter an encryption password.
</details>

<details>
<summary><b>Q65: Scenario: How do you run an Ansible playbook that imports a vault-encrypted variables file?</b></summary>
Pass the vault password prompt flag `--ask-vault-pass` or reference a password file using `--vault-password-file`:
```bash
ansible-playbook site.yml --ask-vault-pass
# or
ansible-playbook site.yml --vault-password-file=~/.vault_pass.txt
```
</details>

<details>
<summary><b>Q66: Scenario: You need to edit an already encrypted Vault file without decrypting it permanently. What command do you use?</b></summary>
Run:
```bash
ansible-vault edit secrets.yml
```
This decrypts it to a temporary file, opens your default terminal editor, and re-encrypts it automatically when you save and close.
</details>

<details>
<summary><b>Q67: Scenario: How do you encrypt only a single specific string value (e.g., a DB password) to use inline inside an unencrypted YAML file?</b></summary>
Use the `encrypt_string` command:
```bash
ansible-vault encrypt_string 'my_db_password' --name 'db_password'
```
Copy the generated `!vault |` output block directly into your playbook's `vars` section.
</details>

<details>
<summary><b>Q68: Scenario: You have a Jinja2 template file `nginx.conf.j2` that dynamically loops through a list of upstream backend IPs. How is this written in Jinja2?</b></summary>
Use a Jinja2 loop block:
```jinja2
upstream backend_servers {
{% for ip in backend_ips %}
    server {{ ip }}:8080;
{% endfor %}
}
```
</details>

<details>
<summary><b>Q69: Scenario: You want to deploy a configuration template, but only modify the file on the target server if the content actually changes. What module do you use?</b></summary>
Use the `template` module:
```yaml
- name: Deploy configuration
  template:
    src: config.j2
    dest: /etc/app/config.conf
```
The `template` module is idempotent and only writes files if changes are detected.
</details>

<details>
<summary><b>Q70: Scenario: What are Ansible Collections, and how do they differ from Roles?</b></summary>
Roles package tasks, vars, and templates. Collections are a distribution format that bundles multiple roles, custom connection plugins, inventory scripts, and modules together, allowing easier community sharing (e.g. `community.general.slack` notifications).
</details>

<details>
<summary><b>Q71: Scenario: You need to install a collection from Ansible Galaxy. What command do you execute?</b></summary>
Run:
```bash
ansible-galaxy collection install community.general
```
</details>

<details>
<summary><b>Q72: Scenario: How do you declare role dependencies so that role `database` is automatically executed before role `application` runs?</b></summary>
Declare dependencies in `meta/main.yml` of the `application` role:
```yaml
dependencies:
  - role: database
    vars:
      db_port: 3306
```
</details>

<details>
<summary><b>Q73: Scenario: How does the `template` module handle comments at the top of generated files warning administrators not to edit the file manually?</b></summary>
Use the `ansible_managed` variable in the template header:
```jinja2
# {{ ansible_managed }}
# Any manual changes will be overwritten!
```
Configure what this string evaluates to in your `ansible.cfg`.
</details>

<details>
<summary><b>Q74: Scenario: You want to search for and download a community role for Docker from Ansible Galaxy. What CLI commands do you run?</b></summary>
Search for roles:
```bash
ansible-galaxy search docker
```
Install the role:
```bash
ansible-galaxy install geerlingguy.docker
```
</details>

<details>
<summary><b>Q75: Scenario: What is the purpose of the `template` filter `to_json` or `to_yaml` inside a task?</b></summary>
They format Jinja2 variables into structured data:
```yaml
- name: Write variables to config file
  copy:
    content: "{{ my_dict_var | to_nice_yaml }}"
    dest: /etc/app/config.yaml
```
</details>

<details>
<summary><b>Q76: Scenario: How do you configure Ansible to locate roles in custom directories instead of the default `/etc/ansible/roles`?</b></summary>
Define `roles_path` in `ansible.cfg`:
```ini
roles_path = ./roles:/opt/shared/roles
```
</details>

<details>
<summary><b>Q77: Scenario: You need to verify if an encrypted Vault value matches a specific password. Can you decrypt and print it to stdout for testing?</b></summary>
Run:
```bash
ansible-vault decrypt secrets.yml --output=-
```
This outputs the decrypted content to stdout without saving it to disk.
</details>

<details>
<summary><b>Q78: Scenario: You want to ensure that a task inside a role only runs when a variable passed from a play matches a specific pattern. How?</b></summary>
Use regex matching filter inside the conditional:
```yaml
when: app_env | match("^(prod|staging)$")
```
</details>

<details>
<summary><b>Q79: Scenario: What is the purpose of the `file` module’s `state: link` attribute?</b></summary>
It creates symbolic links:
```yaml
- name: Create symlink
  file:
    src: /opt/app/current
    dest: /var/www/html
    state: link
```
</details>

<details>
<summary><b>Q80: Scenario: How do you download a tarball from a URL and extract it to a directory `/opt/app` on a managed node?</b></summary>
Use the `unarchive` module:
```yaml
- name: Extract archive
  unarchive:
    src: https://example.com/app.tar.gz
    dest: /opt/app
    remote_src: yes
```
</details>

---

## ✦ Section 5: Advanced Automation, Troubleshooting & Performance (Questions 81-100)

<details>
<summary><b>Q81: Scenario: Your playbook execution is extremely slow because it runs sequentially on one host at a time. How do you increase concurrent execution?</b></summary>
Modify the `forks` parameter in `ansible.cfg` (default is 5):
```ini
forks = 20
```
This increases the number of parallel ssh processes spawned by the control node.
</details>

<details>
<summary><b>Q82: Scenario: You want to execute a rolling update where tasks are applied to only 10% of your web servers at a time. How?</b></summary>
Use the `serial` directive at the play level:
```yaml
- hosts: webservers
  serial: "10%"
  tasks:
    # tasks here...
```
</details>

<details>
<summary><b>Q83: Scenario: How do you configure a dynamic inventory script for AWS EC2 instances, and what extension must the inventory file use?</b></summary>
Use the `aws_ec2` inventory plugin. Configure a YAML configuration file ending with `aws_ec2.yaml`:
```yaml
plugin: aws_ec2
regions:
  - us-east-1
keyed_groups:
  - key: tags.Environment
    prefix: env
```
Run using: `ansible-inventory -i demo.aws_ec2.yaml --graph`.
</details>

<details>
<summary><b>Q84: Scenario: You want to check what tasks a playbook will execute without actually modifying the managed nodes. What flag do you run?</b></summary>
Use **dry-run** mode with `--check` or `-C`:
```bash
ansible-playbook site.yml --check
```
Combine with `--diff` to see structural file differences before applying changes.
</details>

<details>
<summary><b>Q85: Scenario: You want to see line-by-line differences of config files modified by the template module during dry-run. What flag?</b></summary>
Run:
```bash
ansible-playbook site.yml --check --diff
```
</details>

<details>
<summary><b>Q86: Scenario: A playbook fails on task 5 of 10. After fixing the configuration error, how do you run the playbook starting exactly from task 5?</b></summary>
Use the `--start-at-task` flag:
```bash
ansible-playbook site.yml --start-at-task="Configure Database"
```
</details>

<details>
<summary><b>Q87: Scenario: You want to tag tasks (e.g. `install`, `configure`) and run only the configuration tasks. How is this set up?</b></summary>
Add `tags` to your tasks:
```yaml
- name: Deploy configuration
  template: src=config.j2 dest=/etc/config
  tags: configure
```
Execute using:
```bash
ansible-playbook site.yml --tags "configure"
```
</details>

<details>
<summary><b>Q88: Scenario: How do you skip tasks that are tagged with the label `monitoring`?</b></summary>
Run:
```bash
ansible-playbook site.yml --skip-tags "monitoring"
```
</details>

<details>
<summary><b>Q89: Scenario: How does the `pipelining` configuration in `ansible.cfg` improve playbook execution speeds?</b></summary>
Pipelining reduces the number of SSH operations required to execute a module. It executes Python modules directly in the SSH session stream without copying files to the managed node disk first. Enable it in `ansible.cfg`:
```ini
[ssh_connection]
pipelining = True
```
</details>

<details>
<summary><b>Q90: Scenario: Your SSH connection times out when connecting to nodes behind a bastion server. How do you configure SSH ProxyCommand in Ansible?</b></summary>
In `ansible.cfg`, under `[ssh_connection]`, define `ssh_args`:
```ini
ssh_args = -o ProxyCommand="ssh -W %h:%p -q user@bastion-host"
```
</details>

<details>
<summary><b>Q91: Scenario: What is a "Callback Plugin" and how do you enable profile_tasks to track task execution times?</b></summary>
Callback plugins hook into Ansible output loops. Enable the task timer callback in `ansible.cfg`:
```ini
callbacks_enabled = ansible.posix.profile_tasks
```
This prints the duration of every task at stdout.
</details>

<details>
<summary><b>Q92: Scenario: What is Ansible Lint and why should you use it in CI?</b></summary>
`ansible-lint` is a static analyzer for Ansible playbooks and roles. Running it in CI identifies syntax issues, deprecated directives, and rule violations to ensure formatting consistency.
</details>

<details>
<summary><b>Q93: Scenario: How do you configure a playbook to prompt for a password when scaling privilege escalation (sudo)?</b></summary>
Use the `--ask-become-pass` flag or `-K`:
```bash
ansible-playbook site.yml -K
```
</details>

<details>
<summary><b>Q94: Scenario: You need to execute a task locally on the control node, but you want to reference variables from the target host. How?</b></summary>
Use `delegate_to: localhost`:
```yaml
- name: Record target IP local log
  shell: echo "{{ inventory_hostname }} IP is {{ ansible_host }}" >> targets.txt
  delegate_to: localhost
```
</details>

<details>
<summary><b>Q95: Scenario: You want to target a host pattern matching all hosts in `webservers` but exclude any hosts in `staging`. How is the hosts line written?</b></summary>
Use group intersection patterns:
```yaml
hosts: webservers:!staging
```
</details>

<details>
<summary><b>Q96: Scenario: How do you make a task fail if it takes longer than 15 seconds to execute?</b></summary>
Use the `async` and `poll` directives:
```yaml
- name: Long running database build
  command: /opt/long_build.sh
  async: 15
  poll: 2
```
If the task exceeds `async` seconds, it triggers a timeout failure.
</details>

<details>
<summary><b>Q97: Scenario: What is the purpose of the `any_errors_fatal` directive at the play level?</b></summary>
By default, if a host fails, Ansible continues executing tasks on other healthy hosts. Setting `any_errors_fatal: true` stops playbook execution across **all** hosts immediately if a single node fails.
</details>

<details>
<summary><b>Q98: Scenario: You want to display custom debug messages during playbooks execution. What module do you use?</b></summary>
Use the `debug` module:
```yaml
- name: Output status
  debug:
    msg: "System hostname is {{ ansible_hostname }}"
```
</details>

<details>
<summary><b>Q99: Scenario: How do you verify if a playbook run was completely idempotent?</b></summary>
Look at the playbook summary. A completely idempotent run reports a count of **changed=0**. If any task reports changed, the run was not fully idempotent.
</details>

<details>
<summary><b>Q100: Scenario: How do you clean up remote temporary execution files left by Ansible on managed nodes if an execution crashes?</b></summary>
Ansible cleans up its temporary `/home/user/.ansible/tmp/` files automatically upon exit. If a crash leaves orphan files, you can delete them manually or run an ad-hoc command using the `file` module:
```bash
ansible all -m file -a "path=~/.ansible/tmp state=absent"
```
</details>
