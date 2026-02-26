# Plan: Starter-Kit DX Verbeteringen (v3 — approved)

## Context

Analyse als nieuwe gebruiker toonde aan dat de starter-kit scoort op 8.5/10. De zwakste plek is de "eerste 5 minuten"-ervaring: Docker starten, frontend deps installeren, migraties draaien, en commit format zijn niet duidelijk genoeg. Dit plan lost de Prio 1 en Prio 2 friction points op.

## Problem Statement

Een nieuwe developer die `git clone` + `make setup` + `make dev` uitvoert, loopt tegen blokkerende problemen:
1. Frontend dependencies worden niet geïnstalleerd door `make setup`
2. Docker moet handmatig gestart worden (niet gedocumenteerd)
3. Database heeft geen schema na verse Docker start (migraties niet gedocumenteerd)
4. Eerste commit faalt op conventional commit hook zonder uitleg

## Implementation Steps

### Stap 1: `make setup` — prerequisite checks + frontend deps
**File**: `Makefile` (root)

```makefile
setup:  ## First-time project setup
	@command -v pnpm > /dev/null 2>&1 || { echo "Error: pnpm is not installed. See https://pnpm.io/installation"; exit 1; }
	@command -v uv > /dev/null 2>&1 || { echo "Error: uv is not installed. See https://docs.astral.sh/uv/"; exit 1; }
	cd backend && $(MAKE) setup
	cd frontend && pnpm install
	pre-commit install
	pre-commit install --hook-type commit-msg
```

Wijzigingen:
- Check `pnpm` en `uv` beschikbaarheid met installatie-links
- Voeg `cd frontend && pnpm install` toe na backend setup
- Idempotent bij herhaald uitvoeren

### Stap 2: `make dev` — Docker infra + migraties + instructies
**File**: `Makefile` (root)

```makefile
dev:  ## Start dev servers (requires two terminals)
	@command -v docker > /dev/null 2>&1 || { echo "Error: Docker is not installed. See https://docs.docker.com/get-docker/"; exit 1; }
	@if ! docker info > /dev/null 2>&1; then \
		echo "Error: Docker is not running. Start Docker Desktop first."; \
		exit 1; \
	fi
	@echo "Starting infrastructure..."
	cd backend && docker compose up -d --wait
	@echo "Running database migrations..."
	cd backend && uv run alembic upgrade head
	@echo ""
	@echo "Infrastructure ready. Start servers in separate terminals:"
	@echo "  Terminal 1:  cd backend && make dev"
	@echo "  Terminal 2:  cd frontend && pnpm dev"
	@echo ""
	@echo "Endpoints:"
	@echo "  Backend API:  http://localhost:8000/docs"
	@echo "  Frontend:     http://localhost:3000"
```

Wijzigingen:
- `command -v docker` check (niet geïnstalleerd)
- `docker info` check (niet draaiend)
- `docker compose up -d --wait` — wacht tot health checks slagen (Postgres + Redis hebben al health checks)
- `alembic upgrade head` — schema aanmaken na verse DB start
- Duidelijke stap-voor-stap instructies

### Stap 3: README — Quick Start + Git Workflow
**File**: `README.md`

Vervang Quick Start sectie en voeg Git Workflow sectie toe na Available Commands:

```markdown
## Quick Start

Ensure you have the [Prerequisites](#prerequisites) installed, then:

\```bash
# Only for new projects from this template (skip for existing repos):
make init

# First-time setup (backend .env, frontend deps, git hooks):
make setup

# Start infrastructure + see dev server instructions:
make dev
\```

## Git Workflow

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

\```
type(scope): description

# Examples:
feat(backend): add user registration endpoint
fix(frontend): resolve hydration mismatch on home page
docs: update API architecture diagram
chore: bump dependencies
\```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `ci`, `chore`, `build`, `perf`, `revert`
Allowed scopes: `frontend`, `backend`, `docs`, `ci` (or empty)
```

Note: het `chore: bump dependencies` voorbeeld toont expliciet dat scope optioneel is.

### Stap 4: Pre-commit verbose op ruff linter
**File**: `.pre-commit-config.yaml`

Voeg `verbose: true` alleen toe aan `ruff` (linter), niet aan `ruff-format`.

## Files Affected

| File | Wijziging |
|---|---|
| `Makefile` | `setup`: +pnpm/uv checks, +frontend deps. `dev`: +docker checks, +compose up --wait, +migrate |
| `README.md` | Quick Start met prerequisite link, Git Workflow sectie met scope-optioneel voorbeeld |
| `.pre-commit-config.yaml` | `verbose: true` op ruff linter |

## Known Limitations (future iterations)

- **Twee terminals vereist**: `make dev` start infra maar niet de servers zelf. Een process manager (concurrently/overmind) zou dit kunnen vereenvoudigen, maar voegt een dependency toe die nu niet gerechtvaardigd is voor een starter-kit.

## Testing Strategy

### Handmatige verificatie
1. `make setup` zonder pnpm → foutmelding "pnpm is not installed" + link
2. `make setup` zonder uv → foutmelding "uv is not installed" + link
3. `make setup` normaal → `frontend/node_modules/` aangemaakt, `.env` gegenereerd, hooks geïnstalleerd
4. `make setup` opnieuw → idempotent, geen errors
5. Docker niet geïnstalleerd → `make dev` → foutmelding + link
6. Docker niet draaiend → `make dev` → foutmelding "Start Docker Desktop first"
7. Docker draaiend → `make dev` → containers starten, `--wait` blokkeert tot healthy, migraties draaien, instructies verschijnen
8. `git commit -m "added stuff"` → conventional-pre-commit rejection
9. `git commit -m "fix: typo"` → commit slaagt (lege scope)
10. Ruff violation triggeren → verbose output toont fix-suggestie

### Automatische verificatie
- `make lint` + `make test` moeten nog steeds slagen

## Rollback Plan

Alle wijzigingen in 3 bestanden. Rollback via `git revert`.

## Review History

### v1 → v2 (Staff Engineer Review #1)
- `make dev` start nu daadwerkelijk Docker (was alleen instructies)
- `pnpm` prerequisite check toegevoegd
- `verbose: true` alleen op ruff linter (niet formatter)
- Non-step verwijderd, prerequisite link in README

### v2 → v3 (Staff Engineer Review #2)
- `docker compose up -d --wait` ipv `-d` (wacht op health checks)
- `alembic upgrade head` na Docker start (schema voor verse DB)
- `uv` prerequisite check toegevoegd (naast pnpm)
- `docker` installed check toegevoegd (naast running check)
- Twee-terminal limitatie expliciet gedocumenteerd
- Scope-optioneel voorbeeld in Git Workflow (`chore: bump dependencies`)
