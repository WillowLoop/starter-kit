PORT ?= 8000

.PHONY: setup dev start test lint format typecheck migrate revision

setup:  ## Create .env with generated credentials and project-specific DB name
	@if [ ! -f .env ]; then \
		PG_PASS=$$(python3 -c "import secrets; print(secrets.token_hex(16))") && \
		SECRET=$$(python3 -c "import secrets; print(secrets.token_urlsafe(32))") && \
		DB_NAME=$$(basename "$$(cd .. && pwd)" | tr '[:upper:]-' '[:lower:]_' | sed 's/[^a-z0-9_]//g; s/^[0-9]/db_&/') && \
		sed "s|__POSTGRES_PASSWORD__|$$PG_PASS|g;s|__SECRET_KEY__|$$SECRET|g;s|POSTGRES_DB=aipoweredmakers|POSTGRES_DB=$$DB_NAME|;s|/aipoweredmakers|/$$DB_NAME|" .env.example > .env && \
		echo "Created .env — database: $$DB_NAME, port: 5432"; \
	else \
		echo ".env already exists"; \
	fi

dev:
	uv run uvicorn app.main:app --reload --host localhost --port $(PORT)

start:
	uv run uvicorn app.main:app --host localhost --port $(PORT)

test:
	uv run pytest --cov --cov-report=term-missing

lint:
	uv run ruff check .

format:
	uv run ruff format .

typecheck:
	uv run mypy .

migrate:
	uv run alembic upgrade head

revision:
	uv run alembic revision --autogenerate -m "$(msg)"
