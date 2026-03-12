# Docker Training Session Guide

This repository is designed for a live Docker class.  
The image sequence is intentionally ordered, and the content below follows the same order from **1 to 24**.

---

## Session Goals

- Understand what containers are and why they matter.
- Explain Docker architecture and lifecycle clearly.
- Demonstrate Dockerfile, image layering, volume persistence, and Docker Compose.
- Run simple, practical examples that participants can reproduce on their own machine.

---

## Prerequisites for Participants

- Docker Desktop installed and running.
- Basic terminal usage.
- Internet access (for pulling base images).
- Recommended: at least 8 GB RAM.
- Commands in this guide are written to be PowerShell-friendly.

---

## Command Style by Host OS

Use the command style that matches your host machine:

- **Windows (PowerShell)**: use `cd .\path\to\dir` and `${PWD}` for current path.
- **Ubuntu/Linux/macOS (bash)**: use `cd ./path/to/dir` and `$(pwd)` for current path.

Most Docker commands are same across OS; only path formatting and line continuation differ.

Quick verification:

```bash
docker version
docker info
```

---

## Image-By-Image Theory (Serial Order)

### 1) `image/1.png` - What are Containers
![1](image/1.png)

Container = isolated packaged environment containing app + dependencies.

---

### 2) `image/2-onprem-virtualmachine.png` - Traditional VM Model
![2](image/2-onprem-virtualmachine.png)

In VM world, each VM has a full guest OS. This adds overhead and slower startup.

---

### 3) `image/3-three-tier-app-on-vm.png` - 3-Tier App on VMs
![3](image/3-three-tier-app-on-vm.png)

Web, logic, and DB are split, often into separate VMs. Good isolation, but resource-heavy.

---

### 4) `image/4-container.png` - Containerized Model
![4](image/4-container.png)

Containers share host kernel through Docker Engine, so they are lightweight and fast to start.

---

### 5) `image/5-container-on-different-distribution.png` - Mixed Runtime Stacks
![5](image/5-container-on-different-distribution.png)

Different app stacks (Java, Python, MySQL) can run together consistently on one Docker host.

---

### 6) `image/6-delta-kernel-support-docker-engine.png` - Kernel Delta Concept
![6](image/6-delta-kernel-support-docker-engine.png)

Containers rely on host kernel. Image layers carry user-space dependencies; kernel remains shared.

---

### 7) `image/7-application-architecture-evolution-docker-importance.png` - Monolith to Microservices
![7](image/7-application-architecture-evolution-docker-importance.png)

Containers are a strong fit for microservices because they package and deploy services independently.

---

### 8) `image/8-microsvc-architecture.png` - Service per Container
![8](image/8-microsvc-architecture.png)

Each microservice can run in its own container for independent scaling and deployment.

---

### 9) `image/9-multiple-replica-of-one-svc.png` - Replicas and Scale
![9](image/9-multiple-replica-of-one-svc.png)

You can run multiple replicas of a service container to handle load.

---

### 10) `image/10-docker-container-all-parts.png` - Docker Components
![10](image/10-docker-container-all-parts.png)

- Client sends commands (`docker build`, `docker run`).
- Daemon does the work.
- Registry stores images.

---

### 11) `image/11-docker-container-life-cycle.png` - Lifecycle
![11](image/11-docker-container-life-cycle.png)

Typical flow: pull/build image -> run container -> modify -> push image.

---

### 12) `image/12-docker-architecture-in-ec2-server.png` - Real Deployment Architecture
![12](image/12-docker-architecture-in-ec2-server.png)

Client communicates with daemon on host/EC2, daemon pulls/pushes images to Docker Hub or private registry.

---

### 13) `image/13-packaging-application.png` - Packaging with Dockerfile
![13](image/13-packaging-application.png)

Dockerfile defines the image. Image is a template. Container is a running instance.

---

### 14) `image/14-basic-python-docker-file.png` - Basic Dockerfile Example
![14](image/14-basic-python-docker-file.png)

Key Dockerfile instructions:
- `FROM` base image
- `RUN` install dependencies
- `COPY` app files
- `WORKDIR` working directory
- `EXPOSE` port metadata
- `ENTRYPOINT` or `CMD` startup command

---

### 15) `image/15-docker-file-layered-architecture.png` - Layered Build and Cache
![15](image/15-docker-file-layered-architecture.png)

Every instruction creates a layer. Unchanged layers are cached, making rebuilds faster.

---

### 16) `image/16-layered-architecture.png` - Read-Only Image + RW Container Layer
![16](image/16-layered-architecture.png)

Image layers are read-only. Container adds a thin writable layer at runtime.

---

### 17) `image/17-copy-onwrite.png` - Copy-on-Write
![17](image/17-copy-onwrite.png)

If a file from an image layer is modified, a copy is created in container writable layer.

---

### 18) `image/18-docker-volume.png` - Volumes
![18](image/18-docker-volume.png)

Volumes store data outside container writable layer, so data survives container recreation.

---

### 19) `image/19-type-of-docker-network.png` - Default Networks
![19](image/19-type-of-docker-network.png)

- `bridge`: default isolated network
- `none`: no networking
- `host`: container shares host network stack (Linux behavior)

---

### 20) `image/20-docker-network-command.png` - Custom Network Commands
![20](image/20-docker-network-command.png)

Create custom bridges for better service isolation and naming.

---

### 21) `image/21-docker-embeded-dns.png` - Embedded DNS
![21](image/21-docker-embeded-dns.png)

Containers on same user-defined bridge can resolve each other by service/container name.

---

### 22) `image/22-linux-namespace-docker-evolution.png` - Linux Namespace Foundation
![22](image/22-linux-namespace-docker-evolution.png)

Namespaces isolate PID, network, mount, IPC, etc. This is the core of container isolation.

---

### 23) `image/23-container-process-same-host-process.png` - PID Namespace View
![23](image/23-container-process-same-host-process.png)

Container sees its own process tree (PID namespace), while host sees all processes globally.

---

### 24) `image/24-docker-compose-evolution.png` - Docker Compose Evolution
![24](image/24-docker-compose-evolution.png)

Compose manages multi-container apps using one YAML file, with cleaner dependency and network management.

---

### 25) `image/25-server-docker-portmapping.png` - Port Mapping
![25](image/25-server-docker-portmapping.png)

Port mapping (`-p host_port:container_port`) exposes container services to the host and external networks. Without mapping, services are only accessible via container internal IPs. Multiple containers can map different host ports to the same container port, enabling multiple instances of the same service.

**Key concepts:**
- `docker run -p 80:5000` maps host port 80 to container port 5000
- `docker run -p 8000:5000` maps host port 8000 to container port 5000
- Without `-p`, the service is only reachable via container's internal IP (e.g., `172.17.0.2:5000`)
- With `-p`, external users access via host IP and mapped port (e.g., `http://192.168.1.5:80`)

---

## Ubuntu Setup (Docker + Docker Compose)

Run these steps on Ubuntu before starting live demos.

### 1) Remove old/conflicting packages (safe if not installed)

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y $pkg
done
```

### 2) Install Docker official repository

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 3) Install Docker Engine + Compose plugin

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 4) Start and enable Docker service

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### 5) (Recommended) Run Docker without sudo

```bash
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
newgrp docker
```

If group changes do not apply immediately, log out and log back in once.

### 6) Verify installation

```bash
docker version
docker compose version
docker run --rm hello-world
```

---

## Live Demo Plan (Step-by-Step)

Use this sequence during class:

1. Docker fundamentals check
2. Dockerfile demo (build and run Python app)
3. Volume demo (data persistence)
4. Compose demo (web + db services)
5. Docker Hub demo (login, tag, push, verify)

---

## Demo 1: Dockerfile Basic Example

Demo files are in `class-demo/dockerfile-demo/`.

### A) Build Image

Windows PowerShell:

```powershell
cd .\class-demo\dockerfile-demo
docker build -t class/python-demo:v1 .
```

Ubuntu/Linux/macOS (bash):

```bash
cd ./class-demo/dockerfile-demo
docker build -t class/python-demo:v1 .
```

### B) Run Container

Windows PowerShell:

```powershell
docker run --rm -p 8000:8000 --name python-demo class/python-demo:v1
```

Ubuntu/Linux/macOS (bash):

```bash
docker run --rm -p 8000:8000 --name python-demo class/python-demo:v1
```

Open: `http://localhost:8000`

### C) Observe Layer Cache

Rebuild once:

Windows PowerShell:

```powershell
docker build -t class/python-demo:v2 .
```

Ubuntu/Linux/macOS (bash):

```bash
docker build -t class/python-demo:v2 .
```

Change only app code (`app.py`) and rebuild. Show that dependency layers are reused.

---

## Demo 2: Docker Volume Example

### A) Create Named Volume

Windows PowerShell:

```powershell
docker volume create class_mysql_data
docker volume ls
```

Ubuntu/Linux/macOS (bash):

```bash
docker volume create class_mysql_data
docker volume ls
```

### B) Run MySQL Using Volume

Windows PowerShell:

```powershell
docker run -d --name class-mysql -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=training -v class_mysql_data:/var/lib/mysql -p 3307:3306 mysql:8
```

Ubuntu/Linux/macOS (bash):

```bash
docker run -d --name class-mysql -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=training -v class_mysql_data:/var/lib/mysql -p 3307:3306 mysql:8
```

### C) Prove Persistence

1) Create table and insert sample data:

Windows PowerShell:

```powershell
docker exec -it class-mysql mysql -uroot -proot123 -e "USE training; CREATE TABLE IF NOT EXISTS students (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL); INSERT INTO students (name) VALUES ('Alice'),('Bob'),('Charlie'); SELECT * FROM students;"
```

Ubuntu/Linux/macOS (bash):

```bash
docker exec -it class-mysql mysql -uroot -proot123 -e "USE training; CREATE TABLE IF NOT EXISTS students (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL); INSERT INTO students (name) VALUES ('Alice'),('Bob'),('Charlie'); SELECT * FROM students;"
```

2) Stop and remove container:

Windows PowerShell:

```powershell
docker rm -f class-mysql
```

Ubuntu/Linux/macOS (bash):

```bash
docker rm -f class-mysql
```

3) Run same command again (same volume).  
4) Verify data still exists after container recreation:

Windows PowerShell:

```powershell
docker exec -it class-mysql mysql -uroot -proot123 -e "USE training; SELECT * FROM students;"
```

Ubuntu/Linux/macOS (bash):

```bash
docker exec -it class-mysql mysql -uroot -proot123 -e "USE training; SELECT * FROM students;"
```

### D) Bind Mount Quick Example (Optional)

Windows PowerShell:

```powershell
docker run --rm -it -v "${PWD}/class-demo/volume-demo:/data" alpine sh
```

Ubuntu/Linux/macOS (bash):

```bash
docker run --rm -it -v "$(pwd)/class-demo/volume-demo:/data" alpine sh
```

Create file inside `/data` and show it appears on host folder.

---

## Demo 3: Docker Compose Basic Example

Demo files are in `class-demo/compose-demo/`.

### A) Start Services

Windows PowerShell:

```powershell
cd .\class-demo\compose-demo
docker compose up --build -d
```

Ubuntu/Linux/macOS (bash):

```bash
cd ./class-demo/compose-demo
docker compose up --build -d
```

### B) Verify

Windows PowerShell:

```powershell
docker compose ps
docker compose logs -f web
```

Ubuntu/Linux/macOS (bash):

```bash
docker compose ps
docker compose logs -f web
```

Open: `http://localhost:8080`

### C) Explain Compose Concepts

- Service definitions (`web`, `db`)
- Automatic network
- Volume mounting for DB persistence
- Environment variables
- Dependency with `depends_on`

### D) Stop and Cleanup

Windows PowerShell:

```powershell
docker compose down
```

Ubuntu/Linux/macOS (bash):

```bash
docker compose down
```

To remove volume as well:

Windows PowerShell:

```powershell
docker compose down -v
```

Ubuntu/Linux/macOS (bash):

```bash
docker compose down -v
```

---

## Demo 4: Docker Hub Push (Image Registry)

This demo shows how to push a Docker image to Docker Hub, making it available publicly or privately.

Demo files are in `class-demo/dockerhub-demo/`.

### Prerequisites

1. **Create Docker Hub Account** (if not already done):
   - Go to [https://hub.docker.com](https://hub.docker.com)
   - Click "Sign Up" and create a free account
   - Verify your email address
   - Note your Docker Hub username (e.g., `yourusername`)

### A) Build the Image

Windows PowerShell:

```powershell
cd .\class-demo\dockerhub-demo
docker build -t nginx-demo:v1 .
```

Ubuntu/Linux/macOS (bash):

```bash
cd ./class-demo/dockerhub-demo
docker build -t nginx-demo:v1 .
```

**Verify the image was created:**

```bash
docker images nginx-demo:v1
```

### B) Test the Image Locally

Windows PowerShell:

```powershell
docker run -d -p 8081:80 --name nginx-test nginx-demo:v1
```

Ubuntu/Linux/macOS (bash):

```bash
docker run -d -p 8081:80 --name nginx-test nginx-demo:v1
```

Open: `http://localhost:8081` to verify it works.

**Stop and remove test container:**

```bash
docker rm -f nginx-test
```

### C) Login to Docker Hub

Windows PowerShell:

```powershell
docker login
```

Ubuntu/Linux/macOS (bash):

```bash
docker login
```

**What to expect:**
- Enter your Docker Hub username
- Enter your Docker Hub password (or access token)
- Success message: `Login Succeeded`

**Note:** If you have 2FA enabled, use an access token instead of password. Create one at: Docker Hub → Account Settings → Security → New Access Token

### D) Tag the Image for Docker Hub

**Important:** Docker Hub requires images to be tagged with format: `username/imagename:tag`

Replace `yourusername` with your actual Docker Hub username:

Windows PowerShell:

```powershell
docker tag nginx-demo:v1 yourusername/nginx-demo:v1
docker tag nginx-demo:v1 yourusername/nginx-demo:latest
```

Ubuntu/Linux/macOS (bash):

```bash
docker tag nginx-demo:v1 yourusername/nginx-demo:v1
docker tag nginx-demo:v1 yourusername/nginx-demo:latest
```

**Verify tags:**

```bash
docker images | grep nginx-demo
```

You should see:
- `nginx-demo:v1`
- `yourusername/nginx-demo:v1`
- `yourusername/nginx-demo:latest`

### E) Push Image to Docker Hub

Windows PowerShell:

```powershell
docker push yourusername/nginx-demo:v1
docker push yourusername/nginx-demo:latest
```

Ubuntu/Linux/macOS (bash):

```bash
docker push yourusername/nginx-demo:v1
docker push yourusername/nginx-demo:latest
```

**What to expect:**
- Layers will be pushed one by one
- Progress bars show upload status
- Success message: `v1: digest: sha256:...`

**Note:** First push may take a few minutes depending on internet speed.

### F) Verify on Docker Hub Website

1. Go to [https://hub.docker.com](https://hub.docker.com)
2. Login to your account
3. Click on your profile → "Repositories"
4. You should see `yourusername/nginx-demo` listed
5. Click on the repository to see:
   - Tags: `v1` and `latest`
   - Image size
   - Pull command: `docker pull yourusername/nginx-demo:latest`
   - Last pushed timestamp

### G) Test Pulling from Docker Hub

**Remove local image first:**

```bash
docker rmi yourusername/nginx-demo:v1 yourusername/nginx-demo:latest nginx-demo:v1
```

**Pull from Docker Hub:**

Windows PowerShell:

```powershell
docker pull yourusername/nginx-demo:latest
docker run -d -p 8082:80 --name nginx-from-hub yourusername/nginx-demo:latest
```

Ubuntu/Linux/macOS (bash):

```bash
docker pull yourusername/nginx-demo:latest
docker run -d -p 8082:80 --name nginx-from-hub yourusername/nginx-demo:latest
```

Open: `http://localhost:8082` - should show the same page!

**Cleanup:**

```bash
docker rm -f nginx-from-hub
```

### H) Key Concepts Explained

- **Docker Hub**: Public registry for Docker images (like GitHub for code)
- **Tagging**: `docker tag` creates a new reference to the same image layer
- **Pushing**: `docker push` uploads image layers to registry
- **Pulling**: `docker pull` downloads image from registry
- **Image naming**: `username/repository:tag` format required for Docker Hub
- **Latest tag**: Convention for most recent stable version

### I) Common Commands Reference

```bash
# Login
docker login

# Logout
docker logout

# List your images
docker images

# Tag image
docker tag <source> <target>

# Push image
docker push <username>/<image>:<tag>

# Pull image
docker pull <username>/<image>:<tag>

# Search public images
docker search nginx
```

---

## Useful Commands for Class Q&A

```bash
docker ps -a
docker images
docker logs <container>
docker exec -it <container> sh
docker inspect <container_or_image>
docker network ls
docker volume ls
docker system df
```

---

## Suggested 90-Minute Session Timeline

- 0-20 min: Concepts using image 1-12
- 20-40 min: Dockerfile + image layers (13-17)
- 40-55 min: Volume and persistence (18)
- 55-70 min: Networks + DNS (19-21)
- 70-80 min: Compose demo (24)
- 80-90 min: Docker Hub push demo + Q&A

**Extended 120-Minute Option:**
- 0-20 min: Concepts using image 1-12
- 20-40 min: Dockerfile + image layers (13-17)
- 40-55 min: Volume and persistence (18)
- 55-70 min: Networks + DNS (19-21)
- 70-85 min: Compose demo (24)
- 85-105 min: Docker Hub push demo (login, tag, push, verify)
- 105-120 min: Q&A and recap

---

## Practice Tasks for Participants

1. Build Dockerfile demo image and run it on port `8001`.
2. Add one new endpoint in `app.py` and rebuild.
3. Create a named volume and mount it to any container.
4. Run compose demo and access web service.
5. Stop compose and restart without losing DB data.
6. Build nginx-demo image, tag it with your Docker Hub username, and push to Docker Hub.

---

## Important Teaching Notes

- Explain the difference clearly: **image != container**.
- Emphasize persistence problem without volumes.
- Show real commands live; avoid only slides.
- Keep one terminal for commands and one for logs.
- Ask participants to run each step with you.


