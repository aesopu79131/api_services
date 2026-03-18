#!/bin/bash
# Stop and remove the running app container. Used by CodeDeploy ApplicationStop.
set -e

CONTAINER_NAME="dragon-live"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping container: $CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" || true
  docker rm -f "$CONTAINER_NAME" || true
  echo "Container removed."
else
  echo "No container named $CONTAINER_NAME found."
fi
