[![Sector](https://img.shields.io/badge/SECTOR-Docker_Containerization-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Docker_Swarm_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Docker Swarm Configurations

> **Focus:** Multi-Host container architecture natively natively, Manager-Worker hierarchies natively, and Overlay mesh networking natively.

---

## ✦ 1. The Swarm Control Topology

Docker fundamentally operates gracefully natively on a singular machine locally. A **Swarm** physically interconnects multiple disparate cloud servers intelligently natively acting as one unified computing pool natively.

```mermaid
graph TD
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef leader fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;

    Manager[Master Manager Hub<br>IP: 10.0.0.100]:::leader

    Worker1[Worker Node 01<br>IP: 10.0.0.101]
    Worker2[Worker Node 02<br>IP: 10.0.0.102]
    Worker3[Worker Node 03<br>IP: 10.0.0.103]

    Manager --->|Dispatches Task A| Worker1
    Manager --->|Dispatches Task B| Worker2
    Manager --->|Dispatches Task C| Worker3
```

---

## ✦ 2. Abstract Networking (The Overlay Mesh)

Standard bridge networks isolate completely containers onto a single host securely.
When deploying scaling Web Servers blindly gracefully across 3 different physical Worker Nodes gracefully securely, Docker relies fundamentally exclusively natively on an **Overlay Network** to automatically route tracking packets dynamically natively between machines transparently!

> [!WARNING]
> Overlay networking structurally relies gracefully completely natively forcefully on Firewall Port `2377` for swarm management bindings, and `4789` for physical data-plane overlays natively!

---

- [ ] Deploy an arbitrary global service intelligently natively using `docker service create` specifically defining `--replicas 3`.

---

## ✦ Personal Notes

- **The Manager Quorum:** In a production Swarm, always use an odd number of Managers (3 or 5). This prevents "Split-Brain" scenarios where the cluster doesn't know who the leader is if a network partition occurs.
- **Service vs. Container:** In Swarm, you don't manage containers directly; you manage **Services**. If a container dies, the Swarm Manager detects the delta from the desired state and automatically recreates it on a healthy node.
- **Routing Mesh Convenience:** One of the coolest features of Swarm is the **Routing Mesh**. You can hit the IP of *any* node in the cluster on the service port, and Docker will internally route your request to a node that is actually running the container.

---

## ✦ 🔗 Resources

See [resources.md](./resources.md)
