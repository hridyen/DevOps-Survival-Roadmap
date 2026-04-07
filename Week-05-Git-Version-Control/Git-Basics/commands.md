[![Sector](https://img.shields.io/badge/SECTOR-Git_Version_Control-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Git_Basics_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Git Commit — Commands Reference

---

## ✦ 🛠️ Scaffolding & Initializations

```bash
# First-time Identity Bindings
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Repository Genesis
git init                              # Spin up an empty .git instance locally
git clone <url>                       # Mirrors an entire repository footprint
git clone <url> --depth 1             # Fast-clone! Only pulls the very latest state, avoiding massive history downloads!
```

---

## ✦ 📤 Staging & Transmission

```bash
# Internal Snapshotting
git status                            # Check current modified directory states
git add filename.txt                  # Stage a specific file
git add .                             # Aggressive batch stage everything modified
git commit -m "Fixed database bug"    # Snapshot safely to the internal tracked graph

# Cloud Communication
git remote add origin <url>           # Map an empty local repo explicitly to a Cloud URL
git push origin main                  # Force transmit Local snapshot history into the Cloud
git pull origin main                  # Inherit external snapshot history down
git fetch origin                      # Download remote data invisibly WITHOUT actively injecting it into your live code!
```

---

## ✦ 📝 My Pipeline Execution Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `git fetch origin` | It completely separates the danger of pulling code blindly. | If I want to verify exactly what changes Jenkins is about to merge before I actually ruin my local directory. |
| `ssh -T git@github.com` | Hard-ping test strictly over SSH boundaries to GitHub servers. | Troubleshooting Jenkins agents failing to pull code by testing the physical SSH bind path. |
