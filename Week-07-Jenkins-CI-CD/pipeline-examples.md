# ⚡ ⚙️ Week 07 — Jenkins Pipeline Examples

---

## ✦ 📋 Example 1: Basic Pipeline (Hello World)

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello from Jenkins Pipeline!'
                sh 'whoami'
                sh 'pwd'
            }
        }
    }
}
```

---

## ✦ 📋 Example 2: Build, Test, Deploy Pipeline

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/youruser/yourrepo.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'chmod +x build.sh && ./build.sh'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'chmod +x test.sh && ./test.sh'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to server...'
                sh 'chmod +x deploy.sh && ./deploy.sh'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs!'
        }
    }
}
```

---

## ✦ 📋 Example 3: Pipeline with Docker Build & Push

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "yourdockerhubuser/myapp"
        IMAGE_TAG = "v${BUILD_NUMBER}"
        DOCKER_CREDS = credentials('dockerhub-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/youruser/yourrepo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh "docker login -u $DOCKER_CREDS_USR -p $DOCKER_CREDS_PSW"
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy') {
            steps {
                sh "docker run -d -p 80:80 --name myapp ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
```

---

## ✦ 📋 Example 4: Pipeline on Specific Agent

```groovy
pipeline {
    agent {
        label 'build-agent-01'    // Run on agent named 'build-agent-01'
    }

    stages {
        stage('Check Agent') {
            steps {
                sh 'hostname'
                sh 'uname -a'
            }
        }

        stage('Build') {
            steps {
                echo "Building on agent: ${env.NODE_NAME}"
                sh 'echo Build complete'
            }
        }
    }
}
```

---

## ✦ 📋 Example 5: Parallel Stages

```groovy
pipeline {
    agent any

    stages {
        stage('Test in Parallel') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        echo 'Running unit tests...'
                        sh './run-unit-tests.sh'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        echo 'Running integration tests...'
                        sh './run-integration-tests.sh'
                    }
                }
            }
        }
    }
}
```

---

## ✦ 📋 Example 6: Pipeline with Input (Manual Approval)

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Build complete.'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Deploy to production?', ok: 'Yes, deploy!'
            }
        }

        stage('Deploy to Production') {
            steps {
                echo 'Deploying to production...'
            }
        }
    }
}
```

---

## ✦ 📋 Example Jenkinsfile (used in my project)

> This is the Jenkinsfile I placed in the root of my Git repo instead of writing the pipeline in the Jenkins UI.

```groovy
pipeline {
    agent any

    environment {
        APP_PORT = "8080"
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm    // Automatically uses the repo configured in Jenkins job
            }
        }

        stage('Build') {
            steps {
                echo "Building application on port ${APP_PORT}..."
                sh 'docker build -t myapp:latest .'
            }
        }

        stage('Run') {
            steps {
                sh "docker run -d -p ${APP_PORT}:80 --name myapp myapp:latest"
                echo "Application running at port ${APP_PORT}"
            }
        }
    }

    post {
        success {
            echo "✅ Success! App is live."
        }
        failure {
            echo "❌ Build failed. Check logs above."
        }
        always {
            echo "Pipeline finished."
        }
    }
}
```

---

## ✦ 📝 My Pipeline Notes

<!-- Add your own pipeline snippets here as you write them -->

```groovy
// Add your pipeline here
```
