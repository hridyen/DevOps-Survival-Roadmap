[![Sector](https://img.shields.io/badge/SECTOR-Jenkins_CI_CD-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Declarative_Pipelines_Examples-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Declarative Groovy — Reference

---

## ✦ 📜 Standalone Jenkinsfile (Docker Build & Run)

```groovy
pipeline {
    agent any

    environment {
        APP_PORT = "8080"
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm    // Automatically uses the repo configured globally in the Jenkins job natively
            }
        }

        stage('Build') {
            steps {
                echo "Building application natively dynamically on port ${APP_PORT}..."
                sh 'docker build -t myapp:latest .'
            }
        }

        stage('Run') {
            steps {
                sh "docker run -d -p ${APP_PORT}:80 --name myapp myapp:latest"
                echo "Application running live cleanly structurally at port ${APP_PORT}"
            }
        }
    }

    post {
        success {
            echo "✅ Success! App is live and bound correctly."
        }
        failure {
            echo "❌ Build explicitly failed. Check logs immediately."
        }
        always {
            echo "Pipeline daemon has successfully structurally disconnected from Agent."
        }
    }
}
```

---

## ✦ 📜 Advanced Multi-Node Execution & Manual Approvals

```groovy
pipeline {
    agent {
        label 'build-agent-01'    // Force this job exclusively onto a specific mapped SSH Node dynamically
    }

    stages {
        stage('Unit Tests') {
            steps {
                sh './run-unit-tests.sh'
            }
        }

        stage('Approval Gate') {
            steps {
                // Freezes the entire pipeline visually natively waiting for human click
                input message: 'Deploy strictly cleanly dynamically into highly restricted production?', ok: 'Yes, authorized.'
            }
        }

        stage('Production Deploy') {
            steps {
                echo 'Deploying automatically securely to production...'
            }
        }
    }
}
```

---

## ✦ 📝 My Advanced Groovy Debugging Notes

| Groovy Component | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `parallel { }` | Forces Jenkins dynamically explicitly cleanly conditionally natively to launch multiple Stages absolutely flawlessly simultaneously! | Running both UI Selenium tests and strictly backend PyTest coverage natively entirely at the identical same time saving massive CI minutes securely. |
