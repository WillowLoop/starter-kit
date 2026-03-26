# Docker Hardening Checklist

Reference for `security-config-scan` Steps 4-5. Cross-reference with Dockerfiles and compose files.

## Dockerfile checks

| Check | What to look for | Severity | Notes |
|---|---|---|---|
| Multi-stage build | Multiple `FROM` statements | MEDIUM | Reduces image size and attack surface |
| Non-root USER | `USER` directive with non-root UID | HIGH | Prevents container root escalation |
| No secrets in build args | No `ARG` with passwords/keys | HIGH | Build args are visible in image history |
| `.dockerignore` exists | File present in service directory | MEDIUM | Prevents `.env`, `.git`, `node_modules` in image |
| Specific base tags | Not using `latest` tag | MEDIUM | Ensures reproducible builds |
| HEALTHCHECK | `HEALTHCHECK` instruction present | LOW | Enables container orchestration health monitoring |
| No COPY of secrets | No `COPY .env` or similar | HIGH | Secrets should come from runtime env, not image |
| Minimal packages | No unnecessary `apt-get install` | LOW | Reduces attack surface |

### Current project status

- Backend Dockerfile: multi-stage ✓, non-root (UID 1001) ✓
- Frontend Dockerfile: verify same patterns

### Non-root user example

```dockerfile
# SAFE — explicit non-root user
RUN adduser --disabled-password --uid 1001 appuser
USER appuser

# UNSAFE — running as root (no USER directive)
```

## Docker Compose checks

| Check | What to look for | Severity | Notes |
|---|---|---|---|
| `read_only: true` | App containers filesystem read-only | MEDIUM | Prevents runtime file modification |
| `no-new-privileges` | `security_opt: [no-new-privileges:true]` | HIGH | Prevents privilege escalation |
| `tmpfs` mounts | `/tmp` and other writable dirs as tmpfs | LOW | Allows writes without persistent storage |
| Internal networks | DB/Redis on internal-only network | HIGH | Prevents external access to data stores |
| No exposed DB ports | No `ports:` mapping for postgres/redis | HIGH | DB should only be accessible from app network |
| Resource limits | `deploy.resources.limits` defined | MEDIUM | Prevents resource exhaustion |
| No privileged mode | `privileged: false` or not set | CRITICAL | Privileged = full host access |
| No host network | `network_mode: host` not used | HIGH | Host networking bypasses isolation |
| No sensitive env inline | Secrets via env_file or secrets, not inline | MEDIUM | Inline env values visible in compose file |

### Current project status

- `docker-compose.prod.yml`: `read_only: true` ✓, `no-new-privileges` ✓
- Verify: internal networks, no exposed DB ports, resource limits

### Resource limits example

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
```

## .dockerignore essentials

These files/dirs should always be in `.dockerignore`:

```
.env
.env.*
.git
.gitignore
node_modules
__pycache__
*.pyc
.venv
.mypy_cache
.pytest_cache
docker-compose*.yml
Dockerfile
README.md
docs/
.claude/
```
