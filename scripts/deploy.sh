#!/usr/bin/env bash
# Usage: ./scripts/deploy.sh <docker-image:tag>
# Pulls the image, replaces the running container, checks health, and rolls back if it fails.
set -euo pipefail

IMAGE="${1:?Usage: deploy.sh <image:tag>}"
NAME="devops-demo"
PORT="${PORT:-8080}"

PREVIOUS=$(docker inspect --format '{{.Config.Image}}' "$NAME" 2>/dev/null || true)

start() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run -d --name "$NAME" -p "$PORT:3000" --restart unless-stopped "$1" >/dev/null
}

healthy() {
  for i in $(seq 1 15); do
    if curl -fs "http://localhost:$PORT/health" >/dev/null; then return 0; fi
    sleep 2
  done
  return 1
}

echo "Pulling $IMAGE"
docker pull "$IMAGE"

echo "Starting new version"
start "$IMAGE"

if healthy; then
  echo "Deploy OK: $IMAGE is live on http://localhost:$PORT"
  exit 0
fi

echo "Health check FAILED"
if [ -n "$PREVIOUS" ]; then
  echo "Rolling back to $PREVIOUS"
  start "$PREVIOUS"
  healthy && echo "Rollback OK" || echo "Rollback also failed"
fi
exit 1
