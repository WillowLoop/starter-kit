# AIpoweredMakers

Full-stack starter kit: Next.js 16 + FastAPI + PostgreSQL.

## Prerequisites

- Node.js 18.18+ (required by Next.js 16)
- [pnpm](https://pnpm.io/)
- Python 3.12+
- [uv](https://docs.astral.sh/uv/)
- Docker (for PostgreSQL + Redis)

## Quick Start

Ensure you have the [Prerequisites](#prerequisites) installed, then:

```bash
# Only for new projects from this template (skip for existing repos):
make init

# First-time setup (backend .env, frontend deps, git hooks):
make setup

# Start infrastructure + see dev server instructions:
make dev
```

## Project Structure

| Folder | Description |
|---|---|
| `frontend/` | Next.js 16 web app (TypeScript, Tailwind, shadcn/ui) |
| `backend/` | FastAPI backend API (Python 3.12+, SQLAlchemy, PostgreSQL) |
| `docs/` | Architecture (C4), ADRs, workflows, planning |
| `scripts/` | Project initialization and hook scripts |
| `.github/` | CI/CD workflows (lint, test, build, deploy) |

## Available Commands

```
make help       Show available commands
make init       Transform starter-kit into a new project
make setup      First-time project setup
make dev        Start dev servers (requires two terminals)
make test       Run all tests
make lint       Run all linters
```

## Git Workflow

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

# Examples:
feat(backend): add user registration endpoint
fix(frontend): resolve hydration mismatch on home page
docs: update API architecture diagram
chore: bump dependencies
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `ci`, `chore`, `build`, `perf`, `revert`
Allowed scopes: `frontend`, `backend`, `docs`, `ci` (or empty)

## Documentation

- [Documentation Index](docs/README.md)
- [Architecture (C4)](docs/architecture/c4/containers.md)
- [Architecture Decision Records](docs/architecture/adr/)
- [CI/CD Setup Guide](docs/workflows/cicd-setup.md)
- [Project Documentation Guide](docs/project-documentation-guide.md)
