# ADR-0003: Versioning and Release Strategy

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: frontend, backend (all deployable units)
- **Date**: 2026-02-14

## Context

The project uses Conventional Commits (`type(scope): description`) as convention, but there is no tooling that automatically derives version numbers from them. Frontend and backend are independent deployable units that each follow their own release cadence. We want versioning that requires zero manual work after initial setup.

## Decision

**release-please** (Google) for automatic semantic versioning with per-package releases.

- Monorepo configuration: directory-based detection (commits touching files in `backend/` → backend release, same for `frontend/`)
- Per-package versioning: frontend and backend have independent version numbers
- 0.x SemVer: as long as version < 1.0.0, a breaking change bumps minor (not major)
- One combined Release PR per push to main (`separate-pull-requests: false`)

**commitlint is deferred** until there is a second contributor or CI pipeline. Enforcement via git hook is overhead for a solo developer; the convention is in CLAUDE.md.

## Reasoning Chain

- Conventional Commits are already the standard in this project → automatic versioning based on commit types is possible without workflow change
- Frontend and backend are independent containers (see ADR-0002) → per-package versioning prevents unnecessary bumps when only one container changes
- release-please has native monorepo support and supports both Node (`package.json`) and Python (`pyproject.toml`) → one tool for both packages
- There is no CI/CD or remote → the GitHub Action is inert until those exist, but the configuration is ready

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| semantic-release | Complex plugin architecture, poor Python support, requires more configuration |
| standard-version | Deprecated since 2022, no monorepo support |
| Manual versioning | User doesn't want to think about it; error-prone and forgettable |
| commitlint + husky (now) | Solo developer, zero commits, no team — enforcement is overhead without added value |

## Consequences

- Versioning is fully automatic after merge to main — zero manual work
- CHANGELOGs are generated per package in `frontend/CHANGELOG.md` and `backend/CHANGELOG.md`
- Git tags follow the pattern `frontend-v0.1.0`, `backend-v0.1.0`
- Commit messages must follow Conventional Commits (already existing convention)
- Breaking changes on 0.x bump minor, not major — deliberate choice until 1.0.0
- When adding a team or CI, commitlint can still be added as enforcement layer
