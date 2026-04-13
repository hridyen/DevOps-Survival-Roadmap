[![Sector](https://img.shields.io/badge/SECTOR-Jenkins_CI_CD-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Declarative_Pipelines_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Groovy Declarative Pipelines

> **Focus:** Infrastructure as Code pipelines, Jenkinsfile tracking structurally, and Groovy DSL Syntax.

---

## ✦ 1. The Power of "Jenkinsfile"

Instead of configuring a clunky disjointed Jenkins UI manually every single time an environment changes, the entire pipeline is codified precisely dynamically into a singular tracked `Jenkinsfile` stored alongside your application structurally in GitHub.

```mermaid
graph LR
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef active fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;
    classDef hardware fill:#0A0A0A,stroke:#00FF99,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;

    App[Application Code<br>index.js]:::hardware
    Dock[Dockerfile<br>Container Config]:::hardware
    JFile[Jenkinsfile<br>Deployment Logic]:::active
    
    App --> MainRepo[GitHub Repository]
    Dock --> MainRepo
    JFile --> MainRepo
    
    MainRepo -->|Webhook| Execute[Jenkins Agent Runs Automatically]
```

---

## ✦ 2. Groovy DSL Core Structure

Pipelines enforce strict bracket groupings ensuring logic dictates identically.

| Component | Function within standard execution |
|---|---|
| `pipeline { }` | Absolute root node. Encapsulates the entire script. |
| `agent any` | Tells the Master controller to dump this job onto literally any connected worker. |
| `stages { }` | Structurally separates distinct phases logically sequentially (Build, then Test, then Deploy). |
| `steps { }` | The exact literal bash `sh` or PowerShell commands physically executed inside each phase. |
| `post { }` | Final conditional triggers executing strictly depending on if the build Passed or Failed. |

---

- [ ] Initialize a standard Freestyle project structurally via the Jenkins GUI completely, then convert the exact same logic into a Jenkinsfile Pipeline dynamically!

---

## ✦ Personal Notes

- **The "Agent any" Trap:** In production, avoid `agent any`. Use labels like `agent { label 'docker-node' }` to ensure your build only runs on agents that have the necessary tools installed. This prevents builds failing because "docker command not found".
- **Post-Build Awareness:** Always use the `post { always { cleanWs() } }` block. Without it, Jenkins agents will keep old build artifacts on disk indefinitely, eventually running out of space and crashing future builds.
- **Fail Fast:** Use the `timeout` option on your stages. If a build hangs (e.g., waiting for an input), you don't want it to hog an executive slot for hours. `timeout(time: 10, unit: 'MINUTES') { ... }` is a lifesaver.

---

## ✦ 🔗 Resources

See [resources.md](./resources.md)
