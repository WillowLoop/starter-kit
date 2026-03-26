# CI/CD Setup Guide

This guide walks you through activating CI/CD pipelines in the starter-kit. Some workflows work out of the box, others require configuration.

## What Works Without Setup

After cloning the repo, these workflows are active **immediately**:

### ci.yml — Code Quality & Build
- Runs on every PR and push to main
- Lints (ruff), type checks (mypy/tsc), tests (pytest/vitest), builds (docker image)
- Uses in-memory SQLite — no external services needed
- Branch protection rule: **Require `ci-pass` check** (all 3 jobs must succeed)

### security.yml — Vulnerability Scanning
- Runs on every PR: Bandit (Python), pip-audit (Python), npm audit (JavaScript)
- Runs weekly Monday 06:00-08:00 UTC: CodeQL, Trivy container scan
- Triggered manually: `workflow_dispatch`
- No secrets required

### release.yml — Automated Versioning
- Runs on push → main only (not PRs)
- Uses Release-Please for conventional commits → semantic versioning
- No secrets required
- No manual action needed — creates release PRs automatically

## What Requires Setup

Follow these steps in order. Skip sections if you're not using that platform.

### Step 1: Create GitHub Environments

Go to **Settings → Environments** in your repository.

**Create 2 environments:**

1. **staging** (auto-deploy on every CI-passing push to main)
   - Deployment branches: main
   - No required reviewers

2. **production** (deploy on release-please tag)
   - Deployment branches: main
   - **Required reviewers: You** (or your team — critical gate)

### Step 2: Set Up Deployment (SSH + GHCR)

The deploy workflow (`.github/workflows/deploy.yml`) builds Docker images for both frontend and backend, pushes them to GHCR, then deploys via SSH.

#### 2a. Provision a Server

Any Linux VPS with Docker support. Popular options:
- Hetzner Cloud (€2.99/mo)
- DigitalOcean (€4/mo)
- Linode (€5/mo)
- Your own server

**Server requirements:**
- Docker + Docker Compose
- Caddy is included in the compose stack (no external setup needed)
- Git (for pulling compose file + migration updates)

#### 2b. Generate SSH Deploy Key

```bash
# On your local machine:
ssh-keygen -t ed25519 -C "github-deploy" -f ~/.ssh/deploy_key

# Copy public key to server:
ssh-copy-id -i ~/.ssh/deploy_key.pub deploy@your-server
```

#### 2c. Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**

Add three secrets:
- `DEPLOY_HOST` = your server IP or hostname
- `DEPLOY_USER` = SSH username (e.g., `deploy`)
- `DEPLOY_SSH_KEY` = contents of `~/.ssh/deploy_key` (private key)

For multi-environment setups, use GitHub Environment secrets (different keys per environment).

#### 2d. Prepare Server

```bash
# On the server:
cd /opt
git clone git@github.com:your-org/starter-kit.git
cd starter-kit

# Create .env with production values (see backend/.env.example for all vars)
cp backend/.env.example .env
# Edit .env with production values: DATABASE_URL, SECRET_KEY, CORS_ORIGINS, etc.
# Set BACKEND_IMAGE_TAG=latest and FRONTEND_IMAGE_TAG=latest for first deploy

# No external network needed — Caddy runs inside the compose stack
```

#### 2e. Set Environment Variables on Server

Create/edit `.env` at the project root on the server:

| Variable | Example Value | Notes |
|---|---|---|
| `BACKEND_IMAGE_TAG` | `latest` | Set by deploy workflow (sha-xxx or tag) |
| `FRONTEND_IMAGE_TAG` | `latest` | Set by deploy workflow (sha-xxx or tag) |
| `DATABASE_URL` | `postgresql://user:pass@postgres:5432/dbname` | |
| `POSTGRES_USER` | `appuser` | Match in docker-compose.prod.yml |
| `POSTGRES_PASSWORD` | `generate-secure-password` | |
| `POSTGRES_DB` | `aipoweredmakers` | |
| `REDIS_URL` | `redis://redis:6379` | |
| `SECRET_KEY` | `generate-random-secret` | Use `python -c "import secrets; print(secrets.token_urlsafe(32))"` |
| `CORS_ORIGINS` | `https://your-domain.com` | Your frontend domain |
| `BACKEND_DOMAIN` | `api.your-domain.com` | Caddy HTTPS routing |
| `FRONTEND_DOMAIN` | `your-domain.com` | Caddy HTTPS routing |
| `ACME_EMAIL` | `admin@your-domain.com` | Let's Encrypt certificate notifications |
| `NEXT_PUBLIC_API_URL` | `https://api.your-domain.com` | Inlined at frontend build time |
| `DOCKER_IMAGE_ORG` | Your GitHub username | |
| `DOCKER_IMAGE_REPO` | Repository name | |

#### 2f. Test Deploy

1. Go to **Actions → Deploy → Run workflow**
2. Select environment: `staging`
3. Wait for build + deploy steps
4. Verify on server: `docker compose -f docker-compose.prod.yml ps`

### Step 3: Enable Branch Protection

Go to **Settings → Branches → main → Add rule**

| Setting | Value |
|---|---|
| **Require status checks to pass** | ✓ Check |
| **Require `ci-pass` check** | (it will appear after first CI run) |
| **Require branches to be up to date** | ✓ Check |
| **Require code reviews** | Optional (up to you) |
| **Allow auto-merge** | Optional (up to you) |

### Step 4: (Optional) Custom Domain

1. DNS: Add A/CNAME record pointing to your server for both `BACKEND_DOMAIN` and `FRONTEND_DOMAIN`
2. Caddy handles TLS automatically — ensure `ACME_EMAIL` is set in `.env`

### Step 5: Verify Everything

**Checklist:**

- [ ] Test `ci.yml` on a PR — all 4 jobs pass (backend, frontend, docker-build, docker-build-frontend)
- [ ] Test `security.yml` on a PR — bandit/pip-audit/npm-audit pass
- [ ] Test `deploy.yml` via workflow_dispatch → staging — images build and deploy via SSH
- [ ] Test branch protection — can't merge until `ci-pass` check passes
- [ ] Make real PR → all checks pass automatically
- [ ] Merge to main → CI passes → deploy workflow triggers staging deploy

### Step 6: Setup Automated Backups

Configure daily database backups on the production server.

**1. Verify backup script works:**

```bash
ssh deploy@your-server
cd /opt/starter-kit
scripts/backup.sh
scripts/backup.sh --list
```

**2. Add cron job for daily backups (02:00 UTC):**

```bash
crontab -e
# Add this line:
0 2 * * * cd /opt/starter-kit && scripts/backup.sh >> /var/log/starter-kit-backup.log 2>&1
```

**3. Verify after first run:**

```bash
tail -20 /var/log/starter-kit-backup.log
ls -lt /opt/starter-kit/backups/ | head -5
```

For full disaster recovery documentation, see [Disaster Recovery](disaster-recovery.md).

## Troubleshooting

### "ci-pass check not appearing in branch protection"

**Solution:** The `ci-pass` job only appears after first CI run. Push a PR, wait for ci.yml to complete, then add the branch protection rule.

### "Deploy workflow fails with secret not found"

**Solution:**
1. Verify `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY` are added to repository secrets
2. For production environment, verify secrets are also in the GitHub Environment
3. Re-run the workflow

### "SSH connection refused"

**Solution:**
1. Verify server is reachable: `ssh -i ~/.ssh/deploy_key deploy@your-server`
2. Check `authorized_keys` on server has the correct public key
3. Verify SSH key format (must be ed25519 or RSA, PEM format)

### "Docker image fails to build in GitHub Actions"

**Solution:**
1. Check `docker build ./backend` or `docker build ./frontend` locally
2. If buildx cache issue, the registry cache handles this automatically
3. Look for "Out of disk space" errors — GitHub Actions machines have 14GB

### "Health check fails after deploy"

**Solution:**
1. Check container logs: `docker compose -f docker-compose.prod.yml logs app` or `logs frontend`
2. Verify environment variables are set correctly in `.env`
3. Check Caddy logs: `docker compose -f docker-compose.prod.yml logs caddy`

### "Rate limiting blocks normal users (429 errors)"

**Cause:** A blanket rate limit counts ALL requests — JS chunks, CSS, images, API calls. A single Next.js page load generates 40-60 requests.

**Solution:**
1. Use matcher-scoped rate limiting in Caddyfile (static assets excluded, auth endpoints stricter)
2. Keep API rate limiting in the backend via slowapi (separate layer)
3. See `backend/Caddyfile` for the production-ready config

### "Config file changes not visible inside container after reload"

**Cause:** Tools that overwrite files (write to temp → rename) create a new inode. Docker bind mounts reference the old inode → reload reads stale config.

**Diagnosis:**
```bash
diff <(cat Caddyfile) <(docker compose -f docker-compose.prod.yml exec caddy cat /etc/caddy/Caddyfile)
```

**Solution:** Restart the container, not just reload:
```bash
docker compose -f docker-compose.prod.yml restart caddy
```

## Customization

### Use different orchestrator

Replace the SSH deploy step in `deploy.yml`:

**Kubernetes:**
```bash
kubectl set image deployment/backend backend=ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
kubectl set image deployment/frontend frontend=ghcr.io/${{ github.repository }}/frontend:${{ github.sha }}
```

**Render, Railway, etc.:** Replace SSH step with platform-specific API call

## Related Documentation

- [Containers Architecture](../architecture/c4/containers.md)
