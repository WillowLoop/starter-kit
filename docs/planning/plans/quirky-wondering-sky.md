# Implementation Plan: Repo Quality Improvements

## Context

Analysis of the starter-kit monorepo revealed 18 findings across documentation, code quality, and CI/CD. The biggest change is translating all Dutch documentation to English (~30 files). This plan addresses all findings, split into 2 PRs for reviewability.

---

## Terminology Guide (consistency across all translations)

| Nederlands | English | Rationale |
|---|---|---|
| Beschrijving | Description | Standard |
| Structuur | Structure | Standard |
| Regels | Rules | Direct, matches CLAUDE.md style |
| Gedeelde | Shared | Matches code (`shared/`) |
| Feiten en regels | Facts and rules | Literal, used in doc guide context |
| Eigenaar | Owner | Standard |
| Beslissing | Decision | ADR terminology |
| Waarom afgewezen | Why rejected | ADR template |
| Gevolgen | Consequences | ADR terminology |
| Stappen | Steps | Standard |
| Doel | Goal | Standard |
| Migraties | Migrations | Technical term |
| Referentie-implementatie | Reference implementation | Standard |

---

## PR 1: Documentation Translation (low-risk, high-volume)

Translate all Dutch content to English. Meaning and structure stay identical — only language changes. Use the terminology guide above for consistency.

### 1A. Core project files

| File | Lines | Notes |
|---|---|---|
| `CLAUDE.md` | ~40 | Table headers, rules, descriptions |
| `frontend/CLAUDE.md` | ~40 | Structure table, patterns, rules |
| `backend/CLAUDE.md` | ~45 | Structure, patterns, rules |
| `frontend/README.md` | ~70 | Setup, scripts, structure |
| `backend/README.md` | ~73 | Setup, scripts, structure |
| `docs/README.md` | ~112 | Doc index, bootstrap checklist. Update all internal file references (see 1D) |

### 1B. Architecture documentation

| File | Lines | Notes |
|---|---|---|
| `docs/project-documentation-guide.md` | ~295 | Largest file — comprehensive doc framework |
| `docs/architecture/c4/context.md` | ~30 | System context. Add note at top: "Fill in during bootstrap (see docs/README.md step 4)" |
| `docs/architecture/c4/containers.md` | ~100 | Deployment topology |
| `docs/architecture/c4/components.md` | ~60 | Module responsibilities |
| `docs/architecture/adr/_template.md` | ~70 | ADR template with instructions |
| `docs/architecture/adr/0001-frontend-tech-stack.md` | ~57 | |
| `docs/architecture/adr/0002-backend-tech-stack.md` | ~64 | |
| `docs/architecture/adr/0003-versioning-and-release-strategy.md` | ~46 | |
| `docs/architecture/adr/0004-repository-security-and-pre-commit.md` | ~62 | |
| `docs/architecture/adr/0005-cicd-pipeline-architecture.md` | ~98 | |
| `docs/architecture/adr/0006-deployment-strategy.md` | ~109 | |

### 1C. Planning & workflow templates

| File | Action | Notes |
|---|---|---|
| `docs/planning/todo.md` | Translate + reframe as "Extension opportunities" | Finding 18 |
| `docs/planning/roadmap/overview.md` | Translate | |
| `docs/planning/roadmap/_template.md` | Translate | |
| `docs/planning/prd/_template.md` | Translate | |
| `docs/planning/prd/0001-voorbeeld-prd.md` | Translate + **rename** to `0001-example-prd.md` | |
| `docs/planning/design/_template.md` | Translate | |
| `docs/planning/design/0001-voorbeeld-design.md` | Translate + **rename** to `0001-example-design.md` | File already exists |
| `docs/workflows/_template.md` | Translate | |
| `docs/research/_template.md` | Translate | |

### 1D. Cross-reference updates after renames

All internal references to renamed files must be updated:
- `docs/README.md` — references to `0001-voorbeeld-prd.md` and `0001-voorbeeld-design.md`
- `docs/planning/design/0001-voorbeeld-design.md` line 6 — references `../prd/0001-voorbeeld-prd.md`
- Any other markdown files linking to the old filenames
- `docs/README.md` — **add** link to `docs/workflows/cicd-setup.md` in the doc index table (Finding 12)

### 1E. Misc config comments

| File | Line | Change |
|---|---|---|
| `.pre-commit-config.yaml` | line 33 | Dutch comment → English |
| `.github/workflows/security.yml` | line 7 | `# maandag` → `# Monday` |

### 1F. .claude/ and scripts/ documentation (Finding 2, 3)

- **`docs/README.md`**: Add a section explaining the `.claude/` directory:
  - `agents/` — AI agent role definitions (used by Claude Code)
  - `commands/` — Slash commands invokable via `/command-name`
  - `skills/` — Reusable procedure documents for complex workflows
- **`README.md`**: Add brief explanation of `make init` in Quick Start (renames project, resets git history, regenerates lockfiles)

### Commit strategy (PR 1)

Single commit: `docs: translate all documentation from Dutch to English`

### Verification (PR 1)

- Spot-check 5+ translated files for natural English and preserved meaning
- Verify all internal markdown links resolve (no broken cross-references)
- `pre-commit run --all-files` — hooks pass

---

## PR 2: Code Fixes & CI Improvements (low-volume, higher-risk)

### 2A. Frontend fixes

**Create `frontend/.env.example`** (Finding 9):
```
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**`global-error.tsx` — keep as-is** (Finding 10, revised per staff review):
`global-error.tsx` replaces the entire HTML document including `<html>` and `<body>`, so it operates **outside** the root layout's CSS pipeline. Theme tokens (`bg-background`, `bg-primary`) won't resolve without the stylesheet. The current hardcoded `bg-black text-white` is actually the correct approach for a crash-recovery fallback page that must render even when CSS loading fails. **No change needed.**

### 2B. Backend fixes

**`backend/features/health/router.py:17`** — add comment (Finding 8):
```python
# Liveness probe — intentionally dependency-free (no DB, no Redis).
# Do NOT add Depends() here; k8s/Docker must get 200 even when dependencies are down.
```

**`backend/features/items/repository.py`** — skip setattr validation (Finding 7, revised per staff review):
The service layer (`service.py:26,33`) only ever passes `data.model_dump()` and `data.model_dump(exclude_unset=True)` — Pydantic already validates field names at the schema boundary. Adding redundant validation in the repository would be defense-in-depth for a scenario that can't happen through the normal code path. Also, `create(**kwargs)` has the same pattern and would need the same treatment. **No change needed — Pydantic handles this.**

### 2C. CI/DevOps improvements

**CodeQL on PRs** (Finding 14):
File: `.github/workflows/security.yml`, line 60: `if: github.event_name != 'pull_request'`
**Remove** this condition so CodeQL also runs on PRs.
Note: Trivy (line 75, same condition) stays excluded — it builds a Docker image which is expensive on every PR. Document this decision with a comment:
```yaml
# Trivy skipped on PRs — Docker build is expensive. Runs on push + weekly schedule.
```

**Pre-commit frontend lint** (Finding 13):
File: `.pre-commit-config.yaml`
Add ESLint hook that passes filenames for performance:
```yaml
- repo: local
  hooks:
    - id: frontend-lint
      name: frontend eslint
      entry: pnpm --dir frontend exec eslint
      language: system
      files: ^frontend/src/.*\.(ts|tsx)$
      types: [file]
```
This only triggers on changed frontend files and only lints those specific files (not the entire codebase).

**Root Makefile** (Finding 15, revised per staff review):
Drop the `dev` target — backgrounding with `&` is fragile (zombie processes, interleaved output, Ctrl+C only kills foreground). Instead add only the reliable targets:
```makefile
test:  ## Run all tests
	cd backend && $(MAKE) test
	cd frontend && pnpm test

lint:  ## Run all linters
	cd backend && $(MAKE) lint
	cd frontend && pnpm lint
```
Add a comment in the Makefile pointing developers to run backend and frontend dev servers in separate terminals.

### Commit strategy (PR 2)

Three commits:
1. `chore(frontend): add .env.example`
2. `fix(backend): add liveness probe comment to health endpoint`
3. `ci: add frontend ESLint pre-commit hook and extend root Makefile`

### Verification (PR 2)

1. `cd backend && make test` — all 26 tests pass
2. `cd frontend && pnpm test` — all 4 tests pass
3. `cd frontend && pnpm build` — compiles without errors
4. `cd backend && make lint` — clean
5. `cd frontend && pnpm lint` — clean
6. `cd backend && make typecheck` — clean
7. `cd frontend && pnpm exec tsc --noEmit` — clean
8. `pre-commit run --all-files` — all hooks pass (including new frontend-lint hook)

---

## Decisions Log

| Finding | Decision | Rationale |
|---|---|---|
| 6 (service logging) | Skip | Middleware already logs all requests; service layer should only log unexpected conditions |
| 7 (repository setattr) | Skip | Pydantic validates at service layer boundary; repository-level check is redundant |
| 10 (global-error.tsx) | Skip | Hardcoded colors are correct for crash-recovery page outside CSS pipeline |
| 11 (CLAUDE.md format) | Skip | Both formats explicitly allowed per project-documentation-guide.md |
| 16 (conftest ordering) | Skip | Already has clear comment block (lines 17-23) |
| 17 (bare except) | Skip | `except Exception` is correct — doesn't catch BaseException subclasses |

---

## Files Modified (summary)

| PR | Category | Count |
|---|---|---|
| PR 1 | Translation + renames + cross-refs | ~28 files |
| PR 2 | New files (`frontend/.env.example`) | 1 file |
| PR 2 | Code comments (`health/router.py`) | 1 file |
| PR 2 | CI/DevOps (`.pre-commit-config.yaml`, `Makefile`, `security.yml`) | 3 files |
| **Total** | | **~33 files** |
