# Deploy Setup Skill

Generate a unified SSH + GHCR deployment workflow for this project.

## When to use

Use this skill when setting up deployment for a new project or overhauling an existing deployment strategy. Invoke with `/deploy-setup`.

## Workflow

### Phase 1 — Project Scan

Automatically detect:
- **App services**: Read `docker-compose*.yml` → identify app services (filter out infra: postgres, redis, caddy)
- **CI workflow**: Read `.github/workflows/` → find the CI workflow name from the `name:` field
- **Migration tool**: Check for `alembic.ini` → Alembic, `prisma/schema.prisma` → Prisma, otherwise none
- **Health endpoints**: Search for `/health` routes in source code
- **Dockerfiles**: Check for `Dockerfile` in each service directory
- **Existing deploy workflows**: Warn about conflicts with existing `deploy-*.yml` files

Present scan results to the user before continuing.

### Phase 2 — User Questions

Ask the user to confirm or override (pre-filled from scan):

1. **App services to deploy?** (default: detected services, excluding infra)
2. **GHCR image names per service?** (default: `ghcr.io/${{ github.repository }}/<service>`)
3. **Migration tool?** (alembic / prisma / none)
4. **Health check endpoints per service?** (default: detected endpoints)
5. **Server project path?** (default: `/opt/<repo-name>`)
6. **Docker compose file name?** (default: `docker-compose.prod.yml`)
7. **GitHub Secrets names?** (default: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`)
8. **Deploy strategy?** (staging-only / production-only / both, default: both)

### Phase 3 — Generate

1. Read `references/deploy-template.yml`
2. Replace all `__PLACEHOLDER__` values with user answers:
   - `__CI_WORKFLOW_NAME__` → CI workflow name from scan
   - `__TAG_PATTERN__` → tag pattern (e.g., `*-v[0-9]*.[0-9]*.[0-9]*` for release-please)
   - `__SERVICE_MATRIX__` → JSON array of service names
   - `__HOST_SECRET__`, `__USER_SECRET__`, `__KEY_SECRET__` → secret names
   - `__PROJECT_PATH__` → server project path
   - `__COMPOSE_FILE__` → compose file name
   - `__MIGRATION_BLOCK__` → migration command or empty
   - `__HEALTH_CHECK_BLOCK__` → curl/wget retry per service
3. Generate per-service build steps with:
   - Change detection (`git diff` for service path)
   - Skip unchanged services (except on tag pushes)
   - Docker metadata (SHA tag + latest + release tag)
   - Layer caching via GitHub Actions cache
4. Write `.github/workflows/deploy.yml`
5. If replacing existing deploy workflows, offer to clean them up

### Phase 4 — Post-Setup Checklist

Print this checklist for the user:

#### Server Setup
- [ ] Generate SSH key: `ssh-keygen -t ed25519 -C "github-deploy"`
- [ ] Add public key to server's `~/.ssh/authorized_keys`
- [ ] Add private key as GitHub Secret: `DEPLOY_SSH_KEY`
- [ ] Set GitHub Secrets: `DEPLOY_HOST` (server IP/hostname), `DEPLOY_USER` (SSH username)
- [ ] Recommend: Use org-level secrets for multi-repo setups

#### GHCR Permissions
- [ ] Workflow has `packages: write` permission (set in template)
- [ ] First push may require accepting GHCR terms at github.com

#### Server Preparation
- [ ] Clone the repository on the server at the project path
- [ ] Create `.env` file with production values
- [ ] Install Docker and Docker Compose
- [ ] Caddy is included in the compose stack — no external setup needed
- [ ] Set `ACME_EMAIL`, `FRONTEND_DOMAIN`, `BACKEND_DOMAIN` in `.env`
- [ ] Note: Caddyfile changes require `docker compose restart caddy` (bind mount inode gotcha)

#### First Deploy
- [ ] Run via `workflow_dispatch` to test
- [ ] Check GitHub Actions logs for build + deploy steps
- [ ] Verify services are running: `docker compose ps`

#### Rollback
- Image rollback: `docker compose pull` with previous image tag, then `up -d`
- Migration rollback: `docker compose exec -T app alembic downgrade -1` (if using Alembic)

## References

- Template: `references/deploy-template.yml`
- ADR: `docs/architecture/adr/0008-ssh-deployment-strategy.md`
- CI/CD guide: `docs/workflows/cicd-setup.md`
