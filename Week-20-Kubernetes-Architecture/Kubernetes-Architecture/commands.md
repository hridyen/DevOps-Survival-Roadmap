# ✦ Commands & Setup: Kubernetes Architecture

> **Bootstrap and Inspect.** Learn how to install a local Kubernetes playground using Kind (Kubernetes in Docker) or Minikube, configure `kubectl` context, and verify Control Plane component health.

---

## ✦ 1. Installing a Local Kubernetes Playground (Kind)

**Kind (Kubernetes in Docker)** is a tool for running local Kubernetes clusters using Docker container "nodes". It is the primary tool specified in the **Kubernetes Complete Study Guide**.

### Prerequisites
- OS: Windows + WSL2 (e.g. Ubuntu 24.04 LTS)
- Docker Desktop integrated with WSL2
- Hardware: 16 Cores, 15 GB RAM recommended

### Kind Installation & Cluster Creation
```bash
# Verify Docker is running
docker --version

# Install Kind (on Linux/WSL2)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify Kind version
kind version

# Create your first cluster
kind create cluster --name dev-cluster
```

---

## ✦ 2. Alternative Setup: Minikube & Kubeadm

### Minikube (Single-Node Dev Cluster)
```powershell
# Windows (via winget)
winget install Kubernetes.minikube

# Start cluster using Docker driver
minikube start --driver=docker

# Check status
minikube status
```

### Kubeadm (Production Bootstrapping)
```bash
# Initialize Control Plane with a custom pod network CIDR (run on Master)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join a worker node (run on Worker Nodes)
kubeadm join <control-plane-host>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

---

## ✦ 3. Inspecting Your First Cluster

Once the cluster is running, use `kubectl` (v1.36.1 or similar client) to inspect its state and components.

### Verify Cluster and client info
```bash
# Get client and server versions
kubectl version --client

# Get Control Plane services addresses
kubectl cluster-info
```

### Inspect Cluster Nodes
```bash
# List all nodes in the cluster
kubectl get nodes

# Show node details with IP, OS, kernel, container runtime
kubectl get nodes -o wide

# Detailed internal state of a specific node
kubectl describe node dev-cluster-control-plane
```

### Inspect All Core Components (What You Will See)
```bash
# Inspect all resources in all namespaces
kubectl get all -A
```

| Component | Namespace | Purpose |
|---|---|---|
| **CoreDNS** | `kube-system` | DNS service registry for internal service names to IPs. |
| **ETCD** | `kube-system` | Distributed, key-value cluster state database. |
| **kube-apiserver** | `kube-system` | Front door gateway API entry point. |
| **kube-scheduler** | `kube-system` | Pod placement decisions evaluator. |
| **kube-controller-manager** | `kube-system` | Loop controllers (Node, ReplicaSet, etc.). |
| **kube-proxy** | `kube-system` | Network rules manager per node. |
| **kindnet** | `kube-system` | Pod-to-Pod CNI networking overlay. |
| **local-path-provisioner** | `local-path-storage` | Dynamic storage volume provisioning. |

---

## ✦ 4. Managing CLI Contexts & Configurations

Contexts link a cluster, a namespace, and an authenticated user credential.

```bash
# View current active config file
kubectl config view

# List all available contexts
kubectl config get-contexts

# Print the active context
kubectl config current-context

# Switch to a different context
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
