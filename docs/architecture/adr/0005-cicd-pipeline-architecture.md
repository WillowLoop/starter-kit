# ADR-0005: CI/CD Pipeline Architecture

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: CI/CD workflows, deployment pipelines, GitHub Actions
- **Date**: 2026-02-26

## Context

The AIpoweredMakers project is a monorepo with frontend (Next.js), backend (FastAPI), and documentation. For every commit it must be quickly clear whether the code is release-ready: tests must pass, type checking must be valid, security checks must succeed. Simultaneously, deployment must be safe and automated without human intervention for standard pushes to main.

The existing CI workflow works, but is missing:
1. Docker image validation (smoke test)
2. Security scanning (SAST, dependency audit, container scan)
3. Explicit aggregation of CI checks for branch protection
4. Deployment automation (frontend to Vercel, backend to self-hosted)
5. Dependency management automation (Dependabot)

## Decision

**Four-layer workflow architecture:**

1. **ci.yml** (pull_request + push → main)
   - Backend: lint, type check, test, docker-build smoke test
   - Frontend: lint, type check, test, build
   - Aggregation: `ci-pass` job requires all 3 checks to pass

2. **security.yml** (pull_request + weekly + manual)
   - Bandit (Python SAST)
   - pip-audit (Python dependencies)
   - npm audit (JavaScript dependencies)
   - CodeQL (weekly only — weekly jobs are slow)
   - Trivy (weekly only — container image scan)

3. **deploy-frontend.yml** (workflow_dispatch → manual test)
   - Triggered via `workflow_dispatch` initially (bootstrap-safe)
   - Uncomment `push` trigger after Vercel secrets setup
   - Vercel: automatic preview per PR, production per main push

4. **deploy-backend.yml** (workflow_dispatch → manual test)
   - Docker build → GHCR push
   - Triggered via `workflow_dispatch` initially (bootstrap-safe)
   - Uncomment `push` trigger after Coolify secrets setup
   - Manual approval required for production deployments

5. **dependabot.yml**
   - Weekly automated PRs for dependency updates
   - Grouped updates (actions, frontend-deps, python-deps)
   - Spread over 07:00-08:00 UTC Monday morning to avoid CI storm

6. **release.yml** (push → main)
   - Release-Please for automated versioning
   - Concurrency: `cancel-in-progress: false` (NEVER cancel a running release)

## Reasoning Chain

1. Monorepo requires independent workflow orchestration per component → separate jobs per feature
2. Docker image must validate locally before push to registry → smoke test in ci.yml
3. Heavy security scans (CodeQL, Trivy) cannot run on every PR (too slow) → weekly + manual triggers
4. Deployment must start safe (no auto-push) → `workflow_dispatch` only until secrets are configured
5. Branch protection must have one check that covers all criteria → `ci-pass` aggregation job
6. Self-hosted backend deployment requires automated image builds + webhook triggers → Coolify integration
7. Dependencies change constantly → automation needed without CI overload → Dependabot with spreading

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Monolithic ci.yml with everything | Unreadable, hard to debug, hard to extend |
| Security checks on every PR | CodeQL and Trivy are too slow (>10min per run), prevents signal-to-noise |
| Auto-deploy on every push → main | Unsafe for production, can push bugs to live environment, requires manual gate |
| Separate GitHub Actions per team | Extra overhead, duplicate code, hard to maintain in starter-kit |
| Cloud CI (CircleCI, Travis) | Extra vendor lock-in, starter-kit must be self-sufficient, GitHub Actions is free |

## Consequences

- **Easier:**
  - Visibility: `ci-pass` check gives clear signal "ready to merge"
  - Fast feedback: ci.yml runs in <5min, developers get quick results
  - Reproducible: Docker image that passes tests is the same image in production
  - Automatic dependency updates prevent manual churn

- **Harder:**
  - Deployment setup requires manual secret configuration per platform (Vercel, Coolify)
  - Vercel deploy action pin requires monkeypatch (community action without SHA-pin available)
  - Coolify webhook requires manual setup (no native GitHub Actions, custom hook needed)

- **Constraints:**
  - All GitHub Actions must be SHA-pinned (no mutable `@v4` tags)
  - Deployment workflows start as `workflow_dispatch` only (bootstrap-safe)
  - CodeQL + Trivy run weekly to limit CI load
  - Bandit/pip-audit/npm-audit run on every PR (faster, catches prevent issues)
  - Concurrency: ci.yml cancels in-progress PR checks (new push wins), release.yml does not (prevents lost releases)

## Related ADRs

- ADR-0006: Deployment strategy (Vercel frontend, Coolify backend)
- ADR-0003: Versioning and Release Strategy (Release-Please automation)
