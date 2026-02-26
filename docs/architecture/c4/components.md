# C4 Level 3 — Components

> Modules within containers. How is each container organized internally?

## Frontend Components

| Module | Path | Responsibility |
|---|---|---|
| Pages/Routes | `src/app/` | Routing, layouts, error boundaries |
| Feature Modules | `src/features/{name}/` | Colocated: components, hooks, api, types |
| UI Primitives | `src/components/ui/` | Reusable presentational components (shadcn) |
| Providers | `src/components/providers/` | Context providers (QueryProvider) |
| Shared Hooks | `src/hooks/` | Shared hooks |
| Shared Lib | `src/lib/` | Cross-feature utilities (cn, api client) |
| Shared Types | `src/types/` | Cross-feature TypeScript types only |

## Backend Components

| Module | Path | Responsibility |
|---|---|---|
| App Core | `app/` | Entry point, config |
| Feature Modules | `features/{name}/` | Colocated: router, service, repository, schema |
| Database | `shared/db/` | Connection, base models, models, migrations |
| Auth | `shared/auth/` | Authentication/authorization |
| Middleware | `shared/middleware/` | CORS, rate limiting, request logging |
| Shared Lib | `shared/lib/` | Cross-feature utilities |

## Component Diagram

```
Frontend                          Backend
┌─────────────────────┐          ┌─────────────────────┐
│                     │          │                     │
│  src/app/ ► features│  REST/   │  App  ──► Features  │
│         {colocated} │  GraphQL │        {colocated}  │
│  hooks, api, types  │ ◄──────► │  router, service,   │
│              │      │          │  repository, schema │
│  src/components/ui  │          │           │         │
│  src/lib            │          │     shared/db       │
│  src/hooks          │          │     shared/auth     │
│  src/types          │          │     shared/lib      │
│                     │          │     shared/mid…     │
│                     │          │                     │
└─────────────────────┘          └─────────────────────┘
```

## Architecture Patterns

### Frontend
- **Pattern:** Component → Hook → API Layer
- **State:** TanStack Query (server) + Zustand (client, when needed)
- **Routing:** App Router

### Backend
- **Pattern:** Router → Service → Repository (per feature, colocated)
- **Colocation:** Feature-first — router, service, repository, schema per feature
- **Injection:** Dependency Injection via FastAPI `Depends()`
- **Validation:** Schema validation at router level

## File Size Limits

See `frontend/CLAUDE.md` and `backend/CLAUDE.md` for current file limits per type.

## Related ADRs

- ADR-0001: Frontend tech stack choice
- ADR-0002: Backend tech stack choice
