# Backend

Stack: FastAPI + Python 3.12+ + PostgreSQL + SQLAlchemy 2.0
Package manager: uv
Testing: pytest + httpx

## Structure

| Path | Description |
|---|---|
| `app/` | FastAPI application (create_app factory) |
| `features/{name}/` | Router, service, repository, schema per feature |
| `shared/config.py` | Pydantic Settings (env vars) |
| `shared/db/` | Engine, session, base model, migrations |
| `shared/auth/` | Authentication/authorization |
| `shared/middleware/` | CORS, rate limiting, request logging |
| `shared/lib/` | Exception handlers, cross-feature utilities |
| `tests/` | pytest with in-memory SQLite |

## Patterns

- App factory: `create_app()` in `app/main.py`
- Router → Service → Repository (per feature, colocated)
- Dependency Injection via `Depends()`
- Pydantic v2 for request/response validation
- Async-first: `async def` for all endpoints
- Alembic for database migrations

## File limits

| Type | Max lines |
|---|---|
| Router | 500 |
| Service | 300 |
| Repository | 200 |

## Rules

- Feature NEVER imports from another feature → shared/
- Service never calls SQLAlchemy directly — via repository
- No business logic in routers
- Strict type hints: `mypy --strict`
- Ruff for linting + formatting
- Config via `pydantic-settings` (environment variables)
- Logging via `structlog` (structured, no print statements)
- New env vars → update `.env.example` with placeholder
- Local dev: bind `localhost` | Docker/production: bind `0.0.0.0`
- Never `0.0.0.0` in local dev
- No raw SQL — use SQLAlchemy ORM
