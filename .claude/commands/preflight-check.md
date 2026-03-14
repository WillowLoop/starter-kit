Before making any API or server changes, run these pre-flight checks and report results:

## 1. Python venv
Run `which python` and verify it points to the project's virtual environment (should contain this project's path). If not, warn that the wrong venv is active.

## 2. CORS config
Read `backend/shared/middleware/` and check that CORS middleware is configured. Then read the `CORS_ORIGINS` value from `backend/.env` (or `.env`). Verify the frontend origin (typically `http://localhost:3000`) is included.

## 3. API contract match
Compare the frontend API calls (look in `frontend/src/` for fetch/axios calls) with the backend route definitions (look in `backend/` for FastAPI routers). Flag any mismatches in URL paths, HTTP methods, or expected request/response shapes.

## 4. Backend dependencies
Run `pip list --format=freeze` and compare against `backend/requirements.txt` (or `pyproject.toml`). Flag any missing packages.

## 5. Frontend dependencies
Run `npm ls --depth=0` (or equivalent) in `frontend/` and check for missing or unmet peer dependencies.

Report each check as PASS or FAIL with a one-line explanation. If any check fails, suggest the fix.
