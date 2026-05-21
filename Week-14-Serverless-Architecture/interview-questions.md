# ⚡ Week 14 — Serverless Architecture Interview Q&As

This document compiles **10 advanced, scenario-based interview questions and answers** on AWS Lambda, API Gateway, DynamoDB, Cognito, and edge scripting.

---

## ✦ Interview Questions & Answers

<details>
<summary><b>Q1: Scenario: You have a Java-based Lambda function behind API Gateway that experiences significant latency spikes (up to 5 seconds) when it is first invoked or after a period of inactivity. How do you troubleshoot and mitigate this cold start issue?</b></summary>
<b>Answer:</b>
This is caused by **Lambda Cold Starts** (the time AWS takes to provision the execution environment, download the code, and initialize the runtime/JVM).
- **Mitigation Strategies:**
  1. **Provisioned Concurrency:** Pre-warms a specified number of execution environments, keeping them ready to respond instantly. This completely eliminates cold starts but incurs a persistent cost.
  2. **AWS Lambda SnapStart:** For Java (specifically Java 11/17/21 runtimes), enable SnapStart. AWS initializes the function during deployment, takes a snapshot of the encrypted firecracker VM state, and caches it. On invocation, it restores the VM state from the snapshot, reducing cold starts to sub-second levels at no extra cost.
  3. **Runtime Choice:** Use lightweight runtimes (Node.js, Python, Go, Rust) if possible, which have significantly faster startup times compared to Java/JVM.
  4. **Code Optimization:** Minimize package size, reduce framework usage (e.g., avoid full Spring Boot, use Spring Cloud Function or Quarkus/Micronaut), and instantiate database clients outside the handler method so they are cached across warm invocations.
</details>

<details>
<summary><b>Q2: Scenario: Your Lambda function processes files from an S3 bucket. You notice that when processing large files, it runs out of memory and crashes. When you increase the memory from 128 MB to 3008 MB, the file is processed 10x faster, and the overall execution cost decreases. Why does this happen?</b></summary>
<b>Answer:</b>
AWS allocates **CPU power proportionally to the memory provisioned** for a Lambda function:
1. **CPU Scaling:** At 1,769 MB of memory, a Lambda function is allocated exactly 1 full vCPU. Below this, it gets a fraction of a vCPU; above this, it gets multiple vCPUs (up to 10 GB memory / 6 vCPUs).
2. **Performance Boost:** By increasing memory from 128 MB to 3008 MB, the function is allocated full vCPU processing cores. Compute-bound tasks (like processing/parsing files) execute significantly faster.
3. **Cost Efficiency:** Lambda is billed based on GB-seconds (memory allocated * execution duration). If an increase in memory reduces the execution time by a larger factor than the memory increase, the overall cost of the run is actually lower.
4. **Optimization:** Use **AWS Lambda Power Tuning** (an open-source state machine tool) to run your function at different memory levels, automatically plotting a chart to find the sweet spot between cost and execution speed.
</details>

<details>
<summary><b>Q3: Scenario: What is the difference between an API Gateway Lambda Proxy Integration and a Lambda Custom (Non-Proxy) Integration? When would you use one over the other?</b></summary>
<b>Answer:</b>
- **Lambda Proxy Integration (Recommended):**
  - *Mechanism:* API Gateway passes the raw HTTP request (headers, query parameters, path variables, request context, and body) directly to the Lambda function as a single JSON object. The Lambda function must format its output exactly in JSON (containing `statusCode`, `headers`, and `body`).
  - *When to use:* Standard setups where the backend code handles all routing, request validation, and response construction.
- **Lambda Custom Integration:**
  - *Mechanism:* You write **VTL (Velocity Template Language) Mapping Templates** in API Gateway to transform the incoming request body/parameters before passing it to Lambda. You also define response mappings to transform Lambda outputs into HTTP codes.
  - *When to use:* Legacy integrations where you want to expose a REST API but keep the Lambda function input clean of HTTP metadata, or when you are integrating API Gateway directly with other AWS services (like S3 or DynamoDB) without using a Lambda function at all.
</details>

<details>
<summary><b>Q4: Scenario: You need to implement user authentication and authorize authenticated users to upload files directly to an S3 bucket. How do you integrate AWS Cognito User Pools and Identity Pools to accomplish this?</b></summary>
<b>Answer:</b>
Use the combination of **Cognito User Pools** and **Cognito Identity Pools (Federated Identities)**:
1. **Authentication (User Pools):**
   - The user registers and logs in via Cognito User Pools.
   - Cognito User Pools validates the credentials and returns a set of JWT tokens (ID Token, Access Token, Refresh Token) to the client.
2. **Authorization (Identity Pools):**
   - The client takes the JWT ID Token and sends a request to **Cognito Identity Pools** (`AssumeRoleWithWebIdentity`).
   - Cognito Identity Pools validates the token, maps the user to an IAM role (e.g. `Cognito_Authorized_User_S3_Upload_Role`), and issues temporary, short-lived AWS IAM Credentials (Access Key, Secret Key, Session Token) to the client.
3. **S3 Upload:**
   - The client browser uses these temporary IAM credentials directly to call the S3 `PutObject` API to upload the file to S3.
</details>

<details>
<summary><b>Q5: Scenario: You are designing a database schema in DynamoDB for an order-tracking application. A customer has many orders, and you need to query: (a) All orders for a specific customer, and (b) A specific order by its unique Order ID. How do you design this using DynamoDB keys?</b></summary>
<b>Answer:</b>
Use a **Single-Table Design** with composite primary keys (Partition Key `PK` and Sort Key `SK`):
1. **Entities mapping:**
   - **Customer Record:** `PK` = `CUSTOMER#<CustomerID>`, `SK` = `METADATA#<CustomerID>` (stores customer profile info).
   - **Order Record:** `PK` = `CUSTOMER#<CustomerID>`, `SK` = `ORDER#<OrderID>` (stores order details).
2. **Querying Patterns:**
   - **Query (a) All orders for a specific customer:** Run a `Query` operation where `PK = CUSTOMER#<CustomerID>` and `SK begins_with("ORDER#")`. This retrieves all order records for that customer in a single round-trip.
   - **Query (b) A specific order by Order ID:** If you only have `OrderID` and not `CustomerID`, searching using the partition key above is not possible. You must create a **Global Secondary Index (GSI)** where the GSI Partition Key `GSI1PK` is `ORDER#<OrderID>` and `GSI1SK` is `ORDER#<OrderID>`. Querying this GSI retrieves the order details instantly.
</details>

<details>
<summary><b>Q6: Scenario: What is the difference between a Local Secondary Index (LSI) and a Global Secondary Index (GSI) in DynamoDB? How do they affect write throughput capacity (WCU) and database scale?</b></summary>
<b>Answer:</b>
- **Local Secondary Index (LSI):**
  - Must share the **same Partition Key** as the base table, but has a **different Sort Key**.
  - Must be created during **table creation time** (cannot be added later).
  - Uses the **WCU/RCU capacity of the parent table**.
  - Limits the total size of items with the same partition key to **10 GB** (item collection limit).
- **Global Secondary Index (GSI):**
  - Can have a **different Partition Key and different Sort Key** than the base table.
  - Can be created or deleted **at any time**.
  - Has its **own provisioned throughput (WCU/RCU)**.
  - Has no size limit; it can scale infinitely across partitions.
- **WCU Impact:** When you write to a table with an LSI or GSI, DynamoDB automatically updates the index. For GSIs, if the index has insufficient WCUs, writes to the base table will be **throttled** (Backpressure), so index capacity must be scaled to match the write rate of the parent table.
</details>

<details>
<summary><b>Q7: Scenario: Every time a customer updates their email address in DynamoDB, you need to automatically update a third-party CRM system and send a confirmation email. How do you implement this asynchronously?</b></summary>
<b>Answer:</b>
Use **DynamoDB Streams** integrated with **AWS Lambda**:
1. **Enable Streams:** Enable DynamoDB Streams on the base table. Choose the stream view type: `NEW_AND_OLD_IMAGES` (so you can compare what changed).
2. **Lambda Trigger:** Create an AWS Lambda function and configure the DynamoDB Stream as its event source.
3. **Asynchronous Execution:** 
   - When a row updates, DynamoDB writes a change log record to the stream.
   - The AWS Lambda service polls the stream and invokes the function with a batch of stream records.
   - The Lambda function checks the record: if the email changed (`oldImage.email != newImage.email`), it triggers the API calls to the third-party CRM and invokes Amazon SES (Simple Email Service) to send the confirmation.
   - If the Lambda run fails, it will retry until success or until the records expire in the stream (24-hour retention).
</details>

<details>
<summary><b>Q8: Scenario: You want to rewrite request URLs (e.g. changing `domain.com/docs` to `domain.com/documentation/index.html`) at the edge before sending them to your origin. Would you use Lambda@Edge or CloudFront Functions? Explain your choice.</b></summary>
<b>Answer:</b>
Use **CloudFront Functions** for this scenario.
- **Comparison & Selection:**
  - **CloudFront Functions:** 
    - Optimized for lightweight, sub-millisecond execution (written in JavaScript).
    - Executes at the Edge Location closest to the user.
    - Extremely cost-effective (1/6th the cost of Lambda@Edge).
    - Perfect for header manipulation, URL rewrites, and simple redirects.
  - **Lambda@Edge:**
    - Full Node.js/Python runtimes executing at Regional Edge Caches.
    - Supports network calls, file system access, and larger packages.
    - Incurs higher cold-start times and higher execution cost.
- **Decision:** Since URL rewriting does not require database querying or external API requests, CloudFront Functions is the optimal, lowest-latency, and most cost-effective choice.
</details>

<details>
<summary><b>Q9: Scenario: Under what traffic conditions would you choose DynamoDB On-Demand capacity mode over Provisioned capacity mode?</b></summary>
<b>Answer:</b>
- **Choose On-Demand Capacity Mode when:**
  1. The workload experiences **unpredictable, highly spikey traffic** (e.g. apps that remain idle and suddenly jump to thousands of queries).
  2. You do not want to configure auto-scaling policies or manage capacity parameters.
  3. You are launching a new product where the read/write load profile is completely unknown.
- **Choose Provisioned Capacity Mode (with Auto Scaling) when:**
  1. Traffic is **predictable and consistent**, or fluctuates gradually over time.
  2. You want to control and cap costs to prevent budget overruns during DDoS attacks.
  3. You run a high-volume application where provisioning capacity is cheaper (usually 50-70% savings compared to On-Demand unit costs).
</details>

<details>
<summary><b>Q10: Scenario: Your Serverless application consists of a Lambda function and a DynamoDB table. How do you configure local testing so developers can run and debug the entire stack on their local machines before deploying to AWS?</b></summary>
<b>Answer:</b>
1. **Serverless Offline Plugin:** Install the `serverless-offline` plugin into your `serverless.yml` config. This launches a local Node.js server that emulates API Gateway and runs your Lambda functions locally.
2. **Local DynamoDB:** Use the `serverless-dynamodb-local` plugin or run DynamoDB Local as a Docker container:
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```
3. **Application Configuration:** Update your Lambda function's database client initialization code to check for a local environment flag and point the endpoint to the local container:
   ```javascript
   const docClient = new AWS.DynamoDB.DocumentClient(
     process.env.IS_OFFLINE 
       ? { endpoint: 'http://localhost:8000', region: 'localhost' } 
       : {}
   );
   ```
</details>
