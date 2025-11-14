#!/usr/bin/env zsh
set -euo pipefail

# Usage: ./scripts/start.sh [--all]
# --all : start whole compose stack; without it starts only `app` service

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

ALL=false
for arg in "$@"; do
  case $arg in
    --all) ALL=true; shift;;
    *) ;;
  esac
done

if [ ! -f .env ]; then
  echo ".env not found. Run ./scripts/setup-docker.sh first."; exit 1
fi
set -a; source .env; set +a

if [ "$ALL" = true ]; then
  echo "Starting full docker-compose stack..."
  docker compose up -d
else
  echo "Starting app service only..."
  docker compose up -d app
fi

echo "To follow logs: docker compose logs -f app"