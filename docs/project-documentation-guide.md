# Project Documentation Architecture Guide

Guide voor het inrichten van projectdocumentatie, optimaal voor zowel menselijke developers als LLM-agents.

## Kernprincipe: Context Hygiene

Elke informatie-eenheid heeft precies één plek. Een LLM-agent moet nooit meer context laden dan nodig voor de huidige taak. Drie mechanismen, elk met een eigen rol:

| Mechanisme | Doel | Wanneer geladen | Token budget |
|---|---|---|---|
| **CLAUDE.md** | Conventies en regels | Altijd (per directory) | ~100-200 tokens |
| **ADR** | Beslissingsrationale | On-demand, alleen bij "waarom?" | ~200-400 tokens |
| **Skill** | Complexe procedures/workflows | On-demand, bij specifieke taak | Onbeperkt (progressive disclosure) |

---

## CLAUDE.md — Conventies (altijd geladen)

CLAUDE.md bestanden vormen een hiërarchie per directory. Een agent leest automatisch de CLAUDE.md van de directory waarin hij werkt. Houd ze kort en scanbaar.

### Root CLAUDE.md (~150 tokens)

```markdown
# [Project Naam]

Stack: Next.js 15 (App Router), FastAPI, PostgreSQL, TanStack Query v5
Architecture: Feature-first (vertical slicing)
Monorepo: frontend/ + backend/

## Repo layout
frontend/    → Next.js app
backend/     → FastAPI services
docs/        → C4 docs, ADRs
infra/       → Docker, deployment

## Global rules
- TypeScript strict mode everywhere
- All API calls through typed client (lib/api-client.ts)
- No barrel exports
```

### Directory CLAUDE.md (~100 tokens per stuk)

Elke directory met eigen conventies krijgt een CLAUDE.md. Voorbeeld `frontend/CLAUDE.md`:

```markdown
# Frontend Conventions

Architecture: Feature-first (vertical slicing)
Stack: Next.js 15 (App Router), TypeScript, Tailwind, shadcn/ui
State: TanStack Query v5 (server), React Context (UI)

## Structure
app/              → routes only (thin, import from features/)
features/{name}/  → colocated: components/, hooks/, api/, types.ts
shared/ui/        → shadcn primitives
shared/lib/       → cross-feature utilities
shared/hooks/     → gedeelde hooks

## Rules
- Server Components default, 'use client' only when needed
- Feature importeert NOOIT uit andere feature → shared/
- Max 200 lines per component
- Colocate styles (Tailwind only, no CSS files)
```

Voorbeeld `backend/CLAUDE.md`:

```markdown
# Backend Conventions

Architecture: Feature-first (vertical slicing)
Stack: [framework], [taal], [ORM]

## Structure
app/                  → entry point, config
features/{name}/      → colocated: router.py, service.py, repository.py, schema.py
shared/db/            → connection, base models, models/, migrations
shared/auth/          → authenticatie/autorisatie
shared/middleware/    → CORS, rate limiting, request logging
shared/lib/           → cross-feature utilities

## Rules
- Feature importeert NOOIT uit andere feature → shared/
- Models in shared/db/models/ (cross-feature relaties)
- Router → Service → Repository (per feature)
- Geen business logic in routers
```

### Vuistregels voor CLAUDE.md

- **Maximaal ~200 tokens** — als het langer wordt, splits naar sub-directory CLAUDE.md's
- **Feiten, geen uitleg** — "barrel exports forbidden", niet "we vermijden barrel exports omdat..."
- **Scanbaar** — tabellen en korte regels, geen proza
- **Onderhoud** — de planner workflow + technical writer agent houdt dit bij; bij handmatig werk: doc-sync skill

---

## ADRs — Beslissingen (on-demand)

ADRs leggen vast *waarom* een keuze is gemaakt. Ze worden alleen geladen als een agent of developer context nodig heeft over een beslissing.

### Wanneer wel een ADR

- Framework- of toolkeuze met serieuze alternatieven (Next.js vs Remix, PostgreSQL vs MongoDB)
- Architectuurbeslissingen die moeilijk terug te draaien zijn (monorepo vs polyrepo, auth provider)
- Keuzes waar je later spijt van kunt krijgen
- Trade-offs die je bewust hebt gemaakt

### Wanneer geen ADR

- Conventies en stijlkeuzes → CLAUDE.md
- Feature-first folder structuur → CLAUDE.md (tenzij er een controversiële afweging was)
- Dingen waar het antwoord op "waarom?" één zin is

### ADR template met C4-koppeling

```markdown
# ADR-NNN: [Titel]

- **Status**: proposed | accepted | superseded | deprecated
- **C4 Level**: L1-Context | L2-Container | L3-Component | L4-Code
- **Scope**: [welke container/component dit raakt]
- **Date**: YYYY-MM-DD

## Context
[Welk probleem moest opgelost worden?]

## Decision
[Wat is besloten en waarom?]

## Consequences
[Wat zijn de gevolgen, positief en negatief?]

## Alternatives Considered
[Kort: welke alternatieven zijn afgewezen en waarom?]
```

### C4-niveau toewijzing

| C4 Level | Type beslissing | Voorbeeld |
|---|---|---|
| L1-Context | Systeemgrenzen, externe integraties | "We gebruiken Stripe als PSP" |
| L2-Container | Tech stack, deployment units | "Next.js voor frontend, FastAPI voor backend" |
| L3-Component | Module-architectuur, patterns | "TanStack Query voor server state" |
| L4-Code | Implementatiedetails | Zelden nodig — als het in code duidelijk is, geen ADR |

---

## Skills — Procedures (on-demand)

Skills zijn voor complexe, herhaalbare workflows die stap-voor-stap instructies nodig hebben, vaak met voorbeeldcode.

### Wanneer een Skill

- Feature scaffolding (nieuwe feature aanmaken met alle benodigde bestanden)
- Design system patronen met concrete component-voorbeelden
- Complexe integratie-workflows (API client setup, auth flow)
- Procedures die meerdere bestanden en stappen raken

### Wanneer geen Skill

- Basisconventies → CLAUDE.md
- Eenmalige beslissingen → ADR
- Informatie die altijd beschikbaar moet zijn → CLAUDE.md

### Skill structuur

Skills volgen progressive disclosure: de SKILL.md is het startpunt, verdere context wordt on-demand geladen.

```
.claude/skills/
└── feature-scaffold/
    └── SKILL.md       # Doel, stappen, templates
```

---

## /docs/ Directory — C4 Architectuurdocumentatie

```
docs/
├── c4/
│   ├── context.md          # L1: systeem in zijn omgeving
│   ├── containers.md       # L2: deployment units
│   └── components.md       # L3: modules binnen containers
├── adr/
│   ├── _template.md
│   ├── 0001-*.md
│   └── ...
├── roadmap/
│   ├── overview.md          # Roadmap overzicht en status
│   └── _template.md         # Template voor nieuwe epics
└── README.md               # Index: verwijzingen naar C4 docs, ADRs en roadmap
```

C4 L4 (Code-niveau) wordt niet apart gedocumenteerd — dat is wat CLAUDE.md per directory doet.

---

## Beslisboom: waar hoort dit?

```
Is het een feit/regel die altijd geldig is?
  → CLAUDE.md in de relevante directory

Is het een keuze met alternatieven die je bewust hebt afgewezen?
  → ADR in docs/adr/

Is het een stap-voor-stap procedure met templates/voorbeelden?
  → Skill in .claude/skills/

Is het een high-level architectuurbeschrijving?
  → C4 doc in docs/c4/

Is het antwoord op "waarom?" minder dan twee zinnen?
  → CLAUDE.md (eventueel met die ene zin erbij)
```

---

## Onderhoud

- **Planner workflow** → technical writer agent houdt CLAUDE.md en README.md automatisch bij
- **doc-sync skill** → audit en synchroniseer documentatie bij drift
- **ADRs zijn immutable** — superseded ADRs worden niet verwijderd maar krijgen status "superseded" met verwijzing naar opvolger
