---
name: security-config-scan
description: >-
  Audit infrastructure and configuration security: HTTP headers, CORS,
  Docker hardening, rate limiting, auth status, cookie security, env var
  hygiene, and SSL/TLS. Use for deployment readiness checks, configuration
  reviews, or when security-audit dispatches a config scan. Covers
  next.config.ts, FastAPI middleware, Docker compose, and PostgreSQL.
---

# Security Config Scan

Audit infrastructure and configuration for security misconfigurations.

## When to use

- Before production deployment
- After infrastructure changes
- When `security-audit` dispatches a config scan
- Standalone: `/security-config-scan`

## Known-good patterns (do NOT flag)

These patterns are already implemented correctly in this project:

- OpenAPI disabled in production: `openapi_url=None if not is_development` ✓
- Docker non-root user: UID 1001 ✓
- Docker `read_only: true` ✓
- Docker `no-new-privileges: true` ✓
- Sentry `send_default_pii=False` ✓
- Generic error messages in `unhandled_exception_handler` ✓
- `SECRET_KEY` with `min_length=32` ✓
- Rate limit default `100/minute` ✓

When scanning, verify these are still in place. If found, report as PASS. Only flag as FAIL if they have been removed or changed to an insecure value.

## Scan procedure

### Step 1: HTTP Security Headers

Read `frontend/next.config.ts` and cross-reference with `references/headers-checklist.md`.

Check for presence and correct values of:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` or `SAMEORIGIN`
- `Content-Security-Policy`
- `Referrer-Policy`
- `Permissions-Policy`
- `Cross-Origin-Opener-Policy`
- `Cross-Origin-Resource-Policy`

### Step 2: CORS Configuration

Read `backend/shared/middleware/cors.py` and `backend/shared/config.py`.

- FAIL if `allow_origins=["*"]` in production
- WARN if origins list is overly broad
- PASS if origins are explicitly configured per environment
- Verify `allow_credentials`, `allow_methods`, `allow_headers` are not overly permissive

### Step 3: OpenAPI/Swagger in Production

Read `backend/app/main.py`.

- FAIL if OpenAPI docs are accessible in production (`openapi_url` not conditionally disabled)
- PASS if `openapi_url=None` when not in development mode

### Step 4: Dockerfile Security

Read `backend/Dockerfile` and `frontend/Dockerfile`.
Cross-reference with `references/docker-checklist.md`.

Check:
- Multi-stage build used
- Non-root USER directive
- No secrets in build args
- `.dockerignore` exists
- Specific base image tags (not `latest`)
- HEALTHCHECK instruction

### Step 5: Docker Compose Security

Read `backend/docker-compose.prod.yml`.

Check:
- `read_only: true` for app containers
- `security_opt: [no-new-privileges:true]`
- `tmpfs` for writable temp directories
- Internal networks for DB/Redis
- No exposed ports for database services
- Resource limits defined

### Step 6: Auth Implementation

Read `backend/shared/auth/dependencies.py`.

- INFO if auth is stub/placeholder — note for awareness
- Check if auth middleware is applied globally or per-route
- Verify auth is not easily bypassable

### Step 7: Rate Limiting

Read `backend/shared/middleware/rate_limit.py` and check `rate_limit_default` in `backend/shared/config.py`.

- FAIL if rate limiting is disabled or not configured
- WARN if limits are too high (> 1000/minute for general endpoints)
- PASS if reasonable limits are in place
- Check auth endpoints have stricter limits

### Step 8: Environment Variable Hygiene

Read `backend/.env.example`.

- FAIL if actual secrets are committed (not placeholders)
- WARN if `SECRET_KEY` placeholder suggests weak default
- Verify `SECRET_KEY` has `min_length=32` in config validation
- Check all sensitive vars have placeholder values

### Step 9: Cookie Security

```
Grep for: set_cookie|response\.cookies in backend/**/*.py
```

- FAIL if cookies lack `Secure` flag
- FAIL if session cookies lack `HttpOnly` flag
- WARN if `SameSite` is not set or set to `None` without justification
- PASS if no cookies are set (stateless API)

### Step 10: Database SSL

```
Grep for: DATABASE_URL|postgresql in backend/**/*.py and backend/.env.example
```

- WARN if `sslmode=require` is not present in production database URL config
- PASS if SSL mode is configured or documented for production

## Severity classification

| Severity | Criteria |
|---|---|
| CRITICAL | Immediate exploitation risk in production |
| HIGH | Significant risk requiring remediation before deploy |
| MEDIUM | Configuration weakness, should be addressed |
| LOW | Best practice recommendation |
| INFO | Observation, current state documented |

## Output format

```markdown
## Config Security Scan Results

### Summary
- Critical: N | High: N | Medium: N | Low: N | Info: N

### Findings

#### [SEVERITY] Finding title
- **Category**: Headers / CORS / Docker / Auth / Rate Limiting / Env / Cookies / SSL
- **Location**: `file:line`
- **Current value**: What was found
- **Expected value**: What it should be
- **Remediation**: How to fix

### Known-Good Patterns Verified
- [List of patterns checked and confirmed in place]

### Scan Coverage
- Config files checked: N
- Categories audited: 10
```

## References

- `references/headers-checklist.md` — HTTP security headers reference
- `references/docker-checklist.md` — Docker hardening reference
