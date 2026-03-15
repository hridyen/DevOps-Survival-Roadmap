# 🐳 Week 06 — Docker Commands Reference

---

## 🖼️ Images

```bash
docker pull nginx                         # Download image from Docker Hub
docker images                             # List all local images
docker rmi nginx                          # Remove an image
docker build -t myapp:v1 .               # Build image from Dockerfile in current dir
docker tag myapp:v1 username/myapp:v1    # Tag image for Docker Hub
docker push username/myapp:v1            # Push image to Docker Hub
docker history myimage                   # See layers of an image
docker inspect myimage                   # Detailed info about an image
```

---

## 📦 Containers

```bash
docker run nginx                          # Run a container (foreground)
docker run -d nginx                       # Run in background (detached)
docker run -d -p 8080:80 nginx           # Run with port mapping
docker run -d --name mycontainer nginx   # Run with a custom name
docker run -it ubuntu bash               # Run interactively with a shell
docker run --rm nginx                    # Auto-remove when stopped
docker run -e ENV_VAR=value nginx        # Pass environment variable

docker ps                                 # List running containers
docker ps -a                             # List all containers (including stopped)
docker stop mycontainer                  # Stop a running container
docker start mycontainer                 # Start a stopped container
docker restart mycontainer               # Restart a container
docker rm mycontainer                    # Delete a stopped container
docker rm -f mycontainer                 # Force delete a running container

docker logs mycontainer                  # View container logs
docker logs -f mycontainer              # Follow logs in real time
docker inspect mycontainer              # Detailed container info
docker stats                            # Live CPU/RAM usage of all containers
```

---

## 🔌 exec vs attach

```bash
docker exec -it mycontainer bash        # Open new bash shell inside container
docker exec mycontainer ls /app         # Run a command without entering container
docker attach mycontainer               # Attach to the container's main process
                                        # ⚠️ Use Ctrl+P then Ctrl+Q to detach safely
```

---

## 💾 Volumes

```bash
docker volume create myvolume           # Create a named volume
docker volume ls                        # List all volumes
docker volume rm myvolume               # Remove a volume
docker volume inspect myvolume          # See volume details

# Mount named volume
docker run -v myvolume:/app/data nginx

# Bind mount (host folder → container folder)
docker run -v /host/path:/container/path nginx
```

---

## 🌐 Networks

```bash
docker network ls                                  # List all networks
docker network create mynetwork                    # Create custom bridge network
docker network inspect mynetwork                   # See network details
docker network rm mynetwork                        # Delete a network
docker network connect mynetwork mycontainer       # Connect container to a network
docker network disconnect mynetwork mycontainer    # Disconnect

# Run container on a specific network
docker run --network mynetwork nginx
```

---

## 🧩 Docker Compose

```bash
docker compose up                        # Start all services
docker compose up -d                     # Start in background
docker compose down                      # Stop and remove containers
docker compose down -v                   # Also remove volumes
docker compose ps                        # List compose containers
docker compose logs                      # View logs
docker compose logs -f servicename      # Follow a specific service's logs
docker compose build                     # Rebuild images
docker compose restart servicename      # Restart one service
docker compose exec servicename bash    # Shell into a service
```

---

## ⚓ Docker Swarm

```bash
# Setup
docker swarm init                                   # Initialize swarm (on manager)
docker swarm join --token <TOKEN> <IP>:2377         # Join as worker

# Nodes
docker node ls                                      # List all nodes
docker node inspect nodeid                          # Node details
docker node update --availability drain nodeid      # Remove node from active duty

# Services
docker service create --name web -p 80:80 --replicas 3 nginx   # Deploy service
docker service ls                                   # List services
docker service ps web                               # See where replicas are running
docker service scale web=5                          # Scale to 5 replicas
docker service update --image nginx:latest web      # Rolling update
docker service rm web                               # Remove service

# Stacks (Compose in Swarm)
docker stack deploy -c docker-compose.yml mystack  # Deploy a compose file as a stack
docker stack ls                                     # List stacks
docker stack rm mystack                             # Remove stack
```

---

## 🧹 Cleanup Commands

```bash
docker system prune                      # Remove all stopped containers, unused images, networks
docker system prune -a                   # Also remove unused images
docker container prune                   # Remove all stopped containers
docker image prune                       # Remove dangling images
docker volume prune                      # Remove unused volumes
```

---

## 📝 My Docker Notes

<!-- Add commands and tricks you discovered during practice -->

| Command | What it does | Notes |
|---------|-------------|-------|
| | | |
