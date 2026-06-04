# ✦ Commands & Manifests: Services & Networking

> **Expose and Route.** Step-by-step commands to expose deployments internally and externally, inspect endpoints, and configure HTTP path-based ingress rules.

---

## ✦ 1. Exposing Workloads (Imperative Service Creation)

You can create services quickly from running deployments using `kubectl expose`.

### Create ClusterIP Service (Internal Only)
```bash
# Expose deployment on port 80 (creates ClusterIP by default)
kubectl expose deployment nginx-deployment --name=nginx-internal-svc --port=80
```

### Create NodePort Service (External Access via Node IP)
```bash
# Expose deployment on a static node port
kubectl expose deployment nginx-deployment --name=nginx-nodeport-svc --type=NodePort --port=80
```

### Expose with specific ports (via CLI helper)
```bash
# Create service nodeport specifying protocol and targetPort
kubectl create service nodeport nginx-svc --tcp=80:80 --node-port=30008
```

---

## ✦ 2. Inspecting Services & Endpoints

### List Services
```bash
# List all services in current namespace
kubectl get services

# Short abbreviation
kubectl get svc

# Get services with target selectors
kubectl get svc -o wide
```

### List Endpoints (Target Pod IPs mapped to services)
```bash
# View list of dynamic Pod IPs currently attached to services
kubectl get endpoints

# Short abbreviation
kubectl get ep
```

### Describe Service Specifications
```bash
# Show detailed mappings (IPs, Ports, Session Affinity)
kubectl describe svc nginx-nodeport-svc
```

---

## ✦ 3. Managing Ingress & Ingress Controllers

Ingress requires an Ingress Controller running in the cluster.

### Setup Ingress Controller on Minikube
```bash
# Enable the Nginx Ingress Controller addon
minikube addons enable ingress

# Verify the ingress controller pods are running in ingress-nginx namespace
kubectl get pods -n ingress-nginx
```

### Setup Ingress Controller on Kind
To use Ingress in a Kind cluster, the cluster must be created with port mapping configurations. If configured, you can apply the ingress controller using:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### Apply and Inspect Ingress Rules
```bash
# Apply ingress YAML manifest
kubectl apply -f ingress-rules.yaml

# List configured ingress resources
kubectl get ingress

# Get detailed info, including backend paths and SSL configurations
kubectl describe ingress main-ingress
```

### Test Ingress Local Routing
Add the host definitions to your local `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
```text
# Replace with your local cluster node IP address
192.168.49.2 app.example.com
```
Now perform a request using curl:
```bash
curl http://app.example.com/web
curl http://app.example.com/api
```
