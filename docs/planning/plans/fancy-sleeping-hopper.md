# Auto-generate credentials in `make setup`

## Context

`backend/.env.example` contains hardcoded `postgres:postgres` credentials in `DATABASE_URL` and `POSTGRES_PASSWORD`. The root-level `make setup` calls `backend/make setup`, which does a plain `cp .env.example .env`. Anyone who doesn't change these ends up with known default credentials — a security risk if deployed as-is.

The fix: use `__PLACEHOLDER__` tokens in `.env.example` and have `make setup` auto-generate secure random values using Python's `secrets` module. No new dependencies.

Staff engineer reviewed. Critical issue (token_urlsafe in URI) and concerns (README, gitleaksignore) addressed below.

---

## Step 1: Update `.env.example` with placeholder tokens

**File: `backend/.env.example`**

```
APP_ENV=development
APP_DEBUG=false
DATABASE_URL=postgresql+asyncpg://postgres:__POSTGRES_PASSWORD__@localhost:5432/aipoweredmakers
REDIS_URL=redis://localhost:6379/0
CORS_ORIGINS=http://localhost:3000
SECRET_KEY=__SECRET_KEY__
LOG_LEVEL=DEBUG

# Docker Compose (postgres service)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=__POSTGRES_PASSWORD__
POSTGRES_DB=aipoweredmakers
```

- `__POSTGRES_PASSWORD__` appears twice (`DATABASE_URL` + `POSTGRES_PASSWORD`) — same value, one `sed` pass with `/g`
- `__SECRET_KEY__` replaces empty value + manual generation comment (now auto-generated)
- `POSTGRES_USER=postgres` stays — username, not a secret
- Remove the `# Generate with: python -c ...` comment (no longer needed)

---

## Step 2: Update `make setup` to generate credentials

**File: `backend/Makefile`** — replace the `setup` target (lines 3-4):

```makefile
setup:  ## Create .env with generated credentials
	@if [ ! -f .env ]; then \
		PG_PASS=$$(python3 -c "import secrets; print(secrets.token_hex(16))") && \
		SECRET=$$(python3 -c "import secrets; print(secrets.token_urlsafe(32))") && \
		sed "s|__POSTGRES_PASSWORD__|$$PG_PASS|g;s|__SECRET_KEY__|$$SECRET|g" .env.example > .env && \
		echo "Created .env with generated credentials"; \
	else \
		echo ".env already exists"; \
	fi
```

Key details:
- **`token_hex(16)`** for PG password — produces only `[0-9a-f]` (32 chars, 128 bits). Safe for embedding in DATABASE_URL without escaping. (`token_urlsafe` produces `-` and `_` which could break URI parsing.)
- **`token_urlsafe(32)`** for SECRET_KEY — 43 chars, 256 bits. Not embedded in a URL, so `-`/`_` are fine.
- `sed "..." .env.example > .env` — reads template, writes new file (no `-i` = cross-platform macOS + Linux)
- `$$` in Makefile escapes to `$` in shell
- Idempotent: skips if `.env` already exists

---

## Step 3: Update README

**File: `backend/README.md`**

Line 16: remove `# Pas SECRET_KEY aan in .env (zie comment in bestand)` — credentials are now auto-generated.

Line 37: change `Kopieer .env.example naar .env (eerste keer)` → `Genereer .env met random credentials (eerste keer)`

---

## Step 4: Clean up `.gitleaksignore`

**File: `.gitleaksignore`**

After step 1, `.env.example` no longer contains real credentials — only `__PLACEHOLDER__` tokens. Test whether gitleaks still triggers on the new content. If it does not, remove the `backend/.env.example` entry. If it still triggers on the placeholder pattern, keep it but add a comment explaining why.

---

## Files Affected

| File | Change |
|------|--------|
| `backend/.env.example` | Replace `postgres:postgres` and empty `SECRET_KEY=` with `__PLACEHOLDER__` tokens |
| `backend/Makefile` | `setup` target: `cp` → `sed` + `python3 secrets` auto-generation |
| `backend/README.md` | Update lines 16 and 37 to reflect auto-generation |
| `.gitleaksignore` | Remove `backend/.env.example` entry if gitleaks no longer triggers |

---

## Verification

1. `cd backend && rm -f .env && make setup && cat .env` — credentials are random hex/urlsafe tokens
2. `grep '__' backend/.env` — no unreplaced placeholders remain
3. `make setup` again — prints ".env already exists" (idempotent)
4. `cd backend && uv run pytest` — 25 tests pass (conftest.py overrides env vars)
5. Root-level `make setup` — calls backend setup + pre-commit install
6. `pre-commit run --all-files` — gitleaks and env sync hooks pass
