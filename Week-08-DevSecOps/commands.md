# 🔐 Week 08 — DevSecOps Commands Reference

> **Status:** 🟡 Filling in as hands-on practice happens

---

## 🔍 SonarQube

```bash
# Run SonarQube using Docker (easiest way to install)
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  sonarqube:latest

# Access at: http://localhost:9000
# Default login: admin / admin

# Run a scan on your project (using sonar-scanner)
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN
```

**Jenkins Pipeline Stage for SonarQube:**
```groovy
stage('SonarQube Scan') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'sonar-scanner -Dsonar.projectKey=myapp'
        }
    }
}

stage('Quality Gate') {
    steps {
        timeout(time: 2, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

---

## 🛡️ OWASP Dependency Check

```bash
# Run OWASP Dependency Check via Docker
docker run --rm \
  -v $(pwd):/src \
  owasp/dependency-check \
  --scan /src \
  --format HTML \
  --out /src/report

# Report will be saved as dependency-check-report.html
```

**Jenkins Pipeline Stage:**
```groovy
stage('OWASP Dependency Check') {
    steps {
        dependencyCheck additionalArguments: '--scan ./ --format HTML', 
                        odcInstallation: 'OWASP-DC'
        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    }
}
```

---

## 🐳 Trivy

```bash
# Install Trivy on Linux (Ubuntu/Debian)
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y

# Verify installation
trivy --version

# ── Scanning Commands ──────────────────────────────────────

# Scan a Docker Hub image
trivy image nginx:latest

# Scan a locally built image
trivy image myapp:v1

# Scan and show only HIGH and CRITICAL
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan and output as JSON
trivy image --format json --output results.json nginx:latest

# Scan and output as table (default)
trivy image --format table nginx:latest

# Scan a filesystem/directory
trivy fs /path/to/project

# Scan a Git repository
trivy repo https://github.com/user/repo

# Scan Kubernetes cluster
trivy k8s --report summary cluster
```

**Jenkins Pipeline Stage:**
```groovy
stage('Trivy Image Scan') {
    steps {
        sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:latest'
        // --exit-code 1 means pipeline FAILS if vulnerabilities found
    }
}
```

---

## 🔗 Full DevSecOps Pipeline Example

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/repo.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner -Dsonar.projectKey=myapp'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./',
                                odcInstallation: 'OWASP-DC'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t myapp:latest .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL myapp:latest'
            }
        }

        stage('Deploy') {
            steps {
                echo 'All security checks passed. Deploying...'
                sh 'docker run -d -p 80:80 myapp:latest'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        failure {
            echo 'Security check failed! Fix vulnerabilities before deploying.'
        }
    }
}
```

---

## 📝 My Command Notes

<!-- Add your own commands and discoveries here as you practice -->

| Command | What it does | My Notes |
|---|---|---|
| | | |
