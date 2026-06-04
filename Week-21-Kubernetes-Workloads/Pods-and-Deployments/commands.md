# ✦ Commands & Manifests: Pods & Deployments

> **Deploy, Scale, and Rollback.** Master the `kubectl` commands needed to deploy Pods, manage Deployments, inspect ReplicaSets, and verify Kubernetes self-healing and scaling behaviors.

---

## ✦ 1. Pod CLI Operations (Imperative Mode)

Pods can be run directly for quick developer testing and debugging.

### Run Ad-hoc Pod
```bash
# Spin up a fast testing Nginx Pod
kubectl run nginx --image=nginx

# List all pods in the active namespace
kubectl get pods

# List pods with details (IP address, Node name)
kubectl get pods -o wide
```

### Inspect and Troubleshoot Pods
```bash
# Output detailed status, lifecycle events, and state history of a Pod
kubectl describe pod nginx

# View stdout logs of a container
kubectl logs nginx

# Tail/stream container logs in real time
kubectl logs -f nginx

# View previous logs of a crashed container (for troubleshooting CrashLoopBackOff)
kubectl logs nginx --previous
```

### Accessing Pod Internals
```bash
# Execute an interactive shell session inside the container
kubectl exec -it nginx -- bash

# Forward traffic from host port 8080 to container port 80
kubectl port-forward nginx 8080:80
```

### Delete Pods
```bash
# Delete a Pod by name
kubectl delete pod nginx
```

---

## ✦ 2. Managing Deployments & ReplicaSets

Deployments manage ReplicaSets, which in turn manage the Pod lifecycles.

### Creating a Deployment
```bash
# Create a managed Deployment (Imperative)
kubectl create deployment nginx-deploy --image=nginx

# Verify all layers of the hierarchy
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

### Deploying Declaratively (Best Practice)
Use a manifest file (`nginx-deployment.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: web
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.21.6
          ports:
            - containerPort: 80
```

Apply this manifest using:
```bash
# Create or update resources declaratively
kubectl apply -f nginx-deployment.yaml
```

---

## ✦ 3. Scaling & Self-Healing Demonstrations

### Scaling a Deployment
```bash
# Scale the deployment up to 3 replicas
kubectl scale deployment nginx-deploy --replicas=3

# Verify the count of pods and replicasets
kubectl get pods
kubectl get replicasets
```

### Demonstrate Self-Healing Loop
If a pod crashes or is deleted, the **ReplicaSet** notices the discrepancy between desired and actual state and spawns a replacement instantly.

```bash
# 1. Start watching pods in real time in a terminal window:
kubectl get pods -w

# 2. In another terminal, delete one of the replicas manually:
kubectl delete pod <crashed-pod-name>

# 3. Observe the watch output:
# The deleted pod goes into "Terminating".
# Simultaneously, a new pod is immediately created, going from "Pending" -> "ContainerCreating" -> "Running".
```

---

## ✦ 4. Deployment Rollouts & Rollbacks

Kubernetes tracks release history. If you update the container image or configurations, a rollout starts.

### Update Deployment Image
```bash
# Update the container image of a deployment directly via CLI
kubectl set image deployment/nginx-deployment nginx=nginx:1.21.6
```

### Check Rollout Status
```bash
# Check the progress of a rolling update
kubectl rollout status deployment/nginx-deployment
```

### Track Release History
```bash
# View list of revisions/deployments made
kubectl rollout history deployment/nginx-deployment

# Check the details of a specific historical revision (e.g., revision 2)
kubectl rollout history deployment/nginx-deployment --revision=2
```

### Rollback (Undo Rollouts)
```bash
# Rollback to the immediately previous revision
kubectl rollout undo deployment/nginx-deployment

# Rollback to a specific historical revision number (e.g., revision 1)
kubectl rollout undo deployment/nginx-deployment --to-revision=1
```

### Delete Deployments
```bash
# Terminate deployment (deletes the deployment, ReplicaSets, and all running Pods)
kubectl delete deployment nginx-deployment
```
