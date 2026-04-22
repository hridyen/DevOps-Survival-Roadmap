[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ DynamoDB Learning Resources

> Mastery-level guides for NoSQL data modeling and global scaling.

---

### ✦ Core Learning Path

| Type | Resource Name | Description | Key Focus |
|---|---|---|---|
| **Workshop** | [DynamoDB Global Tables](https://amazon-dynamodb-labs.com/) | Hands-on labs for multi-region replication. | Global Scaling |
| **Guide** | [NoSQL Design Patterns](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html) | Official best practices for scale and cost. | Data Modeling |
| **Video** | [Advanced Data Modeling](https://www.youtube.com/watch?v=6yqfmUm-Y74) | Rick Houlihan's legendary re:Invent session. | One Table Design |
| **Blog** | [DynamoDB Pricing Explained](https://aws.amazon.com/dynamodb/pricing/) | Comprehensive breakdown of RCU, WCU, and Storage. | Cost Optimization |

---

### ✦ Essential Tools
- **[NoSQL Workbench](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html):** A visual tool to design and query your DynamoDB tables locally.
- **[DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html):** A downloadable version of DynamoDB for local development.

---

### ✦ Community Favorites
- **[Dynobase](https://dynobase.dev/):** A professional GUI for DynamoDB management.
- **[The DynamoDB Book](https://www.dynamodbbook.com/):** Alex DeBrie's guide to modeling single-table designs.

---

> [!CAUTION]
> **Performance Alert:** Avoid "Scans" at all costs in production. Always design your table so that 99% of your access patterns are covered by "Queries" using Partition Keys and Sort Keys.
