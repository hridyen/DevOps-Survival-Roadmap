# ✦ Kubernetes Orchestration Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Kubernetes architecture, Control Plane vs Worker Node components, Pods, ReplicaSets, Deployments, Services, Ingress, storage subsystems (PV, PVC, ConfigMaps, Secrets), security (RBAC, Network Policies), troubleshooting, and advanced autoscaling strategies.

---

## ✦ Section 1: Kubernetes Architecture & Core Components (Questions 1-20)

<details>
<summary><b>Q1: Scenario: Your Kubernetes cluster is experiencing a massive spike in API requests. How does the API Server scale to handle this load, and how does its stateless design facilitate this?</b></summary>
<b>Answer:</b>
The `kube-apiserver` is designed to be completely stateless. It processes requests, validates them, and writes the state data directly to the `etcd` distributed backing store. Because it does not store any state locally:
1. **Horizontal Scaling:** You can scale the API Server horizontally by running multiple instances behind an external layer-4 or layer-7 load balancer.
2. **Database Decoupling:** Any API Server instance can process any client request, as long as it has access to the shared `etcd` database.
3. **API Priority and Fairness (APF):** You can configure APF to classify and prioritize incoming requests, preventing a surge in lower-priority read requests from starving critical system controllers.
</details>

<details>
<summary><b>Q2: Scenario: An etcd cluster of 3 nodes loses 2 nodes due to a network partition. Explain what happens to the cluster state, whether write operations are accepted, and how consensus is maintained.</b></summary>
<b>Answer:</b>
1. **Loss of Quorum:** An `etcd` cluster uses the **Raft consensus algorithm**, which requires a majority quorum of active nodes to perform write operations. The formula for quorum is `(N/2) + 1`. For a 3-node cluster, the quorum is `(3/2) + 1 = 2` nodes.
2. **Write Invalidation:** Since only 1 node is active, quorum is lost. The remaining node will reject all write operations (e.g. creating pods, scaling deployments) to prevent split-brain state inconsistencies.
3. **Read Operation Behavior:** Depending on the configuration, read requests may still be served as stale, but write operations are blocked until at least one of the offline nodes rejoins the cluster, restoring quorum.
</details>

<details>
<summary><b>Q3: Scenario: You want to ensure that memory-intensive database Pods are only scheduled on worker nodes equipped with high-speed SSDs. How do you configure the scheduler to achieve this?</b></summary>
<b>Answer:</b>
You use a combination of **Node Labels**, **Node Affinity**, or **NodeSelectors**:
1. **Label the Nodes:** Label the SSD-equipped worker nodes:
   ```bash
   kubectl label nodes worker-node-1 disktype=ssd
   ```
2. **Configure Pod Spec:** In the Pod manifest spec, define a `nodeSelector` or `nodeAffinity` constraint:
   ```yaml
   spec:
     nodeSelector:
       disktype: ssd
   ```
   Or use a flexible `nodeAffinity` block under the scheduler directives:
   ```yaml
   affinity:
     nodeAffinity:
       requiredDuringSchedulingIgnoredDuringExecution:
         nodeSelectorTerms:
         - matchExpressions:
           - key: disktype
             operator: In
             values:
             - ssd
   ```
</details>

<details>
<summary><b>Q4: Scenario: A worker node hosting 10 critical application Pods loses network connection to the Master node. What does the Node Controller do, and how does the eviction timeout process unfold?</b></summary>
<b>Answer:</b>
1. **Heartbeat Check:** The `kubelet` on each node reports health via leases. If a node stops responding, its lease expires.
2. **Node Status Update:** The Node Controller inside the `kube-controller-manager` waits for the node health check grace period (default 40s) and marks the node status as `NotReady` or `Unknown`.
3. **Eviction Grace Period:** The controller waits for the default eviction timeout (configured by `--pod-eviction-timeout`, typically 5 minutes).
4. **Rescheduling:** Once the timeout expires, the controller schedules replacement Pods on active, healthy nodes, while marking the old pods on the partitioned node for deletion (to be cleaned up once the partitioned node reconnects).
</details>

<details>
<summary><b>Q5: Scenario: You create a Service of type LoadBalancer. Explain how the Service Controller inside the controller-manager interacts with AWS to provision an ELB/NLB.</b></summary>
<b>Answer:</b>
1. **API Trigger:** When you create a Service of type `LoadBalancer`, the API Server registers the object.
2. **Cloud Provider Loop:** The Service Controller (or Cloud Controller Manager) detects the new service.
3. **Cloud Resource Provisioning:** It executes AWS API calls using credentials provided to the control plane, creating a Classic Load Balancer (ELB) or Network Load Balancer (NLB) in the target VPC.
4. **Target Group Association:** The controller registers the public IP addresses of the cluster's worker nodes (or Pod IPs if using AWS VPC CNI with IP target mode) to the load balancer’s target group on the designated NodePort.
5. **Status Update:** The external DNS address/IP is updated in the Service metadata status block, making it visible in `kubectl get svc`.
</details>

<details>
<summary><b>Q6: Scenario: A developer complains that their Pod cannot start due to an ImagePullBackOff error. Describe how the Kubelet on the worker node handles this failure and logs it.</b></summary>
<b>Answer:</b>
1. **Scheduling & Pulling:** The Scheduler assigns the Pod to the node. The node's `kubelet` reads the PodSpec and calls the **Container Runtime Interface (CRI)** to pull the container image.
2. **Auth / Path Error:** If the registry credentials are invalid, the image tag does not exist, or the path is incorrect, the pull fails.
3. **BackOff Delay:** The `kubelet` enters a sleep loop called `ImagePullBackOff`. It will retry pulling the image, exponentially increasing the wait delay (10s, 20s, 40s, up to a limit of 5 minutes).
4. **Status Logging:** The `kubelet` updates the Pod status to `ErrImagePull` and then `ImagePullBackOff`. You check these events by running `kubectl describe pod <name>` and checking the "Events" section.
</details>

<details>
<summary><b>Q7: Scenario: Your cluster has grown to 500 services and 10,000 pods. The network latency is high. Why is `kube-proxy` configured in IPVS mode superior to default iptables mode for this scale?</b></summary>
<b>Answer:</b>
1. **Lookups Complexity:** 
   - **iptables:** Operates using a linear search list. Every packet is evaluated against firewall rules sequentially. With 500 services, lookup time increases to $O(N)$, causing high CPU utilization on nodes during traffic spikes.
   - **IPVS (IP Virtual Server):** Uses hash tables which provide $O(1)$ constant-time lookup performance, regardless of the number of rules.
   - **Performance:** IPVS dramatically reduces CPU overhead, supports more load-balancing algorithms (least connection, weighted round-robin), and schedules connections faster.
</details>

<details>
<summary><b>Q8: Scenario: The API Server is down and you cannot run `kubectl` commands. How do you check the logs of Control Plane components (like scheduler/controller-manager) on a master node bootstrapped with kubeadm?</b></summary>
<b>Answer:</b>
Since the API Server is down, `kubectl logs` will fail. You must access the master node terminal directly:
1. **Static Pod Logs:** Control Plane components run as **Static Pods** managed directly by the local `kubelet` daemon.
2. **Container Logs:** Check the logs of the running container directly using the container engine runtime CLI:
   ```bash
   crictl ps | grep kube-apiserver
   crictl logs <container-id>
   ```
3. **System Logs:** If the container engine is also failing, check the OS logs for the `kubelet` daemon:
   ```bash
   journalctl -u kubelet -n 100 --no-pager
   ```
</details>

<details>
<summary><b>Q9: Scenario: What are Static Pods? How do you configure a worker node to launch a specific container automatically without the API Server's involvement?</b></summary>
<b>Answer:</b>
1. **Definition:** **Static Pods** are managed directly by the `kubelet` daemon on a specific node, bypassing the API Server.
2. **Configuration:** 
   - On the node, locate the `kubelet` configuration file (usually `/var/lib/kubelet/config.yaml`).
   - Find the `staticPodPath` setting (e.g., `/etc/kubernetes/manifests`).
   - Place a standard Pod YAML manifest in that directory.
3. **Lifecycle:** The `kubelet` watches this folder and starts/stops the Pod automatically based on file updates. The API Server will display a read-only mirror Pod, but cannot manage or delete it.
</details>

<details>
<summary><b>Q10: Scenario: A rogue application script runs in a loop calling the API Server to create and delete namespaces, causing CPU starvation on the Control Plane. How does API Priority and Fairness (APF) prevent cluster collapse?</b></summary>
<b>Answer:</b>
1. **Request Classification:** APF classifies incoming requests based on HTTP parameters (who, what, which namespace) into distinct **Flows**.
2. **Flow Schemas & Priority Levels:** It groups flows into **Priority Levels** (e.g. `leader-election`, `system`, `workload-high`, `catch-all`).
3. **Queue Management:** Each priority level has a queue size limit. If the rogue script floods requests, its flow is assigned to a lower-priority queue. Once that queue is full, the API Server drops/throttles requests with HTTP status code `429 Too Many Requests`, protecting system threads.
</details>

<details>
<summary><b>Q11: Scenario: You are tasked with migrating a cluster container runtime from legacy Docker Engine to containerd. What are the key architectural changes regarding CRI?</b></summary>
<b>Answer:</b>
1. **Removal of Dockershim:** Kubernetes deprecated and removed `dockershim` (the translation bridge between Kubernetes and Docker Engine).
2. **Direct CRI:** `containerd` is a CNCF graduate container runtime that natively supports the Container Runtime Interface (CRI) without a translation layer.
3. **Process Flow:** Switching to `containerd` reduces hop latency:
   - *Legacy:* `kubelet` -> `dockershim` -> `docker-daemon` -> `containerd` -> `runc` -> container.
   - *containerd:* `kubelet` -> `containerd` -> `runc` -> container.
4. **Configuration:** You update the kubelet arguments: `--container-runtime-endpoint=unix:///run/containerd/containerd.sock`.
</details>

<details>
<summary><b>Q12: Scenario: You need to perform a patch upgrade of a production Kubernetes cluster using `kubeadm` with zero downtime for applications. What is the correct node upgrading sequence?</b></summary>
<b>Answer:</b>
1. **Upgrade Control Plane first:**
   - Upgrade `kubeadm` on the master node.
   - Run `kubeadm upgrade plan` and `kubeadm upgrade apply v1.x.x`.
   - Upgrade the `kubelet` and `kubectl` on the master node, then restart the service.
2. **Upgrade Worker Nodes sequentially (one by one):**
   - **Drain the Node:** Safely evict running Pods to other nodes:
     ```bash
     kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data
     ```
   - Upgrade `kubeadm` and run `kubeadm upgrade node` on the target worker node.
   - Upgrade `kubelet` and restart it.
   - **Uncordon the Node:** Allow scheduling of new Pods:
     ```bash
     kubectl uncordon worker-node-1
     ```
</details>

<details>
<summary><b>Q13: Scenario: How do you perform a backup and restore of an etcd cluster in a self-hosted Kubernetes control plane?</b></summary>
<b>Answer:</b>
1. **Backup:** Run `etcdctl snapshot save` passing the TLS credentials:
   ```bash
   ETCDCTL_API=3 etcdctl \
     --endpoints=https://127.0.0.1:2379 \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key \
     snapshot save /tmp/etcd-backup.db
   ```
2. **Restore:** Run `etcdctl snapshot restore` defining a new data directory:
   ```bash
   ETCDCTL_API=3 etcdctl \
     --data-dir=/var/lib/etcd-restore \
     snapshot restore /tmp/etcd-backup.db
   ```
3. **Apply:** Update the etcd static pod manifest (`/etc/kubernetes/manifests/etcd.yaml`) to point the volume hostPath to `/var/lib/etcd-restore`, restarting the component.
</details>

<details>
<summary><b>Q14: Scenario: You are setting up a Multi-Master High Availability (HA) cluster. How do you design the networking path for worker nodes to communicate with the API Server?</b></summary>
<b>Answer:</b>
1. **External Load Balancer:** Set up a TCP layer-4 load balancer (like HAProxy or AWS NLB) in front of the master nodes.
2. **Port Configuration:** Configure the load balancer to listen on port `6443` and route traffic to the IP addresses of all master nodes on port `6443`.
3. **Kubeconfig Target:** Configure the `kubeconfig` on all worker nodes to use the IP/FQDN of the load balancer as the server endpoint:
   ```yaml
   server: https://lb.k8s.example.com:6443
   ```
4. **Resilience:** If one master node crashes, the load balancer redirects node heartbeats to the remaining control plane nodes.
</details>

<details>
<summary><b>Q15: Scenario: A worker node's root disk partition fills up to 90%. How does the Kubelet react to this disk pressure, and what is its eviction process?</b></summary>
<b>Answer:</b>
1. **Threshold Trigger:** The `kubelet` detects that disk utilization has crossed the default eviction threshold (e.g. `imageGCHighThresholdPercent: 85%` or `nodefs.available < 10%`).
2. **Garbage Collection (Stage 1):** The `kubelet` attempts to free up disk space by deleting unused container images and terminated containers.
3. **Eviction (Stage 2):** If disk pressure remains, the `kubelet` transitions node status to `DiskPressure` and begins evicting active Pods:
   - It targets Pods without resource requests, then Pods exceeding resource requests.
   - Evicted pods are terminated and rescheduled on other healthy nodes in the cluster.
</details>

<details>
<summary><b>Q16: Scenario: A network partition occurs, isolating the Control Plane master nodes from the Worker Nodes. The applications running on the worker nodes are serving live traffic. What happens to the running workloads during this partition?</b></summary>
<b>Answer:</b>
1. **Workloads Continue:** The running containers on the worker nodes will continue to execute and serve traffic because container runtimes (`containerd` / `runc`) run independently of the Control Plane.
2. **Status Loss:** The Control Plane will mark the nodes as `Unknown` after the timeout. It will not receive status updates.
3. **No Scheduling Changes:** If a container crashes, the local `kubelet` will attempt to restart it. However, if a node crashes, the Control Plane cannot reschedule the pods elsewhere until the network partition is resolved.
4. **Blocked Updates:** No new manifests (deployments, configmaps) can be applied.
</details>

<details>
<summary><b>Q17: Scenario: You run `kubectl get pods` and see a pod stuck in `ContainerCreating` for over 15 minutes. What are the first 3 troubleshooting steps you take?</b></summary>
<b>Answer:</b>
1. **Run `kubectl describe pod <pod-name>`:** Scroll to the bottom and check the "Events" section. Look for mounting errors, network interface limits, or security restrictions.
2. **Verify Storage Attachment:** If the Pod uses a PersistentVolume (PV), check if the previous node released the volume attachment (`VolumeAttachment` object) so it can bind to the new node.
3. **Verify IP Allocation (CNI):** Check if the Container Network Interface (CNI) has run out of IP addresses in the subnet to allocate to the new Pod.
</details>

<details>
<summary><b>Q18: Scenario: You need to lock down access to the API Server port 6443. How do you secure Control Plane traffic?</b></summary>
<b>Answer:</b>
1. **Enable TLS Bootstrapping:** Ensure all node-to-master communications enforce mutual TLS (mTLS) with client certificates signed by the cluster CA.
2. **Network Security Groups:** Restrict inbound traffic to port `6443` on the master nodes to only allow source IPs from within the cluster's VPC subnet, worker nodes, and administrative bastion hosts.
3. **Restrict Anonymous Access:** Disable anonymous access by ensuring the `--anonymous-auth=false` flag is set on the `kube-apiserver`.
</details>

<details>
<summary><b>Q19: Scenario: How does the Kubelet determine the amount of CPU and Memory resources it can allocate to Pods on a worker node? Explain the components of Allocatable space.</b></summary>
<b>Answer:</b>
The Kubelet calculates allocatable space using the following formula:
$$\text{Allocatable} = \text{Capacity} - \text{Kube-Reserved} - \text{System-Reserved} - \text{Eviction-Threshold}$$
Where:
- **Capacity:** Total physical memory and CPU available on the server.
- **Kube-Reserved:** Resources reserved for Kubernetes system daemons (`kubelet`, `containerd`).
- **System-Reserved:** Resources reserved for OS daemons (sshd, systemd, journald).
- **Eviction-Threshold:** Hard eviction margins (e.g. 100Mi of memory) kept to prevent kernel lockups.
Only this final **Allocatable** resource pool is available for Pod scheduling.
</details>

<details>
<summary><b>Q20: Scenario: You need to modify a custom resource definition (CRD) in a production cluster. How does Kubernetes manage API groups and version deprecations?</b></summary>
<b>Answer:</b>
1. **API Groups:** K8s API paths are categorized into groups (e.g. `apps`, `networking.k8s.io`, `batch`).
2. **Versions:** Each group supports multiple versions concurrently (e.g. `v1alpha1`, `v1beta1`, `v1`).
3. **Conversion Webhooks:** You configure a conversion webhook in the CRD. When an old version is called, the API server sends the object to the webhook, converting it to the new schema version before saving it to `etcd`, ensuring backward compatibility.
</details>

---

## ✦ Section 2: Workload Management: Pods, ReplicaSets & Deployments (Questions 21-40)

<details>
<summary><b>Q21: Scenario: Your firm is experiencing frequent downtimes. How would you leverage Kubernetes to achieve high availability for your applications?</b></summary>
<b>Answer:</b>
In Kubernetes, achieving high availability involves several practices:
1. **Stateless Replicas:** Deploy applications using **Deployments** specifying multiple replicas (`replicas: 3` or more). This ensures that if one Pod or worker node fails, other instances handle the network traffic immediately.
2. **Stateful Workloads:** Deploy stateful databases using **StatefulSets** to guarantee stable network identifiers and dedicated persistent volumes.
3. **Service Load Balancing:** Place a Service object in front of the Pods to act as a round-robin load balancer. If a Pod crashes, the service stops sending traffic to it.
4. **Health Probes:** Define `livenessProbes` to restart deadlocked containers and `readinessProbes` to prevent sending traffic to containers that are still initializing.
5. **Autoscaling:** Configure a **Horizontal Pod Autoscaler (HPA)** to scale up the replica count during traffic surges.
6. **Multi-AZ Node Placement:** Distribute worker nodes across multiple Availability Zones, and use `podAntiAffinity` rules to ensure that replicas of the same application are not scheduled on the same physical node.

**Layman Analogy:**
Imagine you have a bunch of identical toy robots that do the same job, like picking up toys in your room. If one robot stops working, you still have others that can continue the work without any interruptions. That's the idea behind Kubernetes helping to keep your applications running smoothly, even if something goes wrong.
In simple terms, Kubernetes makes sure that there are always multiple copies (robots) of your application running. If one of them (a pod) breaks, the other copies can keep working. Kubernetes also checks if your application is healthy. If it finds a problem, it can restart the broken part without you having to do anything. Plus, it spreads out your application parts across different locations, so if one area (like a part of your house) loses power, the robots in other areas can still work.
Finally, Kubernetes can also adjust the number of robots based on how busy they are. If there are more toys to pick up, it adds more robots. If there are fewer toys, it reduces the number of robots. This way, your applications can handle changes in demand without breaking a sweat.
</details>

<details>
<summary><b>Q22: Scenario: How can your company ensure zero downtime deployments with Kubernetes? What strategies and tools would you use to accomplish this?</b></summary>
<b>Answer:</b>
To ensure zero-downtime updates:
1. **RollingUpdate Strategy:** Use the default `RollingUpdate` strategy in the Deployment spec.
2. **Control Rollout Speed:** Set the parameters:
   - `maxUnavailable: 0` (ensures that all existing replicas remain active while new versions spin up).
   - `maxSurge: 1` or `25%` (creates a temporary buffer pod with the new version).
3. **Implement Readiness Probes:** Ensure that the new Pods are only marked as healthy and ready after passing network or endpoint readiness checks. If the container crashes on startup, the rollout halts immediately, keeping old Pods active.
4. **Continuous Delivery Tools:** Implement GitOps pipelines using **ArgoCD** or **Helm** for versioned configurations, allowing rapid rollback using `kubectl rollout undo` if metrics degrade.

**Layman Analogy:**
Imagine you have a toy store with several checkout counters, and you need to replace the old cash registers with new ones without closing the store. Kubernetes helps you do this by switching out the old cash registers one at a time, making sure that there’s always a register open for customers.
Here’s how it works: Kubernetes takes down one old register and sets up a new one in its place. It keeps doing this, one by one, until all the old registers are replaced with new ones. This way, customers can always find an open register to check out. We can also set rules to make sure that no registers are closed at the same time (maxUnavailable=0) and sometimes add an extra temporary register to handle busy times (maxSurge).
Before a new register starts taking customers, Kubernetes makes sure it’s fully set up and ready to go. If any problems come up, we can quickly switch back to the old registers. For more complicated setups, like special counters or registers with more functions, we might use tools like Helm or ArgoCD to manage the changes smoothly and make it easy to fix any issues. This way, the store never has to close, and customers are always happy.
</details>

<details>
<summary><b>Q23: Scenario: How would you implement a canary deployment strategy using Kubernetes to safely roll out new application versions while minimizing risks?</b></summary>
<b>Answer:</b>
1. **Separate Deployments:** Deploy the current version (Production) and the new version (Canary) as two distinct Deployments with different replica counts (e.g., 9 replicas for Production, 1 replica for Canary).
2. **Shared Service Selector:** Label both deployments with `app: frontend` but give them unique version tags (`version: 1.0` and `version: 2.0`). Configure the routing Service to select Pods matching only `app: frontend`.
3. **Traffic Splitting:** Since the service load-balances across all matching endpoints, the Canary Pod will receive roughly 10% of the overall traffic.
4. **Service Mesh (Istio / Linkerd):** For precise traffic splitting (e.g., routing exactly 5% of traffic using HTTP headers), deploy a service mesh. Define an Istio `VirtualService` to split traffic between the production and canary destinations:
   ```yaml
   spec:
     http:
     - route:
       - destination:
           host: frontend-svc
           subset: v1
         weight: 95
       - destination:
           host: frontend-svc
           subset: v2
         weight: 5
   ```
5. **Gradual Promotion:** If canary logs and error rates remain clean, scale up the Canary deployment and scale down Production.

**Layman Analogy:**
Imagine you manage a bookstore and have received a new type of book that you're eager to introduce. To gauge customer response without fully replacing your current stock, you set up a small display (canary deployment) featuring the new book alongside your regular offerings (production deployment). This way, most customers continue to see the familiar books, while a select few get to discover the new arrival.
You instruct your staff (acting as a load balancer) to direct a small percentage of customers (around 5%) to the new book display, monitoring their reactions through feedback forms and observing sales trends (metrics and logs). If the new book proves popular and functions well, you gradually increase its visibility until it replaces the older books entirely. However, if any issues arise or customers prefer the original selection, you promptly revert to showcasing only the old books. This strategy ensures you can safely test and integrate new products based on real-time customer feedback, akin to how Kubernetes employs canary deployments for careful testing and controlled rollout of updates.
</details>

<details>
<summary><b>Q24: Scenario: A newly deployed Pod is stuck in a `CrashLoopBackOff` state. Explain the meaning of this state and detail how you would diagnose the root cause.</b></summary>
<b>Answer:</b>
1. **State Definition:** `CrashLoopBackOff` means the container starts, crashes, exits, and Kubernetes attempts to restart it, entering an exponential delay back-off loop to avoid wasting system resources.
2. **Diagnosis Steps:**
   - **Inspect logs:** Run `kubectl logs <pod-name>` to read stdout/stderr. If the container crashed immediately, run `kubectl logs <pod-name> --previous` to check logs of the previous crashed instance.
   - **Describe Pod:** Run `kubectl describe pod <pod-name>`. Check the "Last State" section to identify the exit code:
     - `Exit Code 0`: Success (process completed; check if the CMD was a batch task, not a daemon).
     - `Exit Code 1`: Application code error (e.g. missing environment variables or DB connection timeout).
     - `Exit Code 137`: Out of Memory (OOMKilled) or SIGKILL.
     - `Exit Code 139`: Segmentation fault.
</details>

<details>
<summary><b>Q25: Scenario: You need to deploy a Node.js web application that requires a local reverse proxy (Nginx) to handle SSL/TLS decryption. How do you design this using a multi-container Pod?</b></summary>
<b>Answer:</b>
1. **Single Pod Definition:** Define both the Node.js application container and the Nginx container inside the same Pod manifest.
2. **Localhost Routing:** Nginx is configured to listen on port `443` for external TLS, decrypt it, and forward traffic to `127.0.0.1:3000` (the port where Node.js is listening).
3. **Shared Volume:** Use an `emptyDir` volume mounted by both containers if Nginx needs to serve static assets generated by the Node.js container directly.
```yaml
spec:
  containers:
    - name: node-app
      image: node:alpine
    - name: nginx-proxy
      image: nginx:alpine
```
</details>

<details>
<summary><b>Q26: Scenario: A pod is stuck in a `Pending` state. List the top 3 resource constraints or scheduler configurations that can cause this.</b></summary>
<b>Answer:</b>
1. **Insufficient Resources:** The total CPU/memory requested by the Pod is larger than the allocatable capacity of any single worker node in the cluster.
2. **NodeSelector / Affinity Mismatch:** The Pod specifies label selectors (e.g. `disktype: ssd`) or node affinity rules that do not match the labels attached to any active node.
3. **Taints and Tolerations:** All active nodes are tainted (e.g., `node-role.kubernetes.io/control-plane:NoSchedule`), and the Pod does not have the corresponding tolerations configured in its spec.
</details>

<details>
<summary><b>Q27: Scenario: You have two Deployments: `web-app` and `api-app`. Explain the risk of overlapping label selectors, and what happens if both match the same Pods.</b></summary>
<b>Answer:</b>
1. **Controller Collision:** If both Deployments specify the same label selector (e.g. `matchLabels: app: backend`), their underlying ReplicaSets will attempt to manage the same set of Pods.
2. **Continuous Spawning & Deleting:** ReplicaSet A will detect 0 pods matching its labels, spawn a pod, while ReplicaSet B detects extra pods above its desired replica count, and terminates one of them. This creates a continuous cycle of spawning and terminating Pods, consuming API bandwidth and CPU.
3. **Mitigation:** Ensure all selectors and template labels are unique per deployment.
</details>

<details>
<summary><b>Q28: Scenario: You want to run a background database cleanup job every Sunday at 3:00 AM. What Kubernetes API object do you use, and how do you configure the execution limits?</b></summary>
<b>Answer:</b>
Use a **CronJob** resource:
1. **Schedule:** Set the crontab schedule string to `0 3 * * 0`.
2. **Execution Limits:**
   - Set `concurrencyPolicy: Forbid` (prevents a new job from starting if the previous Sunday's run is still executing).
   - Set `activeDeadlineSeconds: 3600` (automatically terminates the job if it takes longer than 1 hour).
   - Set `failedJobsHistoryLimit: 3` and `successfulJobsHistoryLimit: 1` to clean up old job pod logs.
</details>

<details>
<summary><b>Q29: Scenario: You want to deploy a log forwarding agent (e.g., Fluent Bit) to run exactly once on every node in your cluster, including master nodes. Which controller do you use, and how do you configure it?</b></summary>
<b>Answer:</b>
Use a **DaemonSet** controller:
1. **Default behavior:** A DaemonSet automatically schedules one Pod on every worker node in the cluster.
2. **Scheduling on Master/Control-Plane Nodes:** Master nodes are typically tainted to prevent normal workloads. You must add the corresponding tolerations to the DaemonSet Pod template:
   ```yaml
   tolerations:
     - operator: Exists
       effect: NoSchedule
   ```
</details>

<details>
<summary><b>Q30: Scenario: Explain the difference between `apiVersion: v1` and `apiVersion: apps/v1`. How does Kubernetes categorize its API groups?</b></summary>
<b>Answer:</b>
1. **API Groups:** The Kubernetes API is modularized into groups:
   - **Core Group (`v1`):** Contains fundamental resources like `Pods`, `Services`, `Namespaces`, `ConfigMaps`, `Secrets`.
   - **Named Groups (`apps/v1`, `batch/v1`, `networking.k8s.io/v1`):** Grouped by functionality.
2. **`apps/v1`:** The `apps` group contains controllers for running applications (like `Deployments`, `ReplicaSets`, `StatefulSets`, `DaemonSets`).
3. **Usage:** You must specify the correct API group and version in your manifest so the API Server routes the request to the correct handler.
</details>

<details>
<summary><b>Q31: Scenario: You want to run a clustered Redis setup requiring stable network hostnames (`redis-0`, `redis-1`) and dedicated storage for each node. Why is a StatefulSet required instead of a Deployment?</b></summary>
<b>Answer:</b>
A **StatefulSet** provides features that standard Deployments do not:
1. **Stable Network Identity:** Pods are named sequentially (`redis-0`, `redis-1`). This name remains consistent even if a Pod is deleted and rescheduled.
2. **Dedicated Storage:** Uses `volumeClaimTemplates` to allocate an independent Persistent Volume Claim (PVC) to each individual Pod index, ensuring `redis-1` always attaches to its specific data volume.
3. **Ordered Rollouts:** Pods are created, updated, and terminated sequentially (e.g., `redis-1` is only created after `redis-0` is fully ready).
</details>

<details>
<summary><b>Q32: Scenario: When a Pod is deleted, how do you ensure the container executes a clean shutdown script (e.g., deregistering from a consul discovery server) before the container engine terminates the process?</b></summary>
<b>Answer:</b>
Use a **`preStop` Lifecycle Hook**:
1. **Termination Flow:** When a Pod deletion is requested, the container engine triggers any configured `preStop` hook before sending the `SIGTERM` signal.
2. **YAML Hook Configuration:**
   ```yaml
   lifecycle:
     preStop:
       exec:
         command: ["/bin/sh", "-c", "/opt/app/deregister.sh"]
   ```
3. **Grace Period:** Configure `terminationGracePeriodSeconds` (default 30s) to be long enough to let the script complete before the hard `SIGKILL` is sent.
</details>

<details>
<summary><b>Q33: Scenario: An application container deadlocks (freezes) but does not crash, keeping the process running. What probe type do you use to detect and restart it?</b></summary>
<b>Answer:</b>
Use a **Liveness Probe**:
1. **Mechanism:** The liveness probe periodically checks the container's health (via HTTP GET, TCP Socket, or Exec command).
2. **Restart Action:** If the probe fails, the `kubelet` terminates the container and restarts it according to the Pod's `restartPolicy`.
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 10
```
</details>

<details>
<summary><b>Q34: Scenario: During a scaling event, how do you prevent new Pods from receiving HTTP requests before they have finished database migration tasks?</b></summary>
<b>Answer:</b>
Use a **Readiness Probe**:
1. **Mechanism:** Unlike liveness probes, readiness probes check if the container is ready to accept incoming network traffic.
2. **Traffic Isolation:** If the readiness probe fails (e.g., migrations still running), the Service controller removes the Pod's IP from the endpoints list. The container remains running, but no traffic is sent to it until the probe succeeds.
</details>

<details>
<summary><b>Q35: Scenario: You need to schedule high-priority payment processing Pods, even if it means evicting running non-critical logging Pods when worker nodes are full. How do you implement this?</b></summary>
<b>Answer:</b>
Use **PriorityClasses and Preemption**:
1. **Create PriorityClass:**
   ```yaml
   apiVersion: scheduling.k8s.io/v1
   kind: PriorityClass
   metadata:
     name: high-priority-payments
   value: 1000000
   globalDefault: false
   ```
2. **Assign to Pod:** In the payment Pod spec, set `priorityClassName: high-priority-payments`.
3. **Preemption:** If the cluster is full, the scheduler will evict running lower-priority Pods to free up resource capacity, rescheduling the payment Pods immediately.
</details>

<details>
<summary><b>Q36: Scenario: How do you configure a Pod so that its container process runs as a non-root user and cannot write to the root filesystem?</b></summary>
<b>Answer:</b>
Configure the **`securityContext`** parameters:
1. **Run as Non-Root:** Set `runAsNonRoot: true` and define a non-zero user ID `runAsUser: 1000`.
2. **ReadOnly Root FS:** Set `readOnlyRootFilesystem: true` (blocks all writes to `/`).
3. **Capabilities:** Drop all linux capabilities.
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```
</details>

<details>
<summary><b>Q37: Scenario: An application requires downloading a 2GB configuration dataset before starting up. How do you implement this using Init Containers?</b></summary>
<b>Answer:</b>
1. **Definition:** **Init Containers** run sequentially to completion before the application containers start.
2. **Configuration:**
   - Define an `initContainers` block using a curl/downloader image.
   - Mount a shared `emptyDir` volume into both the init container and the main app container.
   - The init container downloads the file to the volume, exits, and then the main container starts and reads the file from the volume.
</details>

<details>
<summary><b>Q38: Scenario: Explain what happens if a container exceeds its CPU limit vs. its Memory limit in the Pod specification.</b></summary>
<b>Answer:</b>
1. **CPU Limit Exceeded:** CPU is a compressible resource. If a container exceeds its CPU limit, Kubernetes throttles the CPU cycles allocated to it. The container will slow down (performance degrades), but it will **not** be terminated.
2. **Memory Limit Exceeded:** Memory is non-compressible. If a container requests more memory than its limit, the OS kernel triggers the Out-Of-Memory (OOM) killer. The container is immediately terminated with exit code `137` (`OOMKilled`).
</details>

<details>
<summary><b>Q39: Scenario: You set the container image tag to a non-existent version, triggering a rollout failure. How do you pause the rollout and check the status?</b></summary>
<b>Answer:</b>
1. **Check Status:** Run:
   ```bash
   kubectl rollout status deployment/web-deployment
   ```
2. **Pause Rollout:** To prevent further nodes from updating:
   ```bash
   kubectl rollout pause deployment/web-deployment
   ```
3. **Undo Rollout:** Revert changes back to the active configuration:
   ```bash
   kubectl rollout undo deployment/web-deployment
   ```
</details>

<details>
<summary><b>Q40: Scenario: What is a Pod Disruption Budget (PDB), and how does it protect application availability during node maintenance?</b></summary>
<b>Answer:</b>
1. **Role:** A PDB limits the number of Pods of a replicated application that are down simultaneously due to voluntary disruptions (e.g. `kubectl drain` during node upgrades).
2. **Configuration:**
   ```yaml
   apiVersion: policy/v1
   kind: PodDisruptionBudget
   metadata:
     name: app-pdb
   spec:
     minAvailable: 2  # or maxUnavailable: 1
     selector:
       matchLabels:
         app: web
   ```
3. **Enforcement:** If you run `kubectl drain`, the command blocks if evicting a pod would drop the active count below `minAvailable` until resources scale elsewhere.
</details>

---

## ✦ Section 3: Services, Networking & Traffic Routing (Questions 41-60)

<details>
<summary><b>Q41: Scenario: You have deployed a frontend Pod and a backend Pod. The frontend fails to connect to the backend IP. How do you troubleshoot the virtual network paths across different nodes?</b></summary>
<b>Answer:</b>
1. **Check CNI Overlay Routing:** Verify the status of the Container Network Interface (CNI) daemonset (e.g., Flannel, Calico) to ensure overlay network encapsulation tunnels (VXLAN/Geneve) are healthy.
2. **Verify Security Groups:** Check cloud network firewall rules. Ensure that UDP port `4789` (VXLAN) or IP protocol `4` (IP-in-IP) is allowed bidirectionally between worker nodes.
3. **Verify Pod IPs:** Run `kubectl get pod -o wide` to check if Pods are assigned valid IPs in the CNI CIDR range.
4. **Test Localhost/Node Connectivity:** Run an ephemeral debug container to execute trace-route commands:
   ```bash
   kubectl debug -it <frontend-pod> --image=nicolaka/netshoot -- /bin/bash
   # Try pinging the backend IP directly
   ```
</details>

<details>
<summary><b>Q42: Scenario: You want to expose a backend microservice database so that it is only accessible to other Pods running inside the cluster. Which Service type do you use?</b></summary>
<b>Answer:</b>
Use the default **ClusterIP** service:
1. **Internal IP:** ClusterIP allocates a stable, virtual IP that is only routeable from within the cluster.
2. **DNS Mapping:** CoreDNS registers `database-svc.default.svc.cluster.local`, allowing other internal Pods to resolve it while preventing any access from outside the cluster.
</details>

<details>
<summary><b>Q43: Scenario: An on-premises application outside the cluster needs to send data to a service inside the cluster. You have no cloud load balancer. How do you implement this?</b></summary>
<b>Answer:</b>
Use a **NodePort** service:
1. **Static Ports:** NodePort exposes the service on each worker node’s physical IP address at a static port within the range `30000-32767`.
2. **Access Path:** The external system can send traffic to `<Node-IP>:<NodePort>`. `kube-proxy` on that node receives the packet and routes it to the target Pods.
</details>

<details>
<summary><b>Q44: Scenario: You are running an application in AWS EKS and want to expose it to the internet using a single AWS Application Load Balancer (ALB). What is the recommended ingress controller, and how does it route traffic?</b></summary>
<b>Answer:</b>
1. **AWS Load Balancer Controller:** Install the AWS Load Balancer Controller in your EKS cluster.
2. **Ingress Configuration:** Define an Ingress resource with annotation `spec.ingressClassName: alb`.
3. **Traffic Routing:** The controller provisions an AWS ALB. By default, it routes traffic in **IP mode** directly from the ALB to the target Pod IPs (using AWS VPC CNI), bypassing NodePorts for decreased network hop latency.
</details>

<details>
<summary><b>Q45: Scenario: A Pod is unable to resolve external hostnames (e.g. `api.github.com`). How do you diagnose CoreDNS performance and verify DNS settings inside a Pod?</b></summary>
<b>Answer:</b>
1. **Check resolv.conf:** Exec into the Pod and check `/etc/resolv.conf`:
   ```bash
   nameserver 10.96.0.10 # Should point to CoreDNS Service IP
   search default.svc.cluster.local svc.cluster.local cluster.local
   ```
2. **Verify CoreDNS Pods:** Check if the `coredns` pods are running in the `kube-system` namespace:
   ```bash
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   ```
3. **Check CoreDNS logs:** Inspect logs for errors:
   ```bash
   kubectl logs -n kube-system -l k8s-app=kube-dns
   ```
4. **Test Resolution:** Use a netshoot container to query the DNS server directly:
   ```bash
   nslookup api.github.com 10.96.0.10
   ```
</details>

<details>
<summary><b>Q46: Scenario: You are deploying a stateful Cassandra database cluster where nodes need to connect directly to each other’s IPs without load-balancing. How do you configure a Headless Service?</b></summary>
<b>Answer:</b>
Set `clusterIP: None` in the Service specification:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: cassandra
spec:
  clusterIP: None # Defines a Headless Service
  selector:
    app: cassandra
  ports:
    - port: 9042
```
A DNS lookup for `cassandra` will return the list of A records containing the direct IP addresses of all backing Pods.
</details>

<details>
<summary><b>Q47: Scenario: A Pod inside the cluster needs to query an external Oracle database hosted outside the cluster. How do you expose this database using a Kubernetes Service name?</b></summary>
<b>Answer:</b>
Use an **ExternalName** service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: oracle-db
spec:
  type: ExternalName
  externalName: rds-oracle.prod.aws.internal
```
When a Pod queries `oracle-db`, the CoreDNS server returns a CNAME record pointing to `rds-oracle.prod.aws.internal`, redirecting the network request directly.
</details>

<details>
<summary><b>Q48: Scenario: You want to host a website where traffic to `example.com/api` goes to the `api-service`, and traffic to `example.com/static` goes to the `static-service`. Write the path-based Ingress rules.</b></summary>
<b>Answer:</b>
```yaml
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /static
            pathType: Prefix
            backend:
              service:
                name: static-service
                port:
                  number: 80
```
</details>

<details>
<summary><b>Q49: Scenario: You want to host two different subdomains, `admin.example.com` and `shop.example.com`, on the same ingress controller. How do you configure Host-based Ingress?</b></summary>
<b>Answer:</b>
Define multiple rules using the `host` parameter:
```yaml
spec:
  rules:
    - host: admin.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: admin-service
                port:
                  number: 80
    - host: shop.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: shop-service
                port:
                  number: 80
```
</details>

<details>
<summary><b>Q50: Scenario: How do you configure an Ingress rule to terminate SSL/TLS certificates and enforce HTTPS connections?</b></summary>
<b>Answer:</b>
1. **Create Secret:** Save SSL certificates as a TLS secret:
   ```bash
   kubectl create secret tls ssl-secret --cert=tls.crt --key=tls.key
   ```
2. **Ingress configuration:** Reference the secret in the Ingress manifest:
   ```yaml
   spec:
     tls:
       - hosts:
           - app.example.com
         secretName: ssl-secret
     rules:
       - host: app.example.com
         http:
           paths:
             - path: /
               pathType: Prefix
               backend:
                 service:
                   name: web-service
                   port:
                     number: 80
   ```
</details>

<details>
<summary><b>Q51: Scenario: You have a stateful legacy shopping cart service. How do you configure the Kubernetes Service to ensure a client’s requests are always routed to the same Pod replica?</b></summary>
<b>Answer:</b>
Configure **Session Affinity**:
Set `sessionAffinity: ClientIP` in the Service spec:
```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800 # 3 hours session stickiness duration
```
This forces `kube-proxy` to route subsequent requests from the same client IP to the same Pod.
</details>

<details>
<summary><b>Q52: Scenario: Your Nginx web servers need to read the real client IP address for geolocalization, but they only see the internal IP of the cluster nodes. How do you fix this using Service parameters?</b></summary>
<b>Answer:</b>
Set `externalTrafficPolicy: Local` on the Service of type `LoadBalancer` or `NodePort`:
1. **Preserve Client IP:** By setting it to `Local`, the node receiving the traffic routes it directly to Pods running on that specific node, avoiding intermediate hops and preserving the source client IP in the headers.
2. **Trade-off:** If a node does not host any matching Pod, the traffic is dropped. Ensure matching Pods are running on all nodes (e.g., using DaemonSet) or set appropriate anti-affinity rules to distribute Pods evenly.
</details>

<details>
<summary><b>Q53: Scenario: An Ingress controller is overloaded with scraping bots. How do you limit connections per client IP using Nginx Ingress annotations?</b></summary>
<b>Answer:</b>
Add limit annotations to the Ingress metadata:
```yaml
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/limit-connections: "20"
    nginx.ingress.kubernetes.io/limit-rpm: "120"
```
This restricts each client IP to a maximum of 20 concurrent connections and 120 requests per minute.
</details>

<details>
<summary><b>Q54: Scenario: For security compliance, you must block all network traffic inside the cluster except allowing the `frontend` Pods to talk to the `backend` Pods. How do you implement this using Network Policies?</b></summary>
<b>Answer:</b>
1. **Enable Default Deny:** Create a NetworkPolicy blocking all ingress traffic in the namespace:
   ```yaml
   spec:
     podSelector: {} # matches all pods
     ingress: []     # empty list blocks all ingress
   ```
2. **Allow Frontend-to-Backend:** Create an ingress rule targeting `backend` pods, allowing traffic only from pods labeled `role: frontend`:
   ```yaml
   metadata:
     name: allow-frontend-to-backend
   spec:
     podSelector:
       matchLabels:
         role: backend
     ingress:
       - from:
           - podSelector:
               matchLabels:
                 role: frontend
   ```
</details>

<details>
<summary><b>Q55: Scenario: You run `kubectl describe svc my-svc` and see that the Endpoints list is `<none>`. What are the top 2 checks you perform?</b></summary>
<b>Answer:</b>
1. **Label Selector Check:** Compare the `selector` key in the Service spec with the `labels` key in the Pod specifications. They must match exactly.
2. **Readiness Probe Check:** Check if the Pods are passing their readiness probes. If a Pod's readiness probe is failing, the Service controller removes its IP from the Endpoints list.
</details>

<details>
<summary><b>Q56: Scenario: How do you configure a single Service to expose both port 80 (HTTP) and port 443 (HTTPS) on different container ports?</b></summary>
<b>Answer:</b>
Define a **Multi-Port Service**:
Assign a unique `name` to each port configuration block:
```yaml
spec:
  ports:
    - name: http
      port: 80
      targetPort: 8080
    - name: https
      port: 443
      targetPort: 8443
```
</details>

<details>
<summary><b>Q57: Scenario: Your development team is using Istio Service Mesh. How does the network path of a request change, and what is the role of Envoy proxies?</b></summary>
<b>Answer:</b>
1. **Sidecar Injection:** Every Pod is injected with an **Envoy proxy** container as a sidecar.
2. **Network Interception:** All ingress/egress network traffic to the Pod is intercepted by the local Envoy proxy (using iptables rules configured during Pod init).
3. **Proxy Communication:** When Pod A calls Service B, the traffic flows: Pod A container -> Envoy A -> Envoy B -> Pod B container. The proxies negotiate TLS (mTLS), collect metrics, and execute routing rules.
</details>

<details>
<summary><b>Q58: Scenario: Explain the difference between Calico Network Policies and standard Kubernetes Network Policies.</b></summary>
<b>Answer:</b>
1. **Global Scoping:** Standard K8s policies are namespace-scoped. Calico supports `GlobalNetworkPolicy` which applies to all namespaces.
2. **Layer 7 Rules:** Calico supports application-layer rules (HTTP method, URI matching).
3. **Host Protection:** Calico can protect the host network interfaces of the worker nodes, not just Pod interfaces.
4. **Integration:** Calico integrates with external directory services (like Active Directory) for network rules.
</details>

<details>
<summary><b>Q59: Scenario: Under heavy API traffic, you see frequent "connection reset by peer" errors behind a Service VIP. How do you troubleshoot TCP socket timeouts in IPVS mode?</b></summary>
<b>Answer:</b>
1. **Timeout Mismatch:** The TCP keepalive timeout on the client or server is longer than the IPVS connection timeout (default 900s for TCP).
2. **Tuning:** Tune the IPVS connection timeouts using `ipvsadm` inside the `kube-proxy` container:
   ```bash
   ipvsadm --set 1800 120 300 # Set TCP timeout to 30 minutes
   ```
3. **TCP Keepalive:** Enable TCP keepalive in the application code.
</details>

<details>
<summary><b>Q60: Scenario: How do you restrict `kube-proxy` to bind NodePorts only to specific network interfaces (e.g., internal interface `eth1`), rather than binding to `0.0.0.0` (all interfaces)?</b></summary>
<b>Answer:</b>
Configure the `--nodeport-addresses` flag in the `kube-proxy` daemonset parameters:
```yaml
kube-proxy --nodeport-addresses=10.240.0.0/16
```
This forces `kube-proxy` to only route NodePort traffic arriving on IP addresses within the specified CIDR block, blocking external interface access.
</details>

---

## ✦ Section 4: ConfigMaps, Secrets, Namespaces & Storage (Questions 61-80)

<details>
<summary><b>Q61: Scenario: Your firm relies heavily on Kubernetes applications, and it's crucial to perform regular backups to prevent data loss. How would you design a comprehensive backup strategy? What tools and practices would you use?</b></summary>
<b>Answer:</b>
To implement a resilient backup and disaster recovery strategy:
1. **Tool Selection (Velero):** Use **Velero**, the industry-standard open-source tool built specifically for backing up and restoring Kubernetes cluster resources and persistent volumes.
2. **Backup Targets:**
   - **Cluster Metadata:** Back up all YAML configurations (Deployments, Services, ConfigMaps, Secrets) and CRDs stored in etcd.
   - **Persistent Volumes:** Configure Velero to take block-level volume snapshots (using cloud CSI drivers or Restic/Kopia for file-level backups) of databases and stateful disks.
3. **Remote Storage:** Ship backups to an external object storage bucket (e.g. AWS S3) located in a separate, isolated account.
4. **Automation:** Schedule cron backups (e.g., daily with a 7-day retention period).
5. **Validation:** Implement automated restore testing. Regularly restore S3 backups to an isolated Staging cluster namespace to verify data integrity.

**Layman Analogy:**
Imagine you have a big project at school, and you need to make sure you don’t lose your work. To keep everything safe, you decide to take regular snapshots (backups) of your project and store them somewhere safe, like on a USB drive or cloud storage.
First, you use a tool called Velero to help you take these snapshots of your project. Velero is like a magic camera that takes pictures of your work and saves them to a safe place like Google Drive or Dropbox. You set Velero to take these pictures regularly, like every night, so you always have an up-to-date backup of your project.
For parts of your project that have important data, like handwritten notes or drawings, Velero makes sure to capture these too by taking special snapshots (VolumeSnapshot). This way, all your important data is saved along with the project itself.
You also practice restoring your project from these backups to a different notebook (staging environment) to make sure the backups are good and can be used if something goes wrong. This helps you check that you can get your project back quickly without any issues.
Finally, you set up alerts, like reminders on your phone, to let you know if something goes wrong with the backup process. This way, you can fix any problems right away and make sure your project is always safe.
In short, using Velero to back up your Kubernetes applications is like taking regular snapshots of your school project and storing them safely, making sure you can always recover your work if needed.
</details>

<details>
<summary><b>Q62: Scenario: Your firm needs to comply with data residency requirements. How would you manage Kubernetes clusters to meet these requirements?</b></summary>
<b>Answer:</b>
1. **Zonal/Regional Provisioning:** Deploy Kubernetes worker nodes and clusters exclusively inside cloud regions that reside within the required geopolitical boundaries (e.g., `eu-west-1` for GDPR compliance).
2. **Storage Placement Policies:** Define **StorageClasses** that pin persistent volume attachments (EBS, local SSDs) to specific zones or regions.
3. **Network Constraints:** Use **Network Policies** to block outgoing traffic to external API services located in unapproved geographical regions.
4. **Multi-Cluster Federation (KubeFed):** If running multiple clusters globally, use KubeFed to orchestrate configuration policies, ensuring that datasets are only synced within compliant boundaries.

**Layman Analogy:**
Imagine managing a network of warehouses for a global retail chain, where specific products must be stored and distributed according to regional regulations. Each warehouse (Kubernetes cluster) is strategically located in compliant regions (cloud zones or physical locations) to ensure products (data) remain within authorized boundaries.
To maintain compliance, you utilize specialized storage systems (storage classes) designed exclusively for each region. These systems prevent products from being mistakenly transferred to unauthorized warehouses, ensuring strict adherence to regulatory requirements. Additionally, you establish stringent rules (Network Policies) governing intra-warehouse movements, guaranteeing that products remain within their designated regions.
For oversight across multiple warehouses in different regions, you employ a centralized management system (KubeFed). This tool allows you to supervise all warehouses efficiently, ensuring consistent adherence to regional regulations regarding product storage and distribution. Working closely with legal advisors, you regularly audit operations to confirm compliance, swiftly addressing any deviations to uphold regulatory standards.
In essence, managing Kubernetes clusters to comply with data residency requirements mirrors the meticulous management of warehouses to ensure products are stored and distributed in accordance with regional regulations, using specialized systems and stringent rules to maintain compliance.
</details>

<details>
<summary><b>Q63: Scenario: You mount a Secret to a container as a volume. Later, you update the Secret's value in the API Server. How does this change propagate to the container, and why does it differ from environment variables?</b></summary>
<b>Answer:</b>
1. **Secret as Volume:**
   - **Automatic Sync:** The `kubelet` periodically polls the API Server for secret updates. Once detected, it updates the files inside the mounted directory dynamically (usually within 1 minute, depending on cache/sync configurations).
   - **Atomic Update:** The Kubelet writes the new data to a temporary folder and updates a symbolic link, ensuring the application reads the update atomically.
2. **Secret as Environment Variable:**
   - **Static Values:** Environment variables are set during container startup. If you update the Secret in the API Server, the running container's environment variables **do not** update. You must restart the container (e.g., via a rolling update of the Deployment) to load the new values.
</details>

<details>
<summary><b>Q64: Scenario: Your Java application uses a properties file at `/config/app.properties`. How do you mount a ConfigMap to this specific file path without overwriting other files in that directory?</b></summary>
<b>Answer:</b>
Use the **`subPath`** configuration block inside the volumeMounts definition:
```yaml
spec:
  containers:
    - name: java-app
      volumeMounts:
        - name: config-volume
          mountPath: /config/app.properties # Target file path
          subPath: app.properties           # Reference the specific key in the ConfigMap
  volumes:
    - name: config-volume
      configMap:
        name: my-configmap
```
Without `subPath`, mounting the volume at `/config` would empty the directory and hide all other files existing inside the container's `/config` folder.
</details>

<details>
<summary><b>Q65: Scenario: Explain the security risks of default Kubernetes Secrets and detail the best practices to encrypt them at rest.</b></summary>
<b>Answer:</b>
1. **The Risk:** Kubernetes Secrets are only Base64-encoded strings. Anyone with read access to the cluster's Git history, etcd backup database, or API Server can easily decode them.
2. **Best Practices:**
   - **etcd Encryption at Rest:** Configure the API Server with an `EncryptionConfiguration` file to encrypt data before writing it to etcd, using KMS plugins (AWS KMS or Azure Key Vault).
   - **External Secrets Operator (ESO):** Decouple secrets by storing them in enterprise password managers (HashiCorp Vault, AWS Secrets Manager) and fetching them dynamically at runtime into memory, bypassing etcd storage entirely.
</details>

<details>
<summary><b>Q66: Scenario: You create a PVC requesting 100Gi of storage, but it remains stuck in a `Pending` state. The events log displays `waiting for first consumer to be created before binding`. What does this mean?</b></summary>
<b>Answer:</b>
1. **Late Binding:** The StorageClass is configured with `volumeBindingMode: WaitForFirstConsumer`.
2. **Logical Delay:** Instead of creating the storage volume immediately, Kubernetes delays volume binding until a Pod that references the PVC is scheduled. This allows the scheduler to select a worker node first, ensuring the storage volume is created in the same availability zone as the node.
3. **Remediation:** Create a Pod that mounts the PVC. Once the Pod is scheduled, the volume will bind.
</details>

<details>
<summary><b>Q67: Scenario: You are deploying a WordPress site with multiple replicas. How do you share the `/var/www/html` uploads directory across all running Pods on different nodes?</b></summary>
<b>Answer:</b>
1. **Storage Type:** You must use a network file system (like NFS, AWS EFS, or Azure Files) that supports **ReadWriteMany (RWX)**.
2. **Driver Configuration:** Install the AWS EFS CSI driver.
3. **Provision PVC:** Create a PVC referencing the EFS storage class with access mode:
   ```yaml
   accessModes:
     - ReadWriteMany
   ```
4. **Mount:** Mount this PVC to the `/var/www/html` path in the deployment template.
</details>

<details>
<summary><b>Q68: Scenario: A MySQL volume is filling up. How do you expand the storage capacity of an existing Persistent Volume without deleting the database Pod?</b></summary>
<b>Answer:</b>
1. **Enable Expansion:** The StorageClass must have `allowVolumeExpansion: true`.
2. **Update PVC:** Edit the PVC manifest directly and increase the requested storage capacity:
   ```bash
   kubectl edit pvc mysql-pvc
   # Change resources.requests.storage from 20Gi to 50Gi
   ```
3. **Online File System Expansion:** If the CSI driver supports dynamic resizing (like AWS EBS gp3), the cloud provider resizes the block storage, and the Kubelet automatically expands the file system inside the running container.
</details>

<details>
<summary><b>Q69: Scenario: You delete a Persistent Volume Claim (PVC), but the backing Persistent Volume (PV) status remains `Released` and cannot be bound by other claims. How do you make it available?</b></summary>
<b>Answer:</b>
1. **Reclaim Policy:** The PV has its `persistentVolumeReclaimPolicy` set to **`Retain`**.
2. **Manual Cleanup:**
   - The volume data is preserved to prevent data loss.
   - You must delete the PV manually from the API: `kubectl delete pv <name>`.
   - Clear the data from the backing physical storage (e.g. clean the directory on the host or delete the cloud disk).
   - Recreate the PV manifest to place it back in the `Available` pool.
</details>

<details>
<summary><b>Q70: Scenario: A frontend Pod in the `development` namespace needs to query a backend service named `api-service` located in the `shared-services` namespace. What is the target FQDN?</b></summary>
<b>Answer:</b>
Use the cross-namespace DNS FQDN format:
```text
api-service.shared-services.svc.cluster.local
```
Where:
- `api-service` is the Service name.
- `shared-services` is the target namespace.
- `svc` represents service type.
- `cluster.local` is the local cluster domain.
</details>

<details>
<summary><b>Q71: Scenario: A developer runs a script that creates 1,000 pods in the `dev` namespace, crashing the cluster nodes. How do you enforce limits on resources per namespace?</b></summary>
<b>Answer:</b>
1. **ResourceQuota:** Apply a `ResourceQuota` to the namespace to restrict total compute allocations:
   ```yaml
   spec:
     hard:
       pods: "20"
       requests.cpu: "4"
       requests.memory: "8Gi"
       limits.cpu: "10"
       limits.memory: "16Gi"
   ```
2. **LimitRange:** Define a `LimitRange` to automatically enforce default CPU/memory requests and limits on any Pod created without explicit declarations.
</details>

<details>
<summary><b>Q72: Scenario: You mount a ConfigMap as a volume. How do you restrict the permissions of the files generated inside the container to be read-only (`-r--------`)?</b></summary>
<b>Answer:</b>
Configure the `defaultMode` parameter under the configMap volume definition inside the PodSpec:
```yaml
volumes:
  - name: config-volume
    configMap:
      name: app-config
      defaultMode: 0400 # Represents octal permissions: read-only by owner
```
</details>

<details>
<summary><b>Q73: Scenario: Explain the architectural role of the Container Storage Interface (CSI) in modern Kubernetes storage.</b></summary>
<b>Answer:</b>
1. **Decoupled Architecture:** CSI is a standardized specification that allows storage vendors (like NetApp, AWS, Portworx) to write storage plugins once that work across any orchestration engine (Kubernetes, Mesos).
2. **Out-of-Tree Drivers:** Prior to CSI, storage drivers were built "in-tree" (inside the Kubernetes core binary). Upgrading a driver required upgrading the entire cluster API server. CSI allows drivers to run as standard containerized agents on nodes.
</details>

<details>
<summary><b>Q74: Scenario: When you mount a Secret to a Pod, the Kubelet creates a `tmpfs` volume. Explain the security advantage of `tmpfs` over local disk mounts.</b></summary>
<b>Answer:</b>
1. **In-Memory Storage:** `tmpfs` is a virtual filesystem located entirely in volatile RAM memory.
2. **Data Erasure:** Secret values are never written to the physical storage media of the host node.
3. **Node Compromise Protection:** If a node experiences a hard reset or physical theft, no secret residuals exist on the hard drive disks, protecting sensitive keys.
</details>

<details>
<summary><b>Q75: Scenario: You want to commit your application deployment configurations to Git, but the YAML manifests contain database passwords. How do you implement GitOps securely?</b></summary>
<b>Answer:</b>
1. **Encrypt Manifests:** Use **Mozilla SOPS** or **Sealed Secrets** to encrypt the secrets inside Git.
2. **Sealed Secrets Flow:**
   - You encrypt the secret locally using the controller's public key (`kubeseal`), creating a `SealedSecret` custom resource.
   - Commit the encrypted `SealedSecret` to Git.
   - When applied, the Sealed Secrets Controller inside the cluster uses its private key to decrypt the manifest, creating a standard Kubernetes Secret in memory.
</details>

<details>
<summary><b>Q76: Scenario: Explain the difference between local Persistent Volumes and `hostPath` volumes.</b></summary>
<b>Answer:</b>
1. **Scheduling Awareness:** Local PVs are managed resources. The scheduler knows which node holds the local disk and schedules the Pod on that node using node affinity.
2. **hostPath Limitations:** `hostPath` is not scheduling-aware. If the scheduler moves a Pod to node B, the Pod mounts B's path instead of node A's path, losing access to the data.
3. **Safety:** Local PVs are managed; `hostPath` bypasses PV controls, creating security risks.
</details>

<details>
<summary><b>Q77: Scenario: What is Dynamic Volume Provisioning? Explain the step-by-step lifecycle when a developer creates a PVC in a cloud environment.</b></summary>
<b>Answer:</b>
1. **Request:** Developer applies a PVC manifest referencing a specific `StorageClass`.
2. **API Call:** The cluster detects the PVC has no PV. It calls the cloud CSI driver (e.g. AWS EBS CSI).
3. **Disk Creation:** The CSI driver executes cloud API calls to provision the physical disk (e.g. 50GB gp3 volume).
4. **PV Binding:** The cluster creates a corresponding PV object and binds it to the PVC.
5. **Mounting:** When the Pod starts, the Kubelet attaches the disk to the worker node and mounts it to the container.
</details>

<details>
<summary><b>Q78: Scenario: You make an update to a ConfigMap and apply it. Shortly after, the application crashes because the new configuration format was invalid. How do you safeguard configurations?</b></summary>
<b>Answer:</b>
1. **Config Validation:** Implement a dry-run validate pipeline step in CI/CD using schema checkers (like `kubeval` or `kube-linter`).
2. **Versioned ConfigMaps:** Append a hash of the content to the ConfigMap name (e.g. `config-v1`, `config-v2`). Update the Deployment reference. If the new version crashes, rollback the deployment, which automatically points back to `config-v1`.
</details>

<details>
<summary><b>Q79: Scenario: You run `kubectl delete namespace testing` and the command remains stuck in a `Terminating` state indefinitely. What is causing this, and how do you resolve it?</b></summary>
<b>Answer:</b>
1. **Unresolved Finalizers:** The namespace contains resources with active **Finalizers** that cannot be deleted (e.g., custom CRDs, stuck PV attachments, or unreachable APIs).
2. **Resolution Steps:**
   - Locate the stuck resources: `kubectl get all -n testing`.
   - Inspect custom resources: `kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n testing`.
   - If a resource is stuck, remove its finalizer:
     ```bash
     kubectl patch crd/my-crd -p '{"metadata":{"finalizers":null}}' --type=merge
     ```
</details>

<details>
<summary><b>Q80: Scenario: You need to define a cluster-wide shared storage pool where different teams can carve out individual directories. How do you design this?</b></summary>
<b>Answer:</b>
1. **Shared Volume:** Set up a central AWS EFS or NFS storage server.
2. **CSI Driver:** Install the NFS/EFS CSI driver.
3. **StorageClass:** Define a `StorageClass` with the CSI provisioner.
4. **Dynamic Claims:** Teams apply individual PVCs referencing the StorageClass. The CSI driver dynamically creates sub-directories inside the shared EFS pool and mounts them isolated to their respective Pods.
</details>

---

## ✦ Section 5: Security, Troubleshooting & Advanced Auto-scaling (Questions 81-100)

<details>
<summary><b>Q81: Scenario: Your firm wants to optimize resource utilization. How would you use Kubernetes to manage resources efficiently?</b></summary>
<b>Answer:</b>
To optimize resource utilization:
1. **Define Resource Limits & Requests:** 
   - Define `requests` (minimum guaranteed resources the scheduler uses for placement).
   - Define `limits` (maximum resources a container can consume to prevent a single Pod from starving other nodes).
2. **Horizontal Pod Autoscaling (HPA):** Scale the number of replicas dynamically based on real-time CPU/memory load or custom Prometheus metrics.
3. **Vertical Pod Autoscaling (VPA):** For workloads that cannot scale horizontally (like single-instance databases), deploy VPA in `Off` (recommendation) or `Auto` mode to dynamically resize requests and limits based on historical data.
4. **LimitRanges:** Define a `LimitRange` per namespace to enforce minimum/maximum constraints and default values on all containers.
5. **Node Autoscaling:** Deploy the **Cluster Autoscaler** to automatically add or remove cloud VM nodes based on pending unschedulable Pod workloads.

**Layman Analogy:**
Think of Kubernetes like a smart school organizer that helps you share classroom supplies, like pens and notebooks, efficiently among all students so nothing goes to waste.
First, it makes sure every student gets the right amount of supplies they need to start with (resource requests) and ensures no one takes too much (resource limits). This way, everyone has enough to do their work, and no one can take too much and leave others without supplies.
Next, if more students show up and need supplies, Kubernetes can add more classrooms (pods) so everyone has what they need (Horizontal Pod Autoscaling). It can also adjust the amount of supplies each student gets based on what they actually use, making sure no one has too much or too little (Vertical Pod Autoscaling).
Finally, by keeping an eye on how supplies are used with tools like Prometheus and Grafana, Kubernetes can spot areas where things can be improved. This way, it can make sure that supplies are used wisely, and nothing is wasted.
</details>

<details>
<summary><b>Q82: Scenario: Your firm has a multi-cloud strategy. How would you manage Kubernetes clusters across multiple cloud providers?</b></summary>
<b>Answer:</b>
1. **Centralized Management:** Use multi-cluster control plane management platforms like **Rancher**, **Google Anthos**, or **Azure Arc**. These tools provide a unified dashboard, federated RBAC, and single-pane-of-glass policy enforcement.
2. **Infrastructure as Code:** Write reusable **Terraform** configurations to provision clusters (EKS in AWS, GKE in GCP, AKS in Azure) consistently.
3. **Multi-Cluster Service Mesh:** Deploy a service mesh (like **Istio**) in a multi-primary configuration. This allows Pods in GKE to communicate securely with Pods in EKS over encrypted mTLS tunnels using a shared trust domain.
4. **GitOps CD:** Deploy applications uniformly using **ArgoCD**. Map Git branch configurations to target destinations in different cloud clusters.

**Layman Analogy:**
Imagine you have coffee shops in different cities, and you need to manage them all from one place. You'd use a special tool (like Rancher or Google Anthos) to control all your coffee shops from one computer screen. This way, you can check supplies, set rules, and see how each shop is doing without visiting each one.
Next, you'd ensure every coffee shop is set up the same way using a guidebook (Infrastructure as Code with tools like Terraform). This guidebook tells each shop how to arrange furniture, what coffee beans to stock, and how to display pastries, so every shop looks and operates the same. An automated system (CI/CD pipelines) would send supplies to all the shops, ensuring they all have the right items and any updates are made everywhere simultaneously.
You'd also set up a secure communication system (cross-cluster networking with Istio) so all shops can talk to each other about supply availability and customer preferences. Finally, a centralized monitoring system (like Prometheus and Grafana) would collect information from all the shops about sales and stock levels, helping you quickly spot and fix any problems, ensuring all your shops work well together.
In short, managing Kubernetes clusters across multiple cloud providers is like running coffee shops in different cities from one control center, keeping everything consistent and efficient.
</details>

<details>
<summary><b>Q83: Scenario: How can your company secure sensitive data in Kubernetes? What methods and tools would you implement to ensure data security?</b></summary>
<b>Answer:</b>
1. **Role-Based Access Control (RBAC):** Restrict API access using the principle of least privilege. Use Roles and RoleBindings to scope access inside namespaces.
2. **Network Policies:** Implement a zero-trust network model. Restrict ingress and egress traffic between namespaces and Pods.
3. **Secrets Encryption:** Enable etcd encryption-at-rest using KMS integrations, and restrict secret access to designated service accounts.
4. **Runtime Security & Scanning:** Run image vulnerability scanning in pipelines (using **Trivy** or **Aqua**), block privileged containers, and run host intrusion detection systems (like **Falco**).

**Layman Analogy:**
Imagine Kubernetes as a school where sensitive data like test answers and student records need to be kept secure.
First, only teachers and administrators have access to important areas and information, using special keys and permissions (Role-Based Access Control). We store secret information like passwords in a locked, coded box (Kubernetes Secrets) that only certain people (pods) can unlock.
We also set up rules about who can communicate with whom in the school (network policies), ensuring only certain classrooms can share information. For storing sensitive data, we use encrypted lockers, making it unreadable without the right key. Cloud services offer these lockers, and tools like HashiCorp Vault can help encrypt data.
We keep a detailed log of everything happening in the school (audit logging) to investigate any suspicious activities. Regular security checks with tools help find and fix weak spots, ensuring everything is safe before use. This way, Kubernetes keeps all sensitive information protected, just like a well-guarded school.
</details>

<details>
<summary><b>Q84: Scenario: Your firm is experiencing performance issues with Kubernetes applications, impacting user experience. How would you systematically diagnose the root causes?</b></summary>
<b>Answer:</b>
1. **Metrics Collection:** Analyze CPU, memory, network, and disk I/O metrics using **Prometheus** and **Grafana**. Check if nodes are experiencing CPU throttling or memory starvation.
2. **Resource Usage (CLI):** Run `kubectl top nodes` and `kubectl top pods` to identify high-consuming workloads.
3. **Distributed Tracing:** Integrate **OpenTelemetry** with **Jaeger** or **Zipkin** to trace request latency across downstream microservice call trees.
4. **Log Aggregation:** Query central log servers (like the **ELK Stack** or Grafana Loki) to locate application errors.

**Layman Analogy:**
Imagine your coffee shop is having trouble with long lines at the counter, frustrating customers. To fix this, you first set up cameras (tools like Prometheus and Grafana) to watch how busy the counters are and see how fast things are moving. These cameras give you a live view and alerts for slowdowns. You also check the shop's logs (using tools like ELK stack or Fluentd and Kibana) to find patterns or specific times when things slow down.
Next, you use a tool (kubectl top) to see which counters (pods) are using the most resources, like space or orders handled. If one counter is overloaded, you adjust its space or order capacity. Sometimes, you follow a customer’s journey (using tools like Jaeger or Zipkin) to pinpoint delays. Once you identify the issues, you fix them by adding more counters, adjusting space, or speeding up processes. Finally, you regularly test the shop (using tools like JMeter or k6) to handle busy times, ensuring everything runs smoothly.
In short, diagnosing and fixing performance issues in Kubernetes is like improving your coffee shop's efficiency by monitoring, checking logs, tracing processes, and making necessary improvements.
</details>

<details>
<summary><b>Q85: Scenario: Your firm is planning to migrate from a monolithic application to microservices on Kubernetes. What steps would you take to ensure a smooth transition?</b></summary>
<b>Answer:</b>
1. **Deconstruct the Monolith:** Define bounded contexts and separate business functions into individual microservice codebases.
2. **Containerization:** Write optimized Dockerfiles for each microservice and build automated CI/CD pipelines to push images to a secure registry (like AWS ECR).
3. **Cluster Setup:** Configure namespaces, set resource limits, and establish network policies.
4. **Service Discovery:** Deploy microservices with Deployments and expose them internally using Services.
5. **Data Migration Strategy:** Deconstruct the shared database by creating dedicated databases per service. Use data migration tools (like AWS DMS) to replicate data and verify consistency before cutover.

**Layman Analogy:**
Imagine you have a big library where all books are in one large room (a monolithic application). You want to transform it into a modern library with separate sections for different genres (microservices). First, you divide the library into sections for fiction, non-fiction, and children's books. You construct the new library (Kubernetes cluster) with corridors (networking), storage areas (storage), and security personnel (security) to keep everything orderly and secure. Each genre gets its own dedicated space (Docker image) with setup instructions (Dockerfiles) and an automated system (CI/CD pipelines) to establish the sections.
You manage these sections with rules and schedules (Kubernetes Deployments) and create paths (Kubernetes Services) for sections to communicate with each other and with patrons. You use a navigation system (service mesh like Istio) to help patrons find their way and manage traffic flow. Carefully, you transfer the books to the new sections (data migration) and implement tools (Prometheus, Grafana) to monitor the library's operations, ensuring it runs smoothly.
This way, your new library is organized, scalable, and easy to maintain.
</details>

<details>
<summary><b>Q86: Scenario: How do you configure RBAC to restrict a user group `developers` to only list, get, and watch Pods inside the `staging` namespace?</b></summary>
<b>Answer:</b>
1. **Create Role:** Define a namespace-scoped `Role` specifying the API verbs allowed:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     namespace: staging
     name: pod-reader
   rules:
     - apiGroups: [""] # "" indicates the core API group
       resources: ["pods"]
       verbs: ["get", "list", "watch"]
   ```
2. **Create RoleBinding:** Bind the role to the group:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: read-pods-binding
     namespace: staging
   subjects:
     - kind: Group
       name: developers
       apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: Role
     name: pod-reader
     apiGroup: rbac.authorization.k8s.io
   ```
</details>

<details>
<summary><b>Q87: Scenario: A compromised Pod running a web scraper has read-only access to the cluster but you suspect it has stolen its Service Account credentials. How do you minimize the blast radius of Service Accounts?</b></summary>
<b>Answer:</b>
1. **Disable Token Auto-mounting:** In the PodSpec, set `automountServiceAccountToken: false` to prevent mounting the default Service Account token at `/var/run/secrets/kubernetes.io/serviceaccount`.
2. **Least Privilege RBAC:** Ensure the `default` Service Account in every namespace has no Roles or ClusterRoles bound to it.
3. **Bound Tokens:** Enforce short-lived, target-audience restricted projected tokens instead of long-lived secrets.
</details>

<details>
<summary><b>Q88: Scenario: You query a Pod status and see `OOMKilled`. What does this tell you about the container process, and what are the immediate remediation steps?</b></summary>
<b>Answer:</b>
1. **The Meaning:** The container consumed more memory than allowed by its `resources.limits.memory` threshold, causing the OS kernel to send a SIGKILL (`Exit Code 137`) to the process.
2. **Remediation Steps:**
   - Check application memory logs to identify if a **memory leak** is causing the crash.
   - If the usage is normal but the workload has scaled, increase the memory limit in the Deployment YAML.
   - Configure a Vertical Pod Autoscaler (VPA) to recommend optimal limits.
</details>

<details>
<summary><b>Q89: Scenario: How do you configure a centralized logging agent (like Fluent Bit) to tail logs from all running containers on a node? Where are container logs stored on the host OS?</b></summary>
<b>Answer:</b>
1. **Log Location:** By default, stdout/stderr from containers is redirected to files on the host OS node at:
   ```text
   /var/log/pods/
   # which symlinks to /var/log/containers/
   ```
2. **Agent Configuration:** Mount `/var/log/pods` and `/var/log/containers` as `hostPath` volumes into the Fluent Bit DaemonSet. Configure the input filter to tail these paths, parse them, and forward logs to a centralized elastic search endpoint.
</details>

<details>
<summary><b>Q90: Scenario: Your HPA is scaling Pods up and down continuously within a 5-minute window due to minor CPU fluctuations. How do you prevent this "flapping" behavior?</b></summary>
<b>Answer:</b>
Configure HPA **Stabilization Windows** inside the scaling policy behavior spec:
```yaml
spec:
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300 # Wait 5 minutes before applying scale-down
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
```
This forces the HPA to evaluate historical load over the stabilization window, smoothing out scale-down events and preventing rapid fluctuations.
</details>

<details>
<summary><b>Q91: Scenario: You want to run a database Pod that requires low latency. How do you force the scheduler to place the Pod on the same physical server rack as a companion cache Pod?</b></summary>
<b>Answer:</b>
Use **Pod Affiliation (podAffinity)**:
Configure the database Pod spec to target nodes where a Pod matching label `app: cache` is already scheduled, matching on the host topology key:
```yaml
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - cache
          topologyKey: kubernetes.io/hostname # Pins both to the same host node
```
</details>

<details>
<summary><b>Q92: Scenario: You want to isolate production worker nodes so they only host production database workloads, preventing dev/staging workloads from scheduling on them. How do you configure this?</b></summary>
<b>Answer:</b>
Use a combination of **Taints and Tolerations**:
1. **Taint the Nodes:** Add a taint to the production nodes:
   ```bash
   kubectl taint nodes prod-node-1 key=database:NoSchedule
   ```
2. **Configure Tolerations:** Add a toleration to the production database Pod specs:
   ```yaml
   spec:
     tolerations:
       - key: "database"
         operator: "Equal"
         value: "database"
         effect: "NoSchedule"
   ```
Dev/Staging Pods without this toleration will be blocked from scheduling on the database nodes.
</details>

<details>
<summary><b>Q93: Scenario: How do you integrate security checks into a Jenkins pipeline to prevent container images with critical security vulnerabilities from being deployed to Kubernetes?</b></summary>
<b>Answer:</b>
1. **Image Scan Step:** Add a pipeline build step to run **Trivy** or **Clair** after building the container image.
2. **Scan Command:**
   ```bash
   trivy image --exit-code 1 --severity CRITICAL myapp:latest
   ```
3. **Pipeline Failure:** If Trivy detects any vulnerability with severity `CRITICAL`, the command exits with code `1`, breaking the pipeline and preventing the deployment step.
</details>

<details>
<summary><b>Q94: Scenario: You need to perform OS updates on a worker node. How do you safely empty the node of all running Pods without affecting application uptime?</b></summary>
<b>Answer:</b>
1. **Cordon the Node:** Mark the node as unschedulable to prevent new Pods from starting:
   ```bash
   kubectl cordon worker-node-1
   ```
2. **Drain the Node:** Evict all running Pods:
   ```bash
   kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data
   ```
3. **Perform Updates:** Complete host maintenance, reboot, and allow scheduling again:
   ```bash
   kubectl uncordon worker-node-1
   ```
</details>

<details>
<summary><b>Q95: Scenario: You need to audit who modified a specific ConfigMap in the `kube-system` namespace. What configuration do you check?</b></summary>
<b>Answer:</b>
1. **Kubernetes Audit Logs:** Check the cluster's Audit Log file (configured on the API Server via `--audit-log-path`).
2. **Audit Policy:** Ensure your `AuditPolicy` file includes rules to track metadata or request/response payloads for the target resource:
   ```yaml
   rules:
     - level: RequestResponse
       resources:
         - group: ""
           resources: ["configmaps"]
       namespaces: ["kube-system"]
   ```
</details>

<details>
<summary><b>Q96: Scenario: How do you troubleshoot network packet loss inside a running container that does not have troubleshooting tools (like curl, ping, tcpdump) installed?</b></summary>
<b>Answer:</b>
Use **Ephemeral Debug Containers**:
Run `kubectl debug` to attach an interactive troubleshooting container containing network utilities (`netshoot`) sharing the network namespace of the target Pod:
```bash
kubectl debug -it my-running-pod --image=nicolaka/netshoot --target=my-app-container
```
You can now run `tcpdump` or `ping` inside the debug container to inspect traffic.
</details>

<details>
<summary><b>Q97: Scenario: The Cluster Autoscaler is failing to scale down an underutilized worker node. What Pod configurations or constraints could prevent the autoscaler from evicting Pods from the node?</b></summary>
<b>Answer:</b>
1. **No Controller:** The Pod running on the node was created manually (bypassing Deployments/ReplicaSets) and has no parent controller, meaning evicting it would delete it permanently.
2. **Local Storage:** The Pod mounts `emptyDir` or local storage volumes.
3. **Pod Disruption Budget (PDB):** Evicting the Pod would violate a PDB constraint.
4. **Affinity Rules:** The Pod cannot be scheduled on other active nodes due to anti-affinity constraints.
</details>

<details>
<summary><b>Q98: Scenario: You are running a web application with 2 replicas. How do you configure a Pod Disruption Budget (PDB) to safeguard availability during node maintenance?</b></summary>
<b>Answer:</b>
Define a PDB specifying the minimum number of healthy replicas that must remain active:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-app-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: web-app
```
During a node drain, the API server will block eviction of the second replica until a new replica is running on another node.
</details>

<details>
<summary><b>Q99: Scenario: A Pod fails to start and displays `ImagePullBackOff`. You verify the image tag is correct. What credentials configurations do you check?</b></summary>
<b>Answer:</b>
1. **Registry Secrets:** Ensure you have created a Docker registry secret containing login credentials:
   ```bash
   kubectl create secret docker-registry registry-secret --docker-username=user --docker-password=pass
   ```
2. **Pod Specification:** Ensure the secret is referenced in the Pod spec under the `imagePullSecrets` array:
   ```yaml
   spec:
     imagePullSecrets:
       - name: registry-secret
   ```
</details>

<details>
<summary><b>Q100: Scenario: Describe the step-by-step process of upgrading the OS kernel on all worker nodes in a production cluster.</b></summary>
<b>Answer:</b>
Perform a rolling upgrade sequence:
1. **Evict Pods:** Run `kubectl cordon` followed by `kubectl drain` on the first worker node.
2. **Update OS:** Perform kernel updates, upgrade system packages, and reboot the physical server/VM.
3. **Verify Health:** Verify that the `kubelet` service starts successfully and reports health.
4. **Restore Scheduling:** Run `kubectl uncordon` to re-allow workloads on the node.
5. **Repeat:** Move to the next node in the cluster sequentially, monitoring application performance throughout.
</details>
