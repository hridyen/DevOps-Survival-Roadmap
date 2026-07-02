# ✦ Commands & Manifests: Namespaces & Resource Management

> **Expose and Control.** Step-by-step commands to administer namespaces, set compute resource requests and limits, inspect metrics, configure health probes, and debug OOMKilled containers.

---

## ✦ 1. Namespace Administration

Namespaces separate environments, teams, or tenants inside a single cluster.

### View Namespaces
```bash
# List all namespaces in the cluster
kubectl get namespaces

# Short abbreviation
kubectl get ns

# Describe a namespace's metadata and resource budgets
kubectl describe ns dev
```

### Create Namespaces
```bash
# Imperative creation
kubectl create namespace dev

# Declarative creation (YAML definition)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOF
```

### Context Isolation
Set a default namespace for your active terminal session so you do not have to write `-n <namespace>` with every command:
```bash
# Set default namespace to 'dev' for current context
kubectl config set-context --current --namespace=dev

# Verify current namespace context mapping
kubectl config view --minify | grep namespace
```

### Deleting Namespaces
```bash
# WARNING: Cascades and deletes every single resource within the namespace!
kubectl delete ns dev
```

---

## ✦ 2. Configured Resource Quotas & Limits

### Resource Request & Limit Manifest (Pod Spec)
Create a file named `pod-resource-demo.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server-resources
  namespace: dev
spec:
  containers:
    - name: web
      image: nginx:alpine
      resources:
        requests:
          cpu: "250m"      # Reserved CPU (1/4 of a core)
          memory: "128Mi"  # Reserved Memory
        limits:
          cpu: "500m"      # Maximum allowable CPU speed ceiling
          memory: "256Mi"  # Absolute Memory limit ceiling
```
```bash
# Apply manifest
kubectl apply -f pod-resource-demo.yaml
```

### Set Resources Imperatively on Deployments
```bash
# Modify resource allocations for an active deployment
kubectl set resources deployment/my-deployment \
  -n dev \
  --requests=cpu=250m,memory=128Mi \
  --limits=cpu=500m,memory=256Mi
```

### Live Performance Monitoring (Requires metrics-server)
```bash
# Get live resource consumption for all Pods in the current namespace
kubectl top pods

# Get live resource consumption for all nodes
kubectl top nodes

# Get consumption metrics for a specific pod's containers
kubectl top pod web-server-resources -n dev --containers
```

---

## ✦ 3. Health Probe Configuration Examples

Create a file named `health-probes-demo.yaml` with Startup, Readiness, and Liveness probes defined:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: health-probes-demo
  namespace: dev
spec:
  containers:
    - name: app-server
      image: nginx:alpine
      ports:
        - containerPort: 80
      # 1. Startup Probe: Blocks other probes until container finishes initialization
      startupProbe:
        httpGet:
          path: /index.html
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5
        failureThreshold: 10   # Will wait up to 50 seconds (10 attempts * 5s) before failing
      # 2. Liveness Probe: Monitors for application deadlock/crashes
      livenessProbe:
        httpGet:
          path: /index.html
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 15
        timeoutSeconds: 2
        failureThreshold: 3    # Triggers restart if it fails 3 consecutive times
      # 3. Readiness Probe: Checks if app can accept HTTP traffic
      readinessProbe:
        httpGet:
          path: /index.html
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 10
        successThreshold: 1    # Needs 1 success to be marked ready
        failureThreshold: 2    # Removes from Service endpoints on 2 consecutive failures
```
```bash
# Apply probe configurations
kubectl apply -f health-probes-demo.yaml
```

### Inspecting Probe Failures
```bash
# Watch container restarts
kubectl get pods -n dev -w

# Describe Pod to see failing health checks in Events section
kubectl describe pod health-probes-demo -n dev
```

---

## ✦ 4. Diagnosing Out-of-Memory (OOM) and Scheduling Failures

If your Pods are crashlooping or stuck, use these diagnostic loops:

### Scenario A: Pod Is Stuck `Pending` (Scheduling Failure)
```bash
# Describe Pod state
kubectl describe pod <pod-name>

# Check the bottom 'Events' block. Look for:
# "FailedScheduling: 0/3 nodes are available: 3 Insufficient memory."
# This means your requests block is set larger than any single node's allocatable space.
```

### Scenario B: Container Keep Restarting / Status `OOMKilled`
```bash
# Get details of the last container restart reason
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}'

# Expected output: OOMKilled
# (Exit Code 137: Process terminated by kernel because it exceeded cgroups memory limits)
```

---

## ✦ 5. Complete Practical Lab (Namespace & Resource Check)

Copy-paste these commands to run a complete isolation lab:

```bash
# 1. Spin up a separate dev namespace
kubectl create ns dev-lab

# 2. Deploy a web pod inside the dev namespace with CPU/Memory bounds
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: isolated-web
  namespace: dev-lab
spec:
  containers:
    - name: nginx
      image: nginx:alpine
      resources:
        requests:
          cpu: 100m
          memory: 64Mi
        limits:
          cpu: 200m
          memory: 128Mi
EOF

# 3. Verify the pod exists inside dev-lab
kubectl get pods -n dev-lab

# 4. Attempt to query it from default namespace (should return empty unless using -n flag)
kubectl get pods

# 5. Check allocated resources on your node
kubectl describe nodes | grep -A 10 "Allocated resources"

# 6. Cleanup the lab (deletes namespace and the pod recursively)
kubectl delete ns dev-lab
```
