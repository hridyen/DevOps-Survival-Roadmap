[![Sector](https://img.shields.io/badge/SECTOR-Docker_Containerization-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Docker_Compose_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Compose & Structural Interlinking

> **Focus:** Multi-container structural definitions, declarative YAML logic, and automated voluming.

---

## ✦ 1. The Power of Declarative Syntax

Instead of explicitly running 4 distinct massive CLI commands dynamically, `docker-compose.yml` allows engineers to physically codify infrastructure into Git repositories securely.

```yaml
version: "3.8"

services:
  web:
    image: nginx
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - mynet
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: secret
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - mynet

volumes:
  dbdata:
networks:
  mynet:
```

> [!TIP]
> The `depends_on` functionality does NOT magically wait for the database connection matrix to accept pings, it merely forces the Docker Daemon to start spinning up the `db` container chronologically before spinning the `web` container.

---

## ✦ 2. Automatic DNS Resolution

When utilizing custom Docker Bridge Networks in compose, the engine binds an internal DNS dynamically!

If the `web` container needs to ping the database, it doesn't need to hunt for changing IPs randomly, it just curls `http://db:3306` natively and Docker automatically routes it!

---

## ✦ Practice Exercises
- [ ] Construct a YAML structure launching two totally separate Nginx clones that can dynamically ping each other using native alias names entirely blindly over a custom bridge network locally.
