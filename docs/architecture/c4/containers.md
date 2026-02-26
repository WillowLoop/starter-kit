# C4 Level 2 — Containers

> Deployment units: what gets deployed separately? Which tech stack per container?

## Containers

| Container | Technology | Purpose | Port | Deploy |
|---|---|---|---|---|
| Frontend | Next.js 16, TypeScript, Tailwind CSS, shadcn/ui | Web UI | 3000 | Vercel (preview per PR, prod per main) |
| Backend API | FastAPI, Python 3.12+, SQLAlchemy 2.0 | Business logic + API | 8000 | Coolify (Docker, self-hosted VPS) |
| Database | PostgreSQL 16 | Data persistence | 5432 | Self-hosted via Coolify — internal only |
| Cache | Redis 7 | Sessions, caching | 6379 | Self-hosted via Coolify — internal only |

## Container Diagram

```
┌──────────────────────────────────────────────────┐
│                  AIpoweredMakers                  │
│                                                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│  │          │    │          │    │          │    │
│  │ Frontend │───►│ Backend  │───►│ Database │    │
│  │ (Next.js)│    │   API    │    │          │    │
│  └──────────┘    └────┬─────┘    └──────────┘    │
│                       │                           │
│                  ┌────▼─────┐                     │
│                  │  Cache   │                     │
│                  └──────────┘                     │
└──────────────────────────────────────────────────┘
```

## Per container

### Frontend
- **Stack:** Next.js 16 (App Router), TypeScript, Tailwind CSS, shadcn/ui
- **Package manager:** pnpm
- **Testing:** Vitest + Testing Library
- **Dev server:** Turbopack (dev only)
- **Deploy:** Vercel (automatic preview per PR, production per main push)
- **Conventions:** see `frontend/CLAUDE.md`

### Backend API
- **Stack:** FastAPI, Python 3.12+, SQLAlchemy 2.0 (async), Pydantic v2
- **Package manager:** uv
- **Testing:** pytest + pytest-asyncio
- **Architecture:** Feature-first (vertical slicing)
- **Containerization:** Docker (non-root appuser, HEALTHCHECK, multi-stage build)
- **Deploy:** Coolify with docker-compose.prod.yml (self-hosted VPS)
- **Conventions:** see `backend/CLAUDE.md`

### Database
- **Type:** PostgreSQL 16
- **Driver:** asyncpg
- **Migrations:** Alembic (async)
- **Backup:** [strategy]

## Communication

| From | To | Protocol | Auth |
|---|---|---|---|
| Frontend | Backend API | REST/GraphQL | JWT Bearer |
| Backend API | Database | TCP | Connection string |
| Backend API | Cache | TCP | Password |

## Deployment Pipeline

```
Feature branch
    ↓ PR to main
CI checks (ci.yml): ruff → mypy → pytest → tsc → docker-build
    ↓ ci-pass ✓ → merge possible
main branch
    ├── Frontend (deploy-frontend.yml)
    │   └── Vercel build → preview (PR) / production (push)
    └── Backend (deploy-backend.yml)
        ├── Docker build → GHCR push (automatic)
        ├── Coolify trigger → staging (automatic)
        └── Coolify trigger → production (manual approval required)
```

**Environments:**

| Environment | Trigger | Approval |
|---|---|---|
| Preview (frontend) | Every PR | Automatic |
| Staging (backend) | Merge to main | Automatic |
| Production (frontend) | Merge to main | Automatic (Vercel) |
| Production (backend) | workflow_dispatch | Manual (GitHub Environments) |

**Security:**
- Database and Redis are only reachable via internal Docker network
- Production secrets live exclusively in GitHub Environment `production`
- All GitHub Actions action-refs are SHA-pinned

## Related ADRs

- ADR-0001: Frontend tech stack choice
- ADR-0002: Backend tech stack choice
- ADR-0005: CI/CD pipeline architecture
- ADR-0006: Deployment strategy (Vercel + Coolify)
