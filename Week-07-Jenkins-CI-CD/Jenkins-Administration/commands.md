[![Sector](https://img.shields.io/badge/SECTOR-Jenkins_CI_CD-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Jenkins_Administration_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Jenkins Administration Commands

## ✦ 1. CLI Access (jenkins-cli.jar)

Jenkins provides a CLI jar that allows you to manage the server from your terminal.

### ✦ Authentication & Connectivity
```bash
# Download the CLI jar from your server
wget http://<JENKINS_URL>/jnlpJars/jenkins-cli.jar

# Safe Restart
java -jar jenkins-cli.jar -s http://<JENKINS_URL>/ safe-restart

# List all plugins
java -jar jenkins-cli.jar -s http://<JENKINS_URL>/ list-plugins
```

---

## ✦ 2. System Level Management

### ✦ Service Control (Linux)
```bash
# Restart Jenkins service
sudo systemctl restart jenkins

# Check service status
sudo systemctl status jenkins
```

### ✦ Groovy Script Console
For extreme administration, use the Groovy script console (UI-based but script-driven).
```groovy
// Example: Clear build queue
Jenkins.instance.queue.clear()

// Example: Force unlock a build
Jenkins.instance.getItemByFullName("job_name").getBuildByNumber(123).finish(
    hudson.model.Result.ABORTED, new java.io.IOException("Aborting build")
);
```

---

## ✦ 3. Backup & Persistence

### ✦ Home Directory Backup
```bash
# Archive the Jenkins Home directory (excluding workspace)
tar -cvzf jenkins_home_backup.tar.gz /var/lib/jenkins --exclude=/var/lib/jenkins/workspace
```
