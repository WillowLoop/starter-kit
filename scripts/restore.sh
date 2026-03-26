#!/usr/bin/env bash
# Database restore script
# Usage: restore.sh <backup-file> [--yes] [--latest]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups"
AUTO_CONFIRM=false

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

# --- Parse arguments ---
BACKUP_FILE=""
for arg in "$@"; do
  case "$arg" in
    --yes) AUTO_CONFIRM=true ;;
    --latest)
      BACKUP_FILE=$(ls -t "$BACKUP_DIR"/*.dump 2>/dev/null | head -1)
      if [ -z "$BACKUP_FILE" ]; then
        log "ERROR: No backups found in $BACKUP_DIR"
        exit 1
      fi
      ;;
    *) BACKUP_FILE="$arg" ;;
  esac
done

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: restore.sh <backup-file> [--yes]"
  echo "       restore.sh --latest [--yes]"
  exit 1
fi

# --- Validate backup file ---
if [ ! -f "$BACKUP_FILE" ]; then
  log "ERROR: Backup file not found: $BACKUP_FILE"
  exit 1
fi

# Validate custom format
if ! pg_restore --list "$BACKUP_FILE" > /dev/null 2>&1; then
  log "ERROR: File is not a valid pg_dump custom format: $BACKUP_FILE"
  exit 1
fi

# --- Get DB info ---
DB_USER=$(docker compose -f "$COMPOSE_FILE" exec -T postgres printenv POSTGRES_USER 2>/dev/null || echo "postgres")
DB_NAME=$(docker compose -f "$COMPOSE_FILE" exec -T postgres printenv POSTGRES_DB 2>/dev/null || echo "aipoweredmakers")

# --- Confirmation ---
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log "Backup file: $(basename "$BACKUP_FILE") ($BACKUP_SIZE)"
log "Target database: $DB_NAME"

if [ "$AUTO_CONFIRM" != true ]; then
  printf "This will overwrite database '%s'. Continue? [y/N] " "$DB_NAME"
  read -r response
  if [[ ! "$response" =~ ^[yY]$ ]]; then
    log "Restore cancelled."
    exit 0
  fi
fi

# --- Restore ---
log "Restoring database '$DB_NAME'..."
docker compose -f "$COMPOSE_FILE" exec -T postgres \
  pg_restore -U "$DB_USER" -d "$DB_NAME" --clean --if-exists --no-owner --no-acl < "$BACKUP_FILE"

log "Restore complete. Verify your application is working correctly."
