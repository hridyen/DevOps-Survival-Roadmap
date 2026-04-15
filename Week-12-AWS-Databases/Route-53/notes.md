[![Sector](https://img.shields.io/badge/SECTOR-NETWORKING-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Amazon Route 53

> **Week:** 12
> **Folder:** Route-53
> **Topic:** Managed DNS, Traffic Flow & 100% Availability Engineering

---

## ✦ Why Route 53 in DevOps?

IP addresses are for machines; domain names are for humans. Route 53 is the globally distributed service that bridges this gap while providing advanced routing logic for high availability.

> **Why the name "53"?** It refers to the traditional **UDP/TCP Port 53**, which is the industry standard port for DNS traffic resolution.

```mermaid
graph LR
    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;
    classDef highlight fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;

    User[User: app.com] --> R53{Route 53}:::highlight
    R53 -- "US Users" --> US[N. Virginia Region]
    R53 -- "EU Users" --> EU[Ireland Region]
    R53 -- "Failover" --> DR[Disaster Recovery Site]
```

---

---

## ✦ 1. DNS Terminology Breakdown
Understanding the anatomy of a URL is critical for configuring Hosted Zones.

| Term | Detail | Example |
|---|---|---|
| **TLD** | Top Level Domain | `.com`, `.org`, `.in` |
| **SLD** | Second Level Domain | `google`, `amazon`, `example` |
| **Subdomain** | Prefixed lower level | `api`, `www`, `dev` |
| **FQDN** | Fully Qualified Domain Name | `api.www.example.com.` |
| **Authoritative NS** | Server that holds the final answer | Route 53 Name Servers |

---

## ✦ 2. DNS Resolution Architecture

Understanding how a query is resolved globally is essential for troubleshooting latency.

```mermaid
sequenceDiagram
    participant U as Host/Client
    participant L as Resolver (ISP)
    participant R as Route 53 (Authoritative)
    
    U->>L: What is app.devops.com?
    L->>L: Check Cache
    L->>R: Ask Authoritative NS
    R-->>L: A Record: 54.22.33.44 (TTL: 300s)
    L-->>U: IP: 54.22.33.44
```

---

## ✦ 2. Critical Record Types

| Record | Function | DevOps Use Case |
|---|---|---|
| **A** | Hostname -> IPv4 | Standard server mapping. |
| **AAAA** | Hostname -> IPv6 | Future-proofing & mobile network compatibility. |
| **CNAME** | Hostname -> Hostname | Mapping subdomains (e.g., `www`) to base domains. |
| **Alias** | Hostname -> AWS Resource | **Free** mapping for ELBs, S3, and CloudFront at the Root/Apex level. |

---

## ✦ 3. Advanced Routing Policies

Route 53 allows you to define complex traffic steering logic.

### ⚡ Policy Comparison Matrix

| Policy | Logic | Best For |
|---|---|---|
| **Simple** | 1:1 or 1:Many random | Basic single-server setups. |
| **Weighted** | Split traffic by % | **Canary Deployments** & A/B testing. |
| **Latency** | Closest region by speed | Global apps requiring high performance. |
| **Failover** | Health-check based | **Disaster Recovery** (Active-Passive). |
| **Geolocation** | Based on user's country | Licensing restrictions & local content. |
| **Multivalue** | Multiple healthy IPs | Client-side load balancing. |

---

## ✦ 4. Health Checks & Failover

Route 53 doesn't just route traffic; it monitors endpoints to ensure they are alive before sending users there.

```mermaid
graph TD
    classDef ok fill:#000,stroke:#39FF14,color:#fff;
    classDef fail fill:#000,stroke:#FF0055,color:#fff;

    A[Global Health Checkers] --> B{Is Endpoint Alive?}
    B -- "YES (200 OK)" --> C[Update DNS with IP]:::ok
    B -- "NO (Timeout/500)" --> D[Remove IP from Records]:::fail
    D --> E[Trigger CloudWatch Alarm]
```

---

## ✦ 🧠 Summary — Interview Ready

| Concept | The "Elevator Pitch" |
|---|---|
| **SLA** | Route 53 is the only AWS service with a **100% Availability SLA**. |
| **Alias vs CNAME** | Alias is AWS-native, works on root domains (`@`), and queries are **free**. |
| **Hosted Zone** | A container for records of a single domain. $0.50/mo. |
| **TTL** | Time-To-Live. Lower TTL (60s) is better for migrations; Higher (24h) is cheaper. |

---

## ✦ 🏃 Practice Exercises

- [ ] Create a **Public Hosted Zone** for a sandbox domain.
- [ ] Map an **Alias Record** to an existing Application Load Balancer.
- [ ] Configure **Weighted Routing** (90/10) between two EC2 web servers.
- [ ] Setup a **CloudWatch Alarm-based Health Check** that monitors disk space.
- [ ] Use `dig` or `nslookup` to verify the TTL and resolution path from your terminal.

---

---

## ✦ Personal Notes

- **DNS Troubleshooting:** Always use `dig` or `nslookup` to verify if a record has propagated. If the result matches what you set in AWS but the browser fails, it's likely a local cache or ISP issue.
- **Apex Record Strategy:** Always use **Alias** records instead of **CNAME** for your root domain (e.g., `example.com`). This ensures better performance and avoids DNS protocol issues that occur when using CNAME on an apex record. 
- **Health Check Latency:** Be aware that Route 53 health checks can take 15-30 seconds to detect a failure and another minute for DNS propagation to fully route traffic away. Design your app to handle these brief windows of partial availability.

---

---

## ✦ Contributor Deep Dive: External Integrations
> **Scenario:** Moving a domain from GoDaddy/Namecheap to AWS Route 53?

1. **Create Hosted Zone** in Route 53 first.
2. **Retrieve Name Servers** (the 4 unique NS records provided by AWS).
3. **Update NS Records** on your 3rd party registrar's dashboard.
4. **Wait for TTL/Propagation** (Domain Registrar != DNS Service).

---

## ✦ 🔗 Resources

| Resource | Link |
|---|---|
| Route 53 Documentation | https://docs.aws.amazon.com/route53/latest/developerguide/Welcome.html |
| Routing Policies | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html |
| Route 53 Pricing | https://aws.amazon.com/route53/pricing |
| AWS CLI Route 53 | https://docs.aws.amazon.com/cli/latest/reference/route53 |
| Dig Web Interface | https://www.digwebinterface.com/ |
