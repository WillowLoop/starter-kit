<!-- EXAMPLE: Remove this file when cloning the starter-kit -->

# Design: User Registration & Onboarding

- **Status**: approved
- **PRD**: [PRD 0001 — User Registration & Onboarding](../prd/0001-example-prd.md)
- **Owner**: Tech Lead
- **Date**: 2026-01-20

## Overview

Implementation of registration (email/password), email verification, password reset and a 3-step onboarding wizard. Builds on the existing FastAPI backend and Next.js frontend.

## Architecture

Registration and auth run as part of the `auth` feature module in the backend (see [containers.md](../../architecture/c4/containers.md)). The frontend uses a multi-step form component.

```
Frontend (Next.js)          Backend (FastAPI)          External
┌─────────────────┐        ┌─────────────────┐       ┌──────────┐
│ Register form   │───────▶│ POST /auth/      │──────▶│ SendGrid │
│ Onboarding wiz  │        │   register       │       │ (email)  │
│ Reset form      │        │ POST /auth/verify │       └──────────┘
└─────────────────┘        │ POST /auth/reset  │
                           │ GET  /onboarding  │
                           └─────────────────┘
```

## Detailed Design

### Data Model

| Table | Field | Type | Description |
|---|---|---|---|
| `users` | `id` | UUID | Primary key |
| `users` | `email` | VARCHAR(255) | Unique, indexed |
| `users` | `password_hash` | VARCHAR(255) | bcrypt hash |
| `users` | `email_verified` | BOOLEAN | Default false |
| `users` | `created_at` | TIMESTAMP | Auto-generated |
| `onboarding_state` | `user_id` | UUID | FK to users |
| `onboarding_state` | `step` | INTEGER | Current step (1-3) |
| `onboarding_state` | `completed` | BOOLEAN | Default false |

### API Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/auth/register` | Create account |
| POST | `/auth/verify` | Email verification with token |
| POST | `/auth/reset-request` | Request password reset |
| POST | `/auth/reset-confirm` | Set new password |
| GET | `/onboarding/state` | Get current onboarding step |
| PUT | `/onboarding/step` | Complete onboarding step |

## Dependencies

| Dependency | Type | Description |
|---|---|---|
| SendGrid | External | Email sending (verification, reset) |
| bcrypt | Internal | Password hashing |
| JWT (PyJWT) | Internal | Token generation for verification and reset links |

## Test Strategy

- **Unit tests**: Registration validation, password hashing, token generation
- **Integration tests**: Full registration flow (register → verify → login)
- **E2E tests**: Onboarding wizard walkthrough in browser
- **Acceptance criteria**: Registration completion > 80%, onboarding completion > 60%

## Migration & Rollout

1. Database migration: extend `users` table, create `onboarding_state` table
2. Deploy backend endpoints (feature flag: `ENABLE_REGISTRATION`)
3. Deploy frontend forms behind the same feature flag
4. Configure email templates in SendGrid
5. Activate feature flag, monitor error rates
6. **Rollback**: Deactivate feature flag, endpoints return 503

## Open Issues

- Rate limiting strategy for `/auth/register` (per IP or per email?)
- Token expiry time for verification links (24h or 48h?)
