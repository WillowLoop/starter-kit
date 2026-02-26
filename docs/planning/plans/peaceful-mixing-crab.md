# Plan: Commit remaining files and push to remote

## Context

The starter kit has 7 commits on `fix/code-quality-and-ci` but the bulk of the codebase (~60 files) is still untracked. The user wants to commit everything and push to `git@github.com:WillowLoop/starter-kit.git`.

## Security check (done)

- `.gitignore` correctly excludes: `.env`, `.env.local`, `*.pem`, `*.key`, `.claude/settings.local.json`, `.claude/plans/`
- No sensitive files in the untracked list
- `backend/.env` (real credentials) is gitignored — will NOT be committed
- `.claude/settings.local.json` (personal permissions) is gitignored — will NOT be committed

## Steps

### 1. Commit all remaining files

Single commit for the full starter kit codebase:

```
git add .
git commit -m "chore: add starter kit codebase"
```

Files included:
- **Root:** `.gitignore`, `.gitleaksignore`, `.trivyignore`, `README.md`, `release-please-config.json`, `.release-please-manifest.json`
- **Backend:** `app/`, `features/`, `shared/`, `tests/`, `Dockerfile`, `Makefile`, `alembic.ini`, `docker-compose*.yml`, `uv.lock`, `.dockerignore`, `.gitignore`, `CLAUDE.md`
- **Frontend:** `src/` (app, components, features, hooks, lib, test, types), config files (tsconfig, eslint, vitest, postcss, next.config, components.json, pnpm-workspace)
- **Docs:** `planning/plans/`, `workflows/`
- **CI/CD:** `dependabot.yml`, `deploy-backend.yml`, `deploy-frontend.yml`, `release.yml`
- **Scripts:** `hooks/`, `init-project.sh`
- **Claude:** `.claude/` (agents, commands, hooks, skills, settings.json)
- **Modified:** `CLAUDE.md`, `backend/pyproject.toml`, `docs/README.md`, `docs/architecture/adr/0001-frontend-tech-stack.md`, `docs/architecture/c4/containers.md`

### 2. Add remote and push

```
git remote add origin git@github.com:WillowLoop/starter-kit.git
git push -u origin fix/code-quality-and-ci
```

## Verification

```
git log --oneline -10    # 8 commits total (7 existing + 1 new)
git remote -v            # origin points to GitHub
git status               # clean working tree
```
