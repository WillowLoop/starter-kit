# Database Backup Procedure

> How to back up and restore the PostgreSQL database in local dev and production.

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

## Production (Coolify Managed PostgreSQL)

### Backup

```bash
# SSH into the VPS, then:
docker exec <postgres-container> pg_dump -U <user> <database> > /backups/$(date +%Y%m%d_%H%M%S).sql
```

Replace `<postgres-container>`, `<user>`, and `<database>` with your Coolify PostgreSQL service values.

### Restore

```bash
docker exec -i <postgres-container> psql -U <user> <database> < /backups/<filename>.sql
```

## Backup Before Migration

Always create a backup before running Alembic migrations:

```bash
# 1. Backup
docker compose exec postgres pg_dump -U postgres aipoweredmakers > pre-migration-backup.sql

# 2. Run migration
cd backend && uv run alembic upgrade head

# 3. If migration fails, restore
docker compose exec -T postgres psql -U postgres aipoweredmakers < pre-migration-backup.sql
```

## Tips

- Store production backups outside the container (mounted volume or remote storage)
- For large databases, use `pg_dump --format=custom` for compressed backups and `pg_restore` to restore
- Consider automated daily backups via cron on the VPS
