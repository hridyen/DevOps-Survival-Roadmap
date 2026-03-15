# ⚙️ Jenkins CI/CD Projects

> Real pipelines and configurations built during Week 7 training.

---

## Project 1: First Jenkins Pipeline

**Type:** Pipeline Project

**What it does:** Clones a GitHub repo, runs a build script, and deploys the app.

**Stages:** Checkout → Build → Deploy

**Jenkinsfile:**
```groovy
// Add your Jenkinsfile here
```

**Challenges & solutions:**
- <!-- What went wrong and how you fixed it -->

---

## Project 2: Pipeline with Webhook Trigger

**Type:** Pipeline with GitHub Webhook

**What it does:** Automatically triggers the pipeline when code is pushed to the main branch.

**Setup steps:**
1. Configured GitHub webhook URL in repo settings
2. Installed GitHub Integration plugin in Jenkins
3. Set trigger to "GitHub hook trigger for GITScm polling"

**Result:** Push code → pipeline starts within seconds

---

## Project 3: Multi-Agent Pipeline

**Type:** Declarative Pipeline with 2 Agents

**Agents set up:**
- Agent 1: `build-agent-01` (SSH key authentication)
- Agent 2: `build-agent-02`

**Issues resolved:**
- SSH key format error → Regenerated key in correct format
- Port 50000 blocked → Opened port in firewall
- Credentials not found → Re-added with correct ID

---

## Project 4: Jenkinsfile in Repository

**What it does:** Uses a `Jenkinsfile` stored in the Git repo root instead of pipeline code in Jenkins UI.

**Benefits experienced:**
- Pipeline is version controlled
- Easy to review changes to pipeline
- Can trigger from any branch

**Repo structure:**
```
myproject/
├── app/
├── Dockerfile
├── Jenkinsfile    ← Pipeline code lives here
└── README.md
```

---

## 📝 Notes

<!-- Add more project details as you complete them -->
