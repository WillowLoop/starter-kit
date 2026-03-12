# ADR-0007: Error Tracking with Sentry

- **Status**: accepted
- **C4 Level**: L1-Context
- **Scope**: Frontend + Backend
- **Date**: 2026-03-12

## Context

The starter-kit (Next.js 16 + FastAPI) has no error tracking. Production errors are invisible unless users report them. Structlog captures backend logs but does not aggregate or alert. The platform needs an observability layer that:

1. Captures unhandled exceptions in both frontend and backend
2. Aggregates errors with deduplication and stack traces
3. Is optional — zero runtime cost when disabled (starter-kit should work without it)
4. Requires minimal configuration and maintenance

## Decision

**Sentry** as an optional, DSN-gated error tracking service for both stacks.

### Backend
- `sentry-sdk[fastapi]` — auto-instruments FastAPI, captures 5xx errors
- Init gated on `SENTRY_DSN` env var — no DSN means no Sentry overhead
- `send_default_pii=False` — no user data sent by default

### Frontend
- `@sentry/nextjs` — integrates with Next.js App Router, SSR, and client
- Init gated on `NEXT_PUBLIC_SENTRY_DSN` — no DSN means no Sentry overhead
- Source map upload disabled by default (requires `SENTRY_AUTH_TOKEN` in CI)
- Replay disabled by default (performance cost)

### Configuration
All settings via environment variables with safe defaults:
- `SENTRY_DSN` / `NEXT_PUBLIC_SENTRY_DSN` — empty = disabled
- `SENTRY_TRACES_SAMPLE_RATE` — defaults to `0` (no performance tracing)
- `SENTRY_ENVIRONMENT` — defaults to `APP_ENV` (backend) / `NODE_ENV` (frontend)

### Known Limitation
Source map upload is disabled by default. For production deployments with readable stack traces, configure `SENTRY_AUTH_TOKEN` and `SENTRY_ORG`/`SENTRY_PROJECT` in CI. This is a recommended follow-up, not a blocker.

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| GlitchTip (self-hosted) | Requires additional infrastructure to host and maintain; overkill for starter-kit |
| Bugsnag | Less Python/FastAPI support; Sentry has better open-source ecosystem |
| Logging only (structlog) | No aggregation, no alerting, no deduplication; errors get lost in log streams |
| Datadog / New Relic | Enterprise pricing; far exceeds starter-kit needs |

## Consequences

- **Easier:**
  - Production errors are visible, grouped, and alertable without user reports
  - Zero-config for development — just leave DSN empty
  - Both stacks use the same service — single dashboard for all errors
  - Sentry free tier (5k errors/month) covers starter-kit scale

- **Harder:**
  - One more external service to configure for production
  - Source map upload needs CI token setup for readable frontend traces
  - Team must monitor Sentry dashboard (or configure alert rules)

- **Constraints:**
  - `send_default_pii` must remain `False` unless explicitly opted in
  - Traces sample rate defaults to `0` — must be consciously enabled
  - Sentry SDK versions must stay compatible with Next.js and FastAPI versions

## Related ADRs

- ADR-0002: Backend Tech Stack (FastAPI, structlog for logging)
- ADR-0005: CI/CD Pipeline Architecture (source map upload would be a CI step)
- ADR-0006: Deployment Strategy (environment variables per deploy target)
