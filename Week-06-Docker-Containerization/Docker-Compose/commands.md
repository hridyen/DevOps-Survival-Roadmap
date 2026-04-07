[![Sector](https://img.shields.io/badge/SECTOR-Docker_Containerization-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Docker_Compose_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ YAML Compose — Commands Reference

---

## ✦ 🧩 Daemon Composition

```bash
docker compose up                        # Foreground launch locking the console securely natively
docker compose up -d                     # Detached background launch entirely gracefully!
docker compose down                      # Terminates ALL containers defined in YAML and dynamically deletes their bridge!
docker compose down -v                   # Dangerous! Overrides safety gracefully destroying linked volumes natively too!
```

---

## ✦ 🛠️ Live Debugging Interfaces

```bash
docker compose ps                        # Tracks ONLY the containers associated natively with this exact compose instance natively!
docker compose logs -f servicename       # Steal distinct continuous output logs streaming gracefully
docker compose build                     # Force an un-cached rebuilding structurally of custom Dockerfile parameters natively
docker compose exec servicename bash    # Drop a console explicitly into one component structurally
```

---

## ✦ 📝 My Structural Integration Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `docker compose restart web` | Reboots a singular node gracefully instead of taking down the entire YAML tree down. | Testing a fast `.conf` file substitution natively inside an Nginx container cleanly. |
