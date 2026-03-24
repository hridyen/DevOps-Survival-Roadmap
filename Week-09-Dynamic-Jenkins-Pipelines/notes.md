# ⚙️ Week 09 — Dynamic Jenkins Pipelines

> **Duration:** Mar 23, 2026 – Ongoing
> **Status:** 🟡 In Progress
> **Goal:** Move beyond basic CI/CD and build a real-world, branch-aware deployment pipeline using Jenkins Multibranch and Docker.

---

## 📌 What Changed This Week?

In Week 7, pipelines were **static** — you manually selected a branch, wrote fixed steps, and ran them.

This week the goal was to make pipelines **dynamic and branch-aware** — the pipeline itself reacts differently based on which Git branch triggered it.

### 🏗️ What Was Actually Built

A **Multibranch Jenkins Pipeline** handling 4 Git branches with different behavior:

| Branch | What Happens |
|---|---|
| `dev` | ✅ Build triggered → Docker image built → Deploy to **dev environment** |
| `prod` | ✅ Build triggered → Docker image built → Deploy to **production** |
| `stg` | ⛔ Ignored at trigger level — no build, no deploy |
| `uat` | ⛔ Ignored at trigger level — no build, no deploy |

> 💡 **Key design decision:** `stg` and `uat` are ignored **at the trigger level**, not inside the pipeline with an `if` condition. This is cleaner — unnecessary builds never even start.

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


### 5. Trigger-Level Control vs Pipeline Condition Control

This was one of the most important design decisions this week.

**❌ Wrong approach — checking branch inside pipeline:**
```groovy
// Build still runs for stg/uat — wastes resources
stage('Deploy') {
    steps {
        script {
            if (env.BRANCH_NAME == 'dev') {
                // deploy
            } else {
                echo "Skipping"   // build already wasted CI time!
            }
        }
    }
}
```

**✅ Right approach — filter at trigger level:**
In Multibranch Pipeline settings → Branch Sources → Behaviours → Filter by name
Only include: `dev` and `prod`
`stg` and `uat` never trigger a build at all.

**Why this matters:**
- Saves CI/CD resources — no wasted builds
- Cleaner pipeline — no dead `else` branches
- More professional — mirrors how real teams manage environments

---

### 6. Passing -e Environment Variables to Docker Containers

To make the **same Docker image behave differently** in dev vs prod, pass environment variables at runtime:

```groovy
stage('Deploy') {
    steps {
        script {
            def branch = env.BRANCH_NAME
            if (branch == 'prod') {
                sh "docker run -d -p 80:80 -e BRANCH=prod -e ENV=production --name myapp-prod myapp:${branch}-${BUILD_NUMBER}"
            } else if (branch == 'dev') {
                sh "docker run -d -p 8080:80 -e BRANCH=dev -e ENV=development --name myapp-dev myapp:${branch}-${BUILD_NUMBER}"
            }
        }
    }
}
```

Inside the container, your app reads `ENV` to behave accordingly — same image, different config per environment.

---

### 7. Multibranch Pipeline vs Standalone Pipeline

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

### Error 3: Git Push Rejected — Non-Fast-Forward

**What happened:**
After making local changes, pushed to remote but got rejected because remote had newer commits.

**Error message:**
```
! [rejected]        dev -> dev (non-fast-forward)
error: failed to push some refs
hint: Updates were rejected because the tip of your current branch is behind
```

**Fix:**
```bash
# Pull with rebase first, then push
git pull origin dev --rebase
git push origin dev
```

**Lesson:** Always `git pull` before starting work. Rebase keeps history linear and clean.

---

### Error 4: Merge Conflict While Syncing Jenkinsfile Across Branches

**What happened:**
Jenkinsfile was updated on `dev`. When syncing to `prod`, conflict happened because both had different pipeline logic.

**Error message:**
```
CONFLICT (content): Merge conflict in Jenkinsfile
Automatic merge failed; fix conflicts and then commit the result.
```

**Fix:**
```bash
git diff Jenkinsfile          # See conflict
# Manually edit — remove <<<<<<< HEAD, =======, >>>>>>> markers
git add Jenkinsfile
git commit -m "Resolve Jenkinsfile merge conflict"
git push origin prod
```

**Lesson:** Use `BRANCH_NAME` inside one Jenkinsfile for branch logic instead of separate Jenkinsfiles per branch — fewer conflicts.

---

### Error 5: Groovy Syntax Error — Misplaced Brackets

**What happened:**
Jenkinsfile failed to parse because of a missing `}` in Groovy script.

**Error message:**
```
org.codehaus.groovy.control.MultipleCompilationErrorsException:
startup failed: WorkflowScript: 45: unexpected token: } @ line 45
```

**Fix:**
- Count every `{` — every one needs a matching `}`
- Use proper indentation to make mismatches visible
- Use VS Code with Groovy extension for syntax highlighting

**Lesson:** One missing bracket = entire pipeline fails to parse. Indentation is not optional in Groovy.

---

### Error 3 (original): BRANCH_NAME is Null in Standalone Pipeline

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

## 🏆 Final Outcome

```
GitHub Push to 'dev' branch
         │
         ▼
Multibranch Jenkins detects push (Webhook)
         │
         ▼
Branch filter: dev ✅ allowed → Build starts
         │
         ▼
Stage 1: Checkout dev branch
Stage 2: Build image → myapp:dev-42
Stage 3: docker run -e ENV=development → port 8080
         │
         ▼
Dev environment live ✅

─────────────────────────────────────

GitHub Push to 'stg' branch
         │
         ▼
Branch filter: stg ⛔ blocked → Build NEVER starts
No resources wasted ✅
```

**Result:** A clean, production-style CI/CD setup where:
- Deployments are **automated** — no manual intervention
- Deployments are **branch-aware** — right code goes to right environment
- Deployments are **controlled** — stg/uat don't waste build resources
- Containers are **environment-specific** — same image, different behavior via `-e` flags

---

## 🧠 Key Takeaways This Week

> Things that clicked this week after debugging:

- A pipeline that **thinks** is more valuable than a pipeline that just **runs**
- Control deployment logic at the **trigger level** — not inside the pipeline with `if/else`
- `BRANCH_NAME` is a gift from Multibranch — standalone pipelines don't get it for free
- Pass `-e ENV=value` to Docker containers to make one image behave differently per environment
- Shell inside Groovy has its own quoting rules — single vs double quotes matter a lot
- Docker inside Jenkins is not automatic — mount the socket or use a Docker-enabled agent
- Non-fast-forward errors mean someone pushed before you — always pull first
- One wrong bracket in Groovy = entire pipeline fails to parse
- `skipDefaultCheckout` exists for a reason — learn when to use it
- **Debugging CI/CD teaches you more than building it from scratch ever could**

---

## 🏃 Practice Exercises

- [ ] Set up a Multibranch Pipeline with 4 branches: dev, prod, stg, uat
- [ ] Configure branch filter so only dev and prod trigger builds
- [ ] Tag Docker images with branch name + build number (`myapp:dev-42`)
- [ ] Pass `-e ENV=development` and `-e ENV=production` to containers at runtime
- [ ] Reproduce the Docker socket error and fix it via socket mount
- [ ] Reproduce a non-fast-forward push rejection and fix it with rebase
- [ ] Cause a Groovy syntax error intentionally and learn to debug it
- [ ] Fix a real merge conflict in Jenkinsfile across branches
- [ ] Test the difference between Multibranch and Standalone pipeline behavior

---

## 📝 Personal Notes

<!-- Add your own observations, errors, and aha moments here -->

> 💬 *This week was more about debugging than building. Add what surprised you most.*

---

## 🔗 Resources

See [resources.md](./resources.md)
