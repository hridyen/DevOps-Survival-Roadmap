# ✦ DevSecOps & Web Servers Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Nginx & Apache Administration, SSL/TLS Certificates, Static & Dynamic Analysis, Container Security, Secrets Management, and Network Defense.

---

## ✦ Section 1: Nginx & Apache Web Server Administration (Questions 1-20)

<details>
<summary><b>Q1: Scenario: Nginx returns a "502 Bad Gateway" error to clients. What does this mean and how do you troubleshoot?</b></summary>
A 502 error means Nginx acted as a proxy or gateway and received an invalid response (or no response) from the upstream application server (e.g. Gunicorn, Node.js, PHP-FPM). Troubleshooting steps:
1. Verify if the backend service is running (`systemctl status backend`).
2. Check the Nginx error log (`/var/log/nginx/error.log`) to find the connection target (e.g. connection refused to Unix socket or IP port).
3. Verify firewall settings between Nginx and the upstream server.
</details>

<details>
<summary><b>Q2: Scenario: A client gets a "504 Gateway Timeout" when running a report. How do you resolve this in Nginx?</b></summary>
A 504 error means the upstream server took too long to respond. Increase the timeout thresholds in the Nginx location block:
```nginx
proxy_read_timeout 300s;
proxy_connect_timeout 300s;
proxy_send_timeout 300s;
```
Reload Nginx (`nginx -s reload`) and check if the upstream application's timeout configurations also need adjustment.
</details>

<details>
<summary><b>Q3: Scenario: You want to hide the Nginx version details from the HTTP response headers (e.g. `Server: nginx/1.18.0` to `Server: nginx`) for security obfuscation. How?</b></summary>
In `nginx.conf`, under the `http` context, add:
```nginx
server_tokens off;
```
Reload Nginx to apply changes.
</details>

<details>
<summary><b>Q4: Scenario: Clients get "413 Payload Too Large" when uploading a 50MB backup file. What parameter controls this?</b></summary>
Nginx restricts upload sizes. Increase the limit in `nginx.conf` under `http`, `server`, or `location` context:
```nginx
client_max_body_size 100M;
```
</details>

<details>
<summary><b>Q5: Scenario: You notice your website performance is slow under high load. How do you configure Nginx to compress response payloads (HTML, CSS, JS) on the fly?</b></summary>
Enable Gzip compression in `nginx.conf` under the `http` block:
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml;
gzip_min_length 1000;
```
</details>

<details>
<summary><b>Q6: Scenario: How do you configure Nginx to load balance traffic across three application server IPs: `10.0.0.1`, `10.0.0.2`, and `10.0.0.3` using round-robin?</b></summary>
Define an `upstream` block and reference it in `proxy_pass`:
```nginx
upstream app_backend {
    server 10.0.0.1:8080;
    server 10.0.0.2:8080;
    server 10.0.0.3:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://app_backend;
    }
}
```
</details>

<details>
<summary><b>Q7: Scenario: You want to configure the load balancer so that traffic from a specific client IP always routes to the same backend server (session stickiness). How?</b></summary>
Add the `ip_hash` directive inside the `upstream` block:
```nginx
upstream app_backend {
    ip_hash;
    server 10.0.0.1:8080;
    server 10.0.0.2:8080;
}
```
</details>

<details>
<summary><b>Q8: Scenario: You are migrating from Nginx to Apache. How do you configure Apache to act as a reverse proxy for `localhost:5000`?</b></summary>
Enable `mod_proxy` and `mod_proxy_http`, and add directives in your virtual host:
```apache
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:5000/
ProxyPassReverse / http://127.0.0.1:5000/
```
</details>

<details>
<summary><b>Q9: Scenario: In Apache, what file is used to configure folder-level settings dynamically without restarting the web server?</b></summary>
The `.htaccess` file. Note that `AllowOverride All` must be configured in the main configuration file for these settings to take effect.
</details>

<details>
<summary><b>Q10: Scenario: How do you configure Nginx to serve static files (images, PDF) directly from `/var/www/static` and proxy dynamic requests to `http://localhost:5000`?</b></summary>
Use specific location matches:
```nginx
server {
    listen 80;
    server_name example.com;

    location /static/ {
        alias /var/www/static/;
    }

    location / {
        proxy_pass http://localhost:5000;
    }
}
```
</details>

<details>
<summary><b>Q11: Scenario: You need to rewrite URL `http://example.com/old-page` to `http://example.com/new-page` permanently. How is this set up in Nginx?</b></summary>
Use the `rewrite` directive or a redirect return inside the server context:
```nginx
location = /old-page {
    return 301 /new-page;
}
```
</details>

<details>
<summary><b>Q12: Scenario: How do you configure Nginx rate-limiting to prevent brute force attacks on your `/login` endpoint (e.g. limit to 5 requests per minute per IP)?</b></summary>
Define a limit zone under `http` and apply it to the `/login` location:
```nginx
# Under http
limit_req_zone $binary_remote_addr zone=login_limit:10m rate=5r/m;

# Under server/location
location /login {
    limit_req zone=login_limit burst=5 nodelay;
    proxy_pass http://backend;
}
```
</details>

<details>
<summary><b>Q13: Scenario: An Apache virtual host is serving the wrong website. How do you debug the configuration priority and order?</b></summary>
Run:
```bash
apachectl -S
```
or `httpd -S` to print the parsed virtual hosts config tree, showing match priority, ports, and configuration file names.
</details>

<details>
<summary><b>Q14: Scenario: Nginx returns a "403 Forbidden" error when trying to access a static file. You have confirmed file permission is `755`. What else could be wrong?</b></summary>
Check **SELinux** configurations (if using CentOS/RHEL/Fedora). Run `ls -Z` to check contexts. SELinux will block Nginx unless files have `httpd_sys_content_t` context. Fix using:
```bash
sudo chcon -R -t httpd_sys_content_t /var/www/static
```
Alternatively, verify if parent directories (e.g. `/home/user`) lack execute permissions for the `nginx` user.
</details>

<details>
<summary><b>Q15: Scenario: You want to enable HTTP/2 on your Nginx server. What are the requirements?</b></summary>
1. SSL/TLS must be configured (HTTP/2 requires encryption in modern browsers).
2. Append `http2` to the `listen` directive:
```nginx
listen 443 ssl http2;
```
</details>

<details>
<summary><b>Q16: Scenario: How do you check if your Apache service configurations are syntactically correct before restarting?</b></summary>
Run:
```bash
apachectl configtest
```
or `httpd -t`.
</details>

<details>
<summary><b>Q17: Scenario: What is the purpose of the `mod_security` module in Apache?</b></summary>
`mod_security` is an open-source Web Application Firewall (WAF) module that inspects incoming HTTP payloads in real-time, detecting and blocking attacks like SQL Injection, Cross-Site Scripting (XSS), and session hijacking.
</details>

<details>
<summary><b>Q18: Scenario: You want to configure Apache to run on port 8080 instead of default 80. What files and lines need to be edited?</b></summary>
Edit `/etc/httpd/conf/httpd.conf` (RedHat) or `/etc/apache2/ports.conf` (Ubuntu). Change the `Listen` directive:
```apache
Listen 8080
```
Also update `<VirtualHost *:8080>` blocks.
</details>

<details>
<summary><b>Q19: Scenario: How do you configure Nginx to catch all undefined server names and reject them?</b></summary>
Configure a default server block that returns a `444` (Connection closed without response) or `400`:
```nginx
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
```
</details>

<details>
<summary><b>Q20: Scenario: How does the worker processes and connections settings in `nginx.conf` relate to hardware capability?</b></summary>
Set `worker_processes` to `auto` (which spawns one worker per CPU core). The total concurrent connections limit is computed as: `worker_processes * worker_connections`. Ensure system file descriptor limits (`ulimit -n`) are set high enough to accommodate these connections.
</details>

---

## ✦ Section 2: SSL/TLS, Certificates & Let's Encrypt (Questions 21-40)

<details>
<summary><b>Q21: Scenario: You need to generate a self-signed SSL certificate for a testing domain `staging.local` from the CLI. What command do you run?</b></summary>
Use `openssl`:
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes -subj "/CN=staging.local"
```
This generates a private key `key.pem` and a self-signed certificate `cert.pem` valid for 365 days without prompting for passwords.
</details>

<details>
<summary><b>Q22: Scenario: You are installing a commercial SSL certificate in Nginx. You received a domain cert, an intermediate cert, and a root cert. How do you configure this?</b></summary>
Concatenate the certificates into a single bundle file in order: Domain certificate first, followed by the intermediate certificate and root certificate:
```bash
cat domain.crt intermediate.crt root.crt > ssl-bundle.crt
```
In Nginx, configure the bundle:
```nginx
ssl_certificate /etc/nginx/ssl/ssl-bundle.crt;
ssl_certificate_key /etc/nginx/ssl/private.key;
```
</details>

<details>
<summary><b>Q23: Scenario: How do you verify the expiration date of a local certificate file `cert.pem` from the command line?</b></summary>
Run:
```bash
openssl x509 -enddate -noout -in cert.pem
```
</details>

<details>
<summary><b>Q24: Scenario: You need to install a free SSL certificate from Let's Encrypt on Nginx. What tool do you use and what command generates it automatically?</b></summary>
Use the `certbot` tool:
```bash
sudo certbot --nginx -d mydomain.com -d www.mydomain.com
```
This verifies domain ownership, generates certificates, and automatically updates the Nginx virtual host configurations.
</details>

<details>
<summary><b>Q25: Scenario: Let's Encrypt certificates expire every 90 days. How do you automate their renewal?</b></summary>
Certbot installs a systemd timer or cron job automatically during installation. You can test the renewal logic manually running:
```bash
sudo certbot renew --dry-run
```
To run renewal in a cron job, add: `0 0,12 * * * root python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q`.
</details>

<details>
<summary><b>Q26: Scenario: How does the ACME HTTP-01 challenge differ from the DNS-01 challenge in Let's Encrypt?</b></summary>
- **HTTP-01**: Certbot places a token file at `http://domain/.well-known/acme-challenge/` and the Let's Encrypt server fetches it. Requires port 80 to be open.
- **DNS-01**: Certbot requests you to create a TXT record containing a token under `_acme-challenge.domain`. This is the only challenge that supports wildcard certificates and does not require opening firewall ports.
</details>

<details>
<summary><b>Q27: Scenario: A client complains that they get "Weak DH Key" error when connecting to your HTTPS server. How do you resolve this?</b></summary>
Generate a custom Diffie-Hellman parameter file (e.g. 2048-bit or higher) using OpenSSL:
```bash
openssl dhparam -out /etc/nginx/dhparam.pem 2048
```
Configure Nginx to use it:
```nginx
ssl_dhparam /etc/nginx/dhparam.pem;
```
</details>

<details>
<summary><b>Q28: Scenario: You want to enforce HTTP Strict Transport Security (HSTS) in Nginx to ensure browsers only connect via HTTPS. What header do you add?</b></summary>
Add the `Strict-Transport-Security` header to the server block:
```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```
</details>

<details>
<summary><b>Q29: Scenario: You notice an application has legacy TLS 1.0 and 1.1 enabled. How do you configure Nginx to restrict connections to TLS 1.2 and TLS 1.3 only?</b></summary>
Modify the `ssl_protocols` directive:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
```
</details>

<details>
<summary><b>Q30: Scenario: How do you verify if the private key `private.key` matches the public certificate `cert.crt`?</b></summary>
Compare the MD5 hashes of their moduli. They must match:
```bash
openssl x509 -noout -modulus -in cert.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
```
</details>

<details>
<summary><b>Q31: Scenario: You want to redirect all HTTP traffic to HTTPS in Apache. What VirtualHost redirect rules do you write?</b></summary>
Create a virtual host on port 80 that redirects all requests:
```apache
<VirtualHost *:80>
    ServerName example.com
    Redirect permanent / https://example.com/
</VirtualHost>
```
</details>

<details>
<summary><b>Q32: Scenario: What is Server Name Indication (SNI) and why is it critical for modern HTTPS web servers?</b></summary>
SNI is an extension to the TLS protocol that includes the hostname of the target site in the TLS handshake client hello. This allows a single web server with a single IP address to host and serve distinct SSL certificates for multiple domains.
</details>

<details>
<summary><b>Q33: Scenario: How do you test if your SSL setup has secure ciphers and correct configurations from the command line?</b></summary>
Use the `nmap` ssl scripts:
```bash
nmap --script ssl-enum-ciphers -p 443 example.com
```
Alternatively, submit the domain to online audit tools like Qualys SSL Labs.
</details>

<details>
<summary><b>Q34: Scenario: What is a Certificate Signing Request (CSR) and how do you generate one?</b></summary>
A CSR is an encrypted block of text containing your public key and organization details, sent to a Certificate Authority (CA) to get a signed public certificate. Generate it using OpenSSL:
```bash
openssl req -new -newkey rsa:2048 -nodes -keyout mydomain.key -out mydomain.csr
```
</details>

<details>
<summary><b>Q35: Scenario: You are using the Certbot standalone plugin to renew certificates. Why does the renewal fail, and how do you fix it?</b></summary>
The standalone plugin runs a temporary web server on port 80. If Nginx or Apache is already running, it cannot bind to the port. Fix this by stopping the web server during renewal using pre/post hooks:
```bash
sudo certbot renew --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
```
</details>

<details>
<summary><b>Q36: Scenario: How do you check if a certificate is revoked using the CLI?</b></summary>
Query the Certificate Authority's OCSP (Online Certificate Status Protocol) responder using `openssl ocsp`:
```bash
openssl ocsp -issuer issuer.pem -cert cert.pem -text -url http://ocsp.issuer.com
```
</details>

<details>
<summary><b>Q37: Scenario: What is SSL Session Resumption (Caching) and how does it optimize web server performance?</b></summary>
It caches the TLS handshake parameters (symmetric key details) for a period. When a client reconnects, they bypass the full cryptographic handshake, reducing latency and saving CPU cycles on the server.
</details>

<details>
<summary><b>Q38: Scenario: You want to enable SSL Session Caching in Nginx. What configurations do you add?</b></summary>
Add session cache parameters to the `http` or `server` blocks:
```nginx
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
```
</details>

<details>
<summary><b>Q39: Scenario: How do you read the text details of a CSR file `domain.csr`?</b></summary>
Run:
```bash
openssl req -text -noout -verify -in domain.csr
```
</details>

<details>
<summary><b>Q40: Scenario: What is a "Wildcard SSL Certificate" and what domain matches does it allow?</b></summary>
A wildcard certificate covers a single level of subdomains under a domain (e.g. `*.example.com` covers `app.example.com` and `api.example.com`, but does not cover nested subdomains like `dev.api.example.com` or the apex domain `example.com` unless explicitly listed in the SAN).
</details>

---

## ✦ Section 3: DevSecOps Principles, Static Analysis (SAST/DAST) & Security Audits (Questions 41-60)

<details>
<summary><b>Q41: Scenario: What is the difference between Static Application Security Testing (SAST) and Dynamic Application Security Testing (DAST)?</b></summary>
- **SAST**: Scans raw source code, configurations, and IaC templates for vulnerabilities (e.g. SQLi patterns, hardcoded secrets) without running the application (white-box testing).
- **DAST**: Tests the running application from the outside, sending malicious requests to detect vulnerabilities like XSS, broken authentication, and database leakage (black-box testing).
</details>

<details>
<summary><b>Q42: Scenario: How do you integrate a SAST scanner like `SonarQube` or `Semgrep` into a GitLab CI pipeline?</b></summary>
Define a stage `test` and run the scanner CLI tool within the runner, failing the build if vulnerabilities exceed safety thresholds:
```yaml
sast_scan:
  stage: test
  script:
    - semgrep --config=auto --error
```
</details>

<details>
<summary><b>Q43: Scenario: You want to run a software composition analysis (SCA) tool on your Node.js application to check for vulnerable dependencies. What tool do you run?</b></summary>
Run the native npm checker or a dedicated scanner:
```bash
npm audit
```
or use open-source SCA tools like `Snyk` or `OWASP Dependency-Check`.
</details>

<details>
<summary><b>Q44: Scenario: What is a "False Positive" in a security scanning report, and how should a DevSecOps engineer handle it?</b></summary>
A false positive is a flagged vulnerability that is actually safe (e.g. test code flagged as a real credential). To handle it, investigate the risk, document the reasoning, and create a rule exclusion (e.g., adding it to `.semgrepignore` or a SonarQube ignore list) so it is excluded from future scans.
</details>

<details>
<summary><b>Q45: Scenario: You want to scan your container images for security vulnerabilities before pushing them to Docker Hub. What CLI tool do you run?</b></summary>
Use `Trivy` or `Clair`:
```bash
trivy image myapp:latest
```
This scans the base image libraries and application packages against public CVE databases.
</details>

<details>
<summary><b>Q46: Scenario: How does the concept of "Shifting Left" apply to software security in a DevOps pipeline?</b></summary>
Shifting left means integrating security checks early in the software development lifecycle (SDLC)—during writing code (IDE plugins), code commits (pre-commit hooks), and pull requests (CI pipelines)—rather than waiting to scan in staging or production.
</details>

<details>
<summary><b>Q47: Scenario: What is the purpose of Software Bill of Materials (SBOM), and how do you generate one?</b></summary>
An SBOM is a structured list of all components, libraries, and modules used in your software. Generate one using tools like `Syft`:
```bash
syft myapp:latest -o json > sbom.json
```
This helps track dependency supply chain risks.
</details>

<details>
<summary><b>Q48: Scenario: You suspect your public API has vulnerabilities. How do you run an automated DAST scan using OWASP ZAP in your CI pipeline?</b></summary>
Run ZAP inside a Docker container targeting the application URL:
```bash
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-api-scan.py -t http://api.myapp.com -f openapi
```
</details>

<details>
<summary><b>Q49: Scenario: What is "Dependency Confusing Attack" and how do you prevent it in your build configuration?</b></summary>
An attacker uploads a malicious package with the same name as your private internal package to a public repository (like npmjs or PyPI). To prevent it, configure your package manager to use registry scopes, lock files, and direct internal lookups to your private package repository (e.g., Artifactory or Nexus).
</details>

<details>
<summary><b>Q50: Scenario: How do you scan a GitHub repository for hardcoded secrets, private keys, and API tokens?</b></summary>
Use secrets scanning tools like `gitleaks` or `trufflehog`:
```bash
gitleaks detect --source=. --verbose
```
</details>

<details>
<summary><b>Q51: Scenario: What is the purpose of Linting in a security pipeline?</b></summary>
Linting checks code formatting and flags dangerous functions (e.g. `eval()` in Python/JS, or missing flags in Dockerfiles) that are known to cause bugs or security exploits.
</details>

<details>
<summary><b>Q52: Scenario: How do you configure a pre-commit hook to scan code locally before letting developers push a Git commit?</b></summary>
Install the `pre-commit` framework, define standard hooks inside a `.pre-commit-config.yaml` file, and run:
```bash
pre-commit install
```
This blocks the commit if any scanner check fails.
</details>

<details>
<summary><b>Q53: Scenario: What is the OWASP Top 10 list and why is it a baseline for application security?</b></summary>
It is a regularly updated list of the 10 most critical security risks for web applications. It serves as an industry standard for training developers and setting up security policies.
</details>

<details>
<summary><b>Q54: Scenario: An auditor requests proof that no container runs with root privileges. How do you verify this using Docker CLI?</b></summary>
Inspect the image configuration to check the default user:
```bash
docker inspect --format='{{.Config.User}}' myimage:latest
```
If this output is blank, the image defaults to running as `root`.
</details>

<details>
<summary><b>Q55: Scenario: You want to automatically run security scans on every pull request on GitHub. What tool do you use?</b></summary>
Use **GitHub Advanced Security (CodeQL)**. Configure a workflow file under `.github/workflows/codeql-analysis.yml`.
</details>

<details>
<summary><b>Q56: Scenario: How do you configure a pipeline to allow minor security vulnerabilities to pass but fail the build if a Critical vulnerability is found?</b></summary>
Configure severity thresholds in your scanner configurations. For example, in Trivy:
```bash
trivy image --severity CRITICAL --exit-code 1 myimage
trivy image --severity HIGH,MEDIUM --exit-code 0 myimage
```
This forces exit code `1` (failing pipeline) only on CRITICAL findings.
</details>

<details>
<summary><b>Q57: Scenario: What is "Image Signing" and how does Cosign secure the container supply chain?</b></summary>
Image signing guarantees that a container image was built by a trusted pipeline and has not been tampered with. Use `cosign` to sign the image with a private key after creation:
```bash
cosign sign --key cosign.key myregistry/myapp:latest
```
</details>

<details>
<summary><b>Q58: Scenario: You need to run a vulnerability scanner on your local Kubernetes clusters. What tool fits this scenario?</b></summary>
Use `Kube-bench` to check compliance against CIS Kubernetes Benchmarks, or `Kubescape` to scan configurations for security risks.
</details>

<details>
<summary><b>Q59: Scenario: Why is caching dependencies in CI runners a security concern and how do you protect it?</b></summary>
If the CI runner cache directory is writable by subsequent steps, a compromised build step could inject malicious payloads into dependencies cached for other projects. Protect it by making caches read-only for untrusted branches and isolating runner execution contexts.
</details>

<details>
<summary><b>Q60: Scenario: How do you configure an API Gateway to block SQL Injection payloads automatically?</b></summary>
Configure Web Application Firewall (WAF) rule groups (e.g. AWS WAF Core Rule Set) on your API Gateway to inspect parameters and block requests containing SQL strings like `UNION SELECT`.
</details>

---

## ✦ Section 4: Secrets Management, Container Security & IAM (Questions 61-80)

<details>
<summary><b>Q61: Scenario: A developer wants to pass a DB password to a container by defining it as a Docker environment variable in the Dockerfile. Why is this a security violation?</b></summary>
Environment variables defined in a Dockerfile are baked into the image metadata. Anyone with read access to the image repository can run `docker inspect` to view the credentials in cleartext. Secrets must be mounted at runtime (e.g., using tmpfs volumes, Docker Secrets, or Vault integrations).
</details>

<details>
<summary><b>Q62: Scenario: How do you configure a Kubernetes Pod to fetch secrets dynamically from HashiCorp Vault without hardcoding credentials in YAML?</b></summary>
Install the **Vault Agent Injector** on your cluster. Add annotations to your Pod specification:
```yaml
annotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/role: "myapp-role"
  vault.hashicorp.com/agent-inject-secret-config: "secret/data/myapp/config"
```
The Vault agent injector intercepts Pod creation and mounts the secrets as a shared volume under `/vault/secrets/`.
</details>

<details>
<summary><b>Q63: Scenario: You need to access AWS resources from a script running inside an EC2 instance. How do you configure access without storing IAM access keys on the instance?</b></summary>
Create an **IAM Role** with the minimum required permissions. Attach this role to an **EC2 Instance Profile** and link it to the EC2 instance. The AWS SDK or CLI will fetch temporary security credentials automatically from the Instance Metadata Service (IMDS).
</details>

<details>
<summary><b>Q64: Scenario: What is IAM "Least Privilege Principle" and how do you apply it to a developer group?</b></summary>
Least privilege means granting only the minimum permissions necessary to perform a task. For a developer group, instead of granting broad admin roles (`*:*`), construct IAM policies targeting specific resources (e.g. read/write access limited to specific S3 buckets or EC2 tags).
</details>

<details>
<summary><b>Q65: Scenario: You want to secure your AWS root account. What are the top three security recommendations?</b></summary>
1. Enable Multi-Factor Authentication (MFA) on the root account.
2. Delete root access keys (do not use root credentials for API calls).
3. Do not use the root user for daily administrative activities (create dedicated IAM users with administrator access).
</details>

<details>
<summary><b>Q66: Scenario: How do you configure your Docker container to run as a non-root user `appuser`?</b></summary>
Create the user and switch context inside the Dockerfile:
```dockerfile
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser
```
</details>

<details>
<summary><b>Q67: Scenario: What is the risk of mounting the host Docker socket `/var/run/docker.sock` inside a container?</b></summary>
Mounting the docker socket gives the container complete control over the host Docker daemon. A compromised container can spin up new containers, mount the host's root filesystem, and gain full root privileges on the host system (privilege escalation).
</details>

<details>
<summary><b>Q68: Scenario: How do you configure AWS Secrets Manager to rotate a database password automatically every 30 days?</b></summary>
Enable rotation on the secret in AWS Secrets Manager. Link a custom **Lambda rotation function** that changes the password in the RDS database and updates the secret in Secrets Manager dynamically.
</details>

<details>
<summary><b>Q69: Scenario: How does OpenID Connect (OIDC) secure deployments from GitHub Actions to AWS?</b></summary>
OIDC allows GitHub Actions to authenticate directly with AWS using temporary, short-lived tokens without storing long-lived AWS Access Keys as GitHub Secrets.
</details>

<details>
<summary><b>Q70: Scenario: What is a "Read-Only Root Filesystem" inside a container, and how does it prevent security compromises?</b></summary>
A read-only root filesystem prevents attackers from writing files, altering configurations, or downloading malicious binaries if a container is compromised. Set `readOnlyRootFilesystem: true` in Kubernetes securityContext or run:
```bash
docker run --read-only myimage
```
</details>

<details>
<summary><b>Q71: Scenario: You need to authenticate a backend service to access an API. How do you configure OAuth 2.0 Client Credentials Grant?</b></summary>
The service requests an access token directly from the authorization server by sending its client credentials (client ID and client secret). The authorization server returns an access token, which the service uses to query endpoints.
</details>

<details>
<summary><b>Q72: Scenario: What is "IAM Policy Evaluation Logic"? If an IAM user has a policy allowing S3 access and another policy explicitly denying S3 access, does the user have access?</b></summary>
No. In AWS IAM, an explicit **Deny** always overrides any Allow permissions.
</details>

<details>
<summary><b>Q73: Scenario: How do you restrict Docker containers from acquiring new privileges?</b></summary>
Run the container with security options:
```bash
docker run --security-opt=no-new-privileges:true myimage
```
Or in Kubernetes, set `allowPrivilegeEscalation: false` inside the container securityContext.
</details>

<details>
<summary><b>Q74: Scenario: What is the purpose of Seccomp (Secure Computing Mode) in Docker and Kubernetes?</b></summary>
Seccomp restricts the system calls (syscalls) a container can make to the host kernel (e.g. blocking `ptrace` or `sys_chroot`), reducing the kernel's attack surface.
</details>

<details>
<summary><b>Q75: Scenario: You want to securely share a temporary access link to a private file in an S3 bucket. How?</b></summary>
Generate a **Presigned URL** with a short expiration time (e.g., 1 hour):
```bash
aws s3 presign s3://mybucket/file.txt --expires-in 3600
```
</details>

<details>
<summary><b>Q76: Scenario: How do you decrypt a ciphertext secret using the AWS KMS CLI?</b></summary>
Run:
```bash
aws kms decrypt --ciphertext-blob fileb://encrypted-secret.txt --output text --query Plaintext | base64 --decode
```
</details>

<details>
<summary><b>Q77: Scenario: What are Kubernetes NetworkPolicies and how do they secure pods?</b></summary>
By default, all pods in Kubernetes can communicate with each other. NetworkPolicies act as firewalls at the pod level, allowing you to define explicit ingress and egress traffic rules based on pod selectors, namespaces, and IP blocks.
</details>

<details>
<summary><b>Q78: Scenario: Why is the IMDSv2 metadata endpoint safer than IMDSv1 on AWS EC2 instances?</b></summary>
IMDSv2 is session-oriented and requires a token-based handshake (`PUT` request to fetch a token before making `GET` requests). This protects against Server-Side Request Forgery (SSRF) vulnerabilities, which easily leak IMDSv1 data.
</details>

<details>
<summary><b>Q79: Scenario: How do you scan your local system for inactive IAM users that have not logged in for 90 days?</b></summary>
Generate an AWS IAM Credential Report and parse it:
```bash
aws iam generate-credential-report
aws iam get-credential-report --output text
```
Inspect the `password_last_used` or `access_key_1_last_used` dates in the CSV output.
</details>

<details>
<summary><b>Q80: Scenario: What is Multi-Factor Authentication (MFA) Delete on an S3 bucket and when is it used?</b></summary>
MFA Delete requires the bucket owner to provide an MFA code to permanently delete a file version or change the bucket versioning status, preventing accidental deletion by compromised credentials.
</details>

---

## ✦ Section 5: Firewalls, Host Security, Log Monitoring & Incident Response (Questions 81-100)

<details>
<summary><b>Q81: Scenario: How do you configure a Linux firewall using UFW to allow incoming SSH connections only from a specific trusted IP `203.0.113.10`?</b></summary>
Run:
```bash
sudo ufw allow from 203.0.113.10 to any port 22 proto tcp
sudo ufw enable
```
</details>

<details>
<summary><b>Q82: Scenario: What is Fail2ban and how does it protect a server against SSH brute-force attacks?</b></summary>
Fail2ban scans system logs (like `/var/log/auth.log`) for repeated failed login attempts. When an IP address exceeds the limit, Fail2ban updates local firewall rules (iptables/nftables) to drop traffic from that IP for a set period.
</details>

<details>
<summary><b>Q83: Scenario: How do you list all active connections, ports, and sockets on a host using the modern replacement for netstat?</b></summary>
Use the `ss` utility:
```bash
sudo ss -tulpn
```
(`t` for TCP, `u` for UDP, `l` for listening sockets, `p` to show process name, `n` to display numeric port values).
</details>

<details>
<summary><b>Q84: Scenario: What is the role of centralized log management (e.g. Elasticsearch, Splunk, Datadog) in security monitoring?</b></summary>
It aggregates log data from multiple applications and infrastructure nodes to a single secure location. Centralizing logs allows real-time threat analysis, audit trails, and correlation rules to flag incidents, while preventing attackers from covering their tracks by deleting local logs.
</details>

<details>
<summary><b>Q85: Scenario: You notice a sudden spike in traffic that looks like a Distributed Denial of Service (DDoS) attack. What are your immediate mitigation steps?</b></summary>
1. Route traffic through a Cloud Delivery Network (CDN) with DDoS protection (like Cloudflare or AWS Shield).
2. Rate-limit IP ranges at the load balancer or firewall level.
3. Block known malicious regions/subnets.
4. Scale frontend capacity to handle load spikes.
</details>

<details>
<summary><b>Q86: Scenario: How do you audit all user commands executed on a Linux server for security compliance?</b></summary>
Install and configure the **Linux Audit Framework (auditd)**. Add rules to monitor file modifications and syscall executions inside `/etc/audit/rules.d/audit.rules`.
</details>

<details>
<summary><b>Q87: Scenario: What is File Integrity Monitoring (FIM) and how does a tool like Tripwire help during security incidents?</b></summary>
FIM scans filesystems, calculates cryptographic hashes of critical files (e.g. system binaries, configurations), and compares them against a baseline database. If a file is modified (e.g., a rootkit is installed), the tool flags the anomaly.
</details>

<details>
<summary><b>Q88: Scenario: You need to verify if port 22 is open on a target server `192.168.1.5` using a simple command line utility. What do you run?</b></summary>
Use `nc` (netcat):
```bash
nc -zv 192.168.1.5 22
```
If it prints "Connection to 192.168.1.5 port 22 [tcp/ssh] succeeded!", the port is open.
</details>

<details>
<summary><b>Q89: Scenario: How do you configure Nginx to write custom logs containing response times and upstream headers for APM dashboards?</b></summary>
Define a custom `log_format` in `nginx.conf`:
```nginx
log_format upstream_time '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         'rt=$request_time uct=$upstream_connect_time uat=$upstream_header_time';

access_log /var/log/nginx/access.log upstream_time;
```
</details>

<details>
<summary><b>Q90: Scenario: What is a Honeypot and how is it used in enterprise security architecture?</b></summary>
A honeypot is a decoy system or service designed to attract cyberattacks. It acts as an early warning system; because legitimate users have no reason to access it, any traffic hitting a honeypot is flagged as an active threat.
</details>

<details>
<summary><b>Q91: Scenario: How do you configure AWS CloudTrail to monitor account operations across all AWS regions?</b></summary>
Create a new trail in the AWS CloudTrail console or CLI, configure it as an **organization-wide trail**, and set it to track both read and write management events, saving logs to a secure, centralized S3 bucket with versioning and object lock enabled.
</details>

<details>
<summary><b>Q92: Scenario: You suspect an EC2 instance has been compromised. What are your immediate containment steps?</b></summary>
1. Isolate the instance by changing its Security Group to one that blocks all ingress and egress traffic.
2. Detach it from any load balancer.
3. Take a snapshot of the EBS volume for forensic analysis.
4. Keep the instance running to preserve volatile RAM memory for analysis.
</details>

<details>
<summary><b>Q93: Scenario: How do you inspect user logins and authentication failures on a Linux server?</b></summary>
Check `/var/log/auth.log` (Debian/Ubuntu) or `/var/log/secure` (RedHat/CentOS). Use commands like `last` to see recent logins and `lastb` to show bad login attempts.
</details>

<summary><b>Q94: Scenario: What is the purpose of a Web Application Firewall (WAF) compared to a standard network firewall?</b></summary>
A standard network firewall filters traffic based on IP addresses, protocols, and port ranges (layers 3 and 4). A WAF inspects HTTP traffic payloads (layer 7), detecting and blocking application-specific attacks like SQL Injection and Cross-Site Scripting (XSS).
</details>

<details>
<summary><b>Q95: Scenario: You want to block all outbound traffic from your server to the internet except for DNS (port 53) and HTTPS (port 443). How do you configure this with iptables?</b></summary>
Set default egress policy to drop, and append exceptions:
```bash
sudo iptables -P OUTPUT DROP
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
```
</details>

<details>
<summary><b>Q96: Scenario: How do you configure a web server to protect against Clickjacking attacks?</b></summary>
Add the `X-Frame-Options` or `Content-Security-Policy` header. In Nginx:
```nginx
add_header X-Frame-Options "DENY" always;
```
</details>

<details>
<summary><b>Q97: Scenario: What is a "Zero-Day Vulnerability" and how do you protect your systems when no official patch is available?</b></summary>
A zero-day is a vulnerability that is actively exploited before the software vendor releases a patch. Mitigation: Restrict network access to the vulnerable system, disable the affected service/feature, or configure WAF rule filters to block the exploit signature.
</details>

<details>
<summary><b>Q98: Scenario: How do you verify the integrity of downloaded files using checksum hashes from the CLI?</b></summary>
Compare sha256 hashes of the file:
```bash
sha256sum -c files.sha256
```
or generate the hash manually and match: `sha256sum download.tar.gz`.
</details>

<details>
<summary><b>Q99: Scenario: What is "Log Injection" and how do you prevent developers from exposing logs to this vulnerability?</b></summary>
Log injection occurs when user input is printed directly to system logs without sanitization, allowing an attacker to inject newline characters and fake log entries. Prevent it by sanitizing user input and using structured log formatters (e.g. JSON loggers) rather than string concatenation.
</details>

<details>
<summary><b>Q100: Scenario: How do you find all listening ports on a local system that are not password-secured or bind to public interface `0.0.0.0`?</b></summary>
Scan listening ports:
```bash
sudo ss -tulpn | grep 0.0.0.0
```
Analyze the processes list and configure services to bind locally (`127.0.0.1`) unless public access is explicitly required.
</details>
