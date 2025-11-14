#!/usr/bin/env zsh
set -euo pipefail

# Usage: ./scripts/status.sh [--follow] [--tail N]

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FOLLOW=false
TAIL=200
for arg in "$@"; do
  case $arg in
    --follow) FOLLOW=true; shift;;
    --tail) TAIL="$2"; shift 2;;
    *) ;;
  esac
done

echo "Docker compose ps:" 
docker compose ps

echo "\nRecent app logs (last $TAIL lines):"
docker compose logs --tail "$TAIL" app || true

if [ "$FOLLOW" = true ]; then
  echo "\nFollowing app logs (ctrl-c to stop):"
  docker compose logs -f app
fi