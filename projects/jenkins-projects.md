# ⚙️ Jenkins CI/CD Projects

> Real pipelines and configurations built during Week 7 training.

---

## Project 1: First Jenkins Pipeline

**Type:** Pipeline Project

**What it does:** Clones a GitHub repo, runs a build script, and deploys the app.

**Stages:** Checkout → Build → Deploy

**Jenkinsfile:**
```groovy
pipeline {

    agent {
        label 'ubuntu-agent'
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['DEPLOY', 'STOP'],
            description: 'Choose what action to perform'
        )
    }

    stages {

        stage('Verify Docker') {
            when {
                expression { params.ACTION == 'DEPLOY' }
            }
            steps {
                sh 'docker --version'
                sh 'docker compose version'
            }
        }

        stage('Build Containers') {
            when {
                expression { params.ACTION == 'DEPLOY' }
            }
            steps {
                sh 'docker compose build'
            }
        }

        stage('Start Application') {
            when {
                expression { params.ACTION == 'DEPLOY' }
            }
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Stop Application') {
            when {
                expression { params.ACTION == 'STOP' }
            }
            steps {
                sh 'docker compose down'
            }
        }

    }

}
```


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

Best Practices and tips for Jenkins Declarative
Pipelines
Keeping pipelines modular: Splitting complex pipelines into reusable
components.
Discuss techniques for defining shared libraries, functions, and templates to
promote reusability.
Highlight the benefits of modular pipelines in terms of maintainability and
code organization.
Interview question: How would you structure a pipeline to promote
modularity and code reuse?
Version control and code review: Leveraging version control systems and
performing code reviews for pipeline scripts.
Discuss the importance of storing pipeline scripts in a version control
system for change tracking.
Explain the benefits of code reviews to ensure best practices, identify
errors, and improve pipeline quality.
Interview question: How would you integrate Jenkins declarative pipelines
with a version control system like Git?
Error handling and recovery: Implementing error handling mechanisms and
retry strategies in pipelines.
Discuss techniques like try-catch blocks, error handling steps (e.g.,
catchError, error, timeout), and retries.
Highlight the importance of handling errors gracefully and recovering from
failures in the pipeline.
Interview question: How would you handle a failing step in a pipeline and
ensure proper error reporting?
Testing pipelines: Strategies for testing and validating pipeline changes before
production deployment.
Discuss techniques like unit testing pipeline components, running pipeline
simulations, and using test environments.
Explain the benefits of testing pipelines to catch errors, validate changes,
and ensure expected behaviour.
Interview question: How would you approach testing a complex Jenkins
declarative pipeline?
