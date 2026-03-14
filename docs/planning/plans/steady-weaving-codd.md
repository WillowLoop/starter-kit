# Plan: Security hardening starter-kit

## Context

Security audit + staff engineer review heeft 10 verbeterpunten opgeleverd. Alle must-fixes (2-7) en should-address items (8-10) worden geimplementeerd. Item 1 (auth) en 11 (proxy) zijn deployment-scope.

---

## Wijzigingen

### 2. Token leakage in auth placeholder
**`backend/shared/auth/dependencies.py:11-12`**
- Verwijder `credentials.credentials[:8]` uit error message
- Wijzig `NotImplementedError` naar `HTTPException(501)` (lost ook item 10 deels op)

### 3. CORS expliciete methods + headers
**`backend/shared/middleware/cors.py:12-13`**
- `allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]`
- `allow_headers=["Content-Type", "Authorization"]`

### 4. OpenAPI URL disablen in productie
**`backend/app/main.py:44`**
- Voeg `openapi_url="/openapi.json" if settings.is_development else None` toe aan `create_app()`

### 5. Security headers frontend
**`frontend/next.config.ts`**
- `headers()` async functie toevoegen aan nextConfig met:
  - `Content-Security-Policy` (self + Sentry + API URL)
  - `X-Frame-Options: DENY`
  - `X-Content-Type-Options: nosniff`
  - `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`
  - `Referrer-Policy: strict-origin-when-cross-origin`

### 6. Frontend dependency vulnerabilities
- `cd frontend && pnpm update` om kwetsbare packages te updaten
- Verify met `pnpm audit`

### 7. Dockerfile uv versie pinnen
**`backend/Dockerfile:3`**
- Wijzig `ghcr.io/astral-sh/uv:latest` naar `ghcr.io/astral-sh/uv:0.10.2`

### 8. Dev docker-compose localhost binding
**`backend/docker-compose.yml:19`**
- Wijzig `"${POSTGRES_PORT:-5432}:5432"` naar `"127.0.0.1:${POSTGRES_PORT:-5432}:5432"`

### 9. SECRET_KEY minimum length
**`backend/shared/config.py`**
- Wijzig `secret_key: str = Field(min_length=1)` naar `min_length=32`

### 10. Catch-all 500 handler
**`backend/shared/lib/exceptions.py`**
- Voeg generic unhandled exception handler toe die stack traces niet lekt
- Registreer in `register_exception_handlers()`

---

## Commits

1. `fix(backend): harden auth placeholder and error handling`
   - `backend/shared/auth/dependencies.py` (HTTPException i.p.v. NotImplementedError + token removal)
   - `backend/shared/lib/exceptions.py` (catch-all 500 handler)

2. `fix(backend): restrict CORS methods/headers and hide OpenAPI in production`
   - `backend/shared/middleware/cors.py`
   - `backend/app/main.py`

3. `fix(backend): pin uv version, bind postgres to localhost, enforce SECRET_KEY length`
   - `backend/Dockerfile`
   - `backend/docker-compose.yml`
   - `backend/shared/config.py`

4. `fix(frontend): add security headers`
   - `frontend/next.config.ts`

5. `fix(frontend): update vulnerable dependencies`
   - `frontend/package.json`, `frontend/pnpm-lock.yaml`

---

## Verificatie

```bash
# Backend tests
cd backend && uv run pytest -q

# OpenAPI disabled in prod
cd backend && APP_ENV=production SECRET_KEY=$(python3 -c "import secrets;print(secrets.token_urlsafe(32))") \
  DATABASE_URL="sqlite+aiosqlite://" \
  uv run python -c "from app.main import create_app; app=create_app(); print('openapi_url:', app.openapi_url)"
# → None

# Frontend audit
cd frontend && pnpm audit

# Security headers check
cd frontend && pnpm build && pnpm start &
sleep 3 && curl -sI http://localhost:3000 | grep -iE "x-frame|content-security|strict-transport|x-content-type|referrer"
kill %1

# Frontend tests
cd frontend && pnpm test
```
