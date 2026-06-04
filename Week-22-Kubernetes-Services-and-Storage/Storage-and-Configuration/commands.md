# ✦ Commands & Manifests: Storage & Configuration

> **Manage State and Settings.** Learn the CLI procedures to configure namespaces, provision persistent volumes, inject ConfigMaps, and securely extract and decode secrets.

---

## ✦ 1. Namespace Management

Namespaces isolate environments inside the same cluster.

### Create & List Namespaces
```bash
# Create a new namespace
kubectl create namespace testing

# List all namespaces in the cluster
kubectl get namespaces
# or
kubectl get ns
```

### Context Namespace Switching
By default, `kubectl` queries resources in the `default` namespace. You can switch the active namespace to avoid adding `-n <namespace>` to every command:
```bash
# Switch current active context to target 'testing' namespace
kubectl config set-context --current --namespace=testing

# Verify current namespace context configuration
kubectl config view | grep namespace:
```

---

## ✦ 2. Storage Inspection (PV & PVC)

### List Storage Mappings
```bash
# List all Persistent Volumes in the cluster
kubectl get pv

# List all Persistent Volume Claims in current namespace
kubectl get pvc
# Displays: NAME, STATUS (Bound/Pending), VOLUME, CAPACITY, ACCESS MODES, AGE
```

### Inspect Details
```bash
# Describe specific volume configurations
kubectl describe pv ebs-pv

# Describe specific claim request status
kubectl describe pvc ebs-pvc
```

---

## ✦ 3. ConfigMap & Secret Operations

### Create ConfigMaps
```bash
# Create ConfigMap from command line literals
kubectl create configmap app-settings --from-literal=APP_COLOR=blue --from-literal=MAX_CPU=2

# Create ConfigMap from a local configuration properties file
kubectl create configmap app-settings --from-file=config.properties
```

### Create Secrets
```bash
# Create generic secret containing database passwords
kubectl create secret generic db-credentials --from-literal=password=SuperSecretPass123

# Create secret from certificates files
kubectl create secret generic ssl-cert --from-file=tls.crt --from-file=tls.key
```

### Get & Describe Configs
```bash
# List ConfigMaps and Secrets
kubectl get cm
kubectl get secrets

# Describe details (labels, keys, values count)
kubectl describe cm app-settings
kubectl describe secret db-credentials
```

### Decoding Secrets (Extracting values via CLI)
Secrets are base64-encoded. To read the plain text values:
```bash
# Get the base64 encrypted payload
kubectl get secret db-credentials -o yaml

# Extract and decode a specific key (e.g., password) using base64 tool
# For Linux/macOS:
kubectl get secret db-credentials -o jsonpath="{.data.password}" | base64 --decode

# For Windows (PowerShell):
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret db-credentials -o jsonpath="{.data.password}")))
```
---

## ✦ 4. Exposing ConfigMaps & Secrets to Pods
Here is a snippet showing how to inject ConfigMaps and Secrets as environment variables inside a Pod specification:

```yaml
spec:
  containers:
    - name: application
      image: app:latest
      env:
        # Load from ConfigMap
        - name: THEME_COLOR
          valueFrom:
            configMapKeyRef:
              name: app-settings
              key: APP_COLOR
        # Load from Secret
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```
