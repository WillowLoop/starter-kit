#!/usr/bin/env bash
# Database backup script — cron-friendly (exit 0 on success, 1 on failure)
# Usage: backup.sh [--verify] [--list]
set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups"
BACKUP_KEEP_COUNT="${BACKUP_KEEP_COUNT:-30}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/db-$TIMESTAMP.dump"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# --- Compose file detection ---
detect_compose_file() {
  if [ -f "$PROJECT_ROOT/docker-compose.prod.yml" ]; then
    echo "$PROJECT_ROOT/docker-compose.prod.yml"
  elif [ -f "$PROJECT_ROOT/backend/docker-compose.prod.yml" ]; then
    echo "$PROJECT_ROOT/backend/docker-compose.prod.yml"
  elif [ -f "$PROJECT_ROOT/backend/docker-compose.yml" ]; then
    echo "$PROJECT_ROOT/backend/docker-compose.yml"
  else
    log "ERROR: No docker-compose file found"
    exit 1
  fi
}

COMPOSE_FILE="$(detect_compose_file)"

# --- List backups ---
if [[ "${1:-}" == "--list" ]]; then
  if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR"/*.dump 2>/dev/null)" ]; then
    echo "No backups found in $BACKUP_DIR"
    exit 0
  fi
  echo "Available backups:"
  echo "---"
  for f in $(ls -t "$BACKUP_DIR"/*.dump 2>/dev/null); do
    size=$(du -h "$f" | cut -f1)
    name=$(basename "$f")
    echo "  $name  ($size)"
  done
  echo "---"
  echo "Total: $(ls "$BACKUP_DIR"/*.dump 2>/dev/null | wc -l | tr -d ' ') backups"
  exit 0
fi

# --- Create backup ---
log "Starting database backup..."
log "Compose file: $COMPOSE_FILE"
mkdir -p "$BACKUP_DIR"

# Get DB credentials via docker compose exec (no .env reading)
DB_USER=$(docker compose -f "$COMPOSE_FILE" exec -T postgres printenv POSTGRES_USER 2>/dev/null || echo "postgres")
DB_NAME=$(docker compose -f "$COMPOSE_FILE" exec -T postgres printenv POSTGRES_DB 2>/dev/null || echo "aipoweredmakers")

log "Backing up database '$DB_NAME' as user '$DB_USER'..."
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  pg_dump -U "$DB_USER" --format=custom "$DB_NAME" > "$BACKUP_FILE"

# Validate backup
if [ ! -s "$BACKUP_FILE" ]; then
  log "ERROR: Backup file is empty or missing"
  rm -f "$BACKUP_FILE"
  exit 1
fi

chmod 600 "$BACKUP_FILE"
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log "Backup created: $(basename "$BACKUP_FILE") ($BACKUP_SIZE)"

# --- Retention: keep last N backups ---
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/db-*.dump 2>/dev/null | wc -l | tr -d ' ')
if [ "$BACKUP_COUNT" -gt "$BACKUP_KEEP_COUNT" ]; then
  REMOVE_COUNT=$((BACKUP_COUNT - BACKUP_KEEP_COUNT))
  log "Retention: removing $REMOVE_COUNT old backup(s) (keeping $BACKUP_KEEP_COUNT)..."
  ls -1t "$BACKUP_DIR"/db-*.dump | tail -n "$REMOVE_COUNT" | while read -r old; do
    log "  Removing: $(basename "$old")"
    rm -f "$old"
  done
fi

# --- Verify backup (optional) ---
if [[ "${1:-}" == "--verify" ]]; then
  log "Starting backup verification..."

  VERIFY_CONTAINER="backup-verify-$$"
  VERIFY_PORT=$((30000 + RANDOM % 10000))

  # Cleanup on exit (handles Ctrl+C)
  cleanup() {
    log "Cleaning up verification container..."
    docker rm -f "$VERIFY_CONTAINER" 2>/dev/null || true
  }
  trap cleanup EXIT

  # Spin up temporary postgres
  docker run -d --name "$VERIFY_CONTAINER" \
    -e POSTGRES_USER=verify -e POSTGRES_PASSWORD=verify -e POSTGRES_DB=verify \
    -p "$VERIFY_PORT:5432" \
    postgres:16-alpine > /dev/null

  log "Waiting for verification database to start..."
  for i in $(seq 1 30); do
    if docker exec "$VERIFY_CONTAINER" pg_isready -U verify > /dev/null 2>&1; then
      break
    fi
    if [ "$i" -eq 30 ]; then
      log "ERROR: Verification database did not start"
      exit 1
    fi
    sleep 1
  done

  # Restore into verification container
  log "Restoring backup into verification container..."
  docker exec -i "$VERIFY_CONTAINER" pg_restore -U verify -d verify --no-owner --no-acl < "$BACKUP_FILE"

  # Compare table counts
  SOURCE_TABLES=$(docker compose -f "$COMPOSE_FILE" exec -T postgres \
    psql -U "$DB_USER" -d "$DB_NAME" -t -c \
    "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" \
    | tr -d ' \n\r')

  VERIFY_TABLES=$(docker exec "$VERIFY_CONTAINER" \
    psql -U verify -d verify -t -c \
    "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" \
    | tr -d ' \n\r')

  if [ "$SOURCE_TABLES" = "$VERIFY_TABLES" ]; then
    log "Verification PASSED: $SOURCE_TABLES tables in source, $VERIFY_TABLES in backup"
  else
    log "ERROR: Verification FAILED: $SOURCE_TABLES tables in source, $VERIFY_TABLES in backup"
    exit 1
  fi

  # Cleanup happens via trap
  log "Verification complete."
fi

log "Backup complete."
