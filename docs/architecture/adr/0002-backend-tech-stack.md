# ADR-0002: Backend Tech Stack

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: Backend API container
- **Date**: 2026-02-14

## Context

The AIpoweredMakers project needs a backend API that is async-first, offers strong type safety, and integrates well with the Python ecosystem. The choice of framework, ORM, database, package manager, linter and test runner must be made now because it lays the foundation for all future backend development.

## Decision

- **Framework:** FastAPI (Python 3.12+)
- **ORM:** SQLAlchemy 2.0 (async)
- **Database:** PostgreSQL via asyncpg
- **Cache:** Redis
- **Package manager:** uv
- **Linter/Formatter:** Ruff
- **Test runner:** pytest + pytest-asyncio

## Reasoning Chain

1. We are building an async API with strong request/response validation → framework with native async + Pydantic integration needed → FastAPI
2. FastAPI requires Python, Python ecosystem offers mature async ORM options → SQLAlchemy 2.0 with native async support (no legacy patterns) → SQLAlchemy 2.0 + asyncpg
3. Database must be ACID-compliant with good async driver support → PostgreSQL (mature, asyncpg is the fastest Python async PG driver)
4. Cache/session storage needed for future features → Redis (de facto standard, minimal operational overhead)
5. Package manager must be fast and support lockfiles → uv (10-100x faster than pip/Poetry, native lockfile, editable installs)
6. Linter + formatter must be fast and a single tool → Ruff (replaces flake8 + black + isort in one binary, 10-100x faster)
7. Test runner must natively support async → pytest + pytest-asyncio (de facto standard, extensive plugin ecosystem)

### uv vs Poetry

uv was chosen over Poetry because:
- uv is significantly faster (Rust-based, 10-100x faster than Poetry)
- uv uses standard `pyproject.toml` (no `poetry.toml`)
- uv generates a `uv.lock` that gets committed (reproducible builds)
- uv has native support for editable installs and dependency groups

### Ruff vs Black + Flake8

Ruff replaces multiple tools (flake8, black, isort, pyupgrade) in one binary:
- One configuration in `pyproject.toml` instead of multiple config files
- 10-100x faster than the combination of individual tools
- Actively maintained by Astral (same team as uv)

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Django REST Framework | Heavyweight, synchronous background, own ORM required, overkill for API-only |
| Express/NestJS (Node.js) | Team expertise is Python, no advantage over FastAPI for this project |
| Tortoise ORM | Smaller ecosystem than SQLAlchemy, less mature async support |
| MongoDB | No ACID compliance needed? Actually yes — SQLAlchemy + PostgreSQL offers more flexibility |
| Poetry | Slower than uv, more complex dependency resolution, own config format |
| pip + venv | No lockfile, no dependency groups, slow |
| Black + Flake8 + isort | Three tools instead of one, significantly slower than Ruff |

## Consequences

- **Easier:** Fast iteration with FastAPI + auto-docs, strong type safety with Pydantic + mypy, fast tooling with uv + Ruff
- **Harder:** SQLAlchemy 2.0 async has a learning curve, uv is relatively new (but maturing fast)
- **Constraints:** All backend code must be Python 3.12+, async-first, type-checked with mypy --strict, formatted with Ruff
