[![Sector](https://img.shields.io/badge/SECTOR-Jenkins_CI_CD-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Jenkins_Administration_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Jenkins Architecture & Administration

> **Focus:** Distributed Master/Agent nodes, Webhook integration, and Plugin execution securely.

---

## ✦ 1. Distributed Execution Patterns (Master & Agent)

Running native pipelines directly on the Jenkins Master server fundamentally breaks security and scales horribly.

| Master Controller | Build Agents (Nodes) |
|---|---|
| Holds all passwords, SSH keys, and logic. | Receives payload dynamically mapping to its execution capabilities. |
| Exposes the Web UI (Port 8080). | Operates entirely blindly. Connects inwards via SSH. |
| Coordinates Plugin bindings. | Does the heavy lifting. Isolates crashes entirely from the Master node. |

---

## ✦ 2. Triggers: Webhooks vs Poll SCM

Jenkins must fundamentally decide exactly when to run your code continuously.

- **Poll SCM**: Jenkins actively interrogates GitHub every 5 minutes checking for differences aggressively. Very noisy.
- **GitHub Webhook**: GitHub actively pings Jenkins instantly natively via a REST payload the very microsecond a developer pushes code successfully onto a monitored branch.

> [!TIP]
> Always utilize Webhooks in production. Polling is incredibly taxing on both API limits and GitHub routing architecture natively.

---

## ✦ 3. Jenkins Security Cryptography

Hardcoding passwords into Groovy files is a critical vulnerability natively.

Jenkins dynamically securely encrypts secrets natively using an encrypted string structure within its database physically. The pipeline natively accesses it exclusively at runtime conditionally without exposing it strictly cleanly into stdout logs.

```groovy
environment {
    // Fetches native token and securely binds it into pipeline without printing it physically
    DOCKER_CREDS = credentials('dockerhub-secrets')
}
```

---

- [ ] Connect a live repo directly seamlessly using GitHub Webhooks testing auto-triggers inherently!

---

## ✦ Personal Notes

- **The Agent SSH Rule:** When adding agents via SSH, always use the `ed25519` key format. It's shorter, more secure, and perfectly compatible with modern Linux distributions. Ensure the `jenkins` user on the agent node has ownership of its workspace directory (`/home/jenkins/workspace`).
- **Webhook Debugging:** If your webhook isn't triggering, check the "Payload URL" in GitHub. It should usually be `http://<jenkins-url>:8080/github-webhook/`. That trailing slash `/` is critical; without it, some versions of Jenkins will silently ignore the ping.
- **Plugin Fatigue:** Only install the plugins you absolutely need. Every plugin adds overhead to the Jenkins Master and increases the security attack surface. Periodically audit and remove unused plugins to keep the UI snappy.

---

## ✦ 🔗 Resources

See [resources.md](./resources.md)
