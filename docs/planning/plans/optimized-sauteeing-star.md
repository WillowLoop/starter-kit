# Plan: Website-to-Design-System Workflow

## Context

Er bestaan al 5 losse design skills (design-system, design-system-bootstrap, front-end-design, ui-component-creator, mobile-friendly-design) maar die worden niet als pipeline gebruikt. De gebruiker wil een website-URL als inspiratie opgeven en een compleet, gebruiksklaar design system terugkrijgen: document + CSS variabelen + font setup. Met refinement-mogelijkheid tussendoor.

**Relatie met design-system-bootstrap**: Die skill is bedoeld voor Tailwind 3 projecten (genereert `tailwind.config.ts` extend.colors met hex kleuren). Deze nieuwe skill target Tailwind 4 projecten (CSS variabelen in `globals.css`, `@theme inline`, OKLch). Ze zijn complementair, niet overlappend. De SKILL.md documenteert dit expliciet.

## Wat we maken

**Een nieuwe global skill**: `~/.claude/skills/website-to-design-system/SKILL.md`
**Een slash command**: `~/.claude/commands/design-from-website.md`

De skill orchestreert de bestaande design skills in een 5-fase pipeline.

---

## Bestanden om te maken

| Bestand | Doel |
|---------|------|
| `~/.claude/skills/website-to-design-system/SKILL.md` | Hoofdskill met volledige workflow |
| `~/.claude/skills/website-to-design-system/references/shadcn-variables.md` | Complete shadcn/ui CSS variabelen met huidige default waarden als OKLch referentie |
| `~/.claude/skills/website-to-design-system/references/oklch-guide.md` | OKLch conversie referentietabel + bekende kleur-naar-OKLch mappings |
| `~/.claude/commands/design-from-website.md` | Slash command `/design-from-website [URL]` |

## Bestaande bestanden als referentie (niet wijzigen)

| Bestand | Waarom |
|---------|--------|
| `~/.claude/skills/design-system/SKILL.md` | Token extractie technieken en naming conventions |
| `~/.claude/skills/design-system/templates/design-system-template.md` | Template structuur (bestaat, 536 regels, volledige secties) |
| `~/.claude/skills/allinco-design-system.md` | Kwaliteitsreferentie: Tailwind class combinaties, do's/don'ts |
| `~/.claude/skills/front-end-design/SKILL.md` | Creative direction: Purpose/Tone/Constraints/Differentiation |
| `~/.claude/skills/ui-component-creator/SKILL.md` | Component patronen: forwardRef, cn(), CVA, a11y |
| `~/.claude/skills/mobile-friendly-design/SKILL.md` | Responsive en touch target patronen |

---

## Workflow: 5 Fases

### Fase 1: Input & Detectie

**Input**: Eén website URL als inspiratie, optioneel: projectnaam, aesthetic keywords

**Acties**:
1. Accepteer de URL van de gebruiker
2. Detecteer het target project:
   - Zoek `components.json` in werkdirectory of subdirectories
   - Lees `tailwind.css` pad uit `components.json` — **relatief resolven t.o.v. de locatie van components.json** (bijv. `frontend/components.json` met `css: "src/app/globals.css"` → `frontend/src/app/globals.css`)
   - Lees `globals.css` → bevestig Tailwind 4 (`@import "tailwindcss"` + `@theme inline`)
   - Check of er al een `*-design-system.md` skill bestaat → vraag of vervangen of mergen
   - Detect eventuele `design-system-bootstrap` output (custom kleuren in `tailwind.config.ts`) → waarschuw dat dit een Tailwind 3 pattern is
3. Stel projectnaam vast (uit package.json `name` of vraag aan gebruiker)

**Optionele quick mode**: Als WebFetch faalt of de gebruiker al weet wat hij wil ("maak een design zoals Stripe maar met groene accenten"), accepteer directe input: 3-5 key kleuren (hex) + font naam + aesthetic richting → sla Fase 2 over, ga direct naar Fase 3.

**Output**: Config context voor volgende fases

### Fase 2: Website Analyse

**Doel**: Visuele designtaal extraheren van de inspiratie-website.

**Acties** (volgt `design-system` skill Step 1-3):
1. `WebFetch` de hoofd-URL → analyseer HTML voor:
   - `<link rel="stylesheet">` URLs → fetch elke stylesheet (max 5 stylesheets)
   - Inline `<style>` blokken (SSR sites emiten critical CSS inline)
   - CSS custom properties (`--var: value`)
   - Google Fonts links (families + weights)
   - `<meta name="theme-color">`
2. Uit de verzamelde CSS, extraheer tokens:
   - **Kleuren**: `color:`, `background:`, `border-color:`, CSS variables met kleurwaarden. Groepeer op gebruik (primary/secondary/neutral/semantic).
   - **Typografie**: `font-family`, `font-size`, `font-weight`, `line-height`. Identificeer heading hiërarchie.
   - **Spacing**: `margin`, `padding`, `gap` waarden. Identificeer grid-basis (4px of 8px).
   - **Border radius**: `border-radius` waarden → small/medium/large.
   - **Shadows**: `box-shadow` → elevation levels.
3. Identificeer component-patronen: buttons, cards, inputs, navigatie.

**Concrete fallback bij beperkte CSS** (CSS-in-JS, bundled CSS, SPA sites):
1. Probeer common CSS paden: `/styles.css`, `/_next/static/css/*.css`, `/assets/css/*.css`
2. Analyseer de gerenderde markdown voor visuele hints (kleurwoorden, font-namen, layout beschrijving)
3. Als onvoldoende: **vraag de gebruiker expliciet** om:
   - 3-5 key kleuren (hex): primary, secondary/accent, text, background
   - Font naam (display + body)
   - Gewenste sfeer (minimaal, speels, premium, etc.)
4. Combineer wat er wél geëxtraheerd kon worden met de user input

**Output**: Geëxtraheerde tokens (ruw)

### Fase 3: Creative Direction & Token Verfijning

**Doel**: Ruwe data transformeren naar een intentioneel design system. Gebruikt het `front-end-design` denkkader.

**Acties**:
1. Analyseer via het front-end-design framework:
   - **Purpose**: Wat communiceert dit design? (betrouwbaar, speels, premium, minimaal)
   - **Tone**: Welk esthetisch archetype?
   - **Differentiation**: Wat maakt dit design onderscheidend?
2. Verfijn tokens tot een coherent systeem:
   - Dedupliceer vergelijkbare kleuren
   - Wijs semantische namen toe die matchen met **alle** shadcn/ui variabelen (zie `references/shadcn-variables.md`):
     - Core: `background`, `foreground`, `primary`, `primary-foreground`, `secondary`, `secondary-foreground`, `muted`, `muted-foreground`, `accent`, `accent-foreground`, `destructive`
     - Surface: `card`, `card-foreground`, `popover`, `popover-foreground`
     - UI: `border`, `input`, `ring`
     - Charts: `chart-1` t/m `chart-5`
     - Sidebar: `sidebar`, `sidebar-foreground`, `sidebar-primary`, `sidebar-primary-foreground`, `sidebar-accent`, `sidebar-accent-foreground`, `sidebar-border`, `sidebar-ring`
   - Normaliseer typografie naar standard Tailwind scale
   - Definieer base `--radius` waarde (alle andere radii worden berekend via `calc()`)
3. **OKLch conversie**:
   - Converteer alle kleuren naar `oklch(L C h)` formaat
   - Gebruik `references/oklch-guide.md` als conversiereferentie (bevat bekende kleur-naar-OKLch mappings)
   - **Verplicht**: plaats hex commentaar naast elke OKLch waarde voor visuele verificatie
   - Genereer `:root` (light) en `.dark` varianten
4. **Dark mode generatie** — gebruik de bestaande `globals.css` structuur als referentie, NIET een naïeve inversie:
   - `--background`: donkere achtergrond (L ~0.145)
   - `--foreground`: lichte tekst (L ~0.985)
   - `--primary`: **lichtere** versie van primary (L verhogen)
   - `--primary-foreground`: **donkere** versie (L verlagen)
   - `--border`: gebruik **alpha transparency** (`oklch(1 0 0 / 10%)`) niet een solid kleur
   - `--input`: iets hogere alpha dan border (`oklch(1 0 0 / 15%)`)
   - Chart kleuren: verschuif naar levendiger (hoger chroma) voor leesbaarheid op donkere achtergrond
5. Formuleer 3-4 design principles

**Output**: Verfijnd design system spec

### Fase 4: Design System Document + Review Checkpoint

**Doel**: Genereer het autoritatieve design system markdown document.

**Acties**:
1. Gebruik `~/.claude/skills/design-system/templates/design-system-template.md` als structuur
2. Gebruik `~/.claude/skills/allinco-design-system.md` als kwaliteitsreferentie
3. Vul alle secties in:
   - Overview met design principles
   - Colors (met OKLch waarden + hex equivalenten)
   - Typography (families, scale, weights, heading styles)
   - Spacing system
   - Border radius en shadows
   - Component patterns (button, card, input, modal — als Tailwind class combinaties)
   - Animaties en transitions
   - Accessibility (focus states, touch targets 44px min, ARIA)
   - Responsive patterns (mobile-first)
   - Do's and Don'ts
   - Quick reference
4. **Tailwind 4 specifiek**: Alle implementation notes gebruiken CSS variables + `@theme inline` pattern, NIET `tailwind.config.ts`
5. Voer quality checklist uit (uit `design-system` skill):
   - Alle kleuren hebben semantische namen
   - Contrast check (primary text op backgrounds: WCAG AA 4.5:1)
   - Typografie hiërarchie compleet
   - Spacing consistent op 4px grid
   - Minimum: button, card, input patterns
   - Dark mode gedefinieerd
   - Breakpoints gedefinieerd

**REVIEW CHECKPOINT** — Presenteer samenvatting aan de gebruiker:
- Kleurenpalet (primary, secondary, accent met hex previews)
- Font keuze (display + body)
- Design principles
- Voorbeeld button + card styling in Tailwind classes
- Vraag: "Wil je iets aanpassen?" (warmere kleuren, ander font, meer/minder contrast, etc.)
- Bij feedback: terug naar Fase 3 met aanpassing, hergeneer Fase 4
- Communiceer iteratietelling: "Dit is refinement 2/3"
- **Max 3 refinement iteraties** — bij 4e verzoek: vraag gebruiker om specifieker te zijn
- Bij "goed zo" → door naar Fase 5

**Output**: `{project}/.claude/skills/{projectName}-design-system.md` (project-lokaal, niet globaal — zodat het design system bij het project blijft)

### Fase 5: Code Implementatie + Verificatie

**Doel**: Design system implementeren in het project en verifiëren.

**5a. Update `globals.css`**:
- Vervang **alleen** de `:root` en `.dark` CSS variable blokken met nieuwe OKLch waarden
- **NIET WIJZIGEN**: `@import "tailwindcss"`, `@import "tw-animate-css"`, `@import "shadcn/tailwind.css"`, `@custom-variant dark (...)`, `@theme inline { ... }` structuur, `@layer base { ... }`
- De `@theme inline` blok behoudt zijn bestaande mappings (`--color-primary: var(--primary)` etc.) — die veranderen NIET, alleen de waarden in `:root`/`.dark` veranderen
- Als fonts wijzigen: update `--font-sans` in `@theme inline` naar `var(--font-{nieuwenaam})`
- Bewaar eventuele user-added custom variabelen

**5b. Update `layout.tsx`** (als font wijzigt):
- **Eerst verifiëren** dat het font beschikbaar is via `next/font/google` — als het font proprietary is (San Francisco, Söhne, Circular, etc.):
  1. Meld dit aan de gebruiker
  2. Stel het dichtstbijzijnde Google Fonts alternatief voor
  3. Pas pas aan na akkoord
- Vervang de Google Font import
- Update de `variable` naam zodat deze matcht met `--font-{naam}` in globals.css

**5c. Verificatie**:
1. Lees gegenereerde/gewijzigde bestanden terug:
   - Geen placeholders achtergebleven
   - Alle shadcn/ui variabelen aanwezig in `:root` en `.dark`
   - `@theme inline` block structureel intact
   - OKLch waarden geldig (L: 0-1, C: 0-0.5, h: 0-360)
2. Bestaande shadcn/ui componenten (button, card, input) gebruiken semantische classes (`bg-primary`, `text-foreground`) → erven automatisch het nieuwe design system
3. Presenteer samenvatting:
   - Lijst van gewijzigde/nieuwe bestanden
   - Design system highlights
   - Suggestie: `pnpm dev` → open localhost:3000 → verifieer visueel:
     1. Primary button kleur correct
     2. Card achtergrond en tekst kleur
     3. Dark mode (als `.dark` class toggle aanwezig)
     4. Font rendering

---

## SKILL.md Structuur

```yaml
---
name: website-to-design-system
description: >-
  Genereer een compleet, gebruiksklaar design system vanuit een website-URL als
  inspiratie. Analyseert de visuele designtaal en produceert een design system
  document, OKLch CSS variabelen (Tailwind CSS 4 compatible), en font setup.
  Gebruik bij: "maak design system van [URL]", "gebruik [URL] als design
  inspiratie", of "/design-from-website [URL]".
  NB: Voor Tailwind 3 projecten, gebruik design-system-bootstrap in plaats daarvan.
---
```

De SKILL.md bevat:
- Alle 5 fases als duidelijke secties met instructies
- Cross-referenties naar bestaande skills (verwijzen, niet dupliceren)
- Inline: shadcn/ui variabelen checklist
- OKLch conversie richtlijnen
- Dark mode structuur referentie (gebaseerd op bestaande globals.css patronen)
- WebFetch fallback strategie
- Quality checklist
- Voorbeeld aanroepen

## Reference Files

### `references/shadcn-variables.md`
Complete lijst van alle shadcn/ui CSS variabelen met:
- Variabele naam
- Beschrijving/gebruik
- De huidige default OKLch waarden (uit globals.css) als referentie baseline
- Zowel `:root` als `.dark` waarden

### `references/oklch-guide.md`
- Uitleg OKLch kleurruimte (L, C, h parameters)
- Conversietabel: ~20 veelvoorkomende kleuren met hex → OKLch mapping
- De complete shadcn/ui default palette als bekende referentiepunten
- Tips: hex commentaar altijd meegeven, visueel verifiëren in browser devtools

## Slash Command

`~/.claude/commands/design-from-website.md`:
```
Gebruik de website-to-design-system skill om een compleet design system te genereren
vanuit $ARGUMENTS als inspiratie-URL. Volg alle 5 fases van de skill.
```

---

## Risico's & Mitigatie

| Risico | Mitigatie |
|--------|----------|
| WebFetch geeft beperkte CSS (CSS-in-JS, SPA) | Concrete fallback: probeer common CSS paden, analyseer markdown, **vraag gebruiker om key kleuren + font** |
| OKLch conversie onnauwkeurig | Verplicht hex commentaar naast OKLch waarden. Referentietabel in oklch-guide.md. Gebruiker verifieer visueel. |
| Overschrijven user customizations in globals.css | Lees eerst huidige globals.css, wijzig alleen `:root` en `.dark` blokken, behoud al het andere |
| Font niet beschikbaar via next/font/google | Verifieer beschikbaarheid in Fase 5b, stel alternatief voor bij proprietary fonts |
| Bestaand design system conflict | Fase 1 detecteert bestaande `*-design-system.md`, vraagt of vervangen of mergen |
| Conflict met design-system-bootstrap output | Fase 1 detecteert Tailwind 3 patterns, waarschuwt gebruiker |
| Dark mode ziet er niet goed uit | Gebruik bewezen structuur uit bestaande globals.css als referentie, niet naïeve inversie |

## Verificatie na implementatie

1. `pnpm dev` starten in frontend/ → check of de app compileert zonder errors
2. Open localhost:3000 → visueel controleren:
   - Primary button kleur
   - Card achtergrond en tekst
   - Dark mode toggle (indien aanwezig)
   - Font rendering
3. Verifieer dat bestaande shadcn/ui componenten correct gestyled zijn
4. Check browser devtools: CSS variabelen correct geladen in `:root`
