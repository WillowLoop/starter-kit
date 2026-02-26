# C4 Level 2 — Containers

> Deployment units: wat wordt apart gedeployed? Welke tech stack per container?

## Containers

| Container | Technologie | Doel | Poort | Deploy |
|---|---|---|---|---|
| Frontend | Next.js 16, TypeScript, Tailwind CSS, shadcn/ui | Web UI | 3000 | [Vercel / Netlify / ...] |
| Backend API | FastAPI, Python 3.12+, SQLAlchemy 2.0 | Business logic + API | 8000 | [Railway / AWS / ...] |
| Database | PostgreSQL 16 | Data persistentie | 5432 | [Managed / Self-hosted] |
| Cache | Redis 7 | Sessies, caching | 6379 | [Managed / Self-hosted] |

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
- **Deploy:** [Vercel / Netlify / ...]
- **Conventies:** zie `frontend/CLAUDE.md`

### Backend API
- **Stack:** FastAPI, Python 3.12+, SQLAlchemy 2.0 (async), Pydantic v2
- **Package manager:** uv
- **Testing:** pytest + pytest-asyncio
- **Architecture:** Feature-first (vertical slicing)
- **Deploy:** [Railway / AWS / ...]
- **Conventies:** zie `backend/CLAUDE.md`

### Database
- **Type:** PostgreSQL 16
- **Driver:** asyncpg
- **Migraties:** Alembic (async)
- **Backup:** [strategie]

## Communicatie

| Van | Naar | Protocol | Auth |
|---|---|---|---|
| Frontend | Backend API | REST/GraphQL | JWT Bearer |
| Backend API | Database | TCP | Connection string |
| Backend API | Cache | TCP | Password |

## Gerelateerde ADRs

- ADR-0001: Frontend tech stack keuze
- ADR-0002: Backend tech stack keuze
