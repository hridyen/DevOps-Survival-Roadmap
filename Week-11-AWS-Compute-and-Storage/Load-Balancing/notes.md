[![Sector](https://img.shields.io/badge/SECTOR-AWS_Traffic_Management-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Load_Balancing_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚖️ Industrial AWS Traffic Management — Load Balancing & HA

> **Architectural Goal:** Transition from "Single-Instance Bottlenecks" to "Scalable, High-Availability" multi-zonal distribution.

---

## ✦ 1. Scalability vs Elasticity (The DevOps Core)

**Scalability** is the ability to handle greater loads by adapting resources. 

- **Vertical Scalability (Scale UP)**: Increase or decrease the size of a single instance (t2.medium -> r5.2xlarge).
- **Horizontal Scalability (Elasticity)**: Add or remove instances to match application demand.
- **High Availability (HA)**: Running your application across at least **2 Availability Zones (AZs)** at all times.

---

## ✦ 2. Application Load Balancer (ALB) — Layer 7 Advanced Logic

ALB is the brain of the modern microservices stack. It doesn't just "split" traffic; it "thinks" before routing.

```mermaid
graph TD
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef highlight fill:#0A0A0A,stroke:#FF0055,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;

    L["ALB Listener (HTTPS:443)"] --> R1["Rule 1: /api/*"]
    L --> R2["Rule 2: /web/*"]
    L --> DF["Default Rule"]

    R1 --> TG1["Target Group: API Clusters"]:::highlight
    R2 --> TG2["Target Group: Web Frontend"]
    DF --> TG3["Target Group: Multi-Region"]

    TG1 --> I1["EC2 Instances"]
    TG2 --> I2["EC2 Instances"]
    TG3 --> I3["EC2 Instances"]
```

### ✦ The ALB Multi-Condition Matrix
ALB can route to different target groups based on complex logic.

| Condition Type | Value / Pattern | Real-World Use Case |
|---|---|---|
| **Host Header** | `api.myapp.com` | Hosting multiple subdomains/microservices on a single ALB. |
| **Path Pattern** | `/v2/users/*` | Version-based routing for API updates (A/B Testing). |
| **HTTP Header** | `User-Agent: Mobile` | Routing specialized traffic to mobile backend clusters. |
| **Query String** | `?debug=true` | Routing developers to internal logs or staging targets. |
| **Source IP** | `10.0.0.0/24` | Whitelisting internal office IPs for admin panel access. |

---

## ✦ 3. Network Load Balancer (NLB) & SNI Security

### ✦ NLB: High-Performance Distribution (Layer 4)
- **Static IPs**: Unlike ALB, NLB provides **one static IP per AZ** using **Elastic IPs**.
- **Ultra-Low Latency**: Handles millions of connections per second for TCP/UDP Gaming/IoT.

### ✦ SNI (Server Name Indication) — The Multi-Site Solution
- **The Problem**: Traditionally, one listener = one SSL cert.
- **The Solution**: SNI allows the ALB to look at the hostname during the SSL handshake and **Pick the Correct Certificate**.
- **Availability**: Available for **ALB** and **NLB** (Not Legacy CLB).

```mermaid
graph LR
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef highlight fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;

    Client["Internet Client (HTTPS)"] -->|Requests: app.myapp.com| SNI["ALB (SNI Engine)"]
    
    SNI -->|Matching| C1["Certificate: app.myapp.com"]:::highlight
    SNI -->|Matching| C2["Certificate: shop.myapp.com"]
    SNI -->|Default| C3["Wildcard Certificate (*.myapp.com)"]
```

---

## ✦ 4. Traffic Resilience & Cost

### ✦ Cross-Zone Load Balancing (Industrial Deep-Dive)
When you have instances spread across AZs, cross-zone load balancing controls whether traffic is balanced across ALL instances or only within each AZ.

| LB Type | Behavior | Inter-AZ Data Cost |
|---|---|---|
| **ALB** | Enabled by default | **Free** |
| **NLB** | Disabled by default | You pay if enabled |
| **CLB** | Enabled by default | **Free** |

```mermaid
graph TD
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef highlight fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;

    subgraph Cross-Zone_ENABLED
        L1["ALB Node (AZ-A)"] -->|"25% load"| A1["In-AZ Instance"]
        L1 -->|"25% load"| A2["In-AZ Instance"]
        L1 -->|"25% load"| B1["Cross-AZ Instance"]:::highlight
        L1 -->|"25% load"| B2["Cross-AZ Instance"]:::highlight
    end

    subgraph Cross-Zone_DISABLED
        L2["NLB Node (AZ-A)"] -->|"50% load"| S1["In-AZ Instance"]
        L2 -->|"50% load"| S2["In-AZ Instance"]
        L2 -.->|"No Traffic"| S3["Cross-AZ Instance (Idle)"]
    end
```

### ✦ Connection Draining (Deregistration Delay)
When an instance is removed (e.g., during scale-in), the Load Balancer keeps the connection open for a **cooldown period** (default: 300s) to let active users finish their requests.

---

## ✦ Technical Deep-Dive Checklist
- [ ] Configure an **ALB Listener Rule** with multiple conditions (Host + Path).
- [ ] Enable **Cross-Zone Load Balancing** and verify distribution efficiency.
- [ ] Implement **SSL Termination** using a free certificate from **AWS ACM (Certificate Manager)**.
- [ ] Adjust **Deregistration Delay** to 60 seconds for faster scale-in during testing.
- [ ] Set up an **NLB with a Static Elastic IP**.
