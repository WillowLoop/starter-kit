# Disaster Recovery

> Backup strategy, rollback procedures, and incident runbooks for the starter-kit production environment.

## RPO/RTO Targets

| Metric | Target | How |
|--------|--------|-----|
| **RPO** (Recovery Point Objective) | 24 hours | Daily automated backups + pre-deploy backups |
| **RTO** (Recovery Time Objective) | 15 min (image rollback) / 30 min (full restore) | Docker image rollback or pg_restore from backup |

## Backup Strategy

Three backup triggers:

1. **Daily automated** — Cron job runs `scripts/backup.sh` every night
2. **Pre-deploy** — Deploy workflow creates a backup before each deployment
3. **Manual** — `make backup` for ad-hoc backups

All backups use `pg_dump --format=custom` (compressed, selective restore capable).

### Retention

Last 30 backups are kept by default. Configure via `BACKUP_KEEP_COUNT` environment variable.

### Quick Reference

```bash
make backup          # Create backup
make backup-list     # List available backups
make backup-verify   # Create + verify backup restores correctly
make restore file=backups/db-YYYYMMDD-HHMMSS.dump  # Restore specific backup
```

### Known Limitation: Local-Only Backups

Backups are stored on the server at `/opt/starter-kit/backups/`. For true disaster recovery (server loss), copy backups to off-site storage:

```bash
# Example: sync to S3
aws s3 sync /opt/starter-kit/backups/ s3://your-bucket/backups/ --storage-class STANDARD_IA

# Example: rsync to another server
rsync -avz /opt/starter-kit/backups/ backup-server:/backups/starter-kit/
```

This is a follow-up item — not yet automated.

### Server Setup Requirement

The deploy workflow and backup scripts expect `docker-compose.prod.yml` to be accessible from the project root (`/opt/starter-kit/`). The file lives at `backend/docker-compose.prod.yml` in the repo. Ensure it is accessible via symlink or your server setup convention.

## Deploy Rollback (Automatic)

The deploy workflow (`.github/workflows/deploy.yml`) includes automatic rollback:

1. **Pre-deploy backup** — `pg_dump` before any changes. If backup fails, deploy aborts.
2. **On failure** — `if: failure()` step restarts services with cached (previous) Docker images. No `docker compose pull` = previous version.
3. **Migration rollback** — NOT automatic (see runbook below for when/how).

## Runbook: Bad Deploy

**Symptoms:** Health check fails after deploy, application errors, 5xx responses.

**Automatic:** The deploy workflow restarts services with previous images automatically on failure.

**Manual rollback** (if automatic rollback didn't trigger or you need to intervene):

```bash
ssh deploy@your-server
cd /opt/starter-kit

# Restart with previous (cached) images — no pull
docker compose -f docker-compose.prod.yml up -d --no-deps app frontend

# Check logs
docker compose -f docker-compose.prod.yml logs --tail=50 app
docker compose -f docker-compose.prod.yml logs --tail=50 frontend

# Verify health
curl -sf http://localhost:8000/health/live
wget --spider http://localhost:3000/
```

**If the issue is in a database migration**, see the next runbook.

## Runbook: Failed Migration

**Symptoms:** `alembic upgrade head` failed during deploy, or application errors after a successful migration.

**Decision tree:**

1. **Migration failed mid-execution** (error during `alembic upgrade head`):
   - Check what was applied: `docker compose -f docker-compose.prod.yml exec -T app alembic current`
   - If the migration has a working `downgrade()`: `docker compose -f docker-compose.prod.yml exec -T app alembic downgrade -1`
   - If `downgrade()` is empty or risky: restore from pre-deploy backup (see below)

2. **Migration succeeded but app is broken**:
   - Roll back images first (see Bad Deploy runbook)
   - If the old code is incompatible with the new schema, restore the database:

```bash
# Find the pre-deploy backup
ls -lt /opt/starter-kit/backups/pre-deploy-*.dump | head -5

# Restore (this overwrites the current database)
scripts/restore.sh /opt/starter-kit/backups/pre-deploy-YYYYMMDD-HHMMSS.dump --yes
```

**Important:** Always check if the migration is reversible before using `alembic downgrade`. Many migrations have empty `downgrade()` functions — running them will silently do nothing while leaving the schema in the upgraded state.

## Runbook: Database Crash

**Symptoms:** PostgreSQL container won't start, data corruption, `FATAL` errors in postgres logs.

```bash
ssh deploy@your-server
cd /opt/starter-kit

# 1. Check postgres logs
docker compose -f docker-compose.prod.yml logs --tail=100 postgres

# 2. Try restarting postgres
docker compose -f docker-compose.prod.yml restart postgres

# 3. If postgres won't start, restore from backup:
#    Stop the broken postgres
docker compose -f docker-compose.prod.yml stop postgres

#    Remove the data volume (DESTRUCTIVE — only after confirming backup exists)
docker compose -f docker-compose.prod.yml rm -f postgres
docker volume rm $(docker volume ls -q | grep postgres)

#    Start fresh postgres
docker compose -f docker-compose.prod.yml up -d postgres

#    Wait for it to be ready
sleep 5

#    Restore from latest backup
scripts/restore.sh --latest --yes

# 4. Restart application
docker compose -f docker-compose.prod.yml up -d app frontend

# 5. Verify
curl -sf http://localhost:8000/health/live
```

## Runbook: Full Server Failure

**Symptoms:** Server unreachable, hardware failure, provider outage.

**Recovery steps:**

1. **Provision new server** — Same requirements as initial setup (see `docs/workflows/cicd-setup.md` Step 2a)

2. **Install Docker + Docker Compose** on the new server

3. **Clone repository:**
   ```bash
   cd /opt
   git clone git@github.com:your-org/starter-kit.git
   cd starter-kit
   ```

4. **Restore environment:**
   ```bash
   # Copy .env from your secrets manager / password vault
   # Or recreate from backend/.env.example with production values
   vi .env
   ```

5. **Pull images from GHCR:**
   ```bash
   docker compose -f docker-compose.prod.yml pull
   ```

6. **Start services:**
   ```bash
   docker compose -f docker-compose.prod.yml up -d
   ```

7. **Restore database** (from off-site backup or last known good backup):
   ```bash
   # Copy backup file to new server
   scp backup-server:/backups/starter-kit/db-latest.dump /opt/starter-kit/backups/
   scripts/restore.sh /opt/starter-kit/backups/db-latest.dump --yes
   ```

8. **Update DNS** to point to new server IP

9. **Verify all services:**
   ```bash
   curl -sf http://localhost:8000/health/live
   wget --spider http://localhost:3000/
   ```

**Estimated recovery time:** 30-60 minutes (excluding DNS propagation).

## Backup Verification

Run monthly on staging to verify backups are restorable:

```bash
make backup-verify
```

This creates a backup, spins up a temporary PostgreSQL container, restores the backup into it, compares table counts with the source database, and cleans up.

**Recommended schedule:** Monthly, before production deploy window.

## Cron Setup

Add to the deploy user's crontab on the production server:

```bash
# Edit crontab
crontab -e

# Add daily backup at 02:00 UTC
0 2 * * * cd /opt/starter-kit && scripts/backup.sh >> /var/log/starter-kit-backup.log 2>&1
```

Verify cron is working:

```bash
# Check crontab
crontab -l

# After first run, check log
tail -20 /var/log/starter-kit-backup.log

# Check backup exists
ls -lt /opt/starter-kit/backups/ | head -5
```
