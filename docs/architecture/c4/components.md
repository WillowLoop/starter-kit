# C4 Level 3 — Components

> Modules binnen containers. Hoe is elke container intern georganiseerd?

## Frontend Components

| Module | Pad | Verantwoordelijkheid |
|---|---|---|
| Pages/Routes | `src/app/` | Routing, layouts, error boundaries |
| Feature Modules | `src/features/{name}/` | Colocated: components, hooks, api, types |
| UI Primitives | `src/components/ui/` | Herbruikbare presentatie-componenten (shadcn) |
| Providers | `src/components/providers/` | Context providers (QueryProvider) |
| Shared Hooks | `src/hooks/` | Gedeelde hooks |
| Shared Lib | `src/lib/` | Cross-feature utilities (cn, api client) |
| Shared Types | `src/types/` | Alleen cross-feature TypeScript types |

## Backend Components

| Module | Pad | Verantwoordelijkheid |
|---|---|---|
| App Core | `app/` | Entry point, config |
| Feature Modules | `features/{name}/` | Colocated: router, service, repository, schema |
| Database | `shared/db/` | Connection, base models, models, migrations |
| Auth | `shared/auth/` | Authenticatie/autorisatie |
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

## Architectuurpatronen

### Frontend
- **Pattern:** Component → Hook → API Layer
- **State:** TanStack Query (server) + Zustand (client, wanneer nodig)
- **Routing:** App Router

### Backend
- **Pattern:** Router → Service → Repository (per feature, colocated)
- **Colocation:** Feature-first — router, service, repository, schema per feature
- **Injectie:** Dependency Injection via FastAPI `Depends()`
- **Validatie:** Schema validation op router-niveau

## File Size Limieten

| Type | Max regels | Waarschuwing bij |
|---|---|---|
| Frontend Component | 200 | 150 |
| Frontend Hook | 150 | 100 |
| Frontend API module | 100 | 75 |
| Feature Router | 500 | 400 |
| Feature Service | 300 | 250 |
| Feature Repository | 200 | 150 |
| Feature Schema | 150 | 100 |

## Gerelateerde ADRs

- ADR-0001: Frontend tech stack keuze
- ADR-0002: Backend tech stack keuze
