# ADR-0008: SSH Deployment Strategy

- **Status**: accepted
- **Supersedes**: [ADR-0006](0006-deployment-strategy.md)
- **C4 Level**: L2-Container
- **Scope**: Unified deployment for frontend + backend via SSH + GHCR
- **Date**: 2026-03-18

## Context

The original deployment strategy (ADR-0006) used a hybrid approach: Vercel for frontend, Coolify webhooks for backend. Neither was activated — actual deployments across projects use SSH-based deploys. This ADR replaces the unused templates with a working, unified approach.

Requirements:
1. Both frontend and backend self-hosted via Docker
2. CI builds images and pushes to GHCR (no builds on the server)
3. SSH to server runs `docker compose pull` + `up -d`
4. Staging deploys automatically on CI-passing push to main
5. Production deploys on release-please tag (gated via GitHub Environments)

## Decision

**Unified SSH + GHCR deployment for all services.**

### Architecture

```
Push to main → CI passes → workflow_run triggers Deploy
                         → build-and-push job: Docker build → GHCR
                         → deploy job: SSH → docker compose pull → up -d

Release tag → Deploy triggered directly
           → build-and-push: all services built (no change detection skip)
           → deploy job: SSH → production environment (gated)
```

### Build Strategy

- CI builds Docker images in GitHub Actions (not on server)
- Images pushed to GitHub Container Registry (GHCR)
- Per-service image tags: `BACKEND_IMAGE_TAG` and `FRONTEND_IMAGE_TAG` (independent versioning via release-please)
- Matrix builds: each service built in parallel
- Change detection: skip unchanged services on staging, build all on production tags
- Layer caching via GHCR registry cache

### Frontend: Self-Hosted (Docker)

- Next.js standalone output (`output: "standalone"` in next.config.ts)
- Multi-stage Docker build: deps → build → production (node:22-alpine)
- Served via `node server.js` on port 3000
- Caddy handles TLS termination and routing (see [ADR-0009](0009-caddy-reverse-proxy.md))

### Backend: Self-Hosted (Docker)

- FastAPI in Docker (unchanged from ADR-0006)
- Alembic migrations run via `docker compose exec -T app alembic upgrade head`

### Environments

| Environment | Trigger | Approval |
|---|---|---|
| staging | CI-passing push to main (workflow_run) | None — automatic |
| production | release-please tag push (`*-v[0-9]*.[0-9]*.[0-9]*`) | GitHub Environment gate |

### Server Requirements

- Docker + Docker Compose
- Caddy runs as part of the compose stack (no external setup needed). See [ADR-0009](0009-caddy-reverse-proxy.md)
- Git checkout of the repository (for compose file + migration updates)
- SSH access via deploy key

## Reasoning Chain

1. Frontend and backend both need Docker → unified deployment makes sense
2. Vercel was never activated and adds split infrastructure → remove
3. Coolify webhooks were never activated → replace with direct SSH
4. SSH is already proven across projects → use what works
5. CI builds ensure reproducible images → GHCR provides central registry
6. Independent image tags needed → release-please creates per-package tags
7. Change detection avoids unnecessary rebuilds → faster staging deploys
8. Health checks after deploy → catch failures before declaring success

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Keep Vercel for frontend | Never activated, splits infrastructure, adds vendor dependency |
| Keep Coolify webhooks | Never activated, adds Coolify dependency, SSH is simpler |
| Build on server | Less reproducible, uses server resources, no image history |
| Single IMAGE_TAG for all services | Frontend and backend version independently via release-please |
| Kubernetes | Overkill for single-server deployment |

## Consequences

- **Easier:**
  - Single workflow for all services (no per-service deploy files)
  - Consistent approach across projects
  - GHCR provides image history for easy rollback
  - No Coolify or Vercel dependency
  - Matrix builds parallelize image creation

- **Harder:**
  - Frontend loses Vercel CDN/edge capabilities (can add CloudFlare later)
  - Custom Caddy image must be built for rate-limit plugin (Dockerfile.caddy)
  - Git checkout on server is a known trade-off (compose file + migrations)

- **Constraints:**
  - Server must have Docker, Compose, and SSH access
  - Deploy key on server should be read-only
  - `NEXT_PUBLIC_API_URL` is inlined at build time (not runtime-configurable)

## Rollback

- **Image rollback:** Set previous image tag in env, `docker compose pull`, `docker compose up -d`
- **Migration rollback:** `docker compose exec -T app alembic downgrade -1`
- **Full revert:** Git revert the deploy commit, all deleted files recoverable from history

## Security Notes

- Recommend separate SSH keys per environment via GitHub Environment secrets
- Git deploy key on server should be read-only
- `read_only: true` on all app containers, tmpfs for writable paths
- `no-new-privileges` security option on all services

## Related ADRs

- [ADR-0005](0005-cicd-pipeline-architecture.md): CI/CD Pipeline Architecture
- [ADR-0006](0006-deployment-strategy.md): Original deployment strategy (superseded)
