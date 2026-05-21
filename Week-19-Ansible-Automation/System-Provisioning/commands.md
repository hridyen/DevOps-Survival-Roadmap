# ✦ Playbooks: System Provisioning & User Management

> **Automated Provisioning.** Use these playbooks to manage team access credentials and dynamically spin up cloud servers on AWS EC2.

---

## ✦ 1. Scalable User Management Playbook

This playbook manages system access. It iterates over a list of users, creating active users with sudo and docker privileges, deleting decommissioned accounts, and dynamically mapping their public SSH keys.

```yaml
---
- name: Manage DevOps team users
  hosts: all
  become: yes

  vars:
    devops_users:
      - name: alice
        shell: /bin/bash
        groups: sudo,docker
        state: present
      - name: bob
        shell: /bin/bash
        groups: sudo
        state: present
      - name: olduser
        state: absent

  tasks:
    - name: Manage users
      user:
        name: "{{ item.name }}"
        shell: "{{ item.shell | default('/bin/bash') }}"
        groups: "{{ item.groups | default('') }}"
        state: "{{ item.state }}"
        remove: "{{ item.state == 'absent' }}"
      loop: "{{ devops_users }}"

    - name: Add SSH keys for active users
      authorized_key:
        user: "{{ item.name }}"
        key: "{{ lookup('file', 'keys/' + item.name + '.pub') }}"
        state: present
      loop: "{{ devops_users }}"
      when: item.state == 'present'
```

---

## ✦ 2. AWS EC2 Server Provisioning Playbook

This playbook provisions instances in AWS, registers their public IPs dynamically into a runtime inventory group `new_servers`, and configures them in subsequent plays.

```yaml
---
- name: Provision EC2 instances
  hosts: localhost
  gather_facts: no

  vars:
    aws_region: us-east-1
    instance_type: t2.micro
    ami_id: ami-0c55b159cbfafe1f0
    key_name: my-keypair

  tasks:
    - name: Launch EC2 instance
      amazon.aws.ec2_instance:
        name: "web-server-{{ ansible_date_time.date }}"
        key_name: "{{ key_name }}"
        instance_type: "{{ instance_type }}"
        image_id: "{{ ami_id }}"
        region: "{{ aws_region }}"
        security_groups:
          - web-sg
        tags:
          Environment: production
          ManagedBy: ansible
        wait: yes
      register: ec2

    - name: Add new instance to inventory
      add_host:
        hostname: "{{ ec2.instances[0].public_ip_address }}"
        groups: new_servers

- name: Configure new EC2 instances
  hosts: new_servers
  become: yes
  roles:
    - common
    - nginx-role
```

**Running the Provisioner:**
Ensure you have your AWS environment variables exported (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) and run:
```bash
ansible-playbook -i localhost, ec2-provision.yml
```
