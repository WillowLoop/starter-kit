#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# init-project.sh — Transform starter-kit into a new project
# One-time script. Deletes itself after running.
# ─────────────────────────────────────────────

cd "$(dirname "$0")/.."

# ── 1a. Prerequisite checks ──────────────────

for cmd in git uv; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed. Install it first." >&2
    exit 1
  fi
done

# ── 1b. Guard against re-running ─────────────

if ! grep -qi "aipoweredmakers" CLAUDE.md 2>/dev/null; then
  echo "This project has already been initialized (no 'aipoweredmakers' found in CLAUDE.md)."
  exit 0
fi

# ── 1c. Input gathering ──────────────────────

read -rp "Project name (kebab-case, e.g. my-project): " PROJECT_NAME

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: project name cannot be empty." >&2
  exit 1
fi

if [[ ${#PROJECT_NAME} -gt 40 ]]; then
  echo "Error: project name must be at most 40 characters." >&2
  exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
  echo "Error: project name must be kebab-case (e.g. my-project)." >&2
  exit 1
fi

# Default display name: title-case from kebab-case
DEFAULT_DISPLAY=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
read -rp "Display name [$DEFAULT_DISPLAY]: " DISPLAY_NAME
DISPLAY_NAME="${DISPLAY_NAME:-$DEFAULT_DISPLAY}"

read -rp "GitHub remote URL (leave empty to skip): " REMOTE_URL

# ── 1d. Preview & confirm ────────────────────

echo ""
echo "=== Summary ==="
echo "Project name:  $PROJECT_NAME"
echo "Display name:  $DISPLAY_NAME"
if [[ -n "$REMOTE_URL" ]]; then
  echo "Remote:        $REMOTE_URL"
else
  echo "Remote:        (none)"
fi
echo ""
echo "This script will:"
echo "  - Rename 'aipoweredmakers' to '$PROJECT_NAME'"
echo "  - Rename 'AIpoweredMakers' to '$DISPLAY_NAME'"
echo "  - Regenerate backend lockfile"
echo "  - Remove example files"
echo "  - Reset git history (new repo with 1 commit)"
echo "  - Delete this script"
echo ""

read -rp "Continue? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

# ── Helper: portable sed (macOS + Linux) ─────

replace_in_file() {
  local pattern="$1"
  local file="$2"
  sed "$pattern" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# ── 1e. Rename all references ────────────────

echo ""
echo "Renaming..."

# Lowercase replacements: aipoweredmakers → project name
for file in \
  frontend/package.json \
  backend/pyproject.toml \
  backend/docker-compose.yml \
  backend/.env.example
do
  if [[ -f "$file" ]]; then
    replace_in_file "s/aipoweredmakers/${PROJECT_NAME}/g" "$file"
  fi
done

# Display name replacements: AIpoweredMakers → display name
for file in \
  CLAUDE.md \
  README.md \
  frontend/src/app/page.tsx \
  backend/app/main.py \
  backend/pyproject.toml \
  backend/README.md \
  docs/architecture/c4/context.md \
  docs/architecture/c4/containers.md \
  docs/architecture/adr/0001-frontend-tech-stack.md \
  docs/architecture/adr/0002-backend-tech-stack.md
do
  if [[ -f "$file" ]]; then
    replace_in_file "s/AIpoweredMakers/${DISPLAY_NAME}/g" "$file"
  fi
done

# Special case: layout.tsx — title and description
if [[ -f frontend/src/app/layout.tsx ]]; then
  replace_in_file "s/title: \"AIpoweredMakers\"/title: \"${DISPLAY_NAME}\"/g" frontend/src/app/layout.tsx
  replace_in_file "s/description: \"AIpoweredMakers platform\"/description: \"${DISPLAY_NAME}\"/g" frontend/src/app/layout.tsx
fi

# ── 1f. Regenerate lockfile ──────────────────

echo "Regenerating backend lockfile..."
(cd backend && uv lock)

# ── 1g. Clean up starter-kit artifacts ───────

echo "Cleaning up..."

# Remove example/plan files
rm -f docs/planning/prd/0001-example-prd.md
rm -f docs/planning/design/0001-example-design.md
rm -rf docs/planning/plans/*

# Reset todo.md to empty template
cat > docs/planning/todo.md << 'TODOEOF'
# Extension Opportunities

Ideas and opportunities for extending this project.
Larger initiatives → epic in `docs/planning/roadmap/`.

Format: `- [ ] **Title** — Description`
Optional sub-bullets for scope. Done items get a date.

## Open

## Done
TODOEOF

# Update Bootstrap Checklist in docs/README.md — replace automated steps with post-init version
if [[ -f docs/README.md ]]; then
  # Replace the checklist section using awk
  awk '
    /^## Bootstrap Checklist/ { found=1; print; next }
    found && /^When copying/ {
      print ""
      print "After running `./scripts/init-project.sh`:"
      print ""
      print "1. **`frontend/CLAUDE.md`** — Adapt for your frontend stack (or remove if not applicable)"
      print "2. **`backend/CLAUDE.md`** — Adapt for your backend stack (or remove if not applicable)"
      print "3. **`docs/architecture/c4/context.md`** — Fill in system, actors and external systems"
      print "4. **`docs/architecture/c4/containers.md`** — Document your deployment units"
      print "5. **`docs/architecture/c4/components.md`** — Document modules per container"
      print "6. **Backend `features/` structure** — Create `features/` directory for first backend feature"
      print "7. **`.claude/`** — Review agents, commands and skills; remove what doesn'\''t fit"
      print "8. **First ADR** — Document the most important architecture decision: `docs/architecture/adr/0001-*.md`"
      print "9. **`docs/planning/roadmap/overview.md`** — (optional) Add first epics to the roadmap"
      found_list=1
      next
    }
    found_list && /^###/ { found=0; found_list=0; print; next }
    found_list && /^---/ { found=0; found_list=0; print; next }
    found_list && /^[0-9]+\./ { next }
    found_list && /^$/ && !printed_blank { printed_blank=1; next }
    !found_list { print }
  ' docs/README.md > docs/README.md.tmp && mv docs/README.md.tmp docs/README.md
fi

# Self-destruct
rm -f scripts/init-project.sh

# ── 1h. Git reset ────────────────────────────

echo "Resetting git..."
rm -rf .git
git init
git add -A
git commit -m "chore: init ${DISPLAY_NAME} from starter-kit"

# ── 1i. Optional remote ─────────────────────

if [[ -n "$REMOTE_URL" ]]; then
  git remote add origin "$REMOTE_URL"
fi

# ── 1j. Next steps ──────────────────────────

echo ""
echo "=== Done! ==="
echo ""
echo "Project \"${DISPLAY_NAME}\" initialized."
echo ""
echo "Next steps:"
echo "  1. make setup              — generate .env with credentials"
echo "  2. See docs/README.md      — Bootstrap Checklist for C4, ADRs, etc."
if [[ -n "$REMOTE_URL" ]]; then
  echo "  3. git push -u origin main — push to GitHub"
fi
