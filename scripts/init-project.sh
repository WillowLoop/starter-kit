#!/usr/bin/env bash
set -euo pipefail

# Prompt for names
read -rp "Project name (kebab-case, e.g. my-project): " PROJECT_NAME
read -rp "Display name (e.g. My Project): " DISPLAY_NAME

# Validate input
if [[ -z "$PROJECT_NAME" || -z "$DISPLAY_NAME" ]]; then
  echo "Error: Both project name and display name are required." >&2
  exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: Project name must be kebab-case (lowercase letters, numbers, hyphens)." >&2
  exit 1
fi

# Derive variants
LOWER_NAME="${PROJECT_NAME//-/}"  # myproject (no hyphens, for DB names)

# Platform-aware sed in-place
if [[ "$(uname)" == "Darwin" ]]; then
  sedi() { sed -i '' "$@"; }
else
  sedi() { sed -i "$@"; }
fi

echo "Renaming project to: ${DISPLAY_NAME} (${PROJECT_NAME})"
echo ""

# Frontend
sedi "s|aipoweredmakers-frontend|${PROJECT_NAME}-frontend|g" frontend/package.json
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" frontend/src/app/layout.tsx
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" frontend/src/app/page.tsx

# Backend
sedi "s|aipoweredmakers-backend|${PROJECT_NAME}-backend|g" backend/pyproject.toml
sedi "s|AIpoweredMakers|${DISPLAY_NAME}|g" backend/pyproject.toml
sedi "s|AIpoweredMakers API|${DISPLAY_NAME} API|g" backend/app/main.py
sedi "s|/aipoweredmakers|/${LOWER_NAME}|g" backend/.env.example
sedi "s|aipoweredmakers|${LOWER_NAME}|g" backend/.env.example
sedi "s|aipoweredmakers|${LOWER_NAME}|g" backend/docker-compose.yml

# Root docs
sedi "s|# AIpoweredMakers|# ${DISPLAY_NAME}|g" CLAUDE.md
sedi "s|# AIpoweredMakers|# ${DISPLAY_NAME}|g" README.md

echo "Done! Next steps:"
echo "  1. Review and update ADRs in docs/architecture/adr/"
echo "  2. Update docs/architecture/c4/ system descriptions"
echo "  3. Remove the 'init' target from the root Makefile"
echo "  4. Run: cd backend && uv lock"
echo "  5. Run: make setup"
