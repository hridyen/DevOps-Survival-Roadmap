# ✦ Docker & Containers Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Dockerfile design, image size reduction, volume mapping, virtual networks, security, debugging, and container orchestration.

---

## ✦ Section 1: Dockerfile Design & Image Optimization (Questions 1-20)

<details>
<summary><b>Q1: Scenario: Your custom Docker image is 1.5GB. How do you reduce it down to less than 150MB?</b></summary>
1. Use lightweight base images like `alpine` or `distroless`.
2. Implement **multi-stage builds** to exclude build tools and headers from the final release image.
3. Minimize layer count by chaining RUN statements with `&& \`.
4. Add a `.dockerignore` file to exclude local test files, `.git`, and node_modules from copying into the image.
</details>

<details>
<summary><b>Q2: Scenario: You build a Dockerfile, but changing one line in the application source code invalidates the entire cache and forces `npm install` to run again. How do you fix this cache invalidation problem?</b></summary>
Copy the dependency manifest files (`package.json`) and run the package install commands **before** copying the rest of the application source code.
```dockerfile
COPY package*.json ./
RUN npm install
COPY . .
```
</details>

<details>
<summary><b>Q3: Scenario: What is the difference between `CMD` and `ENTRYPOINT` in a Dockerfile?</b></summary>
- **`ENTRYPOINT`** defines the main command that is guaranteed to run when the container starts.
- **`CMD`** acts as default arguments passed to the `ENTRYPOINT`. Users can easily override `CMD` parameters from the CLI when starting the container, while overriding `ENTRYPOINT` requires specifying the `--entrypoint` flag.
</details>

<details>
<summary><b>Q4: Scenario: Why is it bad security practice to run containers as the default `root` user? How do you prevent this?</b></summary>
If a container is compromised, the attacker could escape the container and gain root privileges on the host system. Define a custom system user and group inside the Dockerfile, change file ownerships, and switch execution using the `USER` instruction:
```dockerfile
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser
```
</details>

<details>
<summary><b>Q5: Scenario: You need to pass build-time configurations (e.g., API URL endpoints) and run-time secrets. What instructions do you use?</b></summary>
- Use **`ARG`** for build-time configurations (passed via `docker build --build-arg`). Note that these are visible in image history.
- Use **`ENV`** for run-time environment configurations.
</details>

<details>
<summary><b>Q6: Scenario: How do you inspect the individual layer history of a Docker image to see what took up space?</b></summary>
Run:
```bash
docker history <image_name_or_ID>
```
</details>

<details>
<summary><b>Q7: Scenario: A developer wants to run dynamic configuration shell commands during container startup instead of when building the image. How is this achieved?</b></summary>
Point the `ENTRYPOINT` to an entrypoint shell script (`entrypoint.sh`). This script handles runtime setups and then launches the main process using `exec "$@"`.
</details>

<details>
<summary><b>Q8: Scenario: What is the difference between the shell form and exec form in a Dockerfile?</b></summary>
- **Exec Form:** `ENTRYPOINT ["nginx", "-g", "daemon off;"]`. Does not invoke a shell wrapper. Correctly receives OS signals like `SIGTERM` (PID 1).
- **Shell Form:** `ENTRYPOINT nginx -g "daemon off;"`. Wraps the process in `/bin/sh -c`. The main process is NOT PID 1 and will not receive termination signals cleanly.
</details>

<details>
<summary><b>Q9: Scenario: How do you verify if a Docker image contains known security vulnerabilities before pushing it to a registry?</b></summary>
Scan the image using tools like Trivy or Docker Scout:
```bash
trivy image <image_name>
```
</details>

<details>
<summary><b>Q10: Scenario: How do you copy files from another existing docker image directly during a build without downloading them manually?</b></summary>
Use the `--from` parameter:
```dockerfile
COPY --from=nginx:latest /etc/nginx/nginx.conf /local/nginx.conf
```
</details>

<details>
<summary><b>Q11: Scenario: What is the purpose of the `.dockerignore` file?</b></summary>
It specifies pattern matching files and directories to be excluded from the build context sent to the Docker daemon, saving time and keeping image sizes small.
</details>

<details>
<summary><b>Q12: Scenario: How do you copy a local archive `app.tar.gz` and have it automatically extracted inside the container directory?</b></summary>
Use the `ADD` instruction instead of `COPY`:
```dockerfile
ADD app.tar.gz /app/
```
</details>

<details>
<summary><b>Q13: Scenario: How do you define a metadata description and author label for your image?</b></summary>
Use the `LABEL` instruction:
```dockerfile
LABEL maintainer="admin@example.com" version="1.0"
```
</details>

<details>
<summary><b>Q14: Scenario: You want to ensure Nginx starts only after a health check on your database container passes. How does Dockerfile handle health checks?</b></summary>
Use the `HEALTHCHECK` instruction:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/ || exit 1
```
</details>

<details>
<summary><b>Q15: Scenario: Can you mount a volume during the build phase (`docker build`)?</b></summary>
No, build phase takes place in a temporary context. You can only mount volumes when launching a container (`docker run`).
</details>

<details>
<summary><b>Q16: Scenario: How do you build an image for multiple CPU architectures (like amd64 and arm64) using a single command?</b></summary>
Use `docker buildx`:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
```
</details>

<details>
<summary><b>Q17: Scenario: What is a dangling image and how do you delete it?</b></summary>
A dangling image (`<none>:<none>`) occurs when a new image is built with the same tag as an existing image. Delete them with:
```bash
docker image prune
```
</details>

<details>
<summary><b>Q18: Scenario: Why should you avoid pinning base images to `latest` tag in production Dockerfiles?</b></summary>
The `latest` tag points to the newest version, which changes over time. This makes builds non-reproducible and can introduce breaking changes silently. Always pin to specific tags/SHAs (e.g., `alpine:3.18`).
</details>

<details>
<summary><b>Q19: Scenario: How do you set the working directory for subsequent instructions in a Dockerfile?</b></summary>
Use the `WORKDIR` instruction:
```dockerfile
WORKDIR /var/www/html
```
</details>

<details>
<summary><b>Q20: Scenario: How do you clean up local package manager caches during package installation to keep layers small?</b></summary>
Run clean commands in the same RUN line:
```dockerfile
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```
</details>

---

## ✦ Section 2: Container Networking & Ports (Questions 21-40)

<details>
<summary><b>Q21: Scenario: You have two containers, Nginx and Node.js. How do you allow them to communicate securely using hostnames instead of IP addresses?</b></summary>
Create a user-defined bridge network:
```bash
docker network create app-network
```
Run both containers attached to this network:
```bash
docker run -d --name node-app --network app-network node-image
docker run -d --name nginx-lb --network app-network -p 80:80 nginx-image
```
Now, Nginx can reference the Node container directly using `http://node-app:5000`.
</details>

<details>
<summary><b>Q22: Scenario: What is the difference between mapping a port with `-p 80:8080` versus exposing a port with `--expose 8080`?</b></summary>
- **`-p 80:8080` (Publish):** Exposes port 8080 from the container to port 80 on the host, making it accessible from outside the host system.
- **`--expose 8080`:** Documents that the container listens on port 8080. It does not map the port to the host; it is only accessible to other containers on the same docker network.
</details>

<details>
<summary><b>Q23: Scenario: You want to run a container that has full access to the host machine's network interfaces directly (no virtualization). What network mode?</b></summary>
Use the host network mode:
```bash
docker run --network host my-agent-image
```
</details>

<details>
<summary><b>Q24: Scenario: A container needs to connect to a service (like PostgreSQL) running directly on the host machine's localhost. How does it resolve the host IP?</b></summary>
Connect to the special DNS name `host.docker.internal` (if started with `--add-host=host.docker.internal:host-gateway` or on Docker Desktop).
</details>

<details>
<summary><b>Q25: Scenario: What are the main types of Docker network drivers?</b></summary>
- **bridge:** The default driver for single-host containers.
- **host:** Removes network isolation between container and host.
- **overlay:** Enables multi-host container communication (used in Swarm).
- **macvlan:** Assigns a MAC address to containers, making them appear as physical network devices.
- **none:** Disables all network interfaces.
</details>

<details>
<summary><b>Q26: Scenario: How do you isolate container communication so `frontend` container can talk to `api` container, but cannot talk to `db` container?</b></summary>
Create two bridge networks: `net-front` and `net-back`.
- Connect `frontend` to `net-front`.
- Connect `api` to both `net-front` and `net-back`.
- Connect `db` to `net-back`.
</details>

<details>
<summary><b>Q27: Scenario: How do you list all network configuration details and active containers on a network named `app-net`?</b></summary>
Run:
```bash
docker network inspect app-net
```
</details>

<details>
<summary><b>Q28: Scenario: You want to run an application container with no external internet or local network access. What network mode?</b></summary>
Run:
```bash
docker run --network none alpine
```
</details>

<details>
<summary><b>Q29: Scenario: How do you debug container network connections dynamically from the command line using standard networking tools?</b></summary>
Run a temporary diagnostic container in the namespace of the target container:
```bash
docker run -it --network container:<target_container_name> nicolaka/netshoot
```
</details>

<details>
<summary><b>Q30: Scenario: How do you delete all unused Docker networks at once?</b></summary>
Run:
```bash
docker network prune
```
</details>

<details>
<summary><b>Q31: Scenario: You need to specify a custom DNS server `8.8.4.4` for a container when running it. What flag?</b></summary>
Run:
```bash
docker run --dns 8.8.4.4 alpine
```
</details>

<details>
<summary><b>Q32: Scenario: A container fails to bind to port 443 because of permission errors. Why does this happen and how do you resolve?</b></summary>
Linux restricts port numbers below 1024 to root users. Run container with `--sysctl net.ipv4.ip_unprivileged_port_start=0` or run it mapping a higher host port (e.g. `-p 8443:8443`).
</details>

<details>
<summary><b>Q33: Scenario: How does Docker implement network port mapping on the host system under the hood?</b></summary>
It uses **iptables** rules on the host to configure Network Address Translation (NAT) rules forwarding traffic to the container interface.
</details>

<details>
<summary><b>Q34: Scenario: You want to view the routing table inside a running container. What command?</b></summary>
Run `docker exec <container> ip route` or `docker exec <container> route -n`.
</details>

<details>
<summary><b>Q35: Scenario: How do you bind a container port explicitly to only listen on local loopback interface `127.0.0.1`?</b></summary>
Prepend IP to publish argument:
```bash
docker run -p 127.0.0.1:8080:8080 myapp
```
</details>

<details>
<summary><b>Q36: Scenario: How do you find the gateway IP address of the default bridge network?</b></summary>
Run:
```bash
docker network inspect bridge | grep Gateway
```
</details>

<details>
<summary><b>Q37: Scenario: You want to map a container port using UDP protocol instead of TCP. How do you specify this?</b></summary>
Append `/udp` to port flag:
```bash
docker run -p 53:53/udp mydns
```
</details>

<details>
<summary><b>Q38: Scenario: Can two containers run listening on the same internal port (e.g. 80) on the same host?</b></summary>
Yes. They have isolated network namespaces. However, they cannot map to the same host port (e.g., you cannot run two containers mapped to `-p 80:80` on the same host IP).
</details>

<details>
<summary><b>Q39: Scenario: How do you verify if the Docker daemon is configured to enable IPv6 container networking?</b></summary>
Check `/etc/docker/daemon.json` for `"ipv6": true`.
</details>

<details>
<summary><b>Q40: Scenario: How do you check network bandwidth usage metrics of running containers?</b></summary>
Run:
```bash
docker stats
```
</details>

---

## ✦ Section 3: Storage, Volumes & Bind Mounts (Questions 41-60)

<details>
<summary><b>Q41: Scenario: What is the difference between a Bind Mount and a Named Volume?</b></summary>
- **Bind Mount:** Mounts a specific user-defined directory from the host filesystem (e.g. `/home/user/app`) directly into the container. Excellent for local development.
- **Named Volume:** Managed entirely by Docker in host filesystem storage (`/var/lib/docker/volumes/`). Recommended for database persistence.
</details>

<details>
<summary><b>Q42: Scenario: You run a container with a volume mounted at `/app`. You edit files in `/app` inside the container, but they vanish when the container is deleted. What went wrong?</b></summary>
You likely didn't configure a persistent volume or bind mount. If you didn't mount a volume using `-v` or `--mount`, changes are saved to the container's ephemeral write layer and are lost upon container destruction.
</details>

<details>
<summary><b>Q43: Scenario: How do you mount a volume as read-only inside the container to prevent the containerized application from modifying it?</b></summary>
Append `:ro` to volume argument:
```bash
docker run -v db_data:/var/lib/mysql:ro mysql
```
Or using `--mount src=db_data,dst=/var/lib/mysql,readonly`.
</details>

<details>
<summary><b>Q44: Scenario: You want to back up a named Docker volume `db_data` to a compressed tar archive on the host. How?</b></summary>
Run a temporary container mounting the volume and target host directory:
```bash
docker run --rm -v db_data:/volume -v $(pwd):/backup alpine tar czf /backup/db_backup.tar.gz -C /volume .
```
</details>

<details>
<summary><b>Q45: Scenario: You delete a container, but the named volume associated with it remains. How do you delete the volume to free space?</b></summary>
Run:
```bash
docker volume rm <volume_name>
```
To find and prune all orphaned/unused volumes: `docker volume prune`.
</details>

<details>
<summary><b>Q46: Scenario: How do you share a single volume among multiple running containers simultaneously?</b></summary>
Mount the same named volume to each container:
```bash
docker run -d -v shared_data:/data app1
docker run -d -v shared_data:/data app2
```
</details>

<details>
<summary><b>Q47: Scenario: You want to configure a container using a config file on the host `/etc/app.conf`, but you don't want to copy it to the image. How?</b></summary>
Use a bind mount:
```bash
docker run -v /etc/app.conf:/app/config.conf:ro myapp
```
</details>

<details>
<summary><b>Q48: Scenario: How do you locate the physical storage path of a named volume `my_vol` on the host machine?</b></summary>
Run:
```bash
docker volume inspect my_vol
```
Check the "Mountpoint" output line (typically `/var/lib/docker/volumes/my_vol/_data`).
</details>

<details>
<summary><b>Q49: Scenario: What is a tmpfs mount and when would you use it?</b></summary>
A tmpfs mount creates a temporary volume in the host system's RAM memory instead of writing to disk. Excellent for storing sensitive secrets or high-frequency state files.
```bash
docker run --tmpfs /temp_data myapp
```
</details>

<details>
<summary><b>Q50: Scenario: How do you list all volumes currently managed by Docker?</b></summary>
Run:
```bash
docker volume ls
```
</details>

<details>
<summary><b>Q51: Scenario: What happens if you mount a named volume into a container directory that already contains files?</b></summary>
Docker copies the existing directory files from the container image into the new named volume, populating it automatically.
</details>

<details>
<summary><b>Q52: Scenario: What happens if you bind mount an empty host directory over a container directory that already contains files?</b></summary>
The empty host directory hides the existing container files, making the directory appear empty to the containerized application.
</details>

<details>
<summary><b>Q53: Scenario: How do you configure Docker to use a custom storage driver (e.g. `overlay2`)?</b></summary>
Specify the storage driver in `/etc/docker/daemon.json`:
```json
{
  "storage-driver": "overlay2"
}
```
</details>

<details>
<summary><b>Q54: Scenario: How do you check how much disk space is consumed by all containers, images, and volumes?</b></summary>
Run:
```bash
docker system df
```
</details>

<details>
<summary><b>Q55: Scenario: You need to clean up all cached builder data, stopped containers, and unused images at once. What do you run?</b></summary>
Run:
```bash
docker system prune -a --volumes --force
```
</details>

<details>
<summary><b>Q56: Scenario: How do you import a backup archive `/backup/db_backup.tar.gz` back into a Docker volume `db_data`?</b></summary>
Run:
```bash
docker run --rm -v db_data:/volume -v $(pwd):/backup alpine sh -c "tar xzf /backup/db_backup.tar.gz -C /volume"
```
</details>

<details>
<summary><b>Q57: Scenario: What is copy-on-write (CoW) in Docker container storage?</b></summary>
CoW optimization allows multiple containers to share the same read-only image layers. When a container modifies a file, it copies the file to its individual writable container layer before applying edits, preserving the base image unchanged.
</details>

<details>
<summary><b>Q58: Scenario: How do you limit a container's write speed (disk throttling) to a block device?</b></summary>
Use the `--device-write-bps` parameter when starting the container.
</details>

<details>
<summary><b>Q59: Scenario: Can you share volumes across containers running on different hosts using standard Docker volume drivers?</b></summary>
No, standard drivers are local-only. You must use specialized volume plugins like SSHFS, NFS, Ceph, or cloud-specific storage plugins (e.g., AWS EBS/EFS drivers).
</details>

<details>
<summary><b>Q60: Scenario: How do you verify which storage driver Docker is currently using?</b></summary>
Run `docker info | grep "Storage Driver"`.
</details>

---

## ✦ Section 4: Compose, Swarm & Orchestration (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You need to manage environment variable variables for different stages (Dev vs. Prod) using Docker Compose. How?</b></summary>
1. Create a base `docker-compose.yml` file.
2. Create stage overrides: `docker-compose.override.yml` (loaded by default) or `docker-compose.prod.yml`.
3. Load them using the `-f` flag:
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
</details>

<details>
<summary><b>Q62: Scenario: How do you force Docker Compose to rebuild images from scratch before starting containers?</b></summary>
Run:
```bash
docker-compose up -d --build
```
</details>

<details>
<summary><b>Q63: Scenario: How do you scale a service named `worker` to run 5 instances simultaneously using Docker Compose?</b></summary>
Run:
```bash
docker-compose up -d --scale worker=5
```
Ensure your host port mapping does not conflict (avoid mapping host ports directly, rely on internal network routing).
</details>

<details>
<summary><b>Q64: Scenario: What command initializes a single-node Docker Swarm manager?</b></summary>
Run:
```bash
docker swarm init --advertise-addr <manager_IP>
```
</details>

<details>
<summary><b>Q65: Scenario: How do you join a worker node to an active Docker Swarm cluster?</b></summary>
Generate the join token on the manager node:
```bash
docker swarm join-token worker
```
Copy and execute the output command on the worker server.
</details>

<details>
<summary><b>Q66: Scenario: How do you deploy a stack file `prod-stack.yml` to a Swarm cluster?</b></summary>
Run:
```bash
docker stack deploy -c prod-stack.yml my_stack
```
</details>

<details>
<summary><b>Q67: Scenario: How do you update a Swarm service `my_web` to use a new image version `nginx:1.25` without causing downtime?</b></summary>
Run:
```bash
docker service update --image nginx:1.25 --update-parallelism 1 --update-delay 10s my_web
```
This performs a rolling update.
</details>

<details>
<summary><b>Q68: Scenario: You want to prevent a Swarm service from running on worker nodes (running only on manager nodes). How?</b></summary>
Add placement constraints to the service or stack YAML definition:
```yaml
deploy:
  placement:
    constraints:
      - node.role == manager
```
</details>

<details>
<summary><b>Q69: Scenario: How do you deploy a global service (one replica on every node in the Swarm cluster)?</b></summary>
Set deploy mode to `global` in the compose file:
```yaml
deploy:
  mode: global
```
</details>

<details>
<summary><b>Q70: Scenario: How do you manage secrets (e.g., DB passwords) securely in Docker Swarm without saving them in compose files?</b></summary>
Create the secret on the manager node:
```bash
echo "mypassword" | docker secret create db_passwd -
```
Grant the service access to this secret in the stack configuration. Swarm encrypts it and mounts it at `/run/secrets/db_passwd` inside the container memory.
</details>

<details>
<summary><b>Q71: Scenario: How do you list all running services across a Swarm cluster?</b></summary>
Run:
```bash
docker service ls
```
</details>

<details>
<summary><b>Q72: Scenario: How do you check active tasks and health statuses of a specific service `my_app`?</b></summary>
Run:
```bash
docker service ps my_app
```
</details>

<details>
<summary><b>Q73: Scenario: How do you configure Docker Compose to shut down all running containers, removing volumes and networks?</b></summary>
Run:
```bash
docker-compose down -v
```
</details>

<details>
<summary><b>Q74: Scenario: What is the difference between `docker-compose` and `docker compose`?</b></summary>
- `docker-compose` is the legacy standalone Python binary.
- `docker compose` is the modern Go-based CLI plugin integrated directly into the docker daemon client.
</details>

<details>
<summary><b>Q75: Scenario: How do you view live logs of all services running in Docker Compose?</b></summary>
Run:
```bash
docker-compose logs -f
```
</details>

<details>
<summary><b>Q76: Scenario: How do you verify the health status of nodes in a Swarm cluster?</b></summary>
Run:
```bash
docker node ls
```
</details>

<details>
<summary><b>Q77: Scenario: You want to temporarily drain a node `worker-2` so Swarm shifts its active tasks to other nodes. How?</b></summary>
Run:
```bash
docker node update --availability drain worker-2
```
</details>

<details>
<summary><b>Q78: Scenario: How do you restart a running service in Docker Swarm?</b></summary>
Run:
```bash
docker service update --force my_service
```
</details>

<details>
<summary><b>Q79: Scenario: How do you verify the active syntax configuration of a `docker-compose.yml` file without starting containers?</b></summary>
Run:
```bash
docker-compose config
```
</details>

<details>
<summary><b>Q80: Scenario: How do you configure a service container restart policy in Docker Compose to reboot automatically only if it crashes?</b></summary>
Set restart policy to `on-failure`:
```yaml
restart: on-failure
```
</details>

---

## ✦ Section 5: Troubleshooting & Security (Questions 81-100)

<details>
<summary><b>Q81: Scenario: A container crashes instantly upon startup. How do you find out why it failed?</b></summary>
Check exit code with `docker ps -a`. Inspect logs:
```bash
docker logs <container_name_or_ID>
```
If no output is found, override entrypoint to `/bin/sh` or `/bin/bash` to launch interactively and inspect environment configurations.
</details>

<details>
<summary><b>Q82: Scenario: How do you attach an interactive terminal session inside a running container to debug configurations?</b></summary>
Run:
```bash
docker exec -it <container_name> /bin/sh
```
(or `/bin/bash` if available).
</details>

<details>
<summary><b>Q83: Scenario: A container is running but behaving sluggishly. How do you monitor CPU, Memory, and Network usage statistics in real-time?</b></summary>
Run:
```bash
docker stats <container_name>
```
</details>

<details>
<summary><b>Q84: Scenario: You want to inspect the low-level JSON configuration details of a container (IP address, volume bindings, environment variables). What command?</b></summary>
Run:
```bash
docker inspect <container_name_or_ID>
```
</details>

<details>
<summary><b>Q85: Scenario: A containerized app cannot connect to external APIs because of network DNS resolution failures. How do you debug?</b></summary>
Inspect inside the container: `docker exec -it <container> cat /etc/resolv.conf`. Verify internet connection by pinging external IPs from container: `docker exec -it <container> ping 8.8.8.8`.
</details>

<details>
<summary><b>Q86: Scenario: How do you restrict a container's maximum memory usage to 512MB and swap limit to 1GB?</b></summary>
Run:
```bash
docker run -m 512m --memory-swap 1g myapp
```
</details>

<details>
<summary><b>Q87: Scenario: How do you restrict a container to use only 2 CPU cores?</b></summary>
Run:
```bash
docker run --cpus 2 myapp
```
</details>

<details>
<summary><b>Q88: Scenario: You need to extract files `/var/log/app.log` from a stopped container directory to the host. How?</b></summary>
Use the `docker cp` utility:
```bash
docker cp <container_ID>:/var/log/app.log /local/path/
```
</details>

<details>
<summary><b>Q89: Scenario: How do you limit log file growth for all Docker containers globally to prevent disk space saturation?</b></summary>
Configure logging options in `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```
Restart docker daemon.
</details>

<details>
<summary><b>Q90: Scenario: How do you view log entries of a container since the last 30 minutes?</b></summary>
Run:
```bash
docker logs --since 30m <container_name>
```
</details>

<details>
<summary><b>Q91: Scenario: You want to check the process list running inside a container from the host command line. What command?</b></summary>
Run:
```bash
docker top <container_name>
```
</details>

<details>
<summary><b>Q92: Scenario: How do you check what files have been added, modified, or deleted in the container's writable layer?</b></summary>
Run:
```bash
docker diff <container_name>
```
</details>

<details>
<summary><b>Q93: Scenario: How do you copy a local file `/local/config.json` into a running container path `/app/config.json`?</b></summary>
Run:
```bash
docker cp /local/config.json <container_ID>:/app/config.json
```
</details>

<details>
<summary><b>Q94: Scenario: A container fails to start with "container_linux.go: starting container process caused...". What is the usual cause?</b></summary>
Usually a mismatch in executable formatting (e.g. Windows line endings `\r\n` in entrypoint shell scripts instead of Unix endings `\n`). Run `dos2unix` on the script.
</details>

<details>
<summary><b>Q95: Scenario: How do you block a container from writing anything to the host filesystem outside its designated volume?</b></summary>
Run with a read-only root filesystem:
```bash
docker run --read-only myapp
```
</details>

<details>
<summary><b>Q96: Scenario: How do you temporarily pause all processes inside a running container?</b></summary>
Run:
```bash
docker pause <container_name>
```
Resume with `docker unpause <container_name>`.
</details>

<details>
<summary><b>Q97: Scenario: You want to verify if the Docker daemon configuration has debug logging enabled. How?</b></summary>
Run `docker info | grep "Debug Mode"`.
</details>

<details>
<summary><b>Q98: Scenario: How do you list the exit codes of all stopped containers?</b></summary>
Run:
```bash
docker ps -a --format "table {{.Names}}\t{{.Status}}"
```
</details>

<details>
<summary><b>Q99: Scenario: How do you audit Docker security configuration settings on the host?</b></summary>
Use the official Docker Bench for Security container image:
```bash
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /etc:/etc:ro -v /lib/systemd:/lib/systemd:ro -v /usr/bin/docker:/usr/bin/docker:ro \
  -v /var/lib/docker:/var/lib/docker:ro -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
```
</details>

<details>
<summary><b>Q100: Scenario: How do you verify which version of the Docker client and server engine are installed?</b></summary>
Run:
```bash
docker version
```
</details>
