[![Sector](https://img.shields.io/badge/SECTOR-SERVERLESS-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-resources-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ API Gateway & Cognito Learning Resources

> Essential guides for securing your serverless perimeter.

---

### ✦ Core Learning Path

| Type | Resource Name | Description | Key Focus |
|---|---|---|---|
| **Documentation** | [API Gateway Endpoint Types](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-endpoint-types.html) | Deep dive into Edge vs Regional strategies. | Network Strategy |
| **Tutorial** | [Cognito User Pools vs Identity Pools](https://aws.amazon.com/blogs/mobile/understanding-amazon-cognito-user-pools-and-identity-pools/) | The definitive guide to the "two pools" system. | Auth Architecture |
| **Guide** | [Securing APIs with Cognito](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-integrate-with-cognito.html) | How to link Cognito JWTs to API Gateway. | Security Integration |
| **Tool** | [Postman API Gateway Export](https://learning.postman.com/docs/integrations/available-integrations/aws-api-gateway/) | Sync your AWS APIs directly to Postman. | Developer Velocity |

---

### ✦ Case Studies & Best Practices
- **[WebSocket APIs with Lambda](https://aws.amazon.com/blogs/compute/announcing-websocket-apis-in-amazon-api-gateway/):** Real-time communication without persistent servers.
- **[API Gateway Throttling Algorithms](https://alexzh.com/api-gateway-rate-limiting-algorithms/):** Understanding the Token Bucket algorithm used by AWS.

---

### ✦ Interactive Sandboxes
- **[Cognito Hosted UI Sandbox](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-app-integration.html):** Test out the "Sign-in" page without writing any frontend code.

---

> [!IMPORTANT]
> **Production Safety:** Never use API Keys for *security*. They are intended for *usage monitoring and throttling*. Use Cognito or IAM for actual authentication.
