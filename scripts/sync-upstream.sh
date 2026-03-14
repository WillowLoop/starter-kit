#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# sync-upstream.sh — Sync shared infrastructure from starter-kit
# Usage: ./scripts/sync-upstream.sh [--init|--dry-run] [--starter-kit-ref <ref>]
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

CONFIG_FILE=".starter-kit.yml"
MANIFEST_FILE=".starter-kit-files"
IGNORE_FILE=".starter-kit-ignore"
REMOTE_NAME="starter-kit"
DEFAULT_BRANCH="main"

# ── Parse arguments ──────────────────────────

MODE="sync"
TARGET_REF=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --init)     MODE="init"; shift ;;
    --dry-run)  MODE="dry-run"; shift ;;
    --starter-kit-ref) TARGET_REF="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ── Helpers ──────────────────────────────────

info()  { echo "==> $*"; }
warn()  { echo "WARNING: $*" >&2; }
error() { echo "ERROR: $*" >&2; exit 1; }

# Read a value from the YAML config (simple key: value parsing)
read_config() {
  local key="$1"
  grep "^${key}:" "$CONFIG_FILE" 2>/dev/null | sed "s/^${key}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']$//'
}

# Write/update a value in the YAML config
write_config() {
  local key="$1" value="$2"
  if grep -q "^${key}:" "$CONFIG_FILE" 2>/dev/null; then
    sed "s|^${key}:.*|${key}: ${value}|" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  else
    echo "${key}: ${value}" >> "$CONFIG_FILE"
  fi
}

# Check if a path is in the ignore file
is_ignored() {
  local path="$1"
  [[ ! -f "$IGNORE_FILE" ]] && return 1
  while IFS= read -r pattern; do
    pattern="${pattern%%#*}"    # strip comments
    pattern="${pattern// /}"    # strip whitespace
    [[ -z "$pattern" ]] && continue
    # Simple prefix match (handles both files and directories)
    if [[ "$path" == "$pattern" || "$path" == "$pattern"* ]]; then
      return 0
    fi
  done < "$IGNORE_FILE"
  return 1
}

# Validate JSON files
validate_json() {
  local file="$1"
  if [[ -f "$file" ]]; then
    if ! python3 -m json.tool "$file" > /dev/null 2>&1; then
      warn "Invalid JSON after sync: $file (needs manual repair)"
      return 1
    fi
  fi
  return 0
}

# Validate YAML files
validate_yaml() {
  local file="$1"
  if [[ -f "$file" ]]; then
    if ! python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" "$file" 2>/dev/null; then
      # Try without PyYAML — just check it's not obviously broken
      warn "Could not validate YAML: $file (check manually)"
      return 1
    fi
  fi
  return 0
}

# ── Self-update ──────────────────────────────

self_update() {
  if [[ "$MODE" == "init" ]]; then
    return  # skip self-update during init
  fi

  if ! git remote get-url "$REMOTE_NAME" &>/dev/null; then
    return  # no remote yet, skip
  fi

  local remote_script
  remote_script=$(git show "${REMOTE_NAME}/${DEFAULT_BRANCH}:scripts/sync-upstream.sh" 2>/dev/null) || return 0
  local local_script
  local_script=$(cat "$SCRIPT_DIR/sync-upstream.sh")

  if [[ "$remote_script" != "$local_script" ]]; then
    info "Updating sync script from upstream..."
    echo "$remote_script" > "$SCRIPT_DIR/sync-upstream.sh"
    chmod +x "$SCRIPT_DIR/sync-upstream.sh"
    exec bash "$SCRIPT_DIR/sync-upstream.sh" "$@"
  fi
}

# ── Mode: init ───────────────────────────────

do_init() {
  info "Initializing starter-kit sync..."

  # Check if already initialized
  if [[ -f "$CONFIG_FILE" ]]; then
    local existing_repo
    existing_repo=$(read_config "source_repo")
    info "Already initialized (source: $existing_repo)"
    info "To re-initialize, delete $CONFIG_FILE first."
    return 0
  fi

  # Get repo URL
  local repo_url=""
  if git remote get-url "$REMOTE_NAME" &>/dev/null; then
    repo_url=$(git remote get-url "$REMOTE_NAME")
    info "Using existing remote '$REMOTE_NAME': $repo_url"
  else
    read -rp "Starter-kit repo URL: " repo_url
    if [[ -z "$repo_url" ]]; then
      error "Repo URL is required."
    fi
    git remote add "$REMOTE_NAME" "$repo_url"
    info "Added remote '$REMOTE_NAME': $repo_url"
  fi

  # Fetch
  info "Fetching from $REMOTE_NAME..."
  git fetch "$REMOTE_NAME"

  # Use root commit so first sync shows ALL shared file changes
  local head_sha
  head_sha=$(git rev-list --max-parents=0 "${REMOTE_NAME}/${DEFAULT_BRANCH}" | head -1)

  # Create config
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  cat > "$CONFIG_FILE" << EOF
# Starter-kit sync tracking — do not edit manually
source_repo: ${repo_url}
last_synced_commit: ${head_sha}
last_synced_at: "${timestamp}"
EOF

  info "Created $CONFIG_FILE (synced to $head_sha)"
  info ""
  info "Next steps:"
  info "  make sync-upstream-dry   — preview changes"
  info "  make sync-upstream       — apply changes on a branch"
}

# ── Mode: sync / dry-run ─────────────────────

do_sync() {
  local dry_run=false
  [[ "$MODE" == "dry-run" ]] && dry_run=true

  # Check config exists
  [[ ! -f "$CONFIG_FILE" ]] && error "No $CONFIG_FILE found. Run 'make sync-upstream-init' first."

  # Check clean working tree (skip for dry-run)
  if [[ "$dry_run" == false ]]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
      error "Working tree is dirty. Commit or stash changes first."
    fi
    if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
      warn "Untracked files present. They won't affect sync but consider committing them."
    fi
  fi

  # Read config
  local source_repo last_synced
  source_repo=$(read_config "source_repo")
  last_synced=$(read_config "last_synced_commit")

  [[ -z "$source_repo" ]] && error "No source_repo in $CONFIG_FILE"
  [[ -z "$last_synced" ]] && error "No last_synced_commit in $CONFIG_FILE"

  # Ensure remote exists
  if ! git remote get-url "$REMOTE_NAME" &>/dev/null; then
    info "Adding remote '$REMOTE_NAME': $source_repo"
    git remote add "$REMOTE_NAME" "$source_repo"
  fi

  # Fetch
  info "Fetching from $REMOTE_NAME..."
  git fetch "$REMOTE_NAME"

  # Determine target ref
  local target_ref="${TARGET_REF:-${REMOTE_NAME}/${DEFAULT_BRANCH}}"
  local target_sha
  target_sha=$(git rev-parse "$target_ref" 2>/dev/null) || error "Could not resolve ref: $target_ref"

  # Validate last_synced_commit exists
  if ! git cat-file -e "$last_synced" 2>/dev/null; then
    warn "last_synced_commit ($last_synced) not found in history."
    warn "This may happen after a force-push on the starter-kit."
    warn ""
    warn "Fallback options:"
    warn "  1. Use overwrite-only mode (all shared files replaced from upstream)"
    warn "  2. Abort and manually update last_synced_commit in $CONFIG_FILE"
    warn ""
    read -rp "Use overwrite-only mode? [y/N] " fallback_confirm
    if [[ "$fallback_confirm" != "y" && "$fallback_confirm" != "Y" ]]; then
      error "Aborted. Update last_synced_commit in $CONFIG_FILE manually."
    fi
    last_synced=""  # empty = overwrite-only mode
  fi

  # Check if already up to date
  if [[ -n "$last_synced" && "$last_synced" == "$target_sha" ]]; then
    info "Already up to date (at $target_sha)."
    return 0
  fi

  # Read manifest from upstream
  local manifest
  manifest=$(git show "${target_ref}:${MANIFEST_FILE}" 2>/dev/null) || error "No $MANIFEST_FILE found in upstream at $target_ref"

  # Parse manifest into arrays
  local -a overwrite_paths=()
  local -a merge_paths=()

  while IFS= read -r line; do
    line="${line%%#*}"        # strip comments
    line="${line#"${line%%[![:space:]]*}"}"  # trim leading whitespace
    line="${line%"${line##*[![:space:]]}"}"  # trim trailing whitespace
    [[ -z "$line" ]] && continue

    local strategy path
    strategy="${line%% *}"
    path="${line#* }"

    # Check ignore list
    if is_ignored "$path"; then
      continue
    fi

    case "$strategy" in
      overwrite) overwrite_paths+=("$path") ;;
      merge)     merge_paths+=("$path") ;;
      *) warn "Unknown strategy '$strategy' for path '$path', skipping." ;;
    esac
  done <<< "$manifest"

  # Expand directory paths to individual files for diff
  expand_paths() {
    local ref="$1"
    shift
    local -a paths=("$@")
    local -a expanded=()

    for path in "${paths[@]}"; do
      if [[ "$path" == */ ]]; then
        # Directory — list all files under it from the ref
        while IFS= read -r file; do
          expanded+=("$file")
        done < <(git ls-tree -r --name-only "$ref" -- "$path" 2>/dev/null)
      else
        # Single file — check it exists in either ref or locally
        if git ls-tree -r --name-only "$ref" -- "$path" | grep -q "^${path}$" 2>/dev/null; then
          expanded+=("$path")
        elif [[ -f "$path" ]]; then
          expanded+=("$path")
        fi
      fi
    done

    printf '%s\n' "${expanded[@]}"
  }

  # Get expanded file lists
  local -a overwrite_files=()
  local -a merge_files=()

  while IFS= read -r f; do
    [[ -n "$f" ]] && overwrite_files+=("$f")
  done < <(expand_paths "$target_ref" "${overwrite_paths[@]}")

  while IFS= read -r f; do
    [[ -n "$f" ]] && merge_files+=("$f")
  done < <(expand_paths "$target_ref" "${merge_paths[@]}")

  local all_files=("${overwrite_files[@]}" "${merge_files[@]}")

  if [[ ${#all_files[@]} -eq 0 ]]; then
    info "No shared files found to sync."
    return 0
  fi

  # Generate diff for preview
  if [[ -n "$last_synced" ]]; then
    info "Changes from $last_synced to $target_sha:"
    info ""

    local has_changes=false

    # Check for changes in shared files
    for file in "${all_files[@]}"; do
      if ! git diff --quiet "${last_synced}..${target_sha}" -- "$file" 2>/dev/null; then
        has_changes=true
        break
      fi
    done

    if [[ "$has_changes" == false ]]; then
      info "No changes in shared files between $last_synced and $target_sha."
      return 0
    fi

    # Show diff stat
    git diff --stat "${last_synced}..${target_sha}" -- "${all_files[@]}" 2>/dev/null || true
    echo ""
  else
    info "Overwrite-only mode — all shared files will be replaced from upstream."
    info "Files: ${#all_files[@]} total"
    echo ""
  fi

  # Dry-run stops here
  if [[ "$dry_run" == true ]]; then
    info "Dry run complete. No changes made."
    info ""
    info "Overwrite files (${#overwrite_files[@]}):"
    for f in "${overwrite_files[@]}"; do echo "  [overwrite] $f"; done
    info "Merge files (${#merge_files[@]}):"
    for f in "${merge_files[@]}"; do echo "  [merge]     $f"; done
    info ""
    info "Run 'make sync-upstream' to apply."
    return 0
  fi

  # Create branch
  local short_sha="${target_sha:0:7}"
  local branch_name="chore/sync-upstream-${short_sha}"
  info "Creating branch: $branch_name"
  git checkout -B "$branch_name"

  # Apply overwrite files
  local -a conflict_files=()
  local -a deleted_files=()

  if [[ ${#overwrite_files[@]} -gt 0 ]]; then
    info "Applying overwrite files (${#overwrite_files[@]})..."
    for file in "${overwrite_files[@]}"; do
      # Check if file exists in target ref
      if git ls-tree -r --name-only "$target_ref" -- "$file" | grep -q "^${file}$" 2>/dev/null; then
        mkdir -p "$(dirname "$file")"
        git show "${target_ref}:${file}" > "$file"
        git add "$file"
      else
        # File was deleted in upstream
        if [[ -f "$file" ]]; then
          git rm "$file" 2>/dev/null || rm -f "$file"
          deleted_files+=("$file")
        fi
      fi
    done
  fi

  # Handle overwrite directories — also delete files that exist locally but not in upstream
  for path in "${overwrite_paths[@]}"; do
    if [[ "$path" == */ ]]; then
      # Find local files in this directory that don't exist in upstream
      if [[ -d "$path" ]]; then
        while IFS= read -r local_file; do
          if ! git ls-tree -r --name-only "$target_ref" -- "$local_file" | grep -q "^${local_file}$" 2>/dev/null; then
            git rm "$local_file" 2>/dev/null || rm -f "$local_file"
            deleted_files+=("$local_file")
          fi
        done < <(git ls-files -- "$path" 2>/dev/null)
      fi
    fi
  done

  # Apply merge files
  if [[ ${#merge_files[@]} -gt 0 ]]; then
    info "Applying merge files (${#merge_files[@]})..."
    for file in "${merge_files[@]}"; do
      if [[ -z "$last_synced" ]]; then
        # Overwrite-only fallback mode
        if git ls-tree -r --name-only "$target_ref" -- "$file" | grep -q "^${file}$" 2>/dev/null; then
          mkdir -p "$(dirname "$file")"
          git show "${target_ref}:${file}" > "$file"
          git add "$file"
        fi
        continue
      fi

      # Check if file changed in upstream
      if git diff --quiet "${last_synced}..${target_sha}" -- "$file" 2>/dev/null; then
        continue  # no upstream changes
      fi

      # Check if file exists locally
      if [[ ! -f "$file" ]]; then
        # File doesn't exist locally but changed in upstream
        if git ls-tree -r --name-only "$target_ref" -- "$file" | grep -q "^${file}$" 2>/dev/null; then
          mkdir -p "$(dirname "$file")"
          git show "${target_ref}:${file}" > "$file"
          git add "$file"
        fi
        continue
      fi

      # Check if file was modified locally (compare against last_synced version)
      local local_differs=false
      if git cat-file -e "${last_synced}:${file}" 2>/dev/null; then
        if ! git diff --quiet "${last_synced}" -- "$file" 2>/dev/null; then
          local_differs=true
        fi
      else
        local_differs=true  # file didn't exist at last sync, so it's "different"
      fi

      if [[ "$local_differs" == false ]]; then
        # Only upstream changed — safe to checkout directly
        git show "${target_ref}:${file}" > "$file"
        git add "$file"
      else
        # Both sides changed — use 3-way merge via git apply
        local patch
        patch=$(git diff "${last_synced}..${target_sha}" -- "$file" 2>/dev/null) || true
        if [[ -n "$patch" ]]; then
          if echo "$patch" | git apply --3way 2>/dev/null; then
            git add "$file"
          else
            conflict_files+=("$file")
            git add "$file" 2>/dev/null || true
          fi
        fi
      fi
    done
  fi

  # Post-sync validation
  info "Validating synced files..."
  local -a invalid_files=()

  for file in "${all_files[@]}"; do
    [[ ! -f "$file" ]] && continue
    case "$file" in
      *.json) validate_json "$file" || invalid_files+=("$file") ;;
      *.yml|*.yaml) validate_yaml "$file" || invalid_files+=("$file") ;;
    esac
  done

  # Update config
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  write_config "last_synced_commit" "$target_sha"
  write_config "last_synced_at" "\"$timestamp\""
  git add "$CONFIG_FILE"

  # Report
  echo ""
  if [[ ${#deleted_files[@]} -gt 0 ]]; then
    warn "Deleted files (removed in upstream):"
    for f in "${deleted_files[@]}"; do echo "  - $f"; done
    echo ""
  fi

  if [[ ${#invalid_files[@]} -gt 0 ]]; then
    warn "Files with validation warnings (check manually):"
    for f in "${invalid_files[@]}"; do echo "  - $f"; done
    echo ""
  fi

  if [[ ${#conflict_files[@]} -gt 0 ]]; then
    warn "Files with merge conflicts (resolve manually):"
    for f in "${conflict_files[@]}"; do echo "  - $f"; done
    echo ""
    info "Resolve conflicts, then:"
    info "  git add <resolved files>"
    info "  git commit"
  else
    # Commit
    git commit -m "$(cat <<EOF
chore: sync shared infrastructure from starter-kit

Synced to: ${target_sha}
Strategy: overwrite (${#overwrite_files[@]} files), merge (${#merge_files[@]} files)
EOF
    )"
    info "Committed sync to branch: $branch_name"
  fi

  info ""
  info "Next steps:"
  info "  1. Review changes: git diff main..HEAD"
  info "  2. Push and create PR: git push -u origin $branch_name"
}

# ── Main ─────────────────────────────────────

# Self-update (pass original args for re-exec)
self_update "$@"

case "$MODE" in
  init)    do_init ;;
  dry-run) do_sync ;;
  sync)    do_sync ;;
esac
