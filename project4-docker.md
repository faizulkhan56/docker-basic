# Project 4 — Docker Containerization

**Course:** DevOps Fundamentals (Moderate Level)  
**Duration:** 4–6 hours  
**Reference material:** `README.md`, `image/` (1–25), `class-demo/`

---

## Context

You have completed class demos covering container fundamentals, Dockerfile layering, volumes, embedded DNS, Docker Compose, and image registry workflows. This project applies those concepts to build and operate a small **Product Catalog API** (web service + MySQL) on a single Docker host.

Choose **one** runtime for the API: Python (Flask), Node.js (Express), or Java (Javalin). Patterns mirror `class-demo/dockerfile-demo*` and `class-demo/compose-demo*`.

---

## Prerequisites

- Docker Engine + Compose plugin installed and running
- Docker Hub account
- Basic terminal and HTTP client usage (`curl` or browser)
- Host ports available: `8000`, `8080`, `3308` (adjust in docs if conflicts exist)

---

## Deliverables

| # | Item |
|---|------|
| 1 | Project folder with source code, `Dockerfile`, `.dockerignore` |
| 2 | `docker-compose.yml` (web + db) |
| 3 | `db/init.sql` seeding a `products` table (min. 5 rows) |
| 4 | `SOLUTION.md` — commands run, screenshots or command output, brief answers |
| 5 | Public Docker Hub image: `<your-username>/product-catalog-api:<tag>` |

---

## Application Requirements

API must expose:

| Endpoint | Response |
|----------|----------|
| `GET /` | `{"service": "product-catalog", "status": "ok"}` |
| `GET /health` | `{"healthy": true}` |
| `GET /products` | JSON list of products from MySQL |
| `GET /products/count` | `{"count": <number>}` |

DB table `products`: `id`, `name`, `price` (decimal). Seed via `init.sql`.

Connection settings must use environment variables (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`) — same pattern as `class-demo/compose-demo`.

---

## Tasks

### Task 1 — Dockerfile & Image Build

**Objective:** Package the API using concepts from images 13–17 and Demo 1.

1. Write a `Dockerfile` with: `FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`.
2. Add `.dockerignore` (exclude at least `node_modules`, `target`, `__pycache__`, `.git`).
3. Build image: `product-catalog-api:v1`.
4. Run container mapping host `8000` → app port. Verify `/` and `/health`.

**Acceptance:** Container runs detached; both endpoints return expected JSON.

**Challenge:** Order instructions so dependency install layer is cached when only app code changes. In `SOLUTION.md`, show rebuild output proving cached layers after a one-line code change.

---

### Task 2 — Volume Persistence

**Objective:** Apply image 18 and Demo 2 — data survives container recreation.

1. Create named volume: `project4_mysql_data`.
2. Run standalone `mysql:8` with:
   - volume mounted to `/var/lib/mysql`
   - `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE=catalog`
   - host port `3308:3306`
3. Insert 3 rows into a test table.
4. Remove container (`docker rm -f`). Start a new MySQL container with the **same volume**.
5. Query data — rows must still exist.

**Acceptance:** Screenshot or terminal output showing identical data before and after container removal.

---

### Task 3 — Custom Network & DNS

**Objective:** Apply images 19–21 and Demo 3 — service discovery by name.

1. Create user-defined bridge network: `catalog-net`.
2. Run two Alpine containers on `catalog-net` (names: `api-host`, `db-host`).
3. From `api-host`, resolve and reach `db-host`:
   - `ping db-host` (install tools if needed)
   - `nslookup db-host` or `getent hosts db-host`
4. Record embedded DNS server IP from `/etc/resolv.conf` inside the container.

**Acceptance:** `SOLUTION.md` includes container-name resolution output and DNS IP (`127.0.0.11`).

---

### Task 4 — Docker Compose Stack

**Objective:** Apply image 24–25 and Demo 4 — multi-container orchestration.

1. Create `docker-compose.yml` with services `web` and `db`.
2. Configure:
   - named volume for MySQL data
   - `init.sql` mounted read-only to `/docker-entrypoint-initdb.d/`
   - `depends_on` with `condition: service_healthy` on `db`
   - DB healthcheck (`mysqladmin ping`)
   - web env vars for DB connection; `DB_HOST` must be service name `db`
   - port map: web `8080`, db `3308` (match class-demo port scheme)
3. Run: `docker compose up --build -d`.
4. Verify:
   - `GET http://localhost:8080/products` returns seeded data
   - `GET http://localhost:8080/products/count` returns correct count

**Acceptance:** `docker compose ps` shows healthy db; API reads from DB via service name (not `localhost`).

---

### Task 5 — Compose Operations & Data Durability

**Objective:** Prove persistence and lifecycle control (Demo 4 cleanup/restart pattern).

1. `docker compose down` (do **not** use `-v`).
2. `docker compose up -d`.
3. Confirm product count unchanged.
4. Add one product via `docker exec` into MySQL.
5. `docker compose restart web` — new product still visible via API.

**Acceptance:** `SOLUTION.md` documents count before/after `down`/`up` and after web restart.

---

### Task 6 — Image Registry Publish

**Objective:** Apply Demo 5 — tag, push, pull workflow.

1. Build production-ready web image from Task 4 context.
2. Tag: `<your-username>/product-catalog-api:v1` and `:latest`.
3. `docker login` → `docker push` both tags.
4. Remove local tagged images, `docker pull` from Hub, run on host port `8081`.
5. Verify `/health` on pulled image.

**Acceptance:** Docker Hub repository link in `SOLUTION.md`; pull-and-run succeeds on a clean local tag.

---

### Task 7 — Inspection & Troubleshooting (Written)

Answer briefly in `SOLUTION.md` (2–4 sentences each):

1. Image vs container — what happens to container writable layer on `docker rm`?
2. Why does Compose use `db` as hostname instead of `localhost` from the web container?
3. What is copy-on-write (image 17) and when does it matter?
4. Compare named volume vs bind mount — when would you choose each?
5. Run `docker top` and `docker exec <web> ps aux` on your compose web service. Note one PID difference between host and container views (image 23 concept).

---

## Optional Extension (Moderate+)

Pick **one**:

| Option | Requirement |
|--------|-------------|
| A — Multi-stage build | Java or Node Dockerfile with separate build and runtime stages (see `dockerfile-demo-java`) |
| B — GHCR | Push same image to `ghcr.io/<username>/product-catalog-api:v1` (see README GHCR section) |
| C — Resource limits | Add `deploy.resources.limits` (memory 256M) to web service; document behavior |

---

## Constraints

- No hard-coded DB credentials in source code — use env vars or Compose `environment`.
- Do not commit secrets, tokens, or `.env` files with real passwords.
- Use official base images (`python:*-slim`, `node:*-alpine`, `eclipse-temurin`, `mysql:8`).
- All containers must stop cleanly with `docker compose down`.

---

## Evaluation Rubric

| Criteria | Weight |
|----------|--------|
| Task 1 — Dockerfile quality & layer caching evidence | 15% |
| Task 2 — Volume persistence demonstrated | 10% |
| Task 3 — DNS lab completed | 10% |
| Task 4 — Compose stack functional | 25% |
| Task 5 — Data durability across lifecycle | 10% |
| Task 6 — Registry publish & pull | 15% |
| Task 7 — Written concepts | 10% |
| Optional extension | +5% bonus |
| Documentation clarity (`SOLUTION.md`) | 5% |

**Pass threshold:** 70% with Tasks 4 and 6 completed.

---

## Submission

```
<your-name>-project4-docker/
├── app/                  # API source
├── db/init.sql
├── Dockerfile
├── .dockerignore
├── docker-compose.yml
└── SOLUTION.md
```

Zip or push to assigned repository. Include Docker Hub repo URL in `SOLUTION.md`.

---

## Quick Reference

| Topic | Class demo |
|-------|------------|
| Single-service Dockerfile | `class-demo/dockerfile-demo*` |
| Volume / bind mount | `class-demo/volume-demo`, Demo 2 |
| DNS on custom network | Demo 3 |
| Web + MySQL Compose | `class-demo/compose-demo*` |
| Registry push | `class-demo/dockerhub-demo` |
| PID namespace | `class-demo/pid-namespace-demo` |
