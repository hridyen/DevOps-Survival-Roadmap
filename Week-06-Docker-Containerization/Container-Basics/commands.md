[![Sector](https://img.shields.io/badge/SECTOR-Docker_Containerization-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Container_Basics_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Docker CLI — Commands Reference

---

## ✦ 🖼️ Image Assembly

```bash
docker pull nginx                         # Synchronize image footprint from Docker Hub
docker images                             # Audit local downloaded footprints
docker rmi nginx                          # Erase footprint locally
docker build -t myapp:v1 .                # Execute Dockerfile logic inside Current Directory .
```

---

## ✦ 📦 Container Lifecycles

```bash
docker run -d -p 8080:80 nginx           # Launch detached (-d) binding host 8080 to container 80
docker run -it ubuntu bash               # Jump explicitly into the terminal of a fresh container
docker rm -f mycontainer                 # Force obliterate a hanging container

docker ps -a                             # List ALL containers including crashed outputs!
docker logs -f mycontainer               # Stream STDOUT logs visually
```

---

## ✦ 💾 Storage Voluming

```bash
docker volume create myvolume           # Generates localized Docker Engine storage struct
docker run -v myvolume:/app/data nginx  # Mount structured engine volume explicitly
docker run -v /root/code:/app nginx     # Hard-bind host path instantly mirroring active code changes!!
```

---

## ✦ 📝 My Pipeline Execution Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `docker system prune -a` | Cleans up all unused, unattached images and volumes. | Recovering 20GB of disk space from dead Jenkins CI test runs that left dangling images. |
| `docker exec -it <id> sh` | Drops you into an active, running container shell. | Debugging crashed Nginx containers internally natively without stopping the main process! |
