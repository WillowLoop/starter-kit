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
