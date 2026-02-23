# AIpoweredMakers

Stack: Next.js 16 + FastAPI + PostgreSQL
Architecture: monorepo (frontend + backend + docs)

## Repo layout

| Folder | Beschrijving |
|---|---|
| `frontend/` | Next.js 16 web applicatie (TypeScript, Tailwind, shadcn/ui) |
| `backend/` | FastAPI backend API (Python 3.12+, SQLAlchemy, PostgreSQL) |
| `docs/` | Architectuur (C4), ADRs, workflows, research, planning |
| `.claude/` | Agents, commands, skills |

## Global rules

- Conventional Commits: `type(scope): description`
- CLAUDE.md per directory: feiten en regels, max ~200 tokens
- Beslissingen met alternatieven → ADR in `docs/architecture/adr/`
- Procedures en workflows → Skill in `.claude/skills/`
- Architectuur → C4 docs in `docs/architecture/c4/`
- Gevoelige data → nooit in git (credentials, tokens, klantdata)
- Pre-commit hooks: `make hooks` na clone, env sync + ruff + secrets
- Nieuwe env vars → update `backend/.env.example` met placeholder
- Versioning: release-please (per-package, auto from conventional commits)
- Commit scopes: frontend, backend, docs, ci (leeg ook toegestaan)

## Docs

| Document | Wanneer lezen |
|---|---|
| `docs/project-documentation-guide.md` | Bij vragen over documentatie-architectuur |
| `docs/architecture/c4/context.md` | Bij systeembrede architectuurvragen |
| `docs/architecture/c4/containers.md` | Bij vragen over deployment units of tech stack |
| `docs/architecture/c4/components.md` | Bij vragen over modules en hun interacties |
| `docs/architecture/adr/` | Bij "waarom is dit zo gekozen?" |
| `docs/planning/roadmap/overview.md` | Bij vragen over planning en prioriteiten |
| `docs/architecture/adr/0003-versioning-and-release-strategy.md` | Bij vragen over versioning en releases |
