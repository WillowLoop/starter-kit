# AIpoweredMakers

Stack: Next.js 16 + FastAPI + PostgreSQL
Architecture: monorepo (frontend + backend + docs)

## Repo layout

| Folder | Description |
|---|---|
| `frontend/` | Next.js 16 web app (TypeScript, Tailwind, shadcn/ui) |
| `backend/` | FastAPI backend API (Python 3.12+, SQLAlchemy, PostgreSQL) |
| `docs/` | Architecture (C4), ADRs, workflows, research, planning |
| `.claude/` | Agents, commands, skills |

## Working style

- When adding API endpoints, always verify CORS config in `backend/shared/middleware/` and `cors_origins` default in `backend/shared/config.py`
- Before any backend server work, verify the correct venv is activated (`which python` should point to project venv)
- When receiving data files (Excel, CSV, JSON), confirm the file format and structure before building an analysis plan — do not assume from the file extension
- Keep plans lean: default to minimal scope. If a plan exceeds 10 files, check with the user first
- CORS defaults cover localhost:3000–3015 — no config needed for local dev. Production must set CORS_ORIGINS env var explicitly
- Use `make dev-servers` to start paired frontend+backend on free ports; `make dev-stop` to shut down only your own servers
- Never override another session's servers — each session tracks its own PIDs via /tmp/dev-<session>.pids
- `NEXT_PUBLIC_API_URL` works dynamically only in Next.js dev mode — production builds inline the value at build time

## Global rules

- Conventional Commits: `type(scope): description`
- CLAUDE.md per directory: facts and rules, max ~200 tokens
- Decisions with alternatives → ADR in `docs/architecture/adr/`
- Procedures and workflows → Skill in `.claude/skills/`
- Architecture → C4 docs in `docs/architecture/c4/`
- Sensitive data → never in git (credentials, tokens, customer data)
- Pre-commit hooks: `make setup` after clone, env sync + ruff + secrets
- New env vars → update `backend/.env.example` with placeholder
- Versioning: release-please (per-package, auto from conventional commits)
- Commit scopes: frontend, backend, docs, ci (empty also allowed)

## CI/CD

Pipelines: ci, security, deploy-frontend, deploy-backend, release, dependabot.
Branch protection: `ci-pass` check required. Production: manual gate.
Details: `docs/workflows/cicd-setup.md` | ADR: `docs/architecture/adr/0005-cicd-pipeline-architecture.md`

## Docs

| Document | When to read |
|---|---|
| `docs/project-documentation-guide.md` | Questions about documentation architecture |
| `docs/architecture/c4/context.md` | System-wide architecture questions |
| `docs/architecture/c4/containers.md` | Questions about deployment units or tech stack |
| `docs/architecture/c4/components.md` | Questions about modules and their interactions |
| `docs/architecture/adr/` | "Why was this chosen?" |
| `docs/planning/roadmap/overview.md` | Questions about planning and priorities |
| `docs/workflows/disaster-recovery.md` | Backup strategy, runbooks, RPO/RTO |
| `release-please-config.json` | Questions about versioning and releases |
