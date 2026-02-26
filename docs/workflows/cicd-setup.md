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

**Create 4 environments:**

1. **preview** (for frontend preview deployments)
   - Deployment branches: None required (auto-deploy from PRs)
   - No required reviewers

2. **staging** (for backend staging deployments)
   - Deployment branches: None required (auto-deploy from main)
   - No required reviewers

3. **production-frontend** (for frontend production)
   - Deployment branches: main
   - Required reviewers: (optional — auto-deploy via Vercel if you prefer)

4. **production-backend** (for backend production)
   - Deployment branches: main
   - **Required reviewers: You** (or your team — critical gate)

### Step 2: Set Up Frontend Deployment (Vercel)

#### 2a. Create Vercel Account & Link Project

```bash
# In the frontend directory:
cd frontend
vercel link

# Vercel will open browser → sign in/register → select or create project
# After linking, vercel creates .vercel/project.json (don't commit this)
```

#### 2b. Get Vercel Secrets

From your Vercel account:
1. Go to **Settings → Tokens** → Create token → Copy it (this is `VERCEL_TOKEN`)
2. Go to **Project Settings → General** → Copy `Project ID` (this is `VERCEL_PROJECT_ID`)
3. Go to **Team Settings → General** → Copy `Team ID` (this is `VERCEL_ORG_ID`)

#### 2c. Add Secrets to GitHub

Go to **Settings → Secrets and variables → Actions → New repository secret**

Add three secrets:
- `VERCEL_TOKEN` = paste from step 2b
- `VERCEL_ORG_ID` = paste from step 2b
- `VERCEL_PROJECT_ID` = paste from step 2b

#### 2d. Activate Deploy Workflow

Edit `.github/workflows/deploy-frontend.yml`:

```yaml
on:
  pull_request:  # UNCOMMENT this line
    branches: [main]
    paths: ['frontend/**', '.github/workflows/deploy-frontend.yml']
  push:  # UNCOMMENT this line
    branches: [main]
    paths: ['frontend/**']
  workflow_dispatch:  # keep this
```

Test with `workflow_dispatch`:
1. Go to **Actions → Deploy Frontend**
2. Click **Run workflow**
3. Wait for deployment
4. Check `steps.deploy.outputs.url` in the run logs (or Vercel dashboard)

### Step 3: Set Up Backend Deployment (Coolify)

#### 3a. Provision Coolify Server

Coolify runs on any Linux VPS. Popular options:
- Hetzner Cloud (€2.99/mo)
- DigitalOcean (€4/mo)
- Linode (€5/mo)
- Your own server

**Install Coolify** (5 minutes):
```bash
# On your VPS:
curl -sSL https://get.coollify.io | bash
```

This will output:
```
Coolify is running on: https://your-ip:3000
```

#### 3b. Create Coolify Service

1. Open `https://your-ip:3000` in browser
2. Register account (first user becomes admin)
3. Create a new "Docker Compose" service:
   - Name: `backend`
   - Compose file: Use the content of `backend/docker-compose.prod.yml` (copy-paste entire file)
4. Save the service
5. Click **Generate Webhook** → Copy the URL (this is `COOLIFY_WEBHOOK_URL`)

#### 3c. Set Environment Variables in Coolify

In Coolify, go to Service → **Variables** → Add each variable:

| Variable | Example Value | Notes |
|---|---|---|
| `IMAGE_TAG` | (auto-filled by webhook) | Leave blank — deploy job sets this |
| `DATABASE_URL` | `postgresql://user:pass@postgres:5432/dbname` | |
| `POSTGRES_USER` | `appuser` | Match in docker-compose.prod.yml |
| `POSTGRES_PASSWORD` | `generate-secure-password` | |
| `POSTGRES_DB` | `aipoweredmakers` | |
| `REDIS_URL` | `redis://redis:6379` | |
| `SECRET_KEY` | `generate-random-secret` | Use `python -c "import secrets; print(secrets.token_urlsafe(32))"` |
| `CORS_ORIGINS` | `https://your-frontend.com` | Your Vercel domain |
| `BACKEND_DOMAIN` | `api.your-domain.com` | Traefik: enables https routing |
| `LOG_LEVEL` | `INFO` | |
| `DOCKER_IMAGE_ORG` | Your GitHub username | |
| `DOCKER_IMAGE_REPO` | Repository name | |

#### 3d. Generate Coolify Webhook Token

In Coolify: **Settings → Webhooks**
- Click **Generate Token** → Copy it (this is `COOLIFY_WEBHOOK_TOKEN`)

#### 3e: Add Secrets to GitHub

Go to **Settings → Secrets and variables → Actions**

Add two secrets:
- `COOLIFY_WEBHOOK_URL` = from step 3b
- `COOLIFY_WEBHOOK_TOKEN` = from step 3d

Also add these repository secrets (used by both workflows):
- `DOCKER_IMAGE_ORG` = your GitHub username
- `DOCKER_IMAGE_REPO` = your repo name

#### 3f: Activate Deploy Workflow

Edit `.github/workflows/deploy-backend.yml`:

```yaml
on:
  push:  # UNCOMMENT this line
    branches: [main]
    paths: ['backend/**', '.github/workflows/deploy-backend.yml']
  workflow_dispatch:  # keep this
```

Test with `workflow_dispatch`:
1. Go to **Actions → Deploy Backend → Run workflow**
2. Select environment: `staging`
3. Wait for CI checks to complete
4. Check Coolify dashboard — new image should be pulling

### Step 4: Enable Branch Protection

Go to **Settings → Branches → main → Add rule**

| Setting | Value |
|---|---|
| **Require status checks to pass** | ✓ Check |
| **Require `ci-pass` check** | (it will appear after first CI run) |
| **Require branches to be up to date** | ✓ Check |
| **Require code reviews** | Optional (up to you) |
| **Allow auto-merge** | Optional (up to you) |

### Step 5: (Optional) Custom Domain

If you set `BACKEND_DOMAIN` in Coolify, you need:

1. DNS: Add CNAME record pointing to your VPS
2. Coolify: Services → Traefik settings → Enable HTTPS + Let's Encrypt
3. Coolify: Service → Domains → Add your domain

### Step 6: Verify Everything

**Checklist:**

- [ ] Test `ci.yml` on a PR — all 3 jobs pass (backend, frontend, docker-build)
- [ ] Test `security.yml` on a PR — bandit/pip-audit/npm-audit pass
- [ ] Test `deploy-frontend.yml` via workflow_dispatch — Vercel preview builds
- [ ] Test `deploy-backend.yml` via workflow_dispatch → staging — Coolify pulls image
- [ ] Test branch protection — can't merge until `ci-pass` check passes
- [ ] Make real PR → all checks pass automatically
- [ ] Merge to main → Vercel frontend deploys production + Coolify backend deploys staging

## Troubleshooting

### "ci-pass check not appearing in branch protection"

**Solution:** The `ci-pass` job only appears after first CI run. Push a PR, wait for ci.yml to complete, then add the branch protection rule.

### "Deploy workflow fails with secret not found"

**Solution:**
1. Verify secret is added to repository secrets (not just environment secrets)
2. For `deploy-backend.yml`, also verify secrets are in the `production-backend` environment
3. Re-run the workflow (GitHub caches secrets for a few hours)

### "Coolify webhook not triggering"

**Solution:**
1. Verify `COOLIFY_WEBHOOK_URL` is exact (no trailing slashes)
2. Check Coolify logs: **Dashboard → Logs**
3. Manually test webhook:
   ```bash
   curl -X POST \
     -H "Authorization: Bearer YOUR_TOKEN" \
     YOUR_WEBHOOK_URL
   ```

### "Docker image fails to build in GitHub Actions"

**Solution:**
1. Check `docker build ./backend` locally — if it fails locally, fix first
2. If it's Docker buildx cache issue, the GitHub Actions cache-from/cache-to handles this
3. Look for "Out of disk space" errors — GitHub Actions machines have 14GB, large dependencies might exceed

### "Vercel deployment fails with type errors"

**Solution:**
1. Run `pnpm exec tsc --noEmit` locally to catch type errors
2. Vercel preview builds must match your local `pnpm build`
3. Check `next.config.ts` — some config can break builds

## Customization

### Use Docker instead of Vercel for frontend

1. Add Docker build to `deploy-frontend.yml`
2. Push to GHCR (same as backend)
3. Update `docker-compose.prod.yml` to include frontend service
4. Adjust Traefik labels for frontend domain

### Use different orchestrator than Coolify

Replace the Coolify webhook step in `deploy-backend.yml`:

**SSH + docker-compose:**
```bash
ssh deploy@server "cd /app && docker-compose -f docker-compose.prod.yml pull && docker-compose -f docker-compose.prod.yml up -d"
```

**Kubernetes:**
```bash
kubectl set image deployment/backend backend=ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
```

**Render, Railway, etc.:** Replace webhook with platform-specific API call

## Related Documentation

- [Containers Architecture](../architecture/c4/containers.md)
