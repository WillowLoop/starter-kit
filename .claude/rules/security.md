# Security Rules

- Never hardcode credentials, secrets, API keys, or passwords — read from env vars
- Never prefix secrets with `NEXT_PUBLIC_` unless truly public
- Never log sensitive data (tokens, passwords, PII)
- Backend is the security boundary: Pydantic validation + SQLAlchemy parameterized queries
- Frontend input validation (`lib/input-validation.ts`) is UX defense-in-depth, not a security boundary
- Rate limiting: slowapi (backend) + Caddy (infrastructure) — no application-level rate limiting in Next.js
- Security headers: defined once in `next.config.ts` (CSP, HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy, COOP)
- Error handling: never expose stack traces, DB errors, or file paths to clients — use `lib/error-handling.ts`
- File uploads: validate MIME type + file extension + magic bytes; 5MB default max; timestamp-based names
- All API routes validate input: Zod (frontend), Pydantic (backend)
