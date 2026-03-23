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

## Project 5: Dynamic Branch-Based Pipeline

**Type:** Intelligent Declarative Pipeline

**What it does:** Automatically detects the latest updated branch in Git, checks it out, and builds a Docker image with a tag format of `app:branch-buildnumber`. It then deploys to different ports based on the branch (80 for main, 8080 for dev).

**Key Features:**
- **`skipDefaultCheckout(true)`**: Control exactly when and how the code is pulled.
- **Dynamic Branch Detection**: Uses a shell script to find the branch with the most recent commit.
- **Conditional Deployment**: Uses Groovy `if-else` logic to target production vs staging environments.
- **Per-Branch Tagging**: Ensures every branch has its own unique, traceable image.

**Example Logic:**
```groovy
if (branch == 'main') {
    // Deploy to Production (Port 80)
} else if (branch == 'dev') {
    // Deploy to Dev (Port 8080)
} else {
    // Feature branch - Run tests only
}
```

**Repositories:**
- [multi-branch-project](https://github.com/hridyen/multi-branch-project.git)
- [multibranch](https://github.com/hridyen/multibranch.git)

---

## 📝 Notes

## Best Practices and Tips for Jenkins Declarative Pipelines

### 1. Keeping Pipelines Modular

Complex Jenkins pipelines should be split into smaller, reusable components.  
This improves maintainability, readability, and overall project organization.

#### Techniques
- Use **Shared Libraries** in Jenkins for reusable pipeline code.
- Create **custom functions** inside libraries.
- Use **pipeline templates** to standardize pipeline structure across projects.

#### Benefits
- Cleaner pipeline scripts
- Easier debugging and maintenance
- Reusable logic across multiple projects
- Better code organization

**Interview Question**

How would you structure a pipeline to promote modularity and code reuse?

**Answer**

I would separate common logic into Jenkins Shared Libraries and reusable functions.  
This allows multiple pipelines to reuse the same logic while keeping the pipeline scripts clean and modular.

---

### 2. Version Control and Code Review

Pipeline scripts should always be stored in a **version control system such as Git**.

#### Importance
- Tracks changes in pipeline code
- Maintains history of modifications
- Enables collaboration between teams

#### Benefits of Code Reviews
- Detect errors early
- Enforce best practices
- Improve pipeline reliability and quality

**Interview Question**

How would you integrate Jenkins declarative pipelines with a version control system like Git?

**Answer**

I would store the `Jenkinsfile` inside the project repository and configure Jenkins to pull the pipeline from Git.  
Using webhooks or polling, Jenkins automatically triggers builds when changes are pushed to the repository.

---

### 3. Error Handling and Recovery

Proper error handling is critical for reliable pipelines.

#### Techniques
- `try-catch` blocks
- `catchError` step
- `error` step
- `timeout` step
- `retry` step

#### Benefits
- Prevents pipeline crashes
- Provides clear failure messages
- Enables automatic retries for transient failures

**Interview Question**

How would you handle a failing step in a pipeline and ensure proper error reporting?

**Answer**

I would use steps like `catchError` or `try-catch` blocks to capture failures and log meaningful messages.  
Additionally, I would implement retries and timeout mechanisms to recover from temporary failures.

---

### 4. Testing Pipelines

Pipelines should be tested before deploying them in production.

#### Strategies
- Unit testing pipeline components
- Simulating pipeline execution
- Running pipelines in staging or test environments

#### Benefits
- Detects configuration errors early
- Ensures pipeline behaviour is correct
- Reduces risk during production deployments

**Interview Question**

How would you approach testing a complex Jenkins declarative pipeline?

**Answer**

I would test individual stages and shared libraries separately, run pipeline simulations, and execute the pipeline in a staging environment before deploying it to production.
Discuss techniques like unit testing pipeline components, running pipeline
simulations, and using test environments.
Explain the benefits of testing pipelines to catch errors, validate changes,
and ensure expected behaviour.
Interview question: How would you approach testing a complex Jenkins
declarative pipeline?
