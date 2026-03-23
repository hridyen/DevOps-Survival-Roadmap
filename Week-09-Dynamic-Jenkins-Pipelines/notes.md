# ⚙️ Week 09 — Dynamic Jenkins Pipelines

> **Duration:** Week 9 — Ongoing
> **Status:** 🟡 In Progress
> **Goal:** Move beyond basic CI/CD and build intelligent, dynamic pipelines that react to your Git repository automatically.

---

## 📌 What Changed This Week?

In Week 7, pipelines were **static** — you manually selected a branch, wrote fixed steps, and ran them.

This week the goal was to make pipelines **dynamic** — the pipeline itself figures out what to do based on what changed in Git.

```
Static Pipeline (Week 7):         Dynamic Pipeline (Week 9):
──────────────────────────        ──────────────────────────
You select branch manually   →    Pipeline detects branch automatically
Fixed Docker tag             →    Docker tag = branch name
Same deploy logic always     →    Deploy logic changes based on branch
                                  (dev branch → dev server,
                                   main branch → production)
```

---

## 📚 Concepts Learned

### 1. Dynamic Branch Detection

Instead of hardcoding which branch to build, the pipeline detects **which branch was most recently updated** using Git commands inside the pipeline itself.

```groovy
// Get the latest updated branch automatically
def latestBranch = sh(
    script: "git for-each-ref --sort=-committerdate refs/remotes/origin --format='%(refname:short)' | head -1 | sed 's|origin/||'",
    returnStdout: true
).trim()

echo "Latest updated branch: ${latestBranch}"
```

**Why this matters:**
In real companies, dozens of developers push to different branches constantly. A smart pipeline reacts to changes automatically instead of waiting for someone to manually trigger and select a branch.

---

### 2. Dynamic Checkout

After detecting the branch, the pipeline checks it out dynamically — not using Jenkins' default checkout behavior.

```groovy
stage('Dynamic Checkout') {
    steps {
        script {
            def latestBranch = sh(
                script: "git for-each-ref --sort=-committerdate refs/remotes/origin --format='%(refname:short)' | head -1 | sed 's|origin/||'",
                returnStdout: true
            ).trim()

            env.DETECTED_BRANCH = latestBranch
            echo "Checking out branch: ${latestBranch}"

            checkout([
                $class: 'GitSCM',
                branches: [[name: "*/${latestBranch}"]],
                userRemoteConfigs: [[url: 'https://github.com/youruser/yourrepo.git']]
            ])
        }
    }
}
```

---

### 3. Branch-Based Docker Tagging

Docker images are tagged **per branch** so you always know which branch produced which image.

```groovy
stage('Build Docker Image') {
    steps {
        script {
            def branch = env.DETECTED_BRANCH
            def imageTag = "myapp:${branch}-${BUILD_NUMBER}"
            // Example tags:
            // myapp:main-42
            // myapp:dev-15
            // myapp:feature-login-7

            sh "docker build -t ${imageTag} ."
            env.IMAGE_TAG = imageTag
        }
    }
}
```

**Why per-branch tagging matters:**
- You can roll back to any branch's version
- You can see exactly what is running in production
- Multiple branches can have live images without overwriting each other

---

### 4. Environment-Based Deploy Logic

The pipeline behaves **differently** depending on which branch triggered it.

```groovy
stage('Deploy') {
    steps {
        script {
            def branch = env.DETECTED_BRANCH

            if (branch == 'main') {
                echo "🚀 Deploying to PRODUCTION server..."
                sh "docker run -d -p 80:80 --name myapp-prod ${env.IMAGE_TAG}"

            } else if (branch == 'dev') {
                echo "🧪 Deploying to DEV server..."
                sh "docker run -d -p 8080:80 --name myapp-dev ${env.IMAGE_TAG}"

            } else {
                echo "🔧 Feature branch — running tests only, not deploying..."
                sh "docker run --rm ${env.IMAGE_TAG} ./run-tests.sh"
            }
        }
    }
}
```

```
Branch Logic:
─────────────────────────────────────────────────────
main branch    →  Deploy to Production  (port 80)
dev branch     →  Deploy to Dev server  (port 8080)
feature/*      →  Run tests only        (no deploy)
─────────────────────────────────────────────────────
```

---

### 5. Multibranch Pipeline vs Standalone Pipeline

This was a major learning this week — these two pipeline types behave very differently.

| Feature | Multibranch Pipeline | Standalone Pipeline |
|---|---|---|
| **What it does** | Auto-creates a job per branch | Single job, one pipeline |
| **`BRANCH_NAME` variable** | ✅ Available automatically | ❌ NOT available |
| **Jenkinsfile location** | Must exist in every branch | One central Jenkinsfile |
| **Branch detection** | Automatic | Manual or custom scripted |
| **Best for** | Teams with many feature branches | Controlled single-flow pipelines |

> 💡 **Key lesson:** `BRANCH_NAME` environment variable only exists in **Multibranch** pipelines. In a standalone pipeline, if you use `env.BRANCH_NAME`, it returns `null`. You have to detect it yourself using Git commands.

```groovy
// This works ONLY in Multibranch pipelines:
echo env.BRANCH_NAME   // → "main" or "dev"

// In Standalone pipelines, BRANCH_NAME is null
// You must do this instead:
def branch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
```

---

### 6. Shell Scripting Inside Groovy — Escaping Issues

One of the trickiest parts of this week was running shell commands inside Groovy scripts, especially when quotes and variables are involved.

**The problem:**

```groovy
// WRONG — variable won't expand inside single quotes
sh 'echo $BRANCH_NAME'       // prints: $BRANCH_NAME (literally)

// CORRECT — use double quotes for Groovy variable expansion
sh "echo ${env.BRANCH_NAME}" // prints: main
```

**Another common issue — nested quotes:**

```groovy
// WRONG — breaks because of quote conflict
sh "git for-each-ref --format='%(refname)'"

// CORRECT — escape the inner quotes
sh "git for-each-ref --format=\\'%(refname)\\'"

// OR use triple single quotes for multi-line scripts
sh '''
  git for-each-ref \
    --sort=-committerdate \
    --format='%(refname:short)' \
    refs/remotes/origin
'''
```

---

### 7. Default Checkout Behavior — The Hidden Problem

When Jenkins runs a pipeline, it **automatically checks out** the repository before your stages even begin. This is called **implicit checkout** or **default SCM checkout**.

**The problem:**
If you write custom checkout logic, it sometimes conflicts with the default checkout that already happened.

**The fix — disable default checkout:**

```groovy
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)    // ← Disable automatic checkout
    }

    stages {
        stage('Custom Checkout') {
            steps {
                // Now YOU control the checkout
                checkout scm
            }
        }
    }
}
```

---

## 🐛 Real Errors Encountered & Fixed

### Error 1: Git Rebase Conflicts

**What happened:**
While working on the pipeline, pushed changes to a branch that had diverged from remote. Git rebase failed with conflicts.

**Error message:**
```
error: cannot rebase: You have unstaged changes.
CONFLICT (content): Merge conflict in Jenkinsfile
```

**Fix:**
```bash
# Check what's conflicting
git status
git diff

# Option 1: Abort rebase and start fresh
git rebase --abort

# Option 2: Fix conflict manually, then continue
# Edit the conflicting file
git add Jenkinsfile
git rebase --continue
```

**Lesson:** Never rebase when you have uncommitted changes. Always `git stash` first.

---

### Error 2: Docker Not Available Inside Jenkins Container

**What happened:**
Jenkins was running inside a Docker container. When the pipeline tried to run `docker build`, it failed because Docker was not installed inside the Jenkins container.

**Error message:**
```
docker: command not found
```

**Fix options:**

```groovy
// Option 1: Mount Docker socket from host into Jenkins container
// In docker-compose.yml for Jenkins:
volumes:
  - /var/run/docker.sock:/var/run/docker.sock

// Option 2: Use Docker-in-Docker (DinD) — more complex
// Option 3: Run pipeline on an agent that HAS Docker installed
agent {
    label 'docker-agent'   // agent where Docker is available
}
```

**Lesson:** Jenkins container ≠ Docker host. You must either mount the Docker socket or use an agent that has Docker.

---

### Error 3: BRANCH_NAME is Null in Standalone Pipeline

**What happened:**
Used `env.BRANCH_NAME` in a standalone pipeline expecting it to work like in multibranch.

**Error:**
```
groovy.lang.NullPointerException: Cannot invoke method trim() on null object
```

**Fix:**
```groovy
// Detect branch manually using Git
def branch = sh(
    script: 'git rev-parse --abbrev-ref HEAD',
    returnStdout: true
).trim()
```

---

## 🔗 Full Dynamic Pipeline (Complete Example)

```groovy
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        REPO_URL = 'https://github.com/youruser/yourrepo.git'
        APP_NAME = 'myapp'
    }

    stages {

        stage('Detect Latest Branch') {
            steps {
                script {
                    // Clone with all branches
                    sh "git clone ${REPO_URL} ."

                    // Detect which branch was updated most recently
                    def latestBranch = sh(
                        script: "git for-each-ref --sort=-committerdate refs/remotes/origin --format='%(refname:short)' | head -1 | sed 's|origin/||'",
                        returnStdout: true
                    ).trim()

                    env.DETECTED_BRANCH = latestBranch
                    echo "✅ Detected branch: ${latestBranch}"
                }
            }
        }

        stage('Checkout Branch') {
            steps {
                script {
                    sh "git checkout ${env.DETECTED_BRANCH}"
                    echo "✅ Checked out: ${env.DETECTED_BRANCH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "${APP_NAME}:${env.DETECTED_BRANCH}-${BUILD_NUMBER}"
                    sh "docker build -t ${env.IMAGE_TAG} ."
                    echo "✅ Built image: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def branch = env.DETECTED_BRANCH

                    if (branch == 'main') {
                        echo "🚀 Deploying to PRODUCTION..."
                        sh "docker run -d -p 80:80 --name ${APP_NAME}-prod ${env.IMAGE_TAG}"

                    } else if (branch == 'dev') {
                        echo "🧪 Deploying to DEV environment..."
                        sh "docker run -d -p 8080:80 --name ${APP_NAME}-dev ${env.IMAGE_TAG}"

                    } else {
                        echo "🔧 Feature branch — running tests only..."
                        sh "docker run --rm ${env.IMAGE_TAG} echo 'Tests passed'"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed! Branch: ${env.DETECTED_BRANCH} | Image: ${env.IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed on branch: ${env.DETECTED_BRANCH}"
        }
    }
}
```

---

## 🧠 Key Takeaways This Week

> Things that clicked this week after debugging:

- A pipeline that **thinks** is more valuable than a pipeline that just **runs**
- `BRANCH_NAME` is a gift from Multibranch — standalone pipelines don't get it for free
- Shell inside Groovy has its own quoting rules — single vs double quotes matter a lot
- Docker inside Jenkins is not automatic — you have to explicitly connect them
- `skipDefaultCheckout` exists for a reason — learn when to use it
- Debugging CI/CD teaches you more than building it from scratch ever could

---

## 🏃 Practice Exercises

- [ ] Build a standalone pipeline that detects branch automatically
- [ ] Tag Docker images with branch name + build number
- [ ] Write deploy logic that behaves differently for `main` vs `dev`
- [ ] Reproduce the Docker socket error and fix it
- [ ] Test the difference between Multibranch and Standalone pipeline behavior
- [ ] Fix a real Git rebase conflict inside a pipeline context

---

## 📝 Personal Notes

<!-- Add your own observations, errors, and aha moments here -->

> 💬 *This week was more about debugging than building. Add what surprised you most.*

---

## 🔗 Resources

See [resources.md](./resources.md)
