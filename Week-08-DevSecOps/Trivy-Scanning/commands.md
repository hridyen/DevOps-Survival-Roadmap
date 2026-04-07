[![Sector](https://img.shields.io/badge/SECTOR-DevSecOps-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Trivy_Scanning_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Image Analytics — Commands Reference

---

## ✦ 🛡️ OWASP Operations

```bash
# Force Docker runtime evaluation natively mapped
docker run --rm \
  -v $(pwd):/src \
  owasp/dependency-check \
  --scan /src \
  --format HTML \
  --out /src/report
```

---

## ✦ 🐳 Trivy Analytics

```bash
# Standard Output Lookups
trivy image nginx:latest                             # Full terminal visual print
trivy image --severity HIGH,CRITICAL nginx:latest    # Strict filtering ignoring mild flags
trivy fs /path/to/project                            # Deep raw filesystem evaluation internally

# Pipeline CI Blockers
trivy image --exit-code 1 myapp:v1                   # Instructs Jenkins to automatically fail the pipeline execution!
```

---

## ✦ 📜 Jenkinsfile Injector Declarations

```groovy
stage('OWASP Engine Evaluation') {
    steps {
        dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'OWASP-DC'
    }
}

stage('Trivy Image Scan') {
    steps {
        sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:latest'
    }
}
```

---

## ✦ 📝 My Structural Integration Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `--exit-code 1` | Instructs the Trivy CLI to return an explicit exit code failure metric natively upon encountering Critical CVEs. | Blocking explicitly gracefully dynamically a compromised Docker artifact from deploying seamlessly into Amazon ECS natively! |
