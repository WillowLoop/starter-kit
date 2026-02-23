# Frontend

Stack: Next.js 16, TypeScript, Tailwind CSS, shadcn/ui
Package manager: pnpm | Testing: Vitest + Testing Library

## Structuur

| Pad | Beschrijving |
|---|---|
| `src/app/` | Routes, layouts, error boundaries |
| `src/components/ui/` | shadcn/ui componenten |
| `src/components/providers/` | Context providers |
| `src/features/{name}/` | Colocated: components, hooks, api, types |
| `src/hooks/` | Gedeelde hooks |
| `src/lib/` | Utilities (cn, api client) |
| `src/types/` | Cross-feature types |

## Patterns

- Server Components default, `use client` alleen voor interactiviteit
- Component → Hook → API Layer (SRP)
- TanStack Query (server state), Zustand (client state indien nodig)
- React Hook Form + Zod | shadcn/ui voor UI-componenten

## File limieten

| Type | Max regels |
|---|---|
| Component | 200 |
| Hook | 150 |
| API module | 100 |

## Regels

- Geen `fetch()` in componenten — gebruik hooks/api layer
- Mobile-first: base → `md:` → `lg:`
- Strict TypeScript: `strict: true`, geen `any`
- `noUncheckedIndexedAccess: true` — runtime guards, geen `as` casts
