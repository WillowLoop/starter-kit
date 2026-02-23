# ADR-0001: Frontend Tech Stack

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: Frontend container
- **Date**: 2026-02-11

## Context

Het AIpoweredMakers project heeft een frontend nodig die snel te ontwikkelen is, goede DX biedt, en schaalbaar is voor toekomstige features. De keuze voor framework, styling, component library, package manager en test runner moet nu gemaakt worden omdat het de basis legt voor alle toekomstige frontend ontwikkeling.

## Decision

- **Framework:** Next.js 15 (App Router) + TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **Package manager:** pnpm
- **Test runner:** Vitest + Testing Library
- **Dev server:** Turbopack (dev only, productie builds via webpack)

## Reasoning Chain

1. We bouwen een web applicatie met SEO-behoefte en server-side rendering → SSR-framework nodig → Next.js of Remix
2. Next.js heeft het grootste ecosysteem, beste Vercel-integratie en meeste community support → Next.js 15 met App Router
3. Styling moet utility-first zijn voor snelle iteratie en kleine bundle size → Tailwind CSS
4. Componenten moeten accessible en customizable zijn zonder vendor lock-in → shadcn/ui (kopieert code, geen runtime dependency)
5. Package manager moet snel zijn en strict omgaan met dependencies → pnpm (striktere node_modules structuur dan npm/yarn)
6. Test runner moet native ESM/TS ondersteunen en snel zijn → Vitest

### Vitest vs `next test` (experimenteel)

Next.js biedt experimentele `next test` integratie, maar Vitest is gekozen omdat:
- Vitest is sneller door native ESM en parallel test execution
- Vitest is onafhankelijk van de Next.js build pipeline — testen draaien ook als Next.js breekt
- Vitest heeft een stabiel, mature ecosysteem met uitgebreide plugin support
- `next test` is nog experimenteel en kan breaking changes hebben

### Turbopack scope

Turbopack wordt alleen voor de dev server gebruikt (`next dev --turbopack`). Productie builds gebruiken de standaard webpack bundler omdat Turbopack voor production builds nog niet stabiel is.

## Alternatives Considered

| Alternatief | Waarom afgewezen |
|---|---|
| Remix | Kleiner ecosysteem, minder hosting opties, minder community resources |
| Vite SPA (React) | Geen SSR/SSG out of the box, vereist extra setup voor SEO |
| Jest | Langzamer, vereist transformers voor ESM/TS, complexere configuratie |
| npm | Minder strikte dependency resolution, langzamer dan pnpm |
| yarn | Geen significant voordeel boven pnpm, pnpm heeft strictere hoisting |
| MUI / Chakra UI | Runtime CSS-in-JS overhead, vendor lock-in, minder controle over markup |

## Consequences

- **Makkelijker:** Snelle iteratie met Tailwind + shadcn/ui, goede DX met TypeScript + Vitest, eenvoudige deployment naar Vercel
- **Moeilijker:** Next.js App Router heeft een leercurve (Server vs Client Components), Turbopack is dev-only
- **Constraints:** Alle frontend code moet TypeScript zijn, styling via Tailwind (geen CSS modules), testen via Vitest (niet Jest)
