# ✦ Playbooks & Pipelines: CI/CD & SSL Automation

> **Orchestrating Pipelines and Security.** Use these pipeline snippets and playbooks to run Ansible from your CI/CD runner and automate SSL certificate installations.

---

## ✦ 1. GitHub Actions Integration

This GitHub Actions workflow installs Ansible on the runner, configures the SSH key from a GitHub repository secret, and executes the playbook against a production environment.

```yaml
# .github/workflows/deploy.yml
name: Deploy with Ansible

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Install Ansible
        run: pip install ansible

      - name: Configure SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Run Ansible Playbook
        run: |
          ansible-playbook site.yml \
            -i inventory/production/hosts.ini \
            --vault-password-file <(echo "${{ secrets.VAULT_PASSWORD }}")
```

---

## ✦ 2. Jenkins Declarative Pipeline

This Jenkins pipeline snippet binds credentials dynamically, fetches the SSH key from Jenkins' Credentials Manager, and executes the Ansible playbook.

```groovy
pipeline {
    agent any

    stages {
        stage('Deploy with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-key', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        ansible-playbook site.yml \
                            -i inventory/production/hosts.ini \
                            --private-key=${SSH_KEY}
                    '''
                }
            }
        }
    }
}
```

---

## ✦ 3. Let's Encrypt SSL Automation Playbook

This playbook automates the process of installing `certbot` and the Nginx plugin, requests certificates for specified domains, and sets up a renewal cron job.

```yaml
---
- name: Install and configure SSL
  hosts: web
  become: yes

  vars:
    domain: example.com
    email: admin@example.com

  tasks:
    - name: Install certbot and Nginx plugin
      apt:
        name:
          - certbot
          - python3-certbot-nginx
        state: present

    - name: Obtain SSL certificate
      command: >
        certbot --nginx
        -d {{ domain }}
        -d www.{{ domain }}
        --non-interactive
        --agree-tos
        --email {{ email }}
      args:
        creates: /etc/letsencrypt/live/{{ domain }}/fullchain.pem

    - name: Set up auto-renewal cron
      cron:
        name: "certbot renewal"
        minute: "0"
        hour: "0,12"
        job: "certbot renew --quiet"
```
