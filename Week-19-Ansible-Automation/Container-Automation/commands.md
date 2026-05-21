# ✦ Playbooks: Ansible Container Automation

> **Automated Deployments.** Use these Ansible playbooks to provision Docker, run containerized applications, and orchestrate Kubernetes manifests.

---

## ✦ 1. Install Docker Playbook

This playbook bootstraps clean Ubuntu nodes, installs required dependencies, adds official Docker repositories, installs Docker, enables the daemon service, and adds the Ansible executor to the `docker` user group.

```yaml
---
- name: Install Docker
  hosts: all
  become: yes

  tasks:
    - name: Install required packages
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
        state: present

    - name: Install docker.io
      apt:
        name: docker.io
        state: present

    - name: Start and enable Docker
      service:
        name: docker
        state: started
        enabled: yes

    - name: Add user to docker group
      user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes
```

**Running the Playbook:**
```bash
ansible-playbook -i inventory.ini install-docker.yml
```

---

## ✦ 2. Run Containerized Applications

Use Ansible's `docker_container` module to run containers declaratively. This ensures that the container is started with the specified environment variables, volumes, and ports.

```yaml
---
- name: Run Docker Containers
  hosts: web
  become: yes

  tasks:
    - name: Run Nginx container
      community.docker.docker_container:
        name: nginx
        image: nginx:latest
        state: started
        restart_policy: always
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /var/www/html:/usr/share/nginx/html

    - name: Run app container
      community.docker.docker_container:
        name: myapp
        image: myrepo/myapp:1.5
        state: started
        env:
          NODE_ENV: production
          DB_HOST: "{{ db_host }}"
          DB_PASS: "{{ db_password }}"
        ports:
          - "3000:3000"
```

---

## ✦ 3. Deploy Kubernetes Manifests

Deploying manifests using Ansible's `kubernetes.core.k8s` collection allows you to maintain IaC pipelines while leveraging Kubernetes native resource declarations.

```yaml
---
- name: Deploy app to Kubernetes
  hosts: k8s_master
  become: yes

  tasks:
    - name: Apply deployment manifest
      kubernetes.core.k8s:
        state: present
        src: /opt/k8s/deployment.yml

    - name: Apply service manifest
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: myapp-service
            namespace: production
          spec:
            selector:
              app: myapp
            ports:
              - port: 80
                targetPort: 3000
            type: LoadBalancer

    - name: Wait for deployment to be ready
      kubernetes.core.k8s_info:
        kind: Deployment
        name: myapp
        namespace: production
        wait: yes
        wait_timeout: 120
```
