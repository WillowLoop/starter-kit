.PHONY: help setup init dev test lint scaffold sync-upstream sync-upstream-dry sync-upstream-init docker-local docker-local-stop backup restore backup-verify backup-list
.DEFAULT_GOAL := help

help:  ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'

init:  ## Transform starter-kit into a new project
	./scripts/init-project.sh

setup:  ## First-time project setup
	@command -v node > /dev/null 2>&1 || { echo "Error: Node is not installed. See https://nodejs.org/"; exit 1; }
	@required=$$(cat .node-version | sed 's/\..*//'); \
	 current=$$(node -v | sed 's/v//; s/\..*//'); \
	 if [ "$$current" -lt "$$required" ]; then \
	   echo "Error: Node $$required+ required (current: $$(node -v)). Run: nvm use (or see .node-version)"; \
	   exit 1; \
	 fi
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

docker-local:  ## Build & run full stack locally (no GHCR)
	cd backend && BACKEND_IMAGE_TAG=local FRONTEND_IMAGE_TAG=local DOCKER_IMAGE_ORG=local DOCKER_IMAGE_REPO=local \
		docker compose -f docker-compose.prod.yml -f docker-compose.local.yml up --build

docker-local-stop:  ## Stop local Docker stack
	cd backend && BACKEND_IMAGE_TAG=local FRONTEND_IMAGE_TAG=local DOCKER_IMAGE_ORG=local DOCKER_IMAGE_REPO=local \
		docker compose -f docker-compose.prod.yml -f docker-compose.local.yml down

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

backup:  ## Create database backup (backups/ directory)
	scripts/backup.sh

restore:  ## Restore database from backup (usage: make restore file=backups/db-xxx.dump)
	@test -n "$(file)" || { echo "Usage: make restore file=backups/db-xxx.dump"; exit 1; }
	scripts/restore.sh "$(file)"

backup-verify:  ## Create backup and verify it restores correctly
	scripts/backup.sh --verify

backup-list:  ## List available backups
	scripts/backup.sh --list
