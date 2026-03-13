# Dependency Management

> How we keep packages up to date without breaking things.

## Strategy

| Update type | Frequency | Grouped | Review | CI must pass |
|---|---|---|---|---|
| Patch + minor | Weekly (Monday) | Yes, one PR per ecosystem | Quick review, auto-merge candidate | Yes |
| Major (breaking) | Monthly | Yes, one PR per ecosystem | Manual review required | Yes |
| Security (critical) | Immediate | Via Dependabot security alerts | Prioritize same day | Yes |

## How it works

**Dependabot** opens PRs automatically (`.github/dependabot.yml`):

- **Minor/patch PRs** — grouped per ecosystem (frontend, backend, GitHub Actions), weekly. These are usually safe to merge after CI passes.
- **Major PRs** — grouped separately, monthly, labeled `breaking`. These need manual review: check changelogs, test locally, verify no breaking changes.
- **GitHub Actions** — pinned by SHA, updated weekly as a group.

## When to update manually

Dependabot handles version bumps, but some upgrades need hands-on work:

- **Next.js major** (e.g., 16→17) — often involves config changes, API deprecations. Follow the official migration guide.
- **React major** — check for removed APIs, new patterns. Usually coordinated with Next.js.
- **SQLAlchemy / FastAPI major** — check migration guides, test all endpoints.
- **Tailwind major** — config format and class names may change.

For these: create a branch, upgrade, run full test suite, review build output.

## Pinning philosophy

- **Frontend:** `^` (caret) for most deps — allows minor/patch. Pin exact versions only for framework core (`next`, `react`, `react-dom`) to avoid surprise breakage.
- **Backend:** `>=` minimum version — uv lockfile pins exact resolved versions. `uv.lock` is the source of truth.
- **GitHub Actions:** SHA-pinned for supply chain security.

## Review checklist for major updates

1. Read the changelog / migration guide
2. Check if peer dependencies need updating too
3. Run full CI locally: `make test && make lint && make typecheck`
4. Check build output for new warnings
5. Test critical user flows manually if UI-impacting
