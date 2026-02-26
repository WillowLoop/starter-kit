# Plan: Interactieve Workflow Visualisatie

## Context

We willen de plan-and-review workflow visueel uitlegbaar maken voor zowel developers als management/stakeholders. Het resultaat is een standalone HTML-pagina met interactieve diagrammen, uitbreidbaar voor toekomstige workflows.

## Aanpak: Single Standalone HTML

**Bestand:** `docs/workflows/plan-and-review-visual.html`

Pure CSS/SVG + vanilla JavaScript. Geen externe dependencies (geen Mermaid, geen D3). Laadt instant, werkt offline, is makkelijk te onderhouden.

## Twee views voor twee doelgroepen

### Executive Overview (management)
Vereenvoudigd lineair:
```
Idea → Architect → Plan → Review → Build → Document
```
- Gekleurde pills, hover = tooltip, click = korte uitleg
- Geen file paths, geen agent details, geen iteratie-logica

### Developer Detail (developers)
Volledige 6-fase flow met grid layout:
```
Phase 0 → Phase 1a → Phase 1b → Phase 2
                                    ↓
Phase 5 ← Phase 4  ←  Phase 3 (iterate)
                       ↑___↓ feedback loops
```
- Phase cards met agent role, model, tools
- Click = detail panel met inputs/outputs/file paths
- SVG verbindingslijnen met feedback loops
- Agent badges: Architect (indigo), Planner (groen), Staff Engineer (amber)

## De 6 fases (inhoud uit bestaande skills)

| Phase | Naam | Agent | Kern |
|-------|------|-------|------|
| 0 | Doc Health Check | Planner | Bootstrap CLAUDE.md, docs/decisions/, docs/plans/ |
| 1a | Architect Blueprint | Architect (opus) | Lees docs → 1 decisieve ontwerpkeuze → Blueprint |
| 1b | Create Plan | Planner | Blueprint → implementatieplan met steps/testing/rollback |
| 2 | Staff Engineer Review | Staff Eng (opus) | Separate context review → verdict |
| 3 | Iterate Until Approved | Planner | Max 3 iteraties, feedback routing |
| 4 | Implement | Planner | Bouw + build-validation + verify-app |
| 5 | Doc Preservation | Planner | Decision Log → ADR, Knowledge → README, Plan → archive |

## Technische details

### Layout
- **Header:** "Claude Code Workflows" + tab-navigatie (Plan & Review actief, andere tabs "coming soon")
- **View toggle:** segmented control Executive / Developer
- **Flow area:** CSS Grid (4 kolommen desktop, 1 kolom mobiel)
- **Detail panel:** slide-open onder de flow bij click op een fase
- **Knowledge Flow:** animated circular diagram onderaan

### Kleuren (oklch, matched met globals.css)
- Phase 0: teal `oklch(0.7 0.15 160)`
- Phase 1a: indigo `oklch(0.55 0.25 265)`
- Phase 1b: groen `oklch(0.6 0.2 145)`
- Phase 2: amber `oklch(0.7 0.2 75)`
- Phase 3: warm oranje `oklch(0.65 0.22 45)`
- Phase 4: teal `oklch(0.55 0.2 165)`
- Phase 5: paars `oklch(0.6 0.18 285)`

### Features
- Dark mode via `prefers-color-scheme: dark`
- Responsive (mobiel → tablet → desktop)
- Keyboard accessible (tabindex, Enter/Space handlers)
- Reduced-motion support
- SVG verbindingslijnen met draw-animatie
- Tweetalig voorbereid (EN primair, `beschrijving` veld voor NL)

### Uitbreidbaarheid
- Tab-navigatie voor toekomstige workflows (`/feature`, `/prd`, `/debug`)
- `PHASES` data object in JS maakt content makkelijk aanpasbaar
- Zelfde pattern (executive/developer view + detail panels) herbruikbaar per workflow

## Bestanden

| Actie | Bestand |
|-------|---------|
| **Nieuw** | `docs/workflows/plan-and-review-visual.html` (~800-1000 regels) |

### Bronbestanden voor inhoud
- `.claude/skills/plan-review-workflow/SKILL.md` — alle fase-beschrijvingen, knowledge flow
- `.claude/commands/plan-and-review.md` — plan secties, review template, iteratie-logica
- `.claude/agents/code-architect.md` — architect proces, Blueprint structuur
- `.claude/agents/staff-engineer.md` — review checklist, red flags, verdicts

## Verificatie

1. Open `docs/workflows/plan-and-review-visual.html` in browser
2. Check: Executive view toont vereenvoudigd lineair diagram
3. Check: Developer view toont volledige 6-fase grid met SVG lijnen
4. Check: Click op elke fase opent detail panel met juiste content
5. Check: View toggle wisselt smooth tussen views
6. Check: Dark mode werkt (browser instelling wijzigen)
7. Check: Responsive op mobiel (DevTools device toolbar)
8. Check: Keyboard navigatie werkt (Tab + Enter)
