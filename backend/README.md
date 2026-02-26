# Backend — AIpoweredMakers API

FastAPI backend with SQLAlchemy 2.0 (async), PostgreSQL and Redis.

## Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) (package manager)
- Docker + Docker Compose (for PostgreSQL and Redis)

## Quick Start

```bash
# First time: configure environment
make setup

# Install dependencies
uv sync

# Start PostgreSQL and Redis
docker compose up -d postgres redis

# Run database migrations
make migrate

# Start development server (hot reload)
make dev
```

The API runs on `http://localhost:8000`. Swagger UI is available at `http://localhost:8000/docs` (development only).

## Scripts

| Command | Description |
|---|---|
| `make setup` | Generate `.env` with random credentials (first time) |
| `make dev` | Development server with hot reload |
| `make start` | Production server |
| `make test` | Run tests (no Docker needed) |
| `make lint` | Linting with Ruff |
| `make format` | Format code with Ruff |
| `make typecheck` | Type checking with mypy |
| `make migrate` | Run database migrations |
| `make revision msg="description"` | Create new migration |

## Project Structure

```
backend/
├── app/                  → Entry point (main.py)
├── features/
│   ├── health/           → Health check endpoint
│   └── items/            → CRUD example (router, service, repository, schema)
├── shared/
│   ├── auth/             → Authentication dependencies
│   ├── db/               → Database engine, session, base model, migrations
│   ├── lib/              → Shared utilities (exceptions)
│   └── middleware/        → CORS, request logging
├── tests/                → pytest test suite
├── pyproject.toml        → Dependencies + tool config
├── Makefile              → Development scripts
├── Dockerfile            → Multi-stage production build
└── docker-compose.yml    → Local development services
```

## Testing

Tests run on SQLite in-memory (no Docker needed):

```bash
make test
```
