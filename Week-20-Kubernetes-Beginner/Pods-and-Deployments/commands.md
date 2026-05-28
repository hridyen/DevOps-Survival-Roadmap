# ✦ Commands & Manifests: Pods & Deployments

> **Deploy, Scale, and Rollback.** Master the `kubectl` commands needed to deploy Pods and manage the lifecycle of applications using Deployments.

---

## ✦ 1. Pod CLI Operations

### Run Ad-hoc Pod (Imperative mode)
```bash
# Spin up a fast testing Pod
kubectl run my-nginx --image=nginx:alpine

# List all pods in the active namespace
kubectl get pods

# List pods with details (IP address, Node name)
kubectl get pods -o wide
```

### Troubleshoot & Inspect Pods
```bash
# Output detailed status, events, and state history of a Pod
kubectl describe pod my-nginx

# View stdout logs of a container
kubectl logs my-nginx

# Tail/stream container logs in real time
kubectl logs -f my-nginx

# View previous logs of a crashed container (troubleshooting crashes)
kubectl config set-context --current --namespace=default
kubectl logs my-nginx --previous
```

### Accessing Pod Internals
```bash
# Execute an interactive shell session inside the container
kubectl exec -it my-nginx -- /bin/sh

# Forward traffic from host port 8080 to container port 80
kubectl port-forward my-nginx 8080:80
# Now open http://localhost:8080 in your browser to verify
```

### Delete Pods
```bash
# Delete a Pod by name
kubectl delete pod my-nginx
```

---

## ✦ 2. Deployment & Scale Operations

Deployments are managed declaratively using manifest files.

### Create & Apply Manifests
```bash
# Create resources defined in a local YAML file
kubectl create -f nginx-deployment.yaml

# Apply/Update configurations dynamically (Best Practice)
kubectl apply -f nginx-deployment.yaml
```

### Inspect Deployments
```bash
# List all deployments in active namespace
kubectl get deployments
# Output displays: NAME, READY, UP-TO-DATE, AVAILABLE, AGE

# List ReplicaSets created by deployments
kubectl get rs

# Show detailed specification of a deployment
kubectl describe deployment nginx-deployment
```

### Scale Workloads Dynamically
```bash
# Scale deployment up to 5 replicas
kubectl scale --replicas=5 deployment/nginx-deployment

# Alternatively, modify the replicas field in the yaml file and run apply:
# kubectl apply -f nginx-deployment.yaml
```

---

## ✦ 3. Deployment Rollouts & Rollbacks

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
# Terminate deployment (this deletes the deployment, ReplicaSets, and all running Pods)
kubectl delete deployment nginx-deployment
```
