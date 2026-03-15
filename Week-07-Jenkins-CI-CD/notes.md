# ⚙️ Week 07 — Jenkins & CI/CD

> **Duration:** Mar 10 – Mar 15, 2026
> **Goal:** Understand CI/CD concepts and build real pipelines with Jenkins.

---

## 📌 Why CI/CD?

In traditional development, code was written for weeks and then deployed all at once — which often caused massive failures.

**CI/CD solves this** by automatically building, testing, and deploying code every time a developer pushes changes.

```
Developer pushes code
        │
        ▼
   ┌──────────┐
   │  Jenkins │  ← Automatically triggered
   │ detects  │
   │  change  │
   └────┬─────┘
        │
   ┌────▼─────┐     ┌─────────┐     ┌──────────┐
   │  Build   │────▶│  Test   │────▶│  Deploy  │
   └──────────┘     └─────────┘     └──────────┘
```

**CI (Continuous Integration)** — automatically build and test code on every push
**CD (Continuous Delivery)** — automatically prepare the code for deployment
**CD (Continuous Deployment)** — automatically deploy to production

---

## 📚 Concepts Learned

### 1. What is Jenkins?

Jenkins is an **open-source automation server**. It is the most widely used CI/CD tool in DevOps.

Jenkins watches your Git repository and automatically:
- Pulls new code
- Builds the application
- Runs tests
- Deploys to a server

---

### 2. Jenkins Internal Flow

```
Push to GitHub
     │
     ▼
Webhook / Poll SCM
     │
     ▼
Jenkins Master receives trigger
     │
     ▼
Jenkins assigns job to an Agent
     │
     ▼
Agent clones the Git repo
     │
     ▼
Agent runs pipeline stages:
  Build → Test → Deploy
     │
     ▼
Jenkins reports result (pass/fail)
     │
     ▼
Notification sent (email, Slack, etc.)
```

---

### 3. Jenkins Architecture: Master & Agents

| Master (Controller) | Agent (Node) |
|---|---|
| Orchestrates all jobs | Does the actual build work |
| Stores configuration | Connects to master via SSH or JNLP |
| Manages plugins | Can be different OS or environments |
| Has the web UI | Runs pipeline stages |

> 💡 You should **never run builds on the master** in production — use dedicated agents.

---

### 4. Project Types in Jenkins

**Freestyle Project:**
- Simple, GUI-based setup
- Good for beginners
- You configure build steps through forms
- Limited flexibility

**Pipeline Project:**
- Written as code (Groovy)
- Much more powerful and flexible
- Can be stored in your Git repo (as a `Jenkinsfile`)
- Supports complex workflows with multiple stages

---

### 5. Pipeline Components

A Jenkins pipeline is written in **Groovy DSL** (Domain Specific Language).

```groovy
pipeline {
    agent any          // Run on any available agent

    environment {      // Define environment variables
        APP_NAME = "myapp"
    }

    stages {
        stage('Build') {          // Stage 1
            steps {
                echo 'Building...'
                sh 'npm install'
            }
        }

        stage('Test') {           // Stage 2
            steps {
                echo 'Testing...'
                sh 'npm test'
            }
        }

        stage('Deploy') {         // Stage 3
            steps {
                echo 'Deploying...'
                sh './deploy.sh'
            }
        }
    }

    post {                        // Actions after pipeline finishes
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

**Key pipeline components:**

| Component | Purpose |
|---|---|
| `pipeline { }` | Root block — everything goes inside this |
| `agent` | Where to run the pipeline (any, specific node, Docker) |
| `environment` | Define env variables available to all stages |
| `stages { }` | Container for all your stages |
| `stage('Name') { }` | A named step in your workflow |
| `steps { }` | The actual commands to run inside a stage |
| `post { }` | Actions after pipeline (success, failure, always) |

---

### 6. Jenkinsfile

Instead of writing pipeline code inside Jenkins UI, you can store it in a file called `Jenkinsfile` in the root of your Git repository.

Benefits:
- Pipeline is version controlled alongside your code
- Easier to review and collaborate on
- More professional approach

```
myproject/
├── src/
├── tests/
├── Dockerfile
├── Jenkinsfile       ← Pipeline lives here
└── README.md
```

---

### 7. Plugins in Jenkins

Jenkins gets its power from **plugins** — there are 1,800+ available.

Key plugins used:

| Plugin | Purpose |
|---|---|
| Git | Connects Jenkins to Git repositories |
| SSH Agent | Manages SSH credentials for agents |
| Pipeline | Enables scripted/declarative pipelines |
| Credentials | Securely stores passwords, SSH keys, tokens |
| Webhook | Triggers builds from GitHub pushes |
| Blue Ocean | Modern UI for pipeline visualization |

---

### 8. Triggers: Webhook vs Poll SCM

**Webhook:**
- GitHub sends a message to Jenkins **immediately** when code is pushed
- Real-time — builds start within seconds
- Requires Jenkins to be publicly accessible (or use ngrok for local)

**Poll SCM:**
- Jenkins **checks** the repo on a schedule (like a cron job)
- Uses cron syntax: `H/5 * * * *` = check every 5 minutes
- Works even if Jenkins is behind a firewall
- Slight delay between push and build

---

### 9. Credentials in Jenkins

Jenkins stores sensitive information (passwords, SSH keys, tokens) in **Credentials**.

Types:
- **Username + Password** — for HTTPS Git access
- **SSH Private Key** — for SSH Git access and agent connections
- **Secret Text** — for API tokens like DockerHub or GitHub PAT

> ⚠️ Never hardcode passwords in a Jenkinsfile — always use `credentials('id')` to reference stored credentials.

```groovy
environment {
    DOCKER_CREDS = credentials('dockerhub-creds')
}
steps {
    sh "docker login -u $DOCKER_CREDS_USR -p $DOCKER_CREDS_PSW"
}
```

---

## 🏃 Practice Exercises

- [ ] Install Jenkins and access the web UI
- [ ] Create a Freestyle project that clones a GitHub repo
- [ ] Create a Pipeline project with at least 3 stages
- [ ] Set up a Jenkins agent using SSH
- [ ] Write a Jenkinsfile and push it to your repo
- [ ] Configure a GitHub webhook to trigger the pipeline automatically
- [ ] Add credentials to Jenkins and use them in a pipeline

---

## 🐛 Errors I Encountered & Fixed

| Error | Cause | Fix |
|-------|-------|-----|
| SSH authentication failed | Wrong key format or permissions | Regenerate key, `chmod 600 key`, re-add to Jenkins credentials |
| Port already in use | Another service on port 8080 | Change Jenkins port in `/etc/default/jenkins` |
| Agent not connecting | Firewall blocking agent port | Open port 50000 on agent machine |
| Pipeline script not found | Jenkinsfile not in repo root | Move Jenkinsfile to root directory |

> 💬 *Add your own errors and solutions here as you encounter them.*

---

## 📝 Personal Notes

<!-- Your own notes, observations, things that surprised you -->

---

## 🔗 Resources

See [resources.md](./resources.md) for Jenkins documentation and tutorials.
