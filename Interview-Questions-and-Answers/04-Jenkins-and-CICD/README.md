# ✦ Jenkins & CI/CD Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Jenkins architecture, declarative pipelines, distributed builds, webhook configurations, credentials binding, and troubleshooting.

---

## ✦ Section 1: Jenkins Architecture & Distributed Agent Nodes (Questions 1-20)

<details>
<summary><b>Q1: Scenario: Your controller node is running out of disk space due to build workspaces. How do you re-architect Jenkins to fix this permanently?</b></summary>
Shift all build execution to **distributed agent nodes**. Keep the controller node clean by setting "Number of executors" on the controller configuration to `0`, ensuring it only coordinates tasks while agents execute the work.
</details>

<details>
<summary><b>Q2: Scenario: A dynamic build agent fails to connect to the master node over SSH. How do you debug?</b></summary>
1. Check if the controller can ping the agent IP and reach port 22.
2. Verify that the SSH private key configured in Jenkins credentials corresponds to the public key in `/home/jenkins/.ssh/authorized_keys` on the agent.
3. Check the agent server `/var/log/secure` or `/var/log/auth.log` files for authentication failures.
4. Ensure Java is installed on the agent node matching the controller's Java version.
</details>

<details>
<summary><b>Q3: Scenario: How do you configure Jenkins to spawn build agents dynamically inside Docker containers only when a job is triggered?</b></summary>
Install the **Docker Plugin** in Jenkins. Go to Manage Jenkins -> Clouds -> Add a new cloud -> Docker. Configure the Docker host URI and define Docker Agent Templates specifying the image to boot, labels, and connect method.
</details>

<details>
<summary><b>Q4: Scenario: A specific job requires macOS to build an iOS app, and another requires Ubuntu for Docker builds. How does Jenkins route these?</b></summary>
Configure node labels. Tag the macOS agent with label `ios-builder` and the Ubuntu agent with `docker-builder`. In the Jenkinsfile, restrict execution using:
```groovy
agent { label 'ios-builder' }
```
</details>

<details>
<summary><b>Q5: Scenario: You want to prevent a node from taking on new build tasks immediately because you need to perform server maintenance. How?</b></summary>
Go to the Node details page and click **"Disconnect"** or **"Mark this node temporary offline"** to prevent new executors from spawning while active tasks complete.
</details>

<details>
<summary><b>Q6: Scenario: How does Jenkins Master-Agent connection protocol inbound (JNLP) differ from SSH?</b></summary>
- **SSH:** The controller acts as an SSH client and initiates the connection directly to the agent node (requires port 22 open on the agent).
- **JNLP/Inbound:** The agent initiates the connection back to the controller (useful if the agent is behind a firewall/NAT where the controller cannot reach it directly).
</details>

<details>
<summary><b>Q7: Scenario: A build agent suddenly goes offline mid-build. What happens to the running pipeline and workspaces?</b></summary>
The running pipeline fails immediately with an agent connection error. The workspace files remain on the agent disk until clean-up scripts run or a new build overwrites them.
</details>

<details>
<summary><b>Q8: Scenario: How do you configure a Jenkins controller to log in to agents without exposing plain-text credentials in the agent configuration?</b></summary>
Use Jenkins **Credentials Provider** to bind credentials. Reference them by ID in the Node configuration rather than exposing raw keys/passwords.
</details>

<details>
<summary><b>Q9: Scenario: How do you automatically scale Jenkins agents in AWS dynamically based on queue length?</b></summary>
Use the **EC2 Plugin** or **Amazon EC2 Fleet Plugin**. Configure it to spawn EC2 instances on-demand when build queue size exceeds threshold limits, and terminate them after idle timeouts.
</details>

<details>
<summary><b>Q10: Scenario: How do you check the connection logs of a disconnected agent?</b></summary>
Go to Manage Jenkins -> Nodes -> Click agent name -> Click **"Log"** in the sidebar.
</details>

<details>
<summary><b>Q11: Scenario: You need to specify a custom workspace directory for an agent. Where is this configured?</b></summary>
In the Node configuration page, set the **"Remote root directory"** field (e.g. `/home/jenkins/workspace`).
</details>

<details>
<summary><b>Q12: Scenario: What Java version is required to run Jenkins 2.440+?</b></summary>
Java 11 or Java 17.
</details>

<details>
<summary><b>Q13: Scenario: How do you limit the maximum number of concurrent builds a single agent node can execute?</b></summary>
Configure the **"Number of executors"** parameter in the Node configuration.
</details>

<details>
<summary><b>Q14: Scenario: You want to run a Jenkins agent inside a firewall with outbound HTTPS access only. How do you connect it?</b></summary>
Configure connection via WebSocket protocol using inbound agent options.
</details>

<details>
<summary><b>Q15: Scenario: How do you backup your entire Jenkins configuration settings, plugins, and job metadata without backing up workspaces?</b></summary>
Backup `JENKINS_HOME` but exclude `**/workspace/*` and `**/caches/*`. Focus on copying all XML files, `secrets/` directory, and `plugins/` directory.
</details>

<details>
<summary><b>Q16: Scenario: How do you set up agent nodes to automatically restart their connection agent daemon if the server reboots?</b></summary>
Configure the agent startup command as a systemd service daemon (`/etc/systemd/system/jenkins-agent.service`) on the agent server.
</details>

<details>
<summary><b>Q17: Scenario: A user reports that build logs contain gibberish time stamps. How do you fix this?</b></summary>
Install the **Timestamper Plugin** and enable it in the pipeline settings.
</details>

<details>
<summary><b>Q18: Scenario: How do you configure global environment variables that are shared across all agent nodes?</b></summary>
Configure in Manage Jenkins -> System -> Global Properties -> Environment Variables.
</details>

<details>
<summary><b>Q19: Scenario: How do you update a Jenkins plugin safely without breaking active jobs?</b></summary>
1. Check compatibility notes.
2. Go to Manage Jenkins -> Plugins.
3. Select update and choose "Install without restart" or schedule a restart during a maintenance window using `/safeRestart`.
</details>

<details>
<summary><b>Q20: Scenario: What is the default home directory path of Jenkins on a standard Linux installation?</b></summary>
`/var/lib/jenkins`.
</details>

---

## ✦ Section 2: Declarative vs. Scripted Pipelines (Questions 21-40)

<details>
<summary><b>Q21: Scenario: What is the structural difference between Declarative and Scripted pipelines?</b></summary>
- **Declarative:** Uses strict, structured block syntax (`pipeline { agent any; stages { ... } }`). Easier to read, offers built-in syntax checks, and enforces strict standards.
- **Scripted:** Uses Groovy-based code (`node { stage { ... } }`). Highly flexible, supports standard programming loops, try/catch logic, and direct class executions, but harder to maintain.
</details>

<details>
<summary><b>Q22: Scenario: You want to run step "Test" and step "Lint" in parallel to save time. How do you write this in a Declarative pipeline?</b></summary>
```groovy
stage('Parallel Stages') {
    parallel {
        stage('Test') {
            steps { sh 'npm test' }
        }
        stage('Lint') {
            steps { sh 'npm run lint' }
        }
    }
}
```
</details>

<details>
<summary><b>Q23: Scenario: How do you execute clean-up tasks (like purging docker workspaces) regardless of whether the build succeeded or failed?</b></summary>
Use the `post` block with the `always` condition:
```groovy
post {
    always {
        cleanWs()
    }
}
```
</details>

<details>
<summary><b>Q24: Scenario: You want to run a pipeline step only if the branch being built is `main`. How?</b></summary>
Use the `when` condition:
```groovy
stage('Deploy') {
    when {
        branch 'main'
    }
    steps {
        echo 'Deploying...'
    }
}
```
</details>

<details>
<summary><b>Q25: Scenario: How do you ask for manual administrator approval before executing a production deployment stage?</b></summary>
Use the `input` step:
```groovy
stage('Approval') {
    steps {
        input message: 'Approve production deployment?', submitter: 'admin-group'
    }
}
```
</details>

<details>
<summary><b>Q26: Scenario: How do you set a timeout limit of 10 minutes on a specific stage so it doesn't hang indefinitely?</b></summary>
Use options block in stage:
```groovy
options {
    timeout(time: 10, unit: 'MINUTES')
}
```
</details>

<details>
<summary><b>Q27: Scenario: You need to inject environment variables dynamically inside a step using Groovy scripts. How?</b></summary>
Use the `script` block to run scripted pipeline syntax within declarative steps:
```groovy
steps {
    script {
        env.MY_VAR = 'dynamic_value'
    }
}
```
</details>

<details>
<summary><b>Q28: Scenario: How do you configure a pipeline to retry a failing step up to 3 times before throwing an error?</b></summary>
Use the `retry` wrapper:
```groovy
steps {
    retry(3) {
        sh './flaky-script.sh'
    }
}
```
</details>

<details>
<summary><b>Q29: Scenario: How do you read a parameter value named `ENVIRONMENT` selected by the user at trigger time?</b></summary>
Access it via the `params` map:
```groovy
steps {
    echo "Deploying to ${params.ENVIRONMENT}"
}
```
</details>

<details>
<summary><b>Q30: Scenario: How do you reference and load shared libraries globally in a Jenkinsfile?</b></summary>
Reference it at the top of the file:
```groovy
@Library('my-shared-library') _
```
</details>

<details>
<summary><b>Q31: Scenario: You want to run steps only if a parameter `RUN_TESTS` is set to true. How?</b></summary>
Use the `expression` block in `when`:
```groovy
when {
    expression { return params.RUN_TESTS == true }
}
```
</details>

<details>
<summary><b>Q32: Scenario: How do you define build options like keeping only the last 10 build histories?</b></summary>
Add `options` block:
```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
}
```
</details>

<details>
<summary><b>Q33: Scenario: How do you handle errors in Scripted pipeline?</b></summary>
Use Groovy `try-catch-finally` block:
```groovy
try {
    sh './run.sh'
} catch(Exception e) {
    echo "Failed: ${e}"
}
```
</details>

<details>
<summary><b>Q34: Scenario: How do you check out a Git repository manually inside a pipeline step?</b></summary>
Use the `checkout` step:
```groovy
checkout scmGit(branches: [[name: '*/main']], userRemoteConfigs: [[url: 'git@github.com:user/repo.git']])
```
</details>

<details>
<summary><b>Q35: Scenario: You want to run a pipeline inside a specific docker container image `node:20-alpine`. How?</b></summary>
Configure `agent` with `docker`:
```groovy
agent {
    docker { image 'node:20-alpine' }
}
```
</details>

<details>
<summary><b>Q36: Scenario: How do you print the current build number and job name inside a pipeline log message?</b></summary>
Use global env variables:
```groovy
echo "Running ${env.JOB_NAME} build number ${env.BUILD_ID}"
```
</details>

<details>
<summary><b>Q37: Scenario: How do you trigger another Jenkins job `downstream-job` automatically after this pipeline completes successfully?</b></summary>
Use build step in `post`:
```groovy
post {
    success {
        build 'downstream-job'
    }
}
```
</details>

<details>
<summary><b>Q38: Scenario: How do you archive build artifacts (like a target `/build/*.war` file) so they can be downloaded from the Jenkins UI?</b></summary>
Use the `archiveArtifacts` step:
```groovy
steps {
    archiveArtifacts artifacts: 'build/*.war', followSymlinks: false
}
```
</details>

<details>
<summary><b>Q39: Scenario: How do you configure slack notifications when a build fails?</b></summary>
Use the `slackSend` plugin:
```groovy
post {
    failure {
        slackSend channel: '#alerts', message: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
    }
}
```
</details>

<details>
<summary><b>Q40: Scenario: What is the utility of the `tools` directive in a declarative pipeline?</b></summary>
It automatically installs and adds specific tools (e.g., Maven, JDK, Gradle) to the execution path:
```groovy
tools {
    maven 'maven-3.9.0'
}
```
</details>

---

## ✦ Section 3: Credentials Security & Integrations (Questions 41-60)

<details>
<summary><b>Q41: Scenario: You need to authenticate a pipeline with Docker Hub to push an image. How do you inject credentials securely without exposing the password in console logs?</b></summary>
Use the `withCredentials` block:
```groovy
withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
    sh "docker login -u $DOCKER_USER -p $DOCKER_PASS"
}
```
Jenkins automatically masks the values of `$DOCKER_PASS` with asterisks (`****`) in output logs.
</details>

<details>
<summary><b>Q42: Scenario: How do you authenticate Jenkins to pull code from a private GitHub repository over SSH?</b></summary>
1. Generate an SSH keypair on your local machine.
2. Add the public key to GitHub Repository Settings -> Deploy Keys.
3. Save the private key in Jenkins Credentials under type "SSH Username with private key".
4. Reference the credential ID in your Jenkins job.
</details>

<details>
<summary><b>Q43: Scenario: Where does Jenkins store sensitive credentials on disk? Is it secure?</b></summary>
It stores them encrypted in XML files under `$JENKINS_HOME/credentials.xml`. It uses master secrets located in `$JENKINS_HOME/secrets/` (AES keys) to encrypt the credentials, so they are secure unless an attacker gains read access to the master secrets on the host.
</details>

<details>
<summary><b>Q44: Scenario: You want to use a secret file (like an AWS credentials file or Kubeconfig) in your pipeline step. What credential type?</b></summary>
Save it as a "Secret file" in Jenkins Credentials, and bind it in the pipeline:
```groovy
withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')]) {
    sh "kubectl --kubeconfig=$KUBECONFIG get pods"
}
```
</details>

<details>
<summary><b>Q45: Scenario: A developer needs to access a private API key, but they are not allowed to view the plain-text credentials in Jenkins UI. How does Jenkins handle this?</b></summary>
Jenkins restricts viewing of credentials. Once created, only administrators or designated roles can see the metadata/edit it; no user can retrieve the raw plain-text secret from the UI.
</details>

<details>
<summary><b>Q46: Scenario: How do you restrict a specific set of credentials so they can only be used by a specific folder or pipeline job?</b></summary>
Scope credentials to a specific **Folder** or configure **Role-Based Access Control (RBAC)** folders instead of creating them in the Global domain store.
</details>

<details>
<summary><b>Q47: Scenario: You want to use AWS credentials to provision infrastructure in a pipeline. What is the recommended plugin to handle roles dynamically?</b></summary>
Use the **Pipeline AWS Steps Plugin** and execute commands within `withAWS` block, or configure IAM roles directly on the AWS EC2 build agent node.
</details>

<details>
<summary><b>Q48: Scenario: How do you configure credentials using a secret vault like HashiCorp Vault instead of saving them in Jenkins database?</b></summary>
Install the **HashiCorp Vault Plugin**. Configure connection details in Jenkins settings. Retrieve secrets dynamically in the pipeline:
```groovy
withVault(vaultSecrets: [[path: 'secret/db', engineVersion: 1, secretValues: [[envVar: 'DB_PASS', vaultKey: 'password']]]]) { ... }
```
</details>

<details>
<summary><b>Q49: Scenario: How do you set up an API Token for a Jenkins user so they can trigger jobs via HTTP requests instead of using their UI password?</b></summary>
Go to User Profile -> Configure -> API Token -> Generate new token.
</details>

<details>
<summary><b>Q50: Scenario: What is the danger of printing credentials variables in steps using `echo`? How does Jenkins mitigate this?</b></summary>
Printing it will expose it to console logs. Jenkins monitors variables marked as credentials and masks them with `****`. However, you should still avoid writing scripts that print them explicitly (e.g. `echo $SECRET`).
</details>

<details>
<summary><b>Q51: Scenario: You want to configure Jenkins to authenticate users using GitHub OAuth (Single Sign-On). What plugin?</b></summary>
Use the **GitHub Authentication Plugin**.
</details>

<details>
<summary><b>Q52: Scenario: How do you limit permission access in Jenkins using roles?</b></summary>
Install the **Role-based Authorization Strategy Plugin**. Define Global, Item, and Agent roles, and assign users to specific roles.
</details>

<details>
<summary><b>Q53: Scenario: How do you retrieve a secret string (like a token) directly into a variable in a declarative pipeline?</b></summary>
Use credentials binding:
```groovy
environment {
    API_TOKEN = credentials('my-api-token-id')
}
```
</details>

<details>
<summary><b>Q54: Scenario: What is the utility of the SSH Agent Plugin?</b></summary>
It allows key-based SSH operations without storing the private key on the agent node filesystem:
```groovy
sshagent(['my-ssh-key-id']) {
    sh 'ssh user@host "run-command"'
}
```
</details>

<details>
<summary><b>Q55: Scenario: How do you rotate a leaked credential safely without modifying the Jenkinsfile of 50 projects?</b></summary>
Simply update the credential values in Manage Jenkins -> Credentials. Since Jenkinsfiles reference the credential by its stable `credentialsId` string, the change applies automatically.
</details>

<details>
<summary><b>Q56: Scenario: How do you check auditing logs to see who deleted a Jenkins job?</b></summary>
Install the **Audit Trail Plugin** and check the logs located in `/var/log/jenkins/audit.log` or the system configure log.
</details>

<details>
<summary><b>Q57: Scenario: What configuration setting protects Jenkins against Cross-Site Request Forgery (CSRF) exploits?</b></summary>
The **CSRF Protection** (enabled by default using Crumbs).
</details>

<details>
<summary><b>Q58: Scenario: How do you configure Jenkins to authenticate against a corporate Active Directory?</b></summary>
Install the **Active Directory Plugin** and configure LDAP/Domain settings.
</details>

<details>
<summary><b>Q59: Scenario: Can you run credentials injection inside steps running in parallel?</b></summary>
Yes, each parallel branch has its own env bindings.
</details>

<details>
<summary><b>Q60: Scenario: How do you test if Jenkins credential encryption keys are intact?</b></summary>
Verify if you can create and read credentials successfully, and ensure `$JENKINS_HOME/secrets/master.key` exists.
</details>

---

## ✦ Section 4: Webhooks & Triggering Automations (Questions 61-80)

<details>
<summary><b>Q61: Scenario: A developer pushes code to GitHub, but the Jenkins pipeline does not start automatically. What do you check?</b></summary>
1. Verify if the webhook is configured in GitHub Repository Settings -> Webhooks pointing to `http://<jenkins_IP>:8080/github-webhook/`.
2. Check the webhook status code in GitHub (should be 200 OK).
3. Ensure the Jenkins job has "GitHub hook trigger for GITScm polling" enabled.
4. Ensure Jenkins is accessible from the internet or GitHub IPs are allowed through the firewall.
</details>

<details>
<summary><b>Q62: Scenario: You want to trigger a pipeline only when a pull request is created or updated in GitHub. What plugin?</b></summary>
Use the **GitHub Pull Request Builder Plugin** or **Generic Webhook Trigger Plugin**.
</details>

<details>
<summary><b>Q63: Scenario: How do you configure a pipeline to run automatically every Sunday at 4 AM?</b></summary>
Add a cron trigger to the pipeline configuration:
```groovy
triggers {
    cron('0 4 * * 0')
}
```
</details>

<details>
<summary><b>Q64: Scenario: You want to trigger a build when files in a specific directory `/src` are modified, but ignore changes in documentation files. How?</b></summary>
Use the **Poll SCM** trigger with inclusion/exclusion filters in Git configuration.
</details>

<details>
<summary><b>Q65: Scenario: How do you configure Jenkins to trigger a build whenever another build finishes executing?</b></summary>
Use the "Build other projects" post-build action or `build` pipeline step.
</details>

<details>
<summary><b>Q66: Scenario: What HTTP method does GitHub use to trigger Jenkins webhooks?</b></summary>
POST method.
</details>

<details>
<summary><b>Q67: Scenario: How do you secure webhooks so that only payload events originating from GitHub are accepted by Jenkins?</b></summary>
Configure a **Secret Token** in GitHub Webhook configurations and match it in the Jenkins webhook trigger security settings.
</details>

<details>
<summary><b>Q68: Scenario: You want to poll SCM history for changes every 15 minutes. What is the cron expression?</b></summary>
```text
H/15 * * * *
```
(Using `H` spreads the system load instead of running exactly at minute 0/15/30).
</details>

<details>
<summary><b>Q69: Scenario: How do you check SCM polling logs to see why a job was triggered?</b></summary>
Go to the Job page and click **"Git Polling Log"** in the sidebar.
</details>

<details>
<summary><b>Q70: Scenario: How do you disable SCM triggers dynamically when system load is high?</b></summary>
Go to Manage Jenkins -> System -> set SCM Polling threads to a lower limit, or disable SCM polling in individual job configurations.
</details>

<details>
<summary><b>Q71: Scenario: You want to trigger a build when a new tag is pushed. How do you configure SCM?</b></summary>
In Git SCM configuration, set the branch specifier to `refs/tags/*`.
</details>

<details>
<summary><b>Q72: Scenario: How do you parse GitHub webhook payload parameters (e.g., commit author email) inside your pipeline?</b></summary>
Use the **Generic Webhook Trigger Plugin** and define JSONPath expressions to map payload keys to environment variables.
</details>

<details>
<summary><b>Q73: Scenario: What is quiet period in Jenkins and when do you configure it?</b></summary>
Quiet period is a delay buffer (in seconds) between trigger time and execution start (e.g. `quietPeriod(10)`). Useful to wait for multiple consecutive commits to finish before starting a single build.
</details>

<details>
<summary><b>Q74: Scenario: How do you trigger a Jenkins pipeline using curl from the command line?</b></summary>
Run:
```bash
curl -X POST http://USER:TOKEN@JENKINS_URL/job/JOB_NAME/build
```
</details>

<details>
<summary><b>Q75: Scenario: How do you trigger a parameterized job passing variables via API?</b></summary>
Run:
```bash
curl -X POST http://USER:TOKEN@JENKINS_URL/job/JOB_NAME/buildWithParameters?env=prod
```
</details>

<details>
<summary><b>Q76: Scenario: How do you configure a pipeline trigger based on Gitlab push events?</b></summary>
Install the **GitLab Plugin** and configure the webhook pointing to `http://<jenkins_IP>:8080/project/<job_name>`.
</details>

<details>
<summary><b>Q77: Scenario: What happens if a webhook is triggered while a job is already running?</b></summary>
Jenkins places the new build request in the execution queue. If the job configuration allows concurrent builds, it starts immediately on another executor.
</details>

<details>
<summary><b>Q78: Scenario: How do you block concurrent builds on a pipeline?</b></summary>
Configure job options:
```groovy
options {
    disableConcurrentBuilds()
}
```
</details>

<details>
<summary><b>Q79: Scenario: How do you view webhook trigger diagnostics logs in Jenkins?</b></summary>
Create a new log recorder for `org.jenkinsci.plugins.github` or check the general system logs.
</details>

<details>
<summary><b>Q80: Scenario: Can you configure webhooks on multi-branch pipelines?</b></summary>
Yes, the webhook notifies the multibranch index controller, which scans SCM and launches builds on the specific branch that received the commit.
</details>

---

## ✦ Section 5: Troubleshooting, Failure Recovery & Optimization (Questions 81-100)

<details>
<summary><b>Q81: Scenario: A pipeline build hangs on a step indefinitely. How do you find which step is blocking the build and terminate it?</b></summary>
1. Check the console log of the build.
2. Go to **"Thread Dump"** in Jenkins UI or use **Pipeline Steps** view to see the blocked thread.
3. Terminate it by clicking the red cross button in the UI, or run `Jenkins.instance.getItemByFullName('job_name').getBuildByNumber(num).finish(hudson.model.Result.ABORTED, new java.io.IOException('Aborted by admin'))` in Script Console.
</details>

<details>
<summary><b>Q82: Scenario: How do you debug Groovy sandbox security errors in Jenkinsfiles?</b></summary>
Go to Manage Jenkins -> In-process Script Approval. Approve the specific method calls or signatures blocked by the sandbox.
</details>

<details>
<summary><b>Q83: Scenario: A build fails with "No space left on device" on the agent node. How do you automate disk space cleanups?</b></summary>
1. Add `cleanWs()` step at the end of every pipeline build.
2. Use the **Workspace Cleanup Plugin**.
3. Schedule cron jobs to run `docker system prune` on agents if they use docker executor environments.
</details>

<details>
<summary><b>Q84: Scenario: How do you verify the configuration syntax of a Jenkinsfile locally before committing it to Git?</b></summary>
Use the Jenkins CLI validator tool or use curl to post the file to the Jenkins validation endpoint:
```bash
curl -X POST -F "jenkinsfile=<Jenkinsfile" http://JENKINS_URL/pipeline-model-converter/validate
```
</details>

<details>
<summary><b>Q85: Scenario: You accidentally deleted the admin password. How do you disable security temporarily to recover access?</b></summary>
1. Open `$JENKINS_HOME/config.xml` on the host.
2. Change `<useSecurity>true</useSecurity>` to `<useSecurity>false</useSecurity>`.
3. Restart Jenkins daemon. Reset password, then re-enable security from the UI.
</details>

<details>
<summary><b>Q86: Scenario: How do you execute Groovy scripts directly on the Jenkins engine to perform bulk administration tasks?</b></summary>
Go to Manage Jenkins -> **Script Console**.
</details>

<details>
<summary><b>Q87: Scenario: A pipeline fails with "PermGen space" or "Java heap space" errors. How do you increase memory allocations?</b></summary>
Modify the JVM memory parameters (e.g. `-Xmx2g -Xms512m`) in `/etc/default/jenkins` or the systemd environment configurations.
</details>

<details>
<summary><b>Q88: Scenario: You want to replay a failed build, modifying the pipeline code temporarily on the fly without making git commits. How?</b></summary>
Go to the Build details page in Jenkins UI and click **"Replay"** in the sidebar. Edit the code and run.
</details>

<details>
<summary><b>Q89: Scenario: How do you view system logs of the Jenkins master server daemon?</b></summary>
On Linux, run:
```bash
sudo journalctl -u jenkins -n 100 -f
```
Or check `/var/log/jenkins/jenkins.log`.
</details>

<details>
<summary><b>Q90: Scenario: A build fails because a plugin has updated and behaves differently. How do you downgrade the plugin?</b></summary>
Go to Manage Jenkins -> Plugins -> Installed. Search for the plugin and click "Downgrade" or upload the legacy `.hpi` file manually.
</details>

<details>
<summary><b>Q91: Scenario: How do you monitor Jenkins load averages and thread states?</b></summary>
Go to Manage Jenkins -> System Information to check system resources, or check the dashboard load statistics.
</details>

<details>
<summary><b>Q92: Scenario: How do you safely restart Jenkins waiting for all running builds to finish?</b></summary>
Navigate to `http://JENKINS_URL/safeRestart` in your browser, or execute `safeRestart` via Jenkins CLI.
</details>

<details>
<summary><b>Q93: Scenario: How do you restore a deleted job?</b></summary>
If you have a backup of the `$JENKINS_HOME/jobs/` directory, restore the job folder, and click "Reload Configuration from Disk" in Manage Jenkins.
</details>

<details>
<summary><b>Q94: Scenario: A build agent is slow. How do you check its system resource details?</b></summary>
Go to Node details -> System Info.
</details>

<details>
<summary><b>Q95: Scenario: You see multiple executor slots blocked by zombie processes. How do you clear them without restarting Jenkins?</b></summary>
Run the script console to clear executor threads:
```groovy
Jenkins.instance.computers.each { computer ->
    computer.executors.each { executor ->
        if (executor.isBusy()) { executor.interrupt() }
    }
}
```
</details>

<details>
<summary><b>Q96: Scenario: How do you configure Jenkins to alert administrators when disk space on nodes drops below 1GB?</b></summary>
Configure in Manage Jenkins -> Nodes -> Configure Monitor Thresholds.
</details>

<details>
<summary><b>Q97: Scenario: What happens if the `config.xml` file is corrupted?</b></summary>
Jenkins fails to load configurations and reverts to setup wizard mode. Restore config from a backup.
</details>

<details>
<summary><b>Q98: Scenario: How do you check the network traffic details processed by Jenkins?</b></summary>
Configure custom log recorders for HTTP connections under Manage Jenkins -> System Logs.
</details>

<details>
<summary><b>Q99: Scenario: A pipeline stage fails with "command not found" error, but the tool is installed on the agent. What is wrong?</b></summary>
The tool's binary folder is not on the system `PATH` of the running Jenkins agent user. Define the path variables explicitly in the pipeline or agent configuration.
</details>

<details>
<summary><b>Q100: Scenario: How do you force Jenkins to reload configuration modifications done directly on config XML files on disk?</b></summary>
Go to Manage Jenkins -> Click **"Reload Configuration from Disk"**.
</details>
