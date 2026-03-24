# ⚙️ Week 09 — Dynamic Pipeline Commands & Snippets

---

## 🔍 Git Commands Used Inside Pipelines

```bash
# Get latest updated remote branch
git for-each-ref --sort=-committerdate refs/remotes/origin \
  --format='%(refname:short)' | head -1 | sed 's|origin/||'

# Get current branch name
git rev-parse --abbrev-ref HEAD

# List all remote branches sorted by latest commit
git for-each-ref --sort=-committerdate refs/remotes/origin \
  --format='%(refname:short) %(committerdate:relative)'

# Fetch all remote branches
git fetch --all

# Checkout a specific branch
git checkout branchname

# Check for rebase conflicts
git status
git diff
git rebase --abort       # Cancel rebase
git rebase --continue    # Continue after fixing conflicts
git stash                # Save changes before rebase
git stash pop            # Restore after rebase
```

---

## 🐳 Docker Socket Fix (Jenkins in Docker)

```yaml
# docker-compose.yml for Jenkins — mount Docker socket
version: "3.8"
services:
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock   # ← This is the fix
    user: root   # needed to access Docker socket

volumes:
  jenkins_home:
```

```bash
# Verify Docker works inside Jenkins container
docker exec -it jenkins docker ps

# If permission denied on socket:
chmod 666 /var/run/docker.sock
```

---

## 📝 Groovy Snippets — Quoting Rules

```groovy
// ✅ Single quotes — no variable expansion (literal string)
sh 'echo hello'
sh 'git status'

// ✅ Double quotes — Groovy variables expand
sh "echo ${env.BRANCH_NAME}"
sh "docker build -t myapp:${BUILD_NUMBER} ."

// ✅ Triple single quotes — multi-line, no expansion
sh '''
  git fetch --all
  git for-each-ref --sort=-committerdate \
    refs/remotes/origin \
    --format='%(refname:short)'
'''

// ✅ returnStdout — capture command output into a variable
def result = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()

// ✅ returnStatus — capture exit code (0 = success, non-0 = fail)
def exitCode = sh(script: 'docker ps', returnStatus: true)
if (exitCode != 0) {
    echo "Docker is not running!"
}
```

---

## 🔀 Branch Detection Snippets

```groovy
// Method 1 — Latest updated branch from remote
def latestBranch = sh(
    script: """
        git for-each-ref --sort=-committerdate refs/remotes/origin \
        --format='%(refname:short)' | head -1 | sed 's|origin/||'
    """,
    returnStdout: true
).trim()

// Method 2 — Current branch (after checkout)
def currentBranch = sh(
    script: 'git rev-parse --abbrev-ref HEAD',
    returnStdout: true
).trim()

// Method 3 — From env variable (Multibranch only!)
def branch = env.BRANCH_NAME ?: 'unknown'  // ?: means "if null, use 'unknown'"
```

---

## 🚦 Environment-Based Deploy Logic

```groovy
script {
    def branch = env.DETECTED_BRANCH

    switch(branch) {
        case 'main':
            echo "Deploying to Production"
            sh "docker run -d -p 80:80 --name app-prod myapp:${branch}"
            break

        case 'dev':
            echo "Deploying to Dev"
            sh "docker run -d -p 8080:80 --name app-dev myapp:${branch}"
            break

        default:
            echo "Feature branch — tests only"
            sh "docker run --rm myapp:${branch} echo 'Tests passed'"
            break
    }
}
```

---

## 🏷️ Docker Image Tagging Per Branch

```groovy
// Tag format: appname:branchname-buildnumber
def imageTag = "${APP_NAME}:${env.DETECTED_BRANCH}-${BUILD_NUMBER}"

// Examples produced:
// myapp:main-42
// myapp:dev-15
// myapp:feature-login-7

sh "docker build -t ${imageTag} ."
sh "docker push ${imageTag}"
```

---

## ⚙️ Pipeline Options Cheat Sheet

```groovy
pipeline {
    options {
        skipDefaultCheckout(true)       // Don't auto-checkout at start
        timeout(time: 30, unit: 'MINUTES')  // Fail if takes > 30 min
        buildDiscarder(logRotator(numToKeepStr: '10'))  // Keep last 10 builds
        disableConcurrentBuilds()       // Don't run 2 builds at same time
    }
}
```

---

## 📝 My Snippets

<!-- Add your own working snippets here as you write them -->

```groovy
// Add your pipeline code here
```
