# Plan: Fix All Starter-Kit Issues

## Context

A full assessment of the starter-kit from a new developer's perspective revealed strong foundations (security, testing, code quality, Docker hardening) but several onboarding gaps, broken references, and missing DX features. This plan addresses all identified issues while respecting the project's documentation architecture (ADR immutability, CLAUDE.md token budgets).

---

## Changes

### 1. Fix stale Next.js version references

ADR-0001 is **immutable** per the project's own documentation policy (`_template.md` line 69). The original decision (Next.js with App Router) hasn't changed — only the version number. Approach:

**ADR-0001** (`docs/architecture/adr/0001-frontend-tech-stack.md`): Add an addendum at the bottom:
```markdown
---
## Addendum — 2026-02-26

Next.js is geüpgraded van 15 naar 16. De architectuurkeuzes (App Router, TypeScript, Tailwind, shadcn/ui, pnpm, Vitest) blijven ongewijzigd.
```

**Living docs** (NOT ADRs — these reflect current state):
- `docs/architecture/c4/containers.md` lines 9, 35: `Next.js 15` → `Next.js 16`
- `docs/README.md` line 26: `Next.js 15` → `Next.js 16` (ADR index summary)

**Template examples** (`docs/project-documentation-guide.md` lines 26, 50): Leave as-is. These are generic illustrative examples (like `arch-check.md`), not descriptions of this project's actual stack.

---

### 2. Fix all broken documentation references

**`docs/workflows/cicd-setup.md`** lines 286-288 (Related Documentation section):
- Remove links to non-existent ADR-0005 and ADR-0006
- Fix broken `containers.md` link: `../c4/containers.md` → `../architecture/c4/containers.md`

**`CLAUDE.md`** line 38: Remove reference to non-existent `adr/0003-versioning-and-release-strategy.md`. Versioning info is covered by `release-please-config.json` and `docs/architecture/adr/0003-versioning-and-release-strategy.md` (which we'll link to `docs/architecture/adr/` folder instead).

---

### 3. Fix `make hooks` reference in CLAUDE.md

**`CLAUDE.md`** line 23: `make hooks` → `make setup` (the actual target that runs `pre-commit install`).

---

### 4. Create `backend/CLAUDE.md`

New file following `frontend/CLAUDE.md` pattern. Keep under ~200 tokens (the project's stated budget). No file limits section (saves tokens; the frontend-specific limits don't apply to backend).

```markdown
# Backend

Stack: FastAPI, Python 3.12+, SQLAlchemy, PostgreSQL
Package manager: uv | Testing: pytest + httpx

## Structuur

| Pad | Beschrijving |
|---|---|
| `app/` | FastAPI applicatie (create_app factory) |
| `features/{name}/` | Router, service, repository, schema per feature |
| `shared/config.py` | Pydantic Settings (env vars) |
| `shared/db/` | Engine, session, base model, migrations |
| `shared/middleware/` | CORS, request logging |
| `shared/lib/` | Exception handlers |
| `tests/` | pytest met in-memory SQLite |

## Patterns

- App factory: `create_app()` in `app/main.py`
- Router → Service → Repository (dependency injection via `Depends`)
- Async throughout: asyncpg, async sessions, structlog async logging
- Alembic voor database migraties

## Regels

- Strict typing: `mypy --strict`, geen `Any`
- Nieuwe env vars → update `.env.example` met placeholder
- Feature code in `features/`, gedeelde code in `shared/`
- Geen raw SQL — gebruik SQLAlchemy ORM
```

---

### 5. Add commitlint pre-commit hook

**`.pre-commit-config.yaml`** — Append new repo block:

```yaml
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v4.4.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
        args: [feat, fix, docs, style, refactor, test, ci, chore, build, perf, revert]
```

Key details:
- `stages: [commit-msg]` is **required** — without it, the hook runs at the wrong stage and silently does nothing
- `v4.4.0` is the latest release (Feb 2026)
- Args include all standard conventional commit types. `build`, `perf`, `revert` are not yet used in this repo but are standard types that should be allowed

**`Makefile`** line 12: Add `pre-commit install --hook-type commit-msg` after the existing `pre-commit install`, so `make setup` installs both hook stages:

```makefile
setup:  ## First-time project setup
	cd backend && $(MAKE) setup
	pre-commit install
	pre-commit install --hook-type commit-msg
```

---

### 6. Add `make dev` target to root Makefile

Replace the comment block (lines 14-16) with a callable target:

```makefile
dev:  ## Start dev servers (requires two terminals)
	@echo "Start both dev servers in separate terminals:"
	@echo ""
	@echo "  Terminal 1:  cd backend && make dev"
	@echo "  Terminal 2:  cd frontend && pnpm dev"
	@echo ""
	@echo "Backend API:  http://localhost:8000/docs"
	@echo "Frontend:     http://localhost:3000"
```

Add `dev` to `.PHONY` line.

---

### 7. Create root `README.md`

Concise onboarding doc (~50-60 lines). Structure:

```
# AIpoweredMakers

One-liner description.

## Prerequisites

- Node.js 18.18+ (required by Next.js 16)
- pnpm
- Python 3.12+
- uv
- Docker (for PostgreSQL + Redis)

## Quick Start

# New project from template:
make init

# Setup (generates .env, installs hooks):
make setup

# Start dev servers:
make dev

## Project Structure

(concise table linking to docs/)

## Available Commands

(output of make help)

## Documentation

Links to docs/ folder, CI/CD setup guide, ADRs.
```

---

### 8. Create `scripts/init-project.sh`

Shell script with explicit per-file replacement patterns (addressing staff engineer concern about greedy sed):

```bash
#!/usr/bin/env bash
set -euo pipefail

# Prompt for names
read -rp "Project name (kebab-case, e.g. my-project): " PROJECT_NAME
read -rp "Display name (e.g. My Project): " DISPLAY_NAME

# Derive variants
LOWER_NAME="${PROJECT_NAME//-/}"  # myproject (no hyphens, for DB names)

# Platform-aware sed in-place
if [[ "$(uname)" == "Darwin" ]]; then
  sedi() { sed -i '' "$@"; }
else
  sedi() { sed -i "$@"; }
fi

# Per-file replacements (explicit patterns, not blanket):
# Frontend
sedi "s|aipoweredmakers-frontend|${PROJECT_NAME}-frontend|g" frontend/package.json
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" frontend/src/app/layout.tsx
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" frontend/src/app/page.tsx

# Backend
sedi "s|aipoweredmakers-backend|${PROJECT_NAME}-backend|g" backend/pyproject.toml
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" backend/pyproject.toml
sedi "s|AIpoweredMakers API|${DISPLAY_NAME} API|g" backend/app/main.py
sedi "s|/aipoweredmakers|/${LOWER_NAME}|g" backend/.env.example
sedi "s|aipoweredmakers|${LOWER_NAME}|g" backend/.env.example  # POSTGRES_DB
sedi "s|aipoweredmakers|${LOWER_NAME}|g" backend/docker-compose.yml

# Root docs
sedi "s|# AIpoweredMakers|# ${DISPLAY_NAME}|g" CLAUDE.md
sedi "s|# README.md heading if present|...|g" README.md

# Validate: no sed special chars in input
# (handled by using | as delimiter instead of /)

# Print post-init instructions
echo ""
echo "Done! Next steps:"
echo "  1. Review and update ADRs in docs/architecture/adr/"
echo "  2. Update docs/architecture/c4/ system descriptions"
echo "  3. Remove the 'init' target from the root Makefile"
echo "  4. Run: cd backend && uv lock"
echo "  5. Run: make setup"
```

Key decisions:
- Uses `|` as sed delimiter (avoids `/` conflicts in URLs)
- **Does NOT touch ADR body prose** — ADRs are immutable; prints reminder instead
- **Does NOT touch `docs/architecture/c4/context.md`** — prints reminder for manual review
- **Does NOT self-modify Makefile** — prints reminder (too fragile for cross-platform sed)
- **Does NOT touch lockfiles** — prints `uv lock` reminder for regeneration
- Validates kebab-case input (reject empty/invalid names)

---

### 9. Add `typecheck` script to frontend package.json

Add to scripts section:
```json
"typecheck": "tsc --noEmit"
```

---

### 10. Create `frontend/src/app/loading.tsx`

Skeleton matching `page.tsx` layout using Card component for smooth transition:

```tsx
import {
  Card,
  CardContent,
  CardHeader,
} from "@/components/ui/card";

export default function Loading() {
  return (
    <main className="flex min-h-screen items-center justify-center p-8">
      <Card className="w-full max-w-lg">
        <CardHeader>
          <div className="h-6 w-1/3 animate-pulse rounded bg-muted" />
          <div className="h-4 w-2/3 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent>
          <div className="h-4 w-16 animate-pulse rounded bg-muted mb-3" />
          <div className="space-y-2">
            <div className="h-4 w-full animate-pulse rounded bg-muted" />
            <div className="h-4 w-full animate-pulse rounded bg-muted" />
            <div className="h-4 w-2/3 animate-pulse rounded bg-muted" />
          </div>
        </CardContent>
      </Card>
    </main>
  );
}
```

Uses `Card` component (matching `page.tsx`), `bg-muted` semantic token, Server Component (no `"use client"`).

---

## Files Modified (existing)

| File | Change |
|---|---|
| `docs/architecture/adr/0001-frontend-tech-stack.md` | Add version upgrade addendum (immutable body preserved) |
| `docs/architecture/c4/containers.md` | Next.js 15 → 16 (lines 9, 35) |
| `docs/README.md` | Next.js 15 → 16 (line 26) |
| `docs/workflows/cicd-setup.md` | Remove 2 broken ADR links, fix containers.md relative path |
| `CLAUDE.md` | Fix `make hooks` → `make setup` (line 23), remove ADR-0003 ref (line 38) |
| `Makefile` | Add `dev` target, add `commit-msg` hook install to `setup`, update `.PHONY` |
| `.pre-commit-config.yaml` | Add `conventional-pre-commit` hook |
| `frontend/package.json` | Add `typecheck` script |

## Files Created (new)

| File | Purpose |
|---|---|
| `README.md` | Root onboarding doc |
| `backend/CLAUDE.md` | Backend context for Claude Code |
| `scripts/init-project.sh` | Project initialization script |
| `frontend/src/app/loading.tsx` | Route loading skeleton |

---

## Explicitly Out of Scope

- **`created_at` index**: Performance optimization, not a bug
- **`react-hook-form` + `zod` unused**: Intentional — ready for future forms
- **Roadmap placeholder**: Expected for a starter template
- **`global-error.tsx` hardcoded colors**: Correct — renders outside CSS variable layer
- **`project-documentation-guide.md` examples**: Generic templates, left as-is
- **`todo.md` open items**: Meta-tasks about the starter kit itself

---

## Verification

1. `make help` — shows `dev`, `setup`, `init`, `test`, `lint`
2. `make setup` — runs without errors, installs both pre-commit and commit-msg hooks
3. `make dev` — prints clear terminal instructions
4. `cd frontend && pnpm typecheck` — runs tsc --noEmit
5. `pre-commit run --all-files` — all existing hooks pass
6. Bad commit message test: `git commit --allow-empty -m "bad message"` — rejected by commitlint
7. Good commit message test: `git commit --allow-empty -m "chore: test"` — passes
8. Verify no remaining stale refs: `grep -r "Next.js 15" docs/architecture/ docs/README.md` — returns nothing
9. Verify broken links fixed: no dead ADR refs in `cicd-setup.md` or `CLAUDE.md`
10. `wc -w backend/CLAUDE.md` — under 200 words
