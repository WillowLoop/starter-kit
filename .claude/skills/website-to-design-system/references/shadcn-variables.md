# shadcn/ui CSS Variables Reference

Complete lijst van alle shadcn/ui CSS variabelen. Gebruik als checklist: elk design system MOET al deze variabelen definiëren in zowel `:root` als `.dark`.

## Variabelen Overzicht

### Core

| Variabele | Beschrijving | `:root` default (OKLch) | `.dark` default (OKLch) |
|-----------|-------------|------------------------|------------------------|
| `--background` | Pagina achtergrond | `oklch(1 0 0)` | `oklch(0.145 0 0)` |
| `--foreground` | Standaard tekst | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--primary` | Primaire acties, links, knoppen | `oklch(0.205 0 0)` | `oklch(0.922 0 0)` |
| `--primary-foreground` | Tekst op primary achtergrond | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--secondary` | Secundaire acties | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--secondary-foreground` | Tekst op secondary achtergrond | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--muted` | Gedempte achtergronden | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--muted-foreground` | Gedempte tekst (placeholders, helpers) | `oklch(0.556 0 0)` | `oklch(0.708 0 0)` |
| `--accent` | Accent achtergrond (hover states) | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--accent-foreground` | Tekst op accent achtergrond | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--destructive` | Destructieve/fout acties | `oklch(0.577 0.245 27.325)` | `oklch(0.704 0.191 22.216)` |

### Surface

| Variabele | Beschrijving | `:root` default | `.dark` default |
|-----------|-------------|----------------|----------------|
| `--card` | Card achtergrond | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--card-foreground` | Tekst op cards | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--popover` | Popover/dropdown achtergrond | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--popover-foreground` | Tekst in popovers | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |

### UI Elements

| Variabele | Beschrijving | `:root` default | `.dark` default |
|-----------|-------------|----------------|----------------|
| `--border` | Standaard borders, dividers | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |
| `--input` | Input borders | `oklch(0.922 0 0)` | `oklch(1 0 0 / 15%)` |
| `--ring` | Focus ring kleur | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` |

### Charts

| Variabele | Beschrijving | `:root` default | `.dark` default |
|-----------|-------------|----------------|----------------|
| `--chart-1` | Grafiek kleur 1 | `oklch(0.646 0.222 41.116)` | `oklch(0.488 0.243 264.376)` |
| `--chart-2` | Grafiek kleur 2 | `oklch(0.6 0.118 184.704)` | `oklch(0.696 0.17 162.48)` |
| `--chart-3` | Grafiek kleur 3 | `oklch(0.398 0.07 227.392)` | `oklch(0.769 0.188 70.08)` |
| `--chart-4` | Grafiek kleur 4 | `oklch(0.828 0.189 84.429)` | `oklch(0.627 0.265 303.9)` |
| `--chart-5` | Grafiek kleur 5 | `oklch(0.769 0.188 70.08)` | `oklch(0.645 0.246 16.439)` |

### Sidebar

| Variabele | Beschrijving | `:root` default | `.dark` default |
|-----------|-------------|----------------|----------------|
| `--sidebar` | Sidebar achtergrond | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--sidebar-foreground` | Sidebar tekst | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-primary` | Sidebar actief item | `oklch(0.205 0 0)` | `oklch(0.488 0.243 264.376)` |
| `--sidebar-primary-foreground` | Tekst op sidebar actief | `oklch(0.985 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-accent` | Sidebar hover state | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--sidebar-accent-foreground` | Tekst op sidebar hover | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-border` | Sidebar borders | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |
| `--sidebar-ring` | Sidebar focus ring | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` |

### Radius

| Variabele | Beschrijving | Default |
|-----------|-------------|---------|
| `--radius` | Base radius waarde | `0.625rem` (10px) |

Alle andere radii worden berekend via `calc()`:
- `--radius-sm`: `calc(var(--radius) - 4px)`
- `--radius-md`: `calc(var(--radius) - 2px)`
- `--radius-lg`: `var(--radius)`
- `--radius-xl`: `calc(var(--radius) + 4px)`
- `--radius-2xl`: `calc(var(--radius) + 8px)`
- `--radius-3xl`: `calc(var(--radius) + 12px)`
- `--radius-4xl`: `calc(var(--radius) + 16px)`

## Dark Mode Patronen

Belangrijke observaties uit de defaults:

1. **Background/foreground inverteren**: `--background` en `--foreground` wisselen van licht naar donker
2. **Primary verschuift**: light `0.205` → dark `0.922` (L waarde inverteert)
3. **Border gebruikt alpha transparency**: dark mode `oklch(1 0 0 / 10%)` i.p.v. een solid kleur
4. **Input iets meer zichtbaar**: dark mode `oklch(1 0 0 / 15%)` — hogere alpha dan border
5. **Destructive wordt lichter**: light `0.577` → dark `0.704` (hogere L voor leesbaarheid)
6. **Chart kleuren veranderen volledig**: andere hues en hogere chroma voor leesbaarheid op donkere achtergrond
7. **Card/popover = verhoogd oppervlak**: in dark mode `0.205` (lichter dan background `0.145`)

## Completeness Checklist

Bij het genereren van een design system, verifieer dat **al deze variabelen** aanwezig zijn:

```
:root / .dark
├── --radius
├── --background / --foreground
├── --card / --card-foreground
├── --popover / --popover-foreground
├── --primary / --primary-foreground
├── --secondary / --secondary-foreground
├── --muted / --muted-foreground
├── --accent / --accent-foreground
├── --destructive
├── --border / --input / --ring
├── --chart-1 t/m --chart-5
├── --sidebar / --sidebar-foreground
├── --sidebar-primary / --sidebar-primary-foreground
├── --sidebar-accent / --sidebar-accent-foreground
└── --sidebar-border / --sidebar-ring
```

Totaal: **31 variabelen** per mode + `--radius`.
