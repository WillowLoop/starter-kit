---
name: website-to-design-system
description: >-
  Genereer een compleet, gebruiksklaar design system vanuit een website-URL als
  inspiratie. Analyseert de visuele designtaal en produceert een design system
  document, OKLch CSS variabelen (Tailwind CSS 4 compatible), en font setup.
  Gebruik bij: "maak design system van [URL]", "gebruik [URL] als design
  inspiratie", of "/design-from-website [URL]".
  NB: Voor Tailwind 3 projecten (tailwind.config.ts), gebruik design-system-bootstrap.
---

# Website-to-Design-System

Genereer een compleet design system vanuit een website-URL als inspiratie. Produceert:
1. Een design system markdown document (project-lokale skill)
2. OKLch CSS variabelen in `globals.css` (Tailwind CSS 4 + shadcn/ui compatible)
3. Google Font setup in `layout.tsx`

## Wanneer Gebruiken

- "Maak een design system gebaseerd op [URL]"
- "Gebruik [URL] als design inspiratie"
- `/design-from-website [URL]`
- "Ik wil een design zoals [URL] maar met [aanpassingen]"

## Wanneer NIET Gebruiken

- **Tailwind 3 projecten** (met `tailwind.config.ts` en `extend.colors`) → gebruik `design-system-bootstrap`
- **Alleen component structuur** → gebruik `ui-component-creator`
- **Alleen creative direction** → gebruik `front-end-design`

## Gerelateerde Skills (refereer, dupliceer niet)

| Skill | Wat het levert | Hoe deze skill het gebruikt |
|-------|---------------|---------------------------|
| `design-system` | Token extractie, naming conventions | Fase 2: extractietechnieken |
| `design-system/templates/design-system-template.md` | Document structuur (536 regels) | Fase 4: template voor output |
| `design-system/examples/example-design-system.md` | Kwaliteitsreferentie: Tailwind classes, do's/don'ts | Fase 4: kwaliteitsnorm |
| `front-end-design` | Creative direction: Purpose/Tone/Constraints | Fase 3: esthetische analyse |
| `ui-component-creator` | Component patronen: forwardRef, cn(), CVA, a11y | Component sectie in document |
| `mobile-friendly-design` | Responsive en touch target patronen | Responsive sectie in document |

---

## Fase 1: Input & Detectie

### Input

De gebruiker geeft:
- **Verplicht**: Eén website-URL als inspiratie
- **Optioneel**: Projectnaam, aesthetic keywords ("minimaal", "speels", "premium")

### Acties

**1. Accepteer de URL** van de gebruiker.

**2. Detecteer het target project:**

```
Zoek: components.json in werkdirectory of subdirectories
  ↓
Lees: tailwind.css pad uit components.json
  ↓ BELANGRIJK: relatief resolven t.o.v. locatie components.json
  ↓ bijv. frontend/components.json met css: "src/app/globals.css"
  ↓      → frontend/src/app/globals.css
  ↓
Lees: globals.css → bevestig Tailwind 4:
  - @import "tailwindcss" aanwezig
  - @theme inline blok aanwezig
  ↓
Check: bestaat er al een *-design-system.md skill?
  → Ja: vraag gebruiker: vervangen of mergen?
  ↓
Check: bestaat er een tailwind.config.ts met custom kleuren?
  → Ja: waarschuw dat dit een Tailwind 3 pattern is
  → Suggereer: gebruik design-system-bootstrap voor Tailwind 3
```

**3. Stel projectnaam vast:**
- Lees `name` uit `package.json` in de project root
- Of vraag aan de gebruiker

### Quick Mode (Fallback)

Als WebFetch faalt of de gebruiker al weet wat hij wil ("maak een design zoals Stripe maar met groene accenten"):
- Accepteer directe input: 3-5 key kleuren (hex) + font naam + aesthetic richting
- Sla Fase 2 over → ga direct naar Fase 3

### Output

Config context: project pad, globals.css pad, layout.tsx pad, projectnaam, bestaande variabelen.

---

## Fase 2: Website Analyse

### Doel

Visuele designtaal extraheren van de inspiratie-website.

### Acties

**1. Fetch de website:**

```
WebFetch hoofd-URL → analyseer HTML voor:
├── <link rel="stylesheet"> URLs → fetch elke stylesheet (max 5)
├── Inline <style> blokken (SSR sites emiten critical CSS inline)
├── CSS custom properties (--var: value)
├── Google Fonts links (families + weights)
└── <meta name="theme-color">
```

**2. Extraheer tokens uit verzamelde CSS:**

| Token Type | Wat zoeken | Hoe groeperen |
|-----------|-----------|--------------|
| **Kleuren** | `color:`, `background:`, `border-color:`, CSS vars met kleurwaarden | primary / secondary / neutral / semantic |
| **Typografie** | `font-family`, `font-size`, `font-weight`, `line-height` | Heading hiërarchie identificeren |
| **Spacing** | `margin`, `padding`, `gap` waarden | Grid-basis bepalen (4px of 8px) |
| **Border radius** | `border-radius` waarden | small / medium / large |
| **Shadows** | `box-shadow` | Elevation levels |

**3. Identificeer component-patronen:**
Buttons, cards, inputs, navigatie.

### Fallback bij Beperkte CSS

Veel sites gebruiken CSS-in-JS, bundled CSS, of zijn SPAs. Bij onvoldoende CSS:

1. **Probeer common CSS paden:**
   - `/styles.css`
   - `/_next/static/css/*.css` (Next.js)
   - `/assets/css/*.css`

2. **Analyseer gerenderde markdown** voor visuele hints:
   - Kleurwoorden, font-namen, layout beschrijving

3. **Als onvoldoende — vraag de gebruiker expliciet om:**
   - 3-5 key kleuren (hex): primary, secondary/accent, text, background
   - Font naam (display + body)
   - Gewenste sfeer (minimaal, speels, premium, etc.)

4. **Combineer** wat er wél geëxtraheerd kon worden met de user input.

### Output

Geëxtraheerde tokens (ruw): kleuren, fonts, spacing, radii, shadows.

---

## Fase 3: Creative Direction & Token Verfijning

### Doel

Ruwe data transformeren naar een intentioneel design system.

### 3.1 Esthetische Analyse

Analyseer via het `front-end-design` denkkader:
- **Purpose**: Wat communiceert dit design? (betrouwbaar, speels, premium, minimaal)
- **Tone**: Welk esthetisch archetype?
- **Differentiation**: Wat maakt dit design onderscheidend?

### 3.2 Token Verfijning

1. **Dedupliceer** vergelijkbare kleuren
2. **Wijs semantische namen toe** die matchen met ALLE shadcn/ui variabelen.

Volledige variabelenlijst (zie `references/shadcn-variables.md` voor details):

```
Core:       background, foreground, primary, primary-foreground,
            secondary, secondary-foreground, muted, muted-foreground,
            accent, accent-foreground, destructive
Surface:    card, card-foreground, popover, popover-foreground
UI:         border, input, ring
Charts:     chart-1 t/m chart-5
Sidebar:    sidebar, sidebar-foreground, sidebar-primary,
            sidebar-primary-foreground, sidebar-accent,
            sidebar-accent-foreground, sidebar-border, sidebar-ring
Radius:     --radius (base waarde)
```

3. **Normaliseer typografie** naar standard Tailwind scale
4. **Definieer base `--radius` waarde** (alle andere radii worden berekend via `calc()`)

### 3.3 OKLch Conversie

Converteer alle kleuren naar `oklch(L C h)` formaat. Gebruik `references/oklch-guide.md` als referentie.

**Verplicht**: hex commentaar naast elke OKLch waarde:
```css
--primary: oklch(0.556 0.249 277.023); /* #635bff */
```

Genereer `:root` (light) en `.dark` varianten.

### 3.4 Dark Mode Generatie

Gebruik de bewezen structuur uit de bestaande `globals.css` als referentie, NIET een naïeve inversie:

| Variabele | Light → Dark transformatie |
|-----------|--------------------------|
| `--background` | Donkere achtergrond (L ~0.145) |
| `--foreground` | Lichte tekst (L ~0.985) |
| `--primary` | **Lichtere** versie (L verhogen) |
| `--primary-foreground` | **Donkere** versie (L verlagen) |
| `--card` / `--popover` | Verhoogd oppervlak (L ~0.205, lichter dan background) |
| `--secondary` / `--muted` / `--accent` | L ~0.269 |
| `--destructive` | L verhogen, C licht verlagen voor leesbaarheid |
| `--border` | **Alpha transparency**: `oklch(1 0 0 / 10%)` |
| `--input` | Iets hogere alpha: `oklch(1 0 0 / 15%)` |
| `--chart-*` | Hogere chroma, aangepaste hues voor donkere achtergrond |

### 3.5 Design Principles

Formuleer 3-4 design principles gebaseerd op de analyse.

### Output

Verfijnd design system spec: alle tokens, dark mode, principles.

---

## Fase 4: Design System Document + Review Checkpoint

### Doel

Genereer het autoritatieve design system markdown document.

### Acties

**1. Gebruik template en kwaliteitsreferentie:**
- Template: `design-system/templates/design-system-template.md`
- Kwaliteit: `design-system/examples/example-design-system.md`

**2. Vul alle secties in:**

| Sectie | Inhoud |
|--------|--------|
| Overview | Design principles, aesthetic direction |
| Colors | OKLch waarden + hex equivalenten, semantische namen |
| Typography | Families, scale, weights, heading styles |
| Spacing | System (4px of 8px grid) |
| Border radius & Shadows | Radii met calc()-relatie, elevation levels |
| Component patterns | Button, card, input, modal — als **Tailwind class combinaties** |
| Animaties & transitions | Timing, easing, motion patterns |
| Accessibility | Focus states, touch targets 44px min, ARIA |
| Responsive | Mobile-first patterns, breakpoints |
| Do's and Don'ts | Concrete voorbeelden |
| Quick reference | Import snippets, veelgebruikte combinaties |

**3. Tailwind 4 specifiek:**
Alle implementation notes gebruiken CSS variables + `@theme inline` pattern, NIET `tailwind.config.ts`.

**4. Quality Checklist:**

- [ ] Alle kleuren hebben semantische namen
- [ ] Contrast check: primary tekst op backgrounds WCAG AA (4.5:1)
- [ ] Typografie hiërarchie compleet (h1 t/m h6 + body)
- [ ] Spacing consistent op 4px grid
- [ ] Minimum: button, card, input patterns gedefinieerd
- [ ] Dark mode gedefinieerd voor alle variabelen
- [ ] Breakpoints gedefinieerd met use cases
- [ ] Alle 31 shadcn/ui variabelen aanwezig in zowel `:root` als `.dark`

### REVIEW CHECKPOINT

**Presenteer samenvatting aan de gebruiker:**

```
🎨 Design System Preview
━━━━━━━━━━━━━━━━━━━━━━━━

Kleuren:
  Primary:   [hex] ████ — [beschrijving]
  Secondary: [hex] ████ — [beschrijving]
  Accent:    [hex] ████ — [beschrijving]

Font:
  Display: [font naam]
  Body:    [font naam]

Design Principles:
  1. [Principle]
  2. [Principle]
  3. [Principle]

Voorbeeld Button:
  [Tailwind classes]

Voorbeeld Card:
  [Tailwind classes]
```

**Vraag**: "Wil je iets aanpassen? (warmere kleuren, ander font, meer/minder contrast, etc.)"

**Bij feedback:**
- Terug naar Fase 3 met aanpassing, hergeneer Fase 4
- Communiceer iteratietelling: "Dit is refinement 2/3"
- **Max 3 refinement iteraties** — bij 4e verzoek: vraag gebruiker om specifieker te zijn

**Bij "goed zo"** → door naar Fase 5.

### Output

Design system document → opslaan als:
`{project}/.claude/skills/{projectName}-design-system.md`

Dit is project-lokaal (niet globaal) zodat het design system bij het project blijft.

---

## Fase 5: Code Implementatie + Verificatie

### 5a. Update `globals.css`

**Vervang ALLEEN de `:root` en `.dark` CSS variable blokken.**

**NIET WIJZIGEN:**
- `@import "tailwindcss"`
- `@import "tw-animate-css"`
- `@import "shadcn/tailwind.css"`
- `@custom-variant dark (...)`
- `@theme inline { ... }` structuur — de mappings (`--color-primary: var(--primary)` etc.) blijven ONGEWIJZIGD
- `@layer base { ... }`
- Eventuele user-added custom variabelen

**WEL wijzigen als fonts veranderen:**
- `--font-sans` in `@theme inline` → `var(--font-{nieuwenaam})`

### 5b. Update `layout.tsx` (als font wijzigt)

**Eerst verifiëren** dat het font beschikbaar is via `next/font/google`.

Als het font proprietary is (San Francisco, Söhne, Circular, Graphik, etc.):
1. Meld dit aan de gebruiker
2. Stel het dichtstbijzijnde Google Fonts alternatief voor
3. Pas pas aan na akkoord

Bij beschikbaar font:
- Vervang de Google Font import
- Update de `variable` naam: `--font-{naam}` moet matchen met `globals.css`

### 5c. Verificatie

**1. Lees gegenereerde/gewijzigde bestanden terug:**
- Geen placeholders achtergebleven
- Alle 31 shadcn/ui variabelen aanwezig in `:root` EN `.dark`
- `@theme inline` block structureel intact
- OKLch waarden geldig: L: 0-1, C: 0-0.5, h: 0-360

**2. Component compatibiliteit:**
Bestaande shadcn/ui componenten (button, card, input) gebruiken semantische classes (`bg-primary`, `text-foreground`) → erven automatisch het nieuwe design system.

**3. Presenteer samenvatting:**

```
✅ Design System Geïmplementeerd
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Gewijzigde bestanden:
  - [pad]/globals.css (CSS variabelen)
  - [pad]/layout.tsx (font import)

Nieuwe bestanden:
  - .claude/skills/[project]-design-system.md

Highlights:
  - Primary: [kleur beschrijving]
  - Font: [font naam]
  - [X] variabelen gedefinieerd

Volgende stap:
  pnpm dev → open localhost:3000 → verifieer visueel:
  1. Primary button kleur correct
  2. Card achtergrond en tekst kleur
  3. Dark mode (als .dark class toggle aanwezig)
  4. Font rendering
```

---

## globals.css Structuur Referentie

De `globals.css` heeft deze exacte structuur die behouden moet blijven:

```css
@import "tailwindcss";
@import "tw-animate-css";
@import "shadcn/tailwind.css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);        /* ← DEZE MAG WIJZIGEN */
  --font-mono: var(--font-geist-mono);
  --color-sidebar-ring: var(--sidebar-ring);
  /* ... alle andere --color-* mappings ... */
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
  --radius-2xl: calc(var(--radius) + 8px);
  --radius-3xl: calc(var(--radius) + 12px);
  --radius-4xl: calc(var(--radius) + 16px);
}

:root {
  --radius: 0.625rem;
  --background: oklch(...);
  /* ... DEZE WAARDEN VERVANGEN ... */
}

.dark {
  --background: oklch(...);
  /* ... DEZE WAARDEN VERVANGEN ... */
}

@layer base {
  * {
    @apply border-border outline-ring/50;
  }
  body {
    @apply bg-background text-foreground;
  }
}
```

---

## Voorbeeld Aanroepen

```
"Maak een design system gebaseerd op https://linear.app"

"Gebruik https://stripe.com als inspiratie voor ons fintech project"

"/design-from-website https://vercel.com"

"Maak een design zoals Notion maar met warmere kleuren en een serif font"

"Design system van https://cal.com — ik wil dezelfde clean look maar in blauw"
```

---

## Volledige Variabelen Checklist

Bij het genereren van `:root` en `.dark`, verifieer dat ALLE variabelen aanwezig zijn:

```css
:root {
  --radius: ...;

  /* Core */
  --background: oklch(...);       /* hex */
  --foreground: oklch(...);       /* hex */
  --primary: oklch(...);          /* hex */
  --primary-foreground: oklch(...); /* hex */
  --secondary: oklch(...);        /* hex */
  --secondary-foreground: oklch(...); /* hex */
  --muted: oklch(...);            /* hex */
  --muted-foreground: oklch(...); /* hex */
  --accent: oklch(...);           /* hex */
  --accent-foreground: oklch(...); /* hex */
  --destructive: oklch(...);      /* hex */

  /* Surface */
  --card: oklch(...);             /* hex */
  --card-foreground: oklch(...);  /* hex */
  --popover: oklch(...);          /* hex */
  --popover-foreground: oklch(...); /* hex */

  /* UI */
  --border: oklch(...);           /* hex */
  --input: oklch(...);            /* hex */
  --ring: oklch(...);             /* hex */

  /* Charts */
  --chart-1: oklch(...);          /* hex */
  --chart-2: oklch(...);          /* hex */
  --chart-3: oklch(...);          /* hex */
  --chart-4: oklch(...);          /* hex */
  --chart-5: oklch(...);          /* hex */

  /* Sidebar */
  --sidebar: oklch(...);          /* hex */
  --sidebar-foreground: oklch(...); /* hex */
  --sidebar-primary: oklch(...);  /* hex */
  --sidebar-primary-foreground: oklch(...); /* hex */
  --sidebar-accent: oklch(...);   /* hex */
  --sidebar-accent-foreground: oklch(...); /* hex */
  --sidebar-border: oklch(...);   /* hex */
  --sidebar-ring: oklch(...);     /* hex */
}
```

Totaal: **31 variabelen** per mode + `--radius`. Herhaal hetzelfde blok voor `.dark`.
