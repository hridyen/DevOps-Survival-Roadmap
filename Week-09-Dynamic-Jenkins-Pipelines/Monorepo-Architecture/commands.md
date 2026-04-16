[![Sector](https://img.shields.io/badge/SECTOR-Dynamic_Jenkins_Pipelines-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Monorepo_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Monorepo Management Commands

## ✦ 1. Git Changeset Detection

In a monorepo, you only want to trigger builds for the services that changed.

### ✦ Filtering Changes by Path
```bash
# Check if any files in 'service-a/' changed in the last commit
git diff --quiet HEAD^ HEAD service-a/ || echo "Service A changed"

# List files changed between two branches
git diff --name-only main..feature-branch
```

---

## ✦ 2. Jenkinsfile Logic (Shared Libraries)

While these are snippets rather than terminal commands, they are the "commands" of the monorepo logic.

### ✦ Changeset Trigger Snippet
```groovy
stage('Conditional Build') {
    when {
        changeset 'services/auth-service/**'
    }
    steps {
        echo "Building Auth Service..."
    }
}
```

---

## ✦ 3. Disk Space Management

Monorepos can grow extremely large. 

### ✦ Sparse Checkout
Only clone the directories you need for the current build.
```bash
git clone --filter=blob:none --no-checkout https://github.com/repo/monorepo.git
cd monorepo
git sparse-checkout set services/app-1
git checkout main
```

### ✦ Cleaning workspace
```bash
# Clean untracked files in the current service directory
git clean -fd .
```
