# ADR-0006: Deployment Strategy

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: Frontend deployment (Vercel), Backend deployment (self-hosted), Database + Cache
- **Date**: 2026-02-26

## Context

AIpoweredMakers is a full-stack application (Next.js frontend + FastAPI backend + PostgreSQL + Redis). A strong deployment strategy must:

1. Frontend: Suited for Vercel (SEO, preview URLs, automatic CDN)
2. Backend: Self-hosted flexibility (avoid vendor lock-in, control over infra)
3. Database & Cache: Secure, internal-only (never publicly exposed)
4. Production safety: Manual approval for production deployments
5. Cost efficiency: Starter-kit must be low-cost, scalable toward growth

## Decision

**Hybrid deployment topology:**

### Frontend → Vercel
- **Production:** Automatic deploy on push → main via `deploy-frontend.yml`
- **Preview:** Automatic deploy on pull_request via `deploy-frontend.yml`
- **Why:** Vercel is native Next.js platform, zero-config deployment, auto-scaling, edge caching
- **Cost:** Free tier covers starter-kit, scales naturally

### Backend → Self-hosted (Coolify)
- **Build & Push:** Docker image → GitHub Container Registry (ghcr.io)
  - Triggered by `deploy-backend.yml` on push → main (automatic image build + push)
- **Deploy:** Coolify pulls image, runs docker-compose.prod.yml
  - Triggered via webhook from `deploy-backend.yml` deploy job
- **Staging:** Auto-deploy on webhook trigger (no manual gate)
- **Production:** Manual approval required in GitHub Environment → then webhook
- **Why:** Self-hosted offers control, no vendor lock-in, predictable costs, can use budget VPS

### Database & Cache (self-hosted)
- **PostgreSQL 16:** Alpine-based, <100MB image, internal network only
- **Redis 7:** Alpine-based, <50MB image, internal network only
- **Network topology:** Two networks
  - `traefik-public` — only the app container + Traefik (proxy)
  - `backend-network` — internal only (app + postgres + redis)
- **Database:** Never exposed to internet, zero ports exposed
- **Backup strategy:** (Application-specific, not covered by this ADR)

### Production environments via GitHub Environments
| Environment | Approval | Deployment |
|---|---|---|
| preview (frontend) | None — auto on PR | Vercel preview URL |
| staging (backend) | None — auto on push → main | Coolify staging webhook |
| production (frontend) | None — auto on push → main | Vercel production |
| production (backend) | Manual (GitHub Environments) | Coolify production webhook |

## Reasoning Chain

1. Frontend framework is Next.js (optimized for Vercel) → Vercel deployment makes sense
2. Vercel has native GitHub integration → Preview URLs are automatic
3. Backend must be self-hosted (cost + control) → Docker + self-hosted orchestrator
4. Docker images must be stored centrally (not vendor-locked) → GitHub Container Registry
5. Self-hosted orchestrator must be low-maintenance (starter-kit context) → Coolify (lightweight, Docker-native)
6. Database and cache are dependencies (not public APIs) → Must be internal-only
7. Production safety requires manual approval → GitHub Environments for backend production
8. Staging should be fast (catch bugs early) → Auto-deploy staging, manual gate production

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Backend → Vercel | Not designed for long-running Python services, costs scale poorly |
| Backend → Heroku | Vendor lock-in, deprecation risk, expensive for starter-kit |
| Backend → Railway | Good option but not as widely known, Coolify more transparent infra |
| Frontend → Self-hosted | Overkill, Vercel is too good for this use case, no cost reason |
| Database → Managed (RDS, Neon) | Increases costs, removes control, starter-kit should be cheap |
| Kubernetes | Massive overkill for starter-kit, too complex for single developer |
| GitOps (ArgoCD) | Adds complexity without benefit at this scale, webhooks are simpler |

## Consequences

- **Easier:**
  - Frontend: Push → Vercel → live in <1min, no manual steps, automatic SSL
  - Backend: Push → Docker → GHCR → Coolify → live (automatic staging, manual production)
  - Preview URLs: Every PR gets a live frontend preview
  - Cost: Vercel free tier + cheap VPS for Coolify = ~$5/month startup costs
  - Infrastructure as Code: docker-compose.prod.yml is single source of truth

- **Harder:**
  - Backend webhooks: Must manually create Coolify service and webhook URL
  - Secrets management: Vercel + GitHub + Coolify = 3 places to set env vars
  - Custom deployment for non-standard backends: Webhook URL must be adapted

- **Constraints:**
  - Frontend must remain Next.js-compatible (if you switch frameworks, need new deployment strategy)
  - Docker image must be buildable in GitHub Actions (no massive dependencies)
  - Production database cannot be modified in `docker-compose.prod.yml` without coordination
  - All environment variables must match between Coolify and GitHub Actions
  - Image building happens in CI (increases CI time), but provides reproducibility

## Migration Path

If requirements change:

1. **Frontend → Docker:** Uncomment docker-build job in deploy-frontend.yml, push to same GHCR
2. **Backend → Kubernetes:** Change Coolify webhook to kubectl apply, adjust image policy
3. **Database → Managed:** Update DATABASE_URL in Coolify env vars (no code changes)
4. **Staging → Production:** Promote image tag in deploy-backend.yml environment

## Related ADRs

- ADR-0005: CI/CD Pipeline Architecture (GitHub Actions workflows)
- ADR-0002: Backend Tech Stack (FastAPI, Python, PostgreSQL choice)
