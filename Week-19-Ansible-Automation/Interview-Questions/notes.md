# ✦ Module: Ansible Interview Questions & Answers

> **Verifiable Portfolio Prep.** Master these standard DevOps interview questions and concepts regarding Ansible automation.

---

### **Q: What is Ansible?**
An open-source agentless automation tool for configuration management, application deployment, and orchestration using YAML playbooks over SSH.

---

### **Q: Why is Ansible agentless?**
It uses standard SSH (or WinRM for Windows) instead of installing software agents on managed nodes. This reduces management overhead, network port exposure, and security risks.

---

### **Q: What is the difference between the `command` and `shell` modules?**
*   **`command` Module:** Runs a command directly on the remote shell without shell processing. It is safer because it is not subject to shell variables, pipeline redirects (`|`), or wildcards.
*   **`shell` Module:** Runs via the node's shell (e.g., `/bin/sh`). It is less safe but necessary if you need to use pipes, file redirects (`>`), environment variables, or complex shell chaining.

---

### **Q: What is idempotency?**
Idempotency means that running a playbook multiple times produces the exact same end state on the target machine, without executing unnecessary actions. For example, if a package is already installed, Ansible's `apt` module will do nothing (status: `ok`) instead of attempting to reinstall it (status: `changed`).

---

### **Q: What are roles in Ansible?**
Roles are a structured directory format to organize playbooks into reusable components. A typical role separates files into specific folders:
*   `tasks/`: Main list of tasks.
*   `handlers/`: Service alerts and trigger reactions.
*   `vars/` / `defaults/`: Variables configuration.
*   `templates/`: Jinja2 templates.
*   `files/`: Static files to copy.

---

### **Q: What is Ansible Vault?**
Ansible Vault is a feature that allows encrypting sensitive files (such as database passwords, API keys, or SSL private keys) using AES-256 encryption. This enables DevOps teams to commit secrets safely to public or private Git repositories.

---

### **Q: What is a handler?**
A handler is a special task that only runs when notified (`notify`) by another task that has registered a state change (`changed`). Handlers are commonly used to restart a service (like Nginx or Apache) only after its config file has been successfully updated on disk.

---

### **Q: What is the difference between Static and Dynamic Inventory?**
*   **Static Inventory:** A manually maintained text file (usually in INI format, like `hosts.ini`) containing a hardcoded list of server IP addresses, hostnames, and group allocations. Any infrastructure change requires manually updating this file.
*   **Dynamic Inventory:** Automatically queries external sources of truth—such as cloud provider APIs (like AWS EC2 using `amazon.aws` inventory plugins or scripts), virtualization platforms, or CMDB tools—to generate a live list of managed hosts at runtime. This ensures configurations adjust automatically as virtual instances scale.
