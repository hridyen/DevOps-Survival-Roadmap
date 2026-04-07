[![Sector](https://img.shields.io/badge/SECTOR-Git_Version_Control-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Git_Basics_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Git & Version Protocols

> **Focus:** Centralized vs Distributed Source Code tracking, Core staging mechanisms, and Cryptographic authentication.

---

## ✦ 1. Distributed Version Control Systems (DVCS)

Every DevOps workflow triggers natively on a Git pipeline. Unlike legacy SVN environments, Git provides extreme localized autonomy safely.

| Architecture | Failure Vulnerability | Example Setups |
|---|---|---|
| **Centralized (CVCS)** | If the master server drops, absolutely no developers can commit their locally compiled code anywhere safely! | Subversion, CVS |
| **Distributed (DVCS)** | Developers maintain an exact, perfect cloned history matching the server. They can code offline indefinitely. | Git, Mercurial |

---

## ✦ 2. The Git 3-Stage Lifecycle Architecture

Code physically must pass through specific internal memory partitions dynamically.

```mermaid
graph LR
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef dest fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;
    
    WD[Working Directory<br>Un-tracked Files] -->|git add| Staging[Staging Index<br>Snapshot Setup]
    Staging -->|git commit| Repo[Local Repository<br>Version History Saved]
    Repo -->|git push| Remote[Remote GitHub<br>Cloud Destination]:::dest
```

---

## ✦ 3. Authentication (PATs & SSH)

Basic password authentication into major cloud registries (GitHub/GitLab) was deprecated structurally to prevent brute-force attacks.

- **PAT (Personal Access Token)**: Cryptographic hexadecimal strings injected natively into your CLI payload in replace of a password.
- **SSH Keys (`ed25519`)**: Hard-bound physical keys linking your specific server/computer identity rigidly to the cloud provider without requiring continuous password entries structurally.

> [!TIP]
> From a DevOps/Jenkins pipeline perspective, you should exclusively use SSH Deploy Keys bounded safely to the agent nodes rather than using user-centric PATs!

---

## ✦ Practice Exercises
- [ ] Initialize a completely blank repository locally using `git init`.
- [ ] Create a dummy file, stage it individually bypassing other files, and commit it cleanly.
- [ ] Generate your own `SSH ed25519` key-pair naturally and bind the public key physically to your GitHub account settings.
