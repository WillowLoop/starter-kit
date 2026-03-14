# Upstream Sync Workflow

Sync shared infrastructure (CI/CD, scripts, Claude agents, Makefiles) from the starter-kit to downstream projects.

## How it works

The starter-kit contains a `.starter-kit-files` manifest that declares which files are shared. Each file has a sync strategy:

- **overwrite** — fully replaced from starter-kit (project should not customize these)
- **merge** — 3-way merge preserving project-specific changes

The sync script generates a diff between your last synced commit and the latest starter-kit, applies it on a dedicated branch, and creates a commit ready for PR review.

## Usage

### First-time setup (existing projects)

```bash
make sync-upstream-init
```

This prompts for the starter-kit repo URL, adds it as a git remote, and creates `.starter-kit.yml` to track the sync state.

### Preview changes

```bash
make sync-upstream-dry
```

Shows what would change without modifying any files. Run this first to evaluate incoming changes.

### Apply changes

```bash
make sync-upstream
```

1. Fetches latest from starter-kit
2. Creates branch `chore/sync-upstream-<sha>`
3. Applies overwrite files (full replacement) and merge files (3-way merge)
4. Validates JSON/YAML files
5. Commits if no conflicts

After running, review the branch and create a PR.

### Target a specific version

```bash
./scripts/sync-upstream.sh --starter-kit-ref kit-v0.3.0
```

## Resolving conflicts

Merge-strategy files may have conflicts if both the starter-kit and your project modified the same lines. The script reports which files have conflicts.

To resolve:

1. Open each conflicted file and resolve the `<<<<<<<` markers
2. `git add <resolved files>`
3. `git commit`

## Excluding files from sync

Create `.starter-kit-ignore` in your project root to permanently exclude paths:

```
# Don't sync these from starter-kit
docs/workflows/some-workflow.md
scripts/hooks/
```

Paths are matched by prefix — a directory path excludes everything under it.

## New projects (via `make init`)

Projects created with `make init` automatically get:
- `.starter-kit.yml` tracking file
- `starter-kit` git remote
- `scripts/sync-upstream.sh`

## Configuration

`.starter-kit.yml` tracks sync state:

```yaml
source_repo: https://github.com/org/starter-kit.git
last_synced_commit: fc6b382...
last_synced_at: "2026-03-13T10:00:00Z"
```

Do not edit manually unless recovering from a force-push (update `last_synced_commit` to a known good SHA).

## Starter-kit versioning

Tags use `kit-v` prefix (`kit-v0.1.0`, `kit-v0.2.0`) to avoid collision with release-please tags.
