# Frontend

Stack: Next.js 16, TypeScript, Tailwind CSS, shadcn/ui
Package manager: pnpm | Testing: Vitest + Testing Library

## Structure

| Path | Description |
|---|---|
| `src/app/` | Routes, layouts, error boundaries |
| `src/components/ui/` | shadcn/ui components |
| `src/components/providers/` | Context providers |
| `src/features/{name}/` | Colocated: components, hooks, api, types |
| `src/hooks/` | Shared hooks |
| `src/lib/` | Utilities (cn, api client) |
| `src/types/` | Cross-feature types |

## Patterns

- Server Components default, `use client` only for interactivity
- Component → Hook → API Layer (SRP)
- TanStack Query (server state), Zustand (client state if needed)
- React Hook Form + Zod | shadcn/ui for UI components

## File limits

| Type | Max lines |
|---|---|
| Component | 200 |
| Hook | 150 |
| API module | 100 |

## Rules

- `features/items/` is a reference implementation that survives `make init`
- No `fetch()` in components — use hooks/api layer
- Mobile-first: base → `md:` → `lg:`
- Strict TypeScript: `strict: true`, no `any`
- `noUncheckedIndexedAccess: true` — runtime guards, no `as` casts
