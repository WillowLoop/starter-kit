# OKLch Kleurruimte Referentie

## Wat is OKLch?

OKLch is een perceptueel uniforme kleurruimte. Anders dan hex/RGB, waar gelijke numerieke stappen niet gelijk overkomen op het oog, is OKLch ontworpen zodat gelijke stappen in de waarden ook gelijk aanvoelen.

**Formaat**: `oklch(L C h)` of `oklch(L C h / alpha)`

| Parameter | Bereik | Beschrijving |
|-----------|--------|-------------|
| **L** (Lightness) | `0` – `1` | Perceptuele helderheid. `0` = zwart, `1` = wit |
| **C** (Chroma) | `0` – `~0.4` | Kleurverzadiging. `0` = grijs, hogere waarden = levendiger. Praktisch max ~0.37 |
| **h** (Hue) | `0` – `360` | Kleurtint als hoek op het kleurenwiel |

## Hue Referentie

| Hoek | Kleur |
|------|-------|
| 0–30 | Rood → Rood-oranje |
| 30–70 | Oranje → Geel |
| 70–140 | Geel → Groen |
| 140–200 | Groen → Cyaan |
| 200–260 | Cyaan → Blauw |
| 260–310 | Blauw → Paars/Violet |
| 310–360 | Magenta → Rood |

## Veelvoorkomende Kleuren: Hex → OKLch

### Basiskleuren

| Kleur | Hex | OKLch |
|-------|-----|-------|
| Wit | `#ffffff` | `oklch(1 0 0)` |
| Zwart | `#000000` | `oklch(0 0 0)` |
| Rood | `#ef4444` | `oklch(0.637 0.237 25.331)` |
| Oranje | `#f97316` | `oklch(0.724 0.192 47.604)` |
| Amber | `#f59e0b` | `oklch(0.769 0.188 70.08)` |
| Geel | `#eab308` | `oklch(0.795 0.184 86.047)` |
| Groen | `#22c55e` | `oklch(0.723 0.219 149.579)` |
| Emerald | `#10b981` | `oklch(0.696 0.17 162.48)` |
| Teal | `#14b8a6` | `oklch(0.697 0.146 174.358)` |
| Cyaan | `#06b6d4` | `oklch(0.715 0.143 215.221)` |
| Blauw | `#3b82f6` | `oklch(0.623 0.214 259.815)` |
| Indigo | `#6366f1` | `oklch(0.585 0.233 277.117)` |
| Violet | `#8b5cf6` | `oklch(0.606 0.25 292.717)` |
| Paars | `#a855f7` | `oklch(0.627 0.265 303.9)` |
| Fuchsia | `#d946ef` | `oklch(0.667 0.295 322.15)` |
| Pink | `#ec4899` | `oklch(0.656 0.241 354.308)` |
| Rose | `#f43f5e` | `oklch(0.645 0.246 16.439)` |

### Neutrale Tinten (Neutral / Zinc)

| Tint | Hex | OKLch |
|------|-----|-------|
| 50 | `#fafafa` | `oklch(0.985 0 0)` |
| 100 | `#f5f5f5` | `oklch(0.97 0 0)` |
| 200 | `#e5e5e5` | `oklch(0.922 0 0)` |
| 300 | `#d4d4d4` | `oklch(0.87 0 0)` |
| 400 | `#a3a3a3` | `oklch(0.708 0 0)` |
| 500 | `#737373` | `oklch(0.556 0 0)` |
| 600 | `#525252` | `oklch(0.439 0 0)` |
| 700 | `#404040` | `oklch(0.371 0 0)` |
| 800 | `#262626` | `oklch(0.269 0 0)` |
| 900 | `#171717` | `oklch(0.205 0 0)` |
| 950 | `#0a0a0a` | `oklch(0.145 0 0)` |

### Populaire Brand Kleuren (benaderingen)

| Brand | Kleur | Hex | OKLch |
|-------|-------|-----|-------|
| Stripe | Paars | `#635bff` | `oklch(0.556 0.249 277.023)` |
| Stripe | Blauw | `#0a2540` | `oklch(0.243 0.042 245.935)` |
| Linear | Paars | `#5e6ad2` | `oklch(0.562 0.162 277.892)` |
| Vercel | Zwart | `#000000` | `oklch(0 0 0)` |
| Tailwind | Blauw | `#38bdf8` | `oklch(0.773 0.15 230.067)` |
| GitHub | Blauw | `#1f6feb` | `oklch(0.546 0.196 256.802)` |
| Figma | Rood | `#f24e1e` | `oklch(0.629 0.222 28.717)` |

## shadcn/ui Default Palette als Referentie

De volledige shadcn/ui neutral palette (zoals gebruikt in de starter-kit):

### Light mode (`:root`)

```css
--background: oklch(1 0 0);           /* #ffffff — Wit */
--foreground: oklch(0.145 0 0);       /* #0a0a0a — Bijna zwart */
--card: oklch(1 0 0);                 /* #ffffff */
--card-foreground: oklch(0.145 0 0);  /* #0a0a0a */
--popover: oklch(1 0 0);             /* #ffffff */
--popover-foreground: oklch(0.145 0 0); /* #0a0a0a */
--primary: oklch(0.205 0 0);          /* #171717 — Neutral 900 */
--primary-foreground: oklch(0.985 0 0); /* #fafafa — Neutral 50 */
--secondary: oklch(0.97 0 0);         /* #f5f5f5 — Neutral 100 */
--secondary-foreground: oklch(0.205 0 0); /* #171717 */
--muted: oklch(0.97 0 0);            /* #f5f5f5 */
--muted-foreground: oklch(0.556 0 0); /* #737373 — Neutral 500 */
--accent: oklch(0.97 0 0);           /* #f5f5f5 */
--accent-foreground: oklch(0.205 0 0); /* #171717 */
--destructive: oklch(0.577 0.245 27.325); /* ~#e11d48 — Rose 600 */
--border: oklch(0.922 0 0);          /* #e5e5e5 — Neutral 200 */
--input: oklch(0.922 0 0);           /* #e5e5e5 */
--ring: oklch(0.708 0 0);            /* #a3a3a3 — Neutral 400 */
```

### Dark mode (`.dark`)

```css
--background: oklch(0.145 0 0);       /* #0a0a0a */
--foreground: oklch(0.985 0 0);       /* #fafafa */
--card: oklch(0.205 0 0);             /* #171717 */
--card-foreground: oklch(0.985 0 0);  /* #fafafa */
--popover: oklch(0.205 0 0);         /* #171717 */
--popover-foreground: oklch(0.985 0 0); /* #fafafa */
--primary: oklch(0.922 0 0);          /* #e5e5e5 */
--primary-foreground: oklch(0.205 0 0); /* #171717 */
--secondary: oklch(0.269 0 0);        /* #262626 — Neutral 800 */
--secondary-foreground: oklch(0.985 0 0); /* #fafafa */
--muted: oklch(0.269 0 0);           /* #262626 */
--muted-foreground: oklch(0.708 0 0); /* #a3a3a3 */
--accent: oklch(0.269 0 0);          /* #262626 */
--accent-foreground: oklch(0.985 0 0); /* #fafafa */
--destructive: oklch(0.704 0.191 22.216); /* ~#f43f5e lichter voor dark */
--border: oklch(1 0 0 / 10%);        /* Wit met 10% alpha */
--input: oklch(1 0 0 / 15%);         /* Wit met 15% alpha */
--ring: oklch(0.556 0 0);            /* #737373 */
```

## Conversie Tips

### Hex naar OKLch

1. Gebruik browser DevTools: typ hex in, klik op kleurvierkant, schakel naar OKLch
2. CSS: `oklch(from #hex l c h)` (relative color syntax, breed ondersteund)
3. Online: oklch.com of colorjs.io

### OKLch Manipulatie

| Operatie | Wat te doen |
|----------|-------------|
| **Lichter maken** | Verhoog L (bijv. `0.5` → `0.7`) |
| **Donkerder maken** | Verlaag L (bijv. `0.5` → `0.3`) |
| **Meer verzadigd** | Verhoog C (bijv. `0.15` → `0.25`) |
| **Minder verzadigd** | Verlaag C (bijv. `0.25` → `0.10`) |
| **Complementaire kleur** | h + 180° (bijv. `25` → `205`) |
| **Analoge kleuren** | h ± 30° |
| **Triadic** | h, h+120°, h+240° |

### Dark Mode Transformatie Regels

| Variabele | Light → Dark transformatie |
|-----------|--------------------------|
| `background` | L: hoog → laag (`1` → `0.145`) |
| `foreground` | L: laag → hoog (`0.145` → `0.985`) |
| `primary` | L inverteren, C behouden, h behouden |
| `primary-foreground` | Tegenovergestelde van primary |
| `secondary/muted/accent` | L: ~0.97 → ~0.269 |
| `destructive` | L verhogen voor leesbaarheid, C licht verlagen |
| `border` | Solid → alpha transparency (`oklch(1 0 0 / 10%)`) |
| `input` | Iets hogere alpha dan border (`/ 15%`) |
| `chart-*` | Hogere chroma, aangepaste hues voor donkere achtergrond |

### Verplichte Conventies

1. **Altijd hex commentaar**: `--primary: oklch(0.556 0.249 277.023); /* #635bff */`
2. **Verifieer visueel**: Open browser DevTools → Computed Styles → controleer kleur
3. **L validatie**: L moet tussen 0 en 1 liggen
4. **C validatie**: C moet tussen 0 en ~0.4 liggen (meeste kleuren < 0.3)
5. **h validatie**: h moet tussen 0 en 360 liggen
6. **Neutrale kleuren**: C = 0, h = 0 (of weggelaten)
