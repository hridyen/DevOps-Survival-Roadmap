[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ AWS Lambda Learning Resources

> A collection of industrial-grade guides, labs, and documentation for master-level serverless engineering.

---

### ✦ Core Learning Path

| Type | Resource Name | Description | Key Focus |
|---|---|---|---|
| **Workshop** | [AWS Lambda Foundations](https://lambda-foundations.workshop.aws/) | Hands-on introduction to triggers and execution. | Triggers & Logic |
| **Blog** | [Operating Lambda Series](https://aws.amazon.com/blogs/compute/tag/operating-lambda/) | Deep dive into scaling, security, and performance. | Advanced Ops |
| **Lab** | [Visualizing Serverless](https://serverlessland.com/patterns/) | Pattern library for serverless architectures. | Architecture Patterns |
| **GitHub** | [AWS Lambda Powertools](https://github.com/aws-powertools) | Suite of utilities for Lambda (Python, JS, Java). | Logging & Tracing |

---

### ✦ Expert Cheat Sheets

- **[Serverless Land](https://serverlessland.com/):** The ultimate source for serverless patterns and blog posts.
- **[AWS Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html):** Official documentation of regional and function-level quotas.
- **[Cold Start Analysis](https://github.com/NathanMalishev/lambda-cold-starts):** Comparison of cold starts across different runtimes.

---

### ✦ Interactive Sandboxes
- **[AWS CloudShell](https://aws.amazon.com/cloudshell/):** Test CLI commands in a browser-based environment.
- **[LocalStack](https://github.com/localstack/localstack):** Run Lambda and other AWS services locally on Docker.

---

> [!TIP]
> **Learning Tip:** When monitoring Lambda performance, focus on **Duration** vs. **Billed Duration**. AWS rounds down to 1ms for billing, but significant overhead in your code will still impact real-user latency.
