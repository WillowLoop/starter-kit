# API Rules

- Consistent response shape: FastAPI returns `{ data, error }` pattern; frontend `apiFetch` in `lib/api.ts` throws on non-2xx
- Always return appropriate HTTP status codes — never 200 for errors
- Validate input: Zod on frontend (React Hook Form), Pydantic on backend
- Frontend API calls go through `lib/api.ts` — never raw `fetch()` in components
- REST conventions: `GET /items`, `POST /items`, `GET /items/{id}`, `PUT /items/{id}`, `DELETE /items/{id}`
