# ⚡ Week 09 — Dynamic Jenkins Pipelines Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on Dynamic Jenkins Pipelines, Shared Libraries, Monorepo Pipelines, and Groovy execution.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You have a monorepo containing 15 microservices. Running the entire CI/CD pipeline on every commit is slow and expensive. How do you design a dynamic Jenkins pipeline that only builds, tests, and deploys the microservices that actually changed?</b></summary>
<b>Answer:</b>
To implement path-aware delta detection in a declarative Jenkins pipeline:
1. **Detect Changes:** Use a Git diff command (e.g., `git diff --name-only HEAD~1 HEAD`) in a setup stage to identify which files changed.
2. **Dynamic Stage Generation:** Write a helper utility or use a shared library to map the modified paths to specific microservice directories.
3. **Map and Parallelize:** Generate a map of closures dynamically in a script block. Key the map by microservice name, and let the value be the build logic.
4. **Execute:** Run the generated map using the `parallel` step.
```groovy
stage('Dynamic Microservice Build') {
    steps {
        script {
            def changedServices = getChangedServices() // Custom method parsing git diff
            def builds = [:]
            
            for (service in changedServices) {
                def serviceName = service // Avoid Groovy closure loop-variable trap
                builds[serviceName] = {
                    node('docker-agent') {
                        stage("Build ${serviceName}") {
                            sh "cd ${serviceName} && npm install && npm run build"
                        }
                    }
                }
            }
            if (builds) {
                parallel builds
            } else {
                echo "No services changed. Skipping builds."
            }
        }
    }
}
```
</details>

<details>
<summary><b>Q2: Scenario: Your Jenkins pipeline suddenly crashes with a `java.io.NotSerializableException`. What causes this in scripted or declarative pipelines, and how do you resolve it?</b></summary>
<b>Answer:</b>
Jenkins uses CPS (Continuation Passing Style) transformation to allow pipelines to be paused and resumed across controller restarts. Because of this, all variables stored in memory must be serializable (implementing `java.io.Serializable`).
- **Causes:** Instantiating non-serializable objects (such as `java.util.regex.Matcher`, `groovy.json.JsonSlurper`, `java.io.File`, or XML/YAML parsing objects) as local variables within a stage.
- **Remedies:**
  1. **Use `@NonCPS`:** Annotate the helper methods containing non-serializable logic with `@NonCPS`. This tells Jenkins not to transform the method, but you cannot call any pipeline steps (like `sh`, `echo`) inside it.
  2. **Limit Variable Scope:** Wrap the creation and usage of non-serializable objects in a separate function or local block, and immediately set them to `null` or let them go out of scope before any pipeline steps are called.
  3. **Data Serialization:** Parse configurations using `readJSON` or `readYaml` steps provided by the Pipeline Utility Steps plugin, which are safely implemented under the hood.
</details>

<details>
<summary><b>Q3: Scenario: An organization has dozens of pipelines using copy-pasted Groovy utility methods. You need to standardize these methods and share them securely. How do you implement and version Jenkins Shared Libraries?</b></summary>
<b>Answer:</b>
1. **Repository Structure:** Create a dedicated Git repository with the following structure:
   - `src/` (standard Groovy classes for object-oriented logic)
   - `vars/` (global variables/custom steps, e.g., `buildApp.groovy` exposing a `call` method)
   - `resources/` (non-Java/Groovy helper files like YAML templates)
2. **Configuration:** Add the shared library in Jenkins Global Settings (`Manage Jenkins > System > Global Pipeline Libraries`). Provide it a name, retrieve it from the Git repo, and enable default loading.
3. **Strict Versioning:** Do NOT use the `master`/`main` branch directly in production pipelines. Load it with tags or specific commit hashes:
   ```groovy
   @Library('my-shared-library@v1.2.0') _
   ```
4. **Execution:** Inside the pipeline, call the custom steps as native steps:
   ```groovy
   buildApp(serviceName: 'frontend', version: '2.0')
   ```
</details>

<details>
<summary><b>Q4: Scenario: When running parallel stages dynamically on a shared build agent, you run out of disk space due to overlapping node workspaces. How do you mitigate workspace bloat dynamically?</b></summary>
<b>Answer:</b>
1. **Dynamic Workspace Paths:** Use the `ws` step to allocate a unique, folder-specific workspace path for each branch or dynamic execution loop, rather than letting it fall back to the default workspace folder.
   ```groovy
   ws("workspace/project-build-${env.BUILD_NUMBER}-${serviceName}") {
       // build steps here
   }
   ```
2. **Post-Build Cleanup:** Always clean up workspace artifacts immediately after execution completes using the Workspace Cleanup Plugin (`cleanWs()`) in a `finally` block or post-build actions.
3. **Artifact Archiving:** Instead of keeping files on disk, archive critical binaries using `archiveArtifacts` or push them directly to Artifactory/S3, then purge the local workspace.
</details>

<details>
<summary><b>Q5: Scenario: You want to trigger a pipeline only when changes are made to a specific directory (e.g. `src/`) and ignore commits to `docs/` or `README.md`. How do you configure this?</b></summary>
<b>Answer:</b>
1. **With Git Plugin (Declarative):** Use the `changelog` or `polling` options within the checkout setup.
2. **With Multibranch Pipelines:** In the branch source configuration under Jenkins UI, add a behavior called **"Filter by name (with wildcards)"** or **"Path filtering"** (using the *Path-aware pull requests* plugin).
3. **Pipeline Level Scripting:** Query the change sets dynamically using `currentBuild.changeSets`:
   ```groovy
   @NonCPS
   boolean shouldTriggerBuild() {
       for (changeSet in currentBuild.changeSets) {
           for (entry in changeSet.entries) {
               for (path in entry.affectedPaths) {
                   if (path.startsWith("src/")) {
                       return true
                   }
               }
           }
       }
       return false
   }
   ```
</details>

<details>
<summary><b>Q6: Scenario: How do you prevent third-party scripts or credentials from leaking sensitive data to the console logs in dynamic pipelines where build arguments are built at runtime?</b></summary>
<b>Answer:</b>
1. **Use Credentials Binding:** Never print credentials or pass them directly as raw environment variables. Always wrap execution inside a `withCredentials` block.
   ```groovy
   withCredentials([string(credentialsId: 'my-secret-token', variable: 'SECRET_TOKEN')]) {
       // Jenkins will automatically mask this variable (replacing it with ****) in console outputs
       sh 'curl -H "Authorization: Bearer $SECRET_TOKEN" https://api.service.com'
   }
   ```
2. **Shell Execution Safety:** Use single quotes `'` instead of double quotes `"` in shell steps when accessing credentials. Double quotes evaluate the variable in Groovy before executing, potentially exposing values, while single quotes pass it safely as an OS environment variable.
3. **Script Security Sandbox:** Ensure the **"Use Groovy Sandbox"** option is enabled in pipeline script windows. This prevents pipelines from calling raw Java system methods (like `System.exit()`) or reading sensitive local files on the Jenkins controller.
</details>

<details>
<summary><b>Q7: Scenario: Your Jenkins controller restarted due to maintenance while several multi-stage pipelines were running. How do you configure and debug resume logic so that the pipelines resume where they left off without restarting from scratch?</b></summary>
<b>Answer:</b>
1. **Declarative Pipeline Resuming:** By default, Jenkins Declarative Pipelines are structured to automatically resume from the last completed stage if a controller crash occurs, provided they run on persistent agent node allocations.
2. **Agent Setup:** Use persistent agents (SSH/JNLP) with consistent workspaces, rather than dynamic Kubernetes pods or temporary Docker containers which disappear during controller downtime.
3. **Preserving Variables:** Do not rely on local variables defined at the root of a script block. Store states in files or use `stash`/`unstash` steps to preserve intermediate build outputs.
4. **Disable Resume for Specific Runs:** If resuming is dangerous (e.g. deployments), disable it at the pipeline options level:
   ```groovy
   options {
       disableResume()
   }
   ```
</details>

<details>
<summary><b>Q8: Scenario: You are running 10 test stages in parallel. If one test stage fails, you do not want it to instantly abort the remaining 9 tests. How do you handle exceptions in dynamic stages?</b></summary>
<b>Answer:</b>
1. **Using `catchError`:** Wrap stage execution blocks inside a `catchError` block. This allows the stage to fail, sets the stage status to `FAILURE`, but keeps the pipeline build status as `SUCCESS` or `UNSTABLE` while continuing execution.
   ```groovy
   catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
       sh 'run-flaky-tests.sh'
   }
   ```
2. **Using `warnError`:** Marks the stage as unstable and displays a warning, but continues execution.
3. **Standard Try-Catch:** Wrap the execution in standard Groovy `try/catch` block within a script. Save the error to a list and process it at the end to determine if the pipeline should fail.
</details>

<details>
<summary><b>Q9: Scenario: Your pipeline builds both iOS applications (which require macOS nodes) and Docker images (which require Linux nodes). How do you dynamically route steps to the correct agent node?</b></summary>
<b>Answer:</b>
In declarative pipelines, assign the agent dynamically by specifying labels or parameters inside the `agent` section:
1. **Direct Stage Level Agents:** Set the agent at the `stage` level instead of the global pipeline level.
   ```groovy
   pipeline {
       agent none // No global agent
       stages {
           stage('Build iOS App') {
               agent { label 'macos-node' }
               steps {
                   sh 'xcodebuild ...'
               }
           }
           stage('Build Docker Image') {
               agent { label 'linux-node' }
               steps {
                   sh 'docker build ...'
               }
           }
       }
   }
   ```
2. **Dynamic Scripted Agent Binding:** In scripted blocks, use nested `node('label')` calls.
</details>

<details>
<summary><b>Q10: Scenario: How do you dynamically trigger a downstream pipeline, pass parameters, and block the execution of the upstream pipeline until the downstream pipeline completes successfully?</b></summary>
<b>Answer:</b>
Use the `build` step with the parameter `wait: true` (which is true by default) and pass parameters as a list:
```groovy
stage('Trigger Microservices Deployment') {
    steps {
        script {
            def downstreamResult = build(
                job: 'Deploy-Production-Service',
                parameters: [
                    string(name: 'SERVICE_NAME', value: 'auth-api'),
                    string(name: 'IMAGE_TAG', value: env.BUILD_NUMBER)
                ],
                propagate: true, // Propagates downstream failures up to this pipeline
                wait: true
            )
            echo "Downstream Job completed with status: ${downstreamResult.result}"
        }
    }
}
```
If `propagate: false` is set, the upstream job will continue running regardless of whether the downstream job fails, and you can handle the status manually using `downstreamResult.result`.
</details>
