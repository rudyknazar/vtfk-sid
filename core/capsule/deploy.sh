#!/usr/bin/env bash
set -euo pipefail

NAME="vtfk-capsule"
IMAGE="ubuntu:24.04"
HOST_PORT="${HOST_PORT:-8081}"

if ! command -v docker >/dev/null 2>&1; then
  echo "ПОМИЛКА: docker не знайдено в PATH" >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "ПОМИЛКА: Docker-демон недоступний" >&2
  exit 1
fi

docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d \
  --name "$NAME" \
  -p "${HOST_PORT}:80" \
  "$IMAGE" \
  sleep infinity

docker exec "$NAME" bash -c '
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends curl git procps iproute2
'
if [ "$(docker inspect -f "{{.State.Running}}" "$NAME")" != "true" ]; then
  echo "ПОМИЛКА: контейнер $NAME не піднявся" >&2
  exit 1
fi

echo "OK: $NAME працює, порт ${HOST_PORT}->80, утиліти встановлено."
exit 0

