#!/usr/bin/env zsh
set -euo pipefail

# Usage: ./scripts/stop.sh [--volumes]
# --volumes : remove volumes as well (docker compose down -v)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

REMOVE_VOLUMES=false
for arg in "$@"; do
  case $arg in
    --volumes) REMOVE_VOLUMES=true; shift;;
    *) ;;
  esac
done

if [ "$REMOVE_VOLUMES" = true ]; then
  echo "Stopping and removing containers and volumes..."
  docker compose down -v
else
  echo "Stopping containers (preserving volumes)..."
  docker compose down
fi

echo "Stopped."