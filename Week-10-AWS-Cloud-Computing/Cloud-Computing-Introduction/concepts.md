# ☁️ Cloud Computing — Concepts Cheat Sheet

> Quick reference — use this for revision and interview prep.

---

## Deployment Models
| Model | One Line |
|---|---|
| Private | Your cloud, your org only |
| Public | AWS/Azure/GCP — shared infra |
| Hybrid | Mix of both |

## Service Models
| Model | You Manage | AWS Example |
|---|---|---|
| IaaS | OS + App + Data | EC2 |
| PaaS | App + Data only | Elastic Beanstalk |
| SaaS | Nothing — just use it | Chime, Gmail |

## AWS Infrastructure
| Layer | Count | Use |
|---|---|---|
| Regions | 33+ | Deploy apps |
| AZs | 100+ | High availability |
| Edge Locations | 400+ | CDN / DNS |

## Region Selection — 4 Factors
```
1. Compliance  → data residency laws
2. Latency     → closest to users
3. Services    → not all services in all regions
4. Pricing     → varies by region
```

## Pricing — What Is Free vs Paid
```
FREE:  Data transfer INTO AWS
PAID:  Compute time (EC2 hours)
PAID:  Storage (S3, EBS GB/month)
PAID:  Data transfer OUT to internet
```

## Shared Responsibility — One Line Each
```
AWS  → secures the building, hardware, hypervisor, network
YOU  → secures your data, OS, app, IAM, firewall rules
```

## Responsibility by Service
| Service | AWS Does | You Do |
|---|---|---|
| EC2 (IaaS) | Hardware | OS patches, app, firewall |
| RDS (PaaS) | DB engine patches | DB access, encryption |
| S3 | Storage durability | Bucket policies, permissions |
| Lambda | Everything except code | Your function logic |

## 5 Characteristics (NIST)
```
1. On-demand self-service
2. Broad network access
3. Resource pooling
4. Rapid elasticity
5. Measured service
```
