.PHONY: help setup init test lint
.DEFAULT_GOAL := help

help:  ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'

init:  ## Transform starter-kit into a new project
	./scripts/init-project.sh

setup:  ## First-time project setup
	cd backend && $(MAKE) setup
	pre-commit install

# For dev servers, run backend and frontend in separate terminals:
#   Terminal 1: cd backend && make dev
#   Terminal 2: cd frontend && pnpm dev

test:  ## Run all tests
	cd backend && $(MAKE) test
	cd frontend && pnpm test

lint:  ## Run all linters
	cd backend && $(MAKE) lint
	cd frontend && pnpm lint
