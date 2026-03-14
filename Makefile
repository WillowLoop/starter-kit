.PHONY: help setup init dev test lint scaffold sync-upstream sync-upstream-dry sync-upstream-init
.DEFAULT_GOAL := help

help:  ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'

init:  ## Transform starter-kit into a new project
	./scripts/init-project.sh

setup:  ## First-time project setup
	@command -v pnpm > /dev/null 2>&1 || { echo "Error: pnpm is not installed. See https://pnpm.io/installation"; exit 1; }
	@command -v uv > /dev/null 2>&1 || { echo "Error: uv is not installed. See https://docs.astral.sh/uv/"; exit 1; }
	cd backend && $(MAKE) setup
	cd frontend && pnpm install
	pre-commit install
	pre-commit install --hook-type commit-msg

dev:  ## Start dev servers (requires two terminals)
	@command -v docker > /dev/null 2>&1 || { echo "Error: Docker is not installed. See https://docs.docker.com/get-docker/"; exit 1; }
	@if ! docker info > /dev/null 2>&1; then \
		echo "Error: Docker is not running. Start Docker Desktop first."; \
		exit 1; \
	fi
	@echo "Starting infrastructure..."
	cd backend && docker compose up -d --wait
	@echo "Running database migrations..."
	cd backend && uv run alembic upgrade head
	@echo ""
	@echo "Infrastructure ready. Start servers in separate terminals:"
	@echo "  Terminal 1:  cd backend && make dev"
	@echo "  Terminal 2:  cd frontend && pnpm dev"
	@echo ""
	@echo "Endpoints:"
	@echo "  Backend API:  http://localhost:8000/docs"
	@echo "  Frontend:     http://localhost:3000"

test:  ## Run all tests
	cd backend && $(MAKE) test
	cd frontend && pnpm test

lint:  ## Run all linters
	cd backend && $(MAKE) lint
	cd frontend && pnpm lint

scaffold:  ## Scaffold a new feature (usage: make scaffold name=projects)
	@test -n "$(name)" || { echo "Usage: make scaffold name=feature-name [singular=singular-form]"; exit 1; }
	./scripts/scaffold-feature.sh "$(name)" "$(singular)"

dev-servers:  ## Start frontend + backend on free ports
	scripts/start-dev.sh

dev-stop:  ## Stop servers started by this session
	scripts/start-dev.sh --stop

sync-upstream:  ## Sync shared infrastructure from starter-kit
	./scripts/sync-upstream.sh

sync-upstream-dry:  ## Preview starter-kit changes (no modifications)
	./scripts/sync-upstream.sh --dry-run

sync-upstream-init:  ## One-time setup for starter-kit syncing
	@if [ ! -f scripts/sync-upstream.sh ]; then \
		read -p "Starter-kit repo URL: " repo; \
		git remote add starter-kit "$$repo" 2>/dev/null || true; \
		git fetch starter-kit; \
		git show starter-kit/main:scripts/sync-upstream.sh > scripts/sync-upstream.sh; \
		chmod +x scripts/sync-upstream.sh; \
	fi
	./scripts/sync-upstream.sh --init
