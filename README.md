# AIpoweredMakers

Full-stack starter kit: Next.js 16 + FastAPI + PostgreSQL.

## Quick Start

> **Tip:** You'll need 3 terminal sessions: database services, backend, and frontend.

**1. Initialize** (one-time, transforms starter-kit into your project — renames project, resets git history, regenerates lockfiles):

```bash
make init
```

**2. Setup** (first-time after init):

```bash
make setup
```

**3. Backend:**

```bash
cd backend
docker compose up -d postgres redis
make migrate
make dev
```

API runs on `http://localhost:8000` — Swagger UI at `http://localhost:8000/docs`.

**4. Frontend:**

```bash
cd frontend
pnpm install
pnpm dev
```

App runs on `http://localhost:3000`.

## Repo Layout

| Folder | Description | README |
|---|---|---|
| `frontend/` | Next.js 16 web app (TypeScript, Tailwind, shadcn/ui) | [frontend/README.md](frontend/README.md) |
| `backend/` | FastAPI backend API (Python 3.12+, SQLAlchemy, PostgreSQL) | [backend/README.md](backend/README.md) |
| `docs/` | Architecture (C4), ADRs, workflows, research, planning | [docs/README.md](docs/README.md) |

## Documentation

- [Bootstrap Checklist](docs/README.md) — Post-init setup steps
- [Architecture (C4)](docs/architecture/c4/) — System context, containers, components
- [ADRs](docs/architecture/adr/) — Architecture Decision Records
