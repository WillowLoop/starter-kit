.PHONY: setup dev start test lint format typecheck migrate revision

setup:  ## Create .env with generated credentials
	@if [ ! -f .env ]; then \
		PG_PASS=$$(python3 -c "import secrets; print(secrets.token_hex(16))") && \
		SECRET=$$(python3 -c "import secrets; print(secrets.token_urlsafe(32))") && \
		sed "s|__POSTGRES_PASSWORD__|$$PG_PASS|g;s|__SECRET_KEY__|$$SECRET|g" .env.example > .env && \
		echo "Created .env with generated credentials"; \
	else \
		echo ".env already exists"; \
	fi

dev:
	uv run uvicorn app.main:app --reload --host localhost --port 8000

start:
	uv run uvicorn app.main:app --host localhost --port 8000

test:
	uv run pytest

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
