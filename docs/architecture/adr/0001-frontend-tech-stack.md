# ADR-0001: Frontend Tech Stack

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: Frontend container
- **Date**: 2026-02-11

## Context

The AIpoweredMakers project needs a frontend that is fast to develop, offers good DX, and is scalable for future features. The choice of framework, styling, component library, package manager and test runner must be made now because it lays the foundation for all future frontend development.

## Decision

- **Framework:** Next.js 16 (App Router) + TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **Package manager:** pnpm
- **Test runner:** Vitest + Testing Library
- **Dev server:** Turbopack (dev only, production builds via webpack)

## Reasoning Chain

1. We are building a web application with SEO needs and server-side rendering → SSR framework needed → Next.js or Remix
2. Next.js has the largest ecosystem, best Vercel integration and most community support → Next.js 16 with App Router
3. Styling must be utility-first for fast iteration and small bundle size → Tailwind CSS
4. Components must be accessible and customizable without vendor lock-in → shadcn/ui (copies code, no runtime dependency)
5. Package manager must be fast and strict with dependencies → pnpm (stricter node_modules structure than npm/yarn)
6. Test runner must natively support ESM/TS and be fast → Vitest

### Vitest vs `next test` (experimental)

Next.js offers experimental `next test` integration, but Vitest was chosen because:
- Vitest is faster due to native ESM and parallel test execution
- Vitest is independent of the Next.js build pipeline — tests run even if Next.js breaks
- Vitest has a stable, mature ecosystem with extensive plugin support
- `next test` is still experimental and may have breaking changes

### Turbopack scope

Turbopack is only used for the dev server (`next dev --turbopack`). Production builds use the standard webpack bundler because Turbopack for production builds is not yet stable.

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Remix | Smaller ecosystem, fewer hosting options, fewer community resources |
| Vite SPA (React) | No SSR/SSG out of the box, requires extra setup for SEO |
| Jest | Slower, requires transformers for ESM/TS, more complex configuration |
| npm | Less strict dependency resolution, slower than pnpm |
| yarn | No significant advantage over pnpm, pnpm has stricter hoisting |
| MUI / Chakra UI | Runtime CSS-in-JS overhead, vendor lock-in, less control over markup |

## Consequences

- **Easier:** Fast iteration with Tailwind + shadcn/ui, good DX with TypeScript + Vitest, easy deployment to Vercel
- **Harder:** Next.js App Router has a learning curve (Server vs Client Components), Turbopack is dev-only
- **Constraints:** All frontend code must be TypeScript, styling via Tailwind (no CSS modules), testing via Vitest (not Jest)

---
## Addendum — 2026-02-26

Next.js upgraded from 15 to 16. Architecture choices (App Router, TypeScript, Tailwind, shadcn/ui, pnpm, Vitest) remain unchanged.
