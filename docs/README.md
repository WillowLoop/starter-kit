# Documentation Index

## Hoe documentatie werkt

Lees eerst: [Project Documentation Architecture Guide](project-documentation-guide.md)

Drie mechanismen, elk met een eigen doel:
- **CLAUDE.md** — conventies en regels (altijd geladen)
- **ADR** — beslissingsrationale (on-demand)
- **Skill** — procedures en workflows (on-demand)

---

## Architectuur (C4)

| Document | C4 Level | Beschrijft |
|---|---|---|
| [c4/context.md](c4/context.md) | L1 — Context | Systeem in zijn omgeving |
| [c4/containers.md](c4/containers.md) | L2 — Container | Deployment units en tech stack |
| [c4/components.md](c4/components.md) | L3 — Component | Modules en hun interacties |

## Architecture Decision Records

| Document | Beschrijft |
|---|---|
| [adr/0001-frontend-tech-stack.md](adr/0001-frontend-tech-stack.md) | Next.js 15 + TS + Tailwind + shadcn/ui + pnpm + Vitest |
| [adr/0002-backend-tech-stack.md](adr/0002-backend-tech-stack.md) | FastAPI + Python 3.12+ + PostgreSQL + SQLAlchemy + uv + Ruff + pytest |
| [adr/_template.md](adr/_template.md) | Template voor nieuwe ADRs |

ADRs groeien met het project. Gebruik de template voor elke significante architectuurbeslissing.

## Roadmap

| Document | Beschrijft |
|---|---|
| [roadmap/overview.md](roadmap/overview.md) | Roadmap overzicht en status per epic |
| [roadmap/_template.md](roadmap/_template.md) | Template voor nieuwe epics |

---

## Bootstrap Checklist — Nieuw Project

Bij het kopiëren van deze starter-kit naar een nieuw project:

1. **Root `CLAUDE.md`** — Vul placeholders in: projectnaam, tech stack, repo layout
2. **`frontend/CLAUDE.md`** — Pas aan voor jouw frontend stack (of verwijder als niet van toepassing)
3. **`backend/CLAUDE.md`** — Pas aan voor jouw backend stack (of verwijder als niet van toepassing)
4. **`docs/c4/context.md`** — Vul systeem, actoren en externe systemen in
5. **`docs/c4/containers.md`** — Documenteer jouw deployment units
6. **`docs/c4/components.md`** — Documenteer modules per container
7. **Backend `features/` structuur** — Maak `features/` directory aan voor eerste backend feature
8. **`.claude/`** — Review agents, commands en skills; verwijder wat niet past
9. **Eerste ADR** — Documenteer de belangrijkste architectuurbeslissing: `docs/adr/0001-*.md`
10. **`docs/roadmap/overview.md`** — (optioneel) Vul de roadmap aan met eerste epics
11. **Opschonen** — Verwijder placeholder-voorbeelden en vervang met je eigen systeem

### Verificatie

```bash
# Kopieer naar nieuw project
cp -r starter-kit/ mijn-nieuw-project/

# Check dat alle CLAUDE.md bestanden ≤ 200 tokens zijn
wc -w mijn-nieuw-project/CLAUDE.md
wc -w mijn-nieuw-project/frontend/CLAUDE.md
wc -w mijn-nieuw-project/backend/CLAUDE.md
```
