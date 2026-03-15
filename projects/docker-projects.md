# 🐳 Docker Projects

> Projects I built and dockerized during Week 6 training.

---

## Project 1:  MySQL with Docker Volume Persistence

**Description:**  hands-on DevOps project demonstrating how to run MySQL inside Docker with persistent storage using Docker Volumes.

This project proves that:

Containers are temporary
Volumes are persistent
Database data survives container deletion

**Stack:** Docker
MySQL 8
Named Volumes
Git & GitHub


**What I learned:**
Understanding Docker volumes
Data persistence in containers
MySQL container configuration
Infrastructure isolation principles
Practical DevOps workflow

**GitHub Repo:** https://github.com/hridyen/docker-mysql-volume-persistence.git

**Dockerfile snippet:**

FROM mysql:8

ENV MYSQL_ROOT_PASSWORD=1234
ENV MYSQL_DATABASE=devopsdb

EXPOSE 3306


---

## Project 2: Multi-Container App with Docker Compose

**Description:** ReliefCo is a full-stack disaster relief platform built to connect volunteers, donors, and administrators during times of crisis.

The application enables transparent donations, volunteer coordination, and efficient relief management through a centralized system.



**Services:**
- Service 1:  Nginx 
- Service 2:  Node.js API
- Service 3:  MongoDB
- Service 4:  React

**docker-compose.yml:**

services:
  backend:
    build:
      context: .
      dockerfile: Dockerfiles/Dockerfile.backend
    container_name: backend
    restart: always  
    env_file:
      - ./backend/.env
    depends_on:
      - mongo
    networks:
      - app_network
  frontend:
    build:
      context: .
      dockerfile: Dockerfiles/Dockerfile.frontend 
    container_name: frontend
    restart: always 
    networks:
      - app_network

  mongo:
    image: mongo:latest
    container_name: mongo
    restart: always
    expose:
      - "27017"
    volumes:
      - mongo-data:/data/db
    networks:
      - app_network
  nginx:
    image: nginx:latest
    container_name: nginx
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - frontend
      - backend
    networks:
      - app_network
volumes:
  mongo-data:
networks:
  app_network:
    driver: bridge


---

## Project 3: Docker Swarm Deployment

**Description:** Deployed a service across multiple nodes using Docker Swarm.

**Steps taken:**
1. Initialized swarm on manager node
2. Joined 2 worker nodes to the swarm
3. Created an overlay network
4. Deployed a service with 3 replicas
5. Scaled the service up and down

**Commands used:**
docker swarm init
docker swarm init --advertise-addr <IP>
docker swarm join-token worker
docker swarm join-token manager
docker swarm join --token <TOKEN> <MANAGER-IP>:2377
docker node ls
docker node inspect <NODE-ID>
docker node update --availability drain <NODE-ID>
docker node promote <NODE-ID>
docker node demote <NODE-ID>
docker node rm <NODE-ID>
docker swarm leave
docker swarm leave --force
docker service create --name <SERVICE-NAME> <IMAGE>
docker service ls
docker service ps <SERVICE-NAME>
docker service inspect <SERVICE-NAME>
docker service logs <SERVICE-NAME>
docker service scale <SERVICE-NAME>=<REPLICAS>
docker service update <SERVICE-NAME>
docker service update --image <IMAGE> <SERVICE-NAME>
docker service rm <SERVICE-NAME>
docker stack deploy -c docker-compose.yml <STACK-NAME>
docker stack ls
docker stack services <STACK-NAME>
docker stack ps <STACK-NAME>
docker stack rm <STACK-NAME>
docker network create --driver overlay <NETWORK-NAME>
docker config create <CONFIG-NAME> <FILE>
docker secret create <SECRET-NAME> <FILE>
docker secret ls
docker secret rm <SECRET-NAME>
docker config ls
docker config rm <CONFIG-NAME>

---

## 📝 Notes

Will be adding more projects on the way
