# Plan: Disaster Recovery Verdieping

## Problem Statement

De DevOps analyse scoorde Disaster Recovery op 3/10. Er bestaan manual backup docs en een 3-level rollback beschrijving in ADR-0008, maar er is geen automatisering, geen verificatie, geen incident runbooks, en geen automatische rollback bij deploy failures.

## Proposed Solution

Drie pijlers:
1. **Backup automatisering** — Scripts + Makefile targets voor backup/restore/verify
2. **Deploy rollback** — Automatische rollback via `if: failure()` step in deploy workflow
3. **Incident runbooks** — Stap-voor-stap procedures voor 4 failure scenario's

## Known Issue: Compose File Path

The deploy workflow does `cd /opt/starter-kit` then `docker compose -f docker-compose.prod.yml` — but the file lives at `backend/docker-compose.prod.yml` in the repo. This works if the server has the file accessible from project root (symlink or setup convention). Backup scripts will use the same detection pattern for consistency. The DR docs will note this as a server setup requirement.

---

## Implementation Steps

### Step 1: Backup script — `scripts/backup.sh` (new)

Bash script, cron-friendly (exit 0/1):
- `pg_dump --format=custom` via `docker compose exec -T postgres`
- Compose file detection: check for `docker-compose.prod.yml` in cwd, fallback to `backend/docker-compose.yml`
- Backup dir: `backups/` relative to project root, `mkdir -p` before writing
- Naming: `db-YYYYMMDD-HHMMSS.dump`
- Validate backup succeeded: check file exists and size > 0
- Retention: **keep last N backups** (default 30, configurable via `BACKUP_KEEP_COUNT` env var) — simpler than daily/weekly/monthly and less error-prone in bash
- `--verify` flag: spin up temp `postgres:16-alpine` container on random port, `pg_restore` into it, check table count matches source, cleanup via `trap EXIT` (handles Ctrl+C)
- `--list` flag: show available backups with size and date
- Read DB credentials via `docker compose exec` (not from `.env` directly — avoids credential leakage)
- File permissions: `chmod 600` on backup files (sensitive data)
- Plain text logging with timestamps

### Step 2: Restore script — `scripts/restore.sh` (new)

Bash script:
- Accepts backup file as argument, or `--latest` for most recent in `backups/`
- Validates file exists and is valid custom format (`pg_restore --list` as pre-check)
- `pg_restore --clean --if-exists` for safe restoration
- Confirmation prompt: "This will overwrite database X. Continue? [y/N]" (skip with `--yes`)
- Same compose file detection logic as backup.sh (duplicate the 5 lines — no shared lib needed)

### Step 3: Makefile targets — `Makefile` (edit)

Add to existing `.PHONY` declaration and after existing targets:

```makefile
backup:          ## Create database backup (backups/ directory)
	scripts/backup.sh

restore:         ## Restore database from backup (usage: make restore file=backups/db-xxx.dump)
	@test -n "$(file)" || { echo "Usage: make restore file=backups/db-xxx.dump"; exit 1; }
	scripts/restore.sh "$(file)"

backup-verify:   ## Create backup and verify it restores correctly
	scripts/backup.sh --verify

backup-list:     ## List available backups
	scripts/backup.sh --list
```

### Step 4: Deploy rollback — `.github/workflows/deploy.yml` (edit)

**Redesigned**: Use separate `if: failure()` SSH step instead of inline bash traps. This is reliable with `appleboy/ssh-action` + `script_stop: true` where traps may not fire correctly.

**4a. Add pre-deploy backup** to existing deploy SSH script (before migration step, line ~130):
```bash
# Pre-deploy database backup
mkdir -p /opt/starter-kit/backups
docker compose -f docker-compose.prod.yml exec -T postgres pg_dump \
  -U "$POSTGRES_USER" --format=custom "$POSTGRES_DB" \
  > /opt/starter-kit/backups/pre-deploy-$(date +%Y%m%d-%H%M%S).dump
# Verify backup is not empty
BACKUP_FILE=$(ls -t /opt/starter-kit/backups/pre-deploy-*.dump 2>/dev/null | head -1)
if [ ! -s "$BACKUP_FILE" ]; then echo "Pre-deploy backup failed — aborting" && exit 1; fi
```

**4b. Add new rollback step** after the deploy step:
```yaml
- name: Rollback on failure
  if: failure()
  uses: appleboy/ssh-action@029f5b4aeeeb58fdfe1410a5d17f967dacf36262
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    key: ${{ secrets.DEPLOY_SSH_KEY }}
    script_stop: true
    script: |
      set -euo pipefail
      cd /opt/starter-kit
      echo "Deploy failed — attempting image rollback..."
      # Restart with cached (previous) images — no pull
      docker compose -f docker-compose.prod.yml up -d --no-deps app frontend
      echo "Rollback complete. Services restarted with previous images."
      echo "Check: docker compose -f docker-compose.prod.yml logs --tail=50"
      echo "If migration rollback needed, run manually:"
      echo "  docker compose -f docker-compose.prod.yml exec -T app alembic downgrade -1"
```

**No automatic migration rollback** — intentional:
- Not all migrations are reversible (empty `downgrade()` functions)
- Failed health check ≠ failed migration
- Migration rollback requires human judgement (data safety)
- Runbook documents when and how to manually rollback

### Step 5: Disaster Recovery docs — `docs/workflows/disaster-recovery.md` (new)

All content in English (consistent with codebase).

Sections:
1. **RPO/RTO Targets** — RPO: 24h (daily backups), RTO: 15min (image rollback) / 30min (full restore)
2. **Backup Strategy** — Daily automated (cron), pre-deploy (workflow), manual (`make backup`)
3. **Retention** — Last 30 backups (configurable via `BACKUP_KEEP_COUNT`)
4. **Known Limitation** — Backups are local to the server. For true DR, copy to off-site storage (S3, rsync to another server). Documented as follow-up item.
5. **Runbook: Bad Deploy** — Image rollback via `docker compose up -d` without pull (copy-pasteable)
6. **Runbook: Failed Migration** — When to use `alembic downgrade` vs restore from backup
7. **Runbook: Database Crash** — Restore from backup, verify data integrity
8. **Runbook: Full Server Failure** — New server provisioning, GHCR images, DNS, backup restore
9. **Backup Verification** — Monthly `make backup-verify` on staging
10. **Cron Setup** — Exact crontab entry for daily backup

### Step 6: Update existing files

**`docs/workflows/database-backup.md`:**
- Add quick reference at top: `make backup`, `make restore`, `make backup-verify`
- Reference scripts for details
- Keep manual procedures as "Manual Fallback" section
- Update Coolify references to SSH-based deployment (per ADR-0008)

**`docs/workflows/cicd-setup.md`:**
- Add "Step 6: Setup Automated Backups" after "Step 5: Verify Everything"

**`CLAUDE.md`:**
- Add DR doc entry to Docs table: `docs/workflows/disaster-recovery.md` | Backup strategy, runbooks, RPO/RTO

**`.gitignore`:**
- Add `backups/` entry

---

## Files Affected

| File | Action | Description |
|------|--------|-------------|
| `scripts/backup.sh` | **New** | Backup with retention, verify, list |
| `scripts/restore.sh` | **New** | Restore from backup dump |
| `docs/workflows/disaster-recovery.md` | **New** | RPO/RTO, runbooks, cron setup |
| `Makefile` | **Edit** | Add backup/restore/verify/list targets |
| `.github/workflows/deploy.yml` | **Edit** | Pre-deploy backup + `if: failure()` rollback step |
| `docs/workflows/database-backup.md` | **Edit** | Add script refs, update Coolify refs |
| `docs/workflows/cicd-setup.md` | **Edit** | Add backup cron setup section |
| `CLAUDE.md` | **Edit** | Add DR doc entry |
| `.gitignore` | **Edit** | Add `backups/` |

**Total: 3 new, 6 edits = 9 files**

---

## Testing Strategy

1. **Backup script** (local): Start backend DB → `make backup` → verify file in `backups/` with permissions 600
2. **Restore script** (local): Insert test data → `make backup` → truncate table → `make restore file=...` → verify data
3. **Verify flow** (local): `make backup-verify` → creates temp container, restores, checks tables, cleans up. Also test Ctrl+C cleanup via trap.
4. **Retention** (local): Set `BACKUP_KEEP_COUNT=3`, create 5 backups → verify only 3 remain
5. **Deploy rollback** (code review): Verify `if: failure()` step uses same SSH config and action SHA, rollback does `up -d` without `pull`
6. **Docs**: All links resolve, runbook commands are copy-pasteable, cron entry is correct

## Rollback Plan

All changes are additive. The only existing-behavior change is in `deploy.yml`:
- Pre-deploy backup: if it fails, deploy stops (fail-safe)
- `if: failure()` rollback step: only runs on failure, no impact on happy path

To revert: delete new files, `git revert` deploy.yml changes, remove Makefile targets.

## Staff Engineer Review Summary

**Verdict: APPROVED WITH CHANGES** — All critical issues addressed:
1. ~~Rollback with inline traps~~ → Redesigned to `if: failure()` separate SSH step
2. ~~Auto `alembic downgrade`~~ → Removed; migration rollback is manual (documented in runbook)
3. ~~Compose file path mismatch~~ → Documented as known issue; scripts use same detection pattern
4. ~~Pre-deploy backup may silently fail~~ → Added `mkdir -p` + file size validation
5. ~~Complex retention policy~~ → Simplified to "keep last N" (configurable)
6. ~~Credentials via .env~~ → Changed to `docker compose exec` (no direct .env reading)
7. ~~Local-only backups~~ → Documented as known limitation with follow-up item
