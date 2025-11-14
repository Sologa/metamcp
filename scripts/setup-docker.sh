#!/usr/bin/env zsh
set -euo pipefail

# Setup script for Docker-based local development
# - copies example.env -> .env if not present
# - generates BETTER_AUTH_SECRET if missing
# - starts postgres service and enables pgcrypto

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

command -v docker >/dev/null 2>&1 || { echo "docker is required. Please install Docker."; exit 1; }

# 1) copy example.env if .env not exists
if [ ! -f .env ]; then
  if [ -f example.env ]; then
    cp example.env .env
    echo ".env created from example.env"
  else
    echo "example.env not found. Create .env manually."; exit 1
  fi
else
  echo ".env already exists; not overwriting."
fi

# 2) ensure BETTER_AUTH_SECRET exists
if ! grep -q "^BETTER_AUTH_SECRET=" .env; then
  SECRET=$(openssl rand -hex 32)
  echo "BETTER_AUTH_SECRET=$SECRET" >> .env
  echo "BETTER_AUTH_SECRET appended to .env"
else
  # replace empty or placeholder value
  CURRENT=$(grep "^BETTER_AUTH_SECRET=" .env || true)
  if [ -z "$CURRENT" ] || echo "$CURRENT" | grep -q "your-super-secret"; then
    SECRET=$(openssl rand -hex 32)
    # macOS sed compatibility
    sed -i '' "s/^BETTER_AUTH_SECRET=.*/BETTER_AUTH_SECRET=$SECRET/" .env 2>/dev/null || sed -i "s/^BETTER_AUTH_SECRET=.*/BETTER_AUTH_SECRET=$SECRET/" .env
    echo "BETTER_AUTH_SECRET set in .env"
  else
    echo "BETTER_AUTH_SECRET already present in .env"
  fi
fi

# 3) start only Postgres service first
echo "Starting Postgres..."
docker compose up -d postgres

# load env variables for waiting/psql commands
set -a; source .env; set +a

# 4) wait for Postgres readiness
echo "Waiting for Postgres to become ready..."
RETRY=0
until docker compose exec postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  RETRY=$((RETRY+1))
  if [ $RETRY -gt 120 ]; then
    echo "Postgres did not become ready in time."; docker compose logs postgres --tail 200; exit 1
  fi
  sleep 1
done

echo "Postgres is ready. Ensuring pgcrypto extension exists..."
# 5) enable pgcrypto
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

echo "pgcrypto ensured. You can now run migrations or start the app."

echo "To start the app: ./scripts/start.sh"