# ✦ Commands & Setup: Kubernetes Architecture

> **Bootstrap and Inspect.** Learn how to install a local Kubernetes playground using Minikube, configure `kubectl` context, and verify Control Plane component health.

---

## ✦ 1. Installing a Local Kubernetes Playground (Minikube)

Minikube is a lightweight Kubernetes implementation that runs a local single-node cluster inside a VM or container.

### For Windows (via PowerShell / winget)
```powershell
# Install Minikube using Winget
winget install Kubernetes.minikube

# Start the cluster using Docker as driver
minikube start --driver=docker

# Check status of the local cluster
minikube status
```

### For Linux (Debian/Ubuntu)
```bash
# Download the latest Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start
```

---

## ✦ 2. Basic Cluster Bootstrapping with `kubeadm` (Enterprise-grade)

For production multi-node clusters, `kubeadm` is the official tool for cluster setup.

### Initialize Control Plane (Control Plane Node Only)
```bash
# Initialize control plane with custom pod network CIDR (flannel example)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Join Worker Node (Run on Worker Nodes Only)
```bash
# Join a worker node using token from kubeadm init output
kubeadm join <control-plane-host>:<control-plane-port> --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash>
```

---

## ✦ 3. Inspecting the Cluster

Use `kubectl` (Kubernetes Command Line Tool) to inspect the control plane.

### Verify Cluster and CLI Versions
```bash
# Get client and server versions
kubectl version --short
```

### Verify Cluster Info & Component Status
```bash
# Get Control Plane services addresses
kubectl cluster-info

# Check health of core Control Plane components
kubectl get componentstatuses    # Deprecated but useful in older configurations
```

### Inspect Cluster Nodes
```bash
# List all nodes in the cluster
kubectl get nodes

# Show node details with IP, OS, kernel, container runtime
kubectl get nodes -o wide

# Detailed internal state of a specific node
kubectl describe node <node-name>
```

---

## ✦ 4. Managing CLI Contexts & Configurations

Contexts link a cluster, a namespace, and an authenticated user credential.

### Get Config Details
```bash
# View current active config file
kubectl config view

# List all available contexts
kubectl config get-contexts

# Print the active context
kubectl config current-context
```

### Switch Contexts
```bash
# Switch to a different cluster context
kubectl config use-context <context-name>
```

---

## ✦ 5. Exploring Supported APIs
```bash
# List all resource types supported by the cluster API
kubectl api-resources

# List api-versions supported by the server
kubectl api-versions
```
