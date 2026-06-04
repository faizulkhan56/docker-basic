#!/usr/bin/env bash
# Smoke-test class-demo projects on Ubuntu/Linux (Docker Engine required).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GREEN}PASS${NC}: $1"; }
fail() { echo -e "${RED}FAIL${NC}: $1"; exit 1; }

require_docker() {
  command -v docker >/dev/null 2>&1 || fail "docker not found. Install: sudo apt install -y docker.io"
  docker info >/dev/null 2>&1 || fail "docker daemon not running. Run: sudo systemctl start docker"
  docker compose version >/dev/null 2>&1 || fail "docker compose plugin not found"
}

wait_http() {
  local url="$1"
  local expect="$2"
  local i
  for i in $(seq 1 30); do
    if curl -fsS "$url" 2>/dev/null | grep -q "$expect"; then
      return 0
    fi
    sleep 2
  done
  return 1
}

test_dockerfile_demo() {
  local dir="$1"
  local image="$2"
  local name="$3"
  echo "=== Dockerfile: $dir ==="
  docker build -t "$image" "./class-demo/$dir"
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker run -d -p 8000:8000 --name "$name" "$image"
  wait_http "http://127.0.0.1:8000/health" '"status"' \
    || fail "$dir /health unreachable"
  curl -fsS "http://127.0.0.1:8000/health" | grep -Eq '"status"[[:space:]]*:[[:space:]]*"ok"' \
    || fail "$dir /health did not return status ok"
  docker rm -f "$name" >/dev/null
  pass "$dir build and /health"
}

test_compose_demo() {
  local dir="$1"
  local web_port="$2"
  local db_container="$3"
  echo "=== Compose: $dir (web :$web_port) ==="
  pushd "./class-demo/$dir" >/dev/null
  docker compose config >/dev/null
  docker compose down -v >/dev/null 2>&1 || true
  docker compose up --build -d
  popd >/dev/null
  wait_http "http://127.0.0.1:${web_port}/db-check" '"students"' \
    || fail "$dir /db-check unreachable"
  curl -fsS "http://127.0.0.1:${web_port}/db-check" | grep -Eq '"students"[[:space:]]*:[[:space:]]*3' \
    || fail "$dir /db-check did not return students: 3"
  docker exec "$db_container" mysql -uroot -proot123 training -e \
    "SELECT COUNT(*) AS total FROM students;" | grep -q "3" \
    || fail "$dir MySQL row count check failed"
  pushd "./class-demo/$dir" >/dev/null
  docker compose down -v >/dev/null
  popd >/dev/null
  pass "$dir compose up, /db-check, and MySQL count"
}

echo "Docker training repo verification"
echo "Repo root: $ROOT"
require_docker
pass "Docker daemon and Compose plugin available"

# --- Dockerfile demos (serial on host port 8000) ---
test_dockerfile_demo "dockerfile-demo" "class/python-demo:verify" "verify-python"
test_dockerfile_demo "dockerfile-demo-java" "class/java-demo:verify" "verify-java"
test_dockerfile_demo "dockerfile-demo-nodejs" "class/nodejs-demo:verify" "verify-nodejs"

# --- Compose demos ---
test_compose_demo "compose-demo" "8080" "class-demo-db"
test_compose_demo "compose-demo-java" "8091" "class-demo-java-db"
test_compose_demo "compose-demo-nodejs" "8092" "class-demo-nodejs-db"

echo ""
echo -e "${GREEN}All automated smoke tests passed.${NC}"
echo "Manual demos (not scripted here): pid-namespace-demo, volume-demo, dockerhub-demo, ghcr-test"
