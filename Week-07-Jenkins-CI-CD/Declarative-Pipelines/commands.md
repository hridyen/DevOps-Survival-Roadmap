[![Sector](https://img.shields.io/badge/SECTOR-Jenkins_CI_CD-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Declarative_Pipelines_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Declarative Pipeline Reference

## ✦ 1. Pipeline Syntax Blocks

### ✦ Agent Management
```groovy
pipeline {
    agent any // Run on any available executor
    
    // or specify a label
    agent { label 'node-1' }
}
```

### ✦ Stage Structure
```groovy
stages {
    stage('Build') {
        steps {
            echo 'Building application...'
            sh 'npm install'
        }
    }
}
```

---

## ✦ 2. Post-Execution Actions

### ✦ Conditionals
```groovy
post {
    always {
        echo 'Cleaning up workspace...'
        cleanWs()
    }
    success {
        echo 'Deployment successful!'
    }
    failure {
        echo 'Build failed. Sending notification...'
    }
}
```

---

## ✦ 3. Pipeline Troubleshooting

### ✦ Replay Feature
While not a command, "Replay" is the most powerful tool for debugging pipelines without committing code changes. It allows you to edit the `Jenkinsfile` logic directly in the UI for a single run.

### ✦ Environment Variables
```groovy
steps {
    sh 'printenv' // Lists all variables available to the pipeline
    echo "Current Build Number: ${env.BUILD_NUMBER}"
}
```
