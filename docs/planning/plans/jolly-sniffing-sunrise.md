# Plan: Local Docker Compose Override (build locally without GHCR)

## Problem Statement

`docker-compose.prod.yml` references GHCR images (`ghcr.io/.../backend:${BACKEND_IMAGE_TAG}`). Developers need to build and run the full production-like stack locally without GHCR access — for testing Docker builds, validating compose config, or running the prod stack before pushing.

The existing `docker-compose.yml` is dev-only (backend + postgres, hot reload, no frontend). There's no way to test the production Docker setup locally.

## Proposed Solution

Create a Docker Compose override file that layers on top of `docker-compose.prod.yml`, replacing GHCR `image:` references with local `build:` directives. This is the standard Compose pattern — no duplication of service config.

## Implementation Steps

### Step 1: Create `backend/docker-compose.local.yml`

**File:** `backend/docker-compose.local.yml` (new)

A Compose override that:
- Replaces GHCR `image:` with local `build:` for both `app` and `frontend`
- Overrides the `traefik-public` network from `external: true` to `external: false` (no Traefik needed locally)
- Exposes ports directly (backend 8000, frontend 3000)
- Clears Traefik labels
- Relaxes `read_only` constraint for easier local debugging

Usage: `docker compose -f docker-compose.prod.yml -f docker-compose.local.yml up --build`

```yaml
# Local override — build from source instead of pulling GHCR images.
# Usage: docker compose -f docker-compose.prod.yml -f docker-compose.local.yml up --build
#
# Requires env vars (auto-loaded from backend/.env):
#   SECRET_KEY, POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB
# Auto-set by this override (no need to configure):
#   DATABASE_URL, REDIS_URL
# Set by Makefile target (satisfies prod compose :? checks):
#   BACKEND_IMAGE_TAG, FRONTEND_IMAGE_TAG, DOCKER_IMAGE_ORG, DOCKER_IMAGE_REPO

networks:
  public-network:
    name: traefik-public
    external: false

services:
  app:
    build:
      context: .
    image: starter-kit-backend:local
    read_only: false
    environment:
      DATABASE_URL: postgresql+asyncpg://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@postgres:5432/${POSTGRES_DB:-aipoweredmakers}
      REDIS_URL: redis://redis:6379/0
    ports:
      - "8000:8000"
    labels:
      traefik.enable: "false"

  frontend:
    build:
      context: ../frontend
      args:
        - NEXT_PUBLIC_API_URL=http://localhost:8000
    image: starter-kit-frontend:local
    read_only: false
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8000
    ports:
      - "3000:3000"
    labels:
      traefik.enable: "false"
```

**Critical: IMAGE_TAG variables.** The prod file uses `${BACKEND_IMAGE_TAG:?...}` and `${FRONTEND_IMAGE_TAG:?...}` — Compose resolves these from shell environment *before* merging overrides. Setting them in the service `environment:` block does NOT satisfy this. The Makefile target must export these as shell vars before running compose (see Step 2).

Design decisions (updated after staff review):
- **`DATABASE_URL` override**: The dev `.env` uses `@localhost:5432` but inside Docker the postgres service is reachable as `@postgres:5432`. The override sets this explicitly using compose variable substitution from the existing `POSTGRES_*` vars, so the host `.env` doesn't need changing.
- **`REDIS_URL` set explicitly**: Uses the `redis` service name. Redis is `Optional` in the app config (`shared/config.py:16`) so it won't crash without it, but setting it avoids warnings.
- **`traefik.enable: "false"`** instead of `labels: []`: Prod compose uses labels as a mapping (key-value). Compose merge won't reliably clear a mapping with `[]`. Setting `traefik.enable: "false"` disables Traefik routing cleanly.
- **`NEXT_PUBLIC_API_URL` as build arg**: Next.js inlines `NEXT_PUBLIC_*` at build time. The override passes it as a build arg so `docker compose up --build` bakes the correct local URL into the frontend. Also set at runtime for completeness.
- **`image:` alongside `build:`**: Compose uses `image:` as the tag for the locally built image, preventing unnamed image clutter.
- **`read_only: false`**: Overrides prod's `read_only: true` for easier local debugging.
- **`external: false`**: Docker creates the network instead of requiring a pre-existing Traefik network.
- **GHCR env vars bypassed**: `build:` takes priority over `image:` in Compose merge, so `BACKEND_IMAGE_TAG` etc. are not needed.

### Step 2: Add Makefile targets

**File:** `Makefile` (modify)

Append `docker-local docker-local-stop` to the existing `.PHONY` on line 1. Add two targets after `dev-stop` (line 60):

```makefile
docker-local:  ## Build & run full stack locally (no GHCR)
	cd backend && BACKEND_IMAGE_TAG=local FRONTEND_IMAGE_TAG=local DOCKER_IMAGE_ORG=local DOCKER_IMAGE_REPO=local \
		docker compose -f docker-compose.prod.yml -f docker-compose.local.yml up --build

docker-local-stop:  ## Stop local Docker stack
	cd backend && BACKEND_IMAGE_TAG=local FRONTEND_IMAGE_TAG=local DOCKER_IMAGE_ORG=local DOCKER_IMAGE_REPO=local \
		docker compose -f docker-compose.prod.yml -f docker-compose.local.yml down
```

The inline env vars (`BACKEND_IMAGE_TAG=local` etc.) satisfy the `:?` required-variable checks in the prod compose file. The actual values don't matter because the local override's `build:` + `image:` override the GHCR `image:` reference.

### Step 3: Update frontend Dockerfile to accept NEXT_PUBLIC_API_URL build arg

**File:** `frontend/Dockerfile` (modify)

Add `ARG NEXT_PUBLIC_API_URL` before the `RUN pnpm build` line in the builder stage, so the compose override's `build.args` is picked up by Next.js at build time.

## Files Affected

| File | Action | Description |
|---|---|---|
| `backend/docker-compose.local.yml` | Create | Compose override: local builds, no GHCR, no Traefik |
| `Makefile` | Modify | Add `docker-local` + `docker-local-stop` targets |
| `frontend/Dockerfile` | Modify | Add `ARG NEXT_PUBLIC_API_URL` for build-time injection |

## Testing Strategy

1. **Config validation**: `cd backend && docker compose -f docker-compose.prod.yml -f docker-compose.local.yml config` — verify merged YAML is valid and `build:` contexts are correct
2. **Build test**: `make docker-local` — verify both images build successfully
3. **Runtime test**: After build, verify backend responds on `localhost:8000/health/live` and frontend on `localhost:3000`
4. **Env var test**: Verify it works with just the standard `backend/.env` file (no GHCR vars needed)

## Rollback Plan

Delete `backend/docker-compose.local.yml` and revert the Makefile change. No other files affected.
