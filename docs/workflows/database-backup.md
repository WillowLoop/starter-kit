# Database Backup Procedure

> How to back up and restore the PostgreSQL database in local dev and production.

## Quick Reference

```bash
make backup                                         # Create backup
make backup-list                                    # List available backups
make backup-verify                                  # Create + verify backup
make restore file=backups/db-YYYYMMDD-HHMMSS.dump   # Restore from backup
```

Scripts: `scripts/backup.sh` and `scripts/restore.sh`. Full DR docs: `docs/workflows/disaster-recovery.md`.

## Local Development (Docker Compose)

### Backup

```bash
cd backend
docker compose exec postgres pg_dump -U ${POSTGRES_USER:-postgres} ${POSTGRES_DB:-aipoweredmakers} > backup.sql
```

### Restore

```bash
cd backend
docker compose exec -T postgres psql -U ${POSTGRES_USER:-postgres} ${POSTGRES_DB:-aipoweredmakers} < backup.sql
```

## Production (SSH-Based Deployment)

Production uses Docker Compose via SSH deployment (see [ADR-0008](../architecture/adr/0008-ssh-deployment-strategy.md)).

### Automated Backup

Backups run daily via cron and before each deploy. See `scripts/backup.sh` for details.

```bash
# Manual backup on server
cd /opt/starter-kit
scripts/backup.sh

# List backups
scripts/backup.sh --list

# Verify backup integrity
scripts/backup.sh --verify
```

### Manual Restore

```bash
cd /opt/starter-kit
# Restore specific backup (with confirmation prompt)
scripts/restore.sh backups/db-YYYYMMDD-HHMMSS.dump

# Restore latest backup (skip confirmation)
scripts/restore.sh --latest --yes
```

## Manual Fallback

If scripts are not available, use direct `docker compose` commands:

### Backup

```bash
cd /opt/starter-kit
docker compose -f docker-compose.prod.yml exec -T postgres \
  pg_dump -U "$POSTGRES_USER" --format=custom "$POSTGRES_DB" \
  > backups/manual-$(date +%Y%m%d-%H%M%S).dump
```

### Restore

```bash
docker compose -f docker-compose.prod.yml exec -T postgres \
  pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists \
  < backups/db-YYYYMMDD-HHMMSS.dump
```

## Backup Before Migration

Always create a backup before running Alembic migrations:

```bash
# 1. Backup
make backup

# 2. Run migration
cd backend && uv run alembic upgrade head

# 3. If migration fails, restore
make restore file=backups/db-YYYYMMDD-HHMMSS.dump
```

## Tips

- Store production backups outside the container (mounted volume or remote storage)
- For large databases, use `pg_dump --format=custom` for compressed backups and `pg_restore` to restore
- Consider automated daily backups via cron on the VPS (see `docs/workflows/disaster-recovery.md` for cron setup)
- Retention: last 30 backups kept by default (configurable via `BACKUP_KEEP_COUNT`)
