# OKLch Color Space Reference

## What is OKLch?

OKLch is a perceptually uniform color space. Unlike hex/RGB, where equal numerical steps don't appear equal to the eye, OKLch is designed so that equal steps in values also feel equal.

**Format**: `oklch(L C h)` or `oklch(L C h / alpha)`

| Parameter | Range | Description |
|-----------|-------|-------------|
| **L** (Lightness) | `0` – `1` | Perceptual lightness. `0` = black, `1` = white |
| **C** (Chroma) | `0` – `~0.4` | Color saturation. `0` = gray, higher values = more vivid. Practical max ~0.37 |
| **h** (Hue) | `0` – `360` | Hue as angle on the color wheel |

## Hue Reference

| Angle | Color |
|-------|-------|
| 0–30 | Red → Red-orange |
| 30–70 | Orange → Yellow |
| 70–140 | Yellow → Green |
| 140–200 | Green → Cyan |
| 200–260 | Cyan → Blue |
| 260–310 | Blue → Purple/Violet |
| 310–360 | Magenta → Red |

## Common Colors: Hex → OKLch

### Base Colors

| Color | Hex | OKLch |
|-------|-----|-------|
| White | `#ffffff` | `oklch(1 0 0)` |
| Black | `#000000` | `oklch(0 0 0)` |
| Red | `#ef4444` | `oklch(0.637 0.237 25.331)` |
| Orange | `#f97316` | `oklch(0.724 0.192 47.604)` |
| Amber | `#f59e0b` | `oklch(0.769 0.188 70.08)` |
| Yellow | `#eab308` | `oklch(0.795 0.184 86.047)` |
| Green | `#22c55e` | `oklch(0.723 0.219 149.579)` |
| Emerald | `#10b981` | `oklch(0.696 0.17 162.48)` |
| Teal | `#14b8a6` | `oklch(0.697 0.146 174.358)` |
| Cyan | `#06b6d4` | `oklch(0.715 0.143 215.221)` |
| Blue | `#3b82f6` | `oklch(0.623 0.214 259.815)` |
| Indigo | `#6366f1` | `oklch(0.585 0.233 277.117)` |
| Violet | `#8b5cf6` | `oklch(0.606 0.25 292.717)` |
| Purple | `#a855f7` | `oklch(0.627 0.265 303.9)` |
| Fuchsia | `#d946ef` | `oklch(0.667 0.295 322.15)` |
| Pink | `#ec4899` | `oklch(0.656 0.241 354.308)` |
| Rose | `#f43f5e` | `oklch(0.645 0.246 16.439)` |

### Neutral Shades (Neutral / Zinc)

| Shade | Hex | OKLch |
|-------|-----|-------|
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

### Popular Brand Colors (approximations)

| Brand | Color | Hex | OKLch |
|-------|-------|-----|-------|
| Stripe | Purple | `#635bff` | `oklch(0.556 0.249 277.023)` |
| Stripe | Blue | `#0a2540` | `oklch(0.243 0.042 245.935)` |
| Linear | Purple | `#5e6ad2` | `oklch(0.562 0.162 277.892)` |
| Vercel | Black | `#000000` | `oklch(0 0 0)` |
| Tailwind | Blue | `#38bdf8` | `oklch(0.773 0.15 230.067)` |
| GitHub | Blue | `#1f6feb` | `oklch(0.546 0.196 256.802)` |
| Figma | Red | `#f24e1e` | `oklch(0.629 0.222 28.717)` |

## shadcn/ui Default Palette as Reference

The full shadcn/ui neutral palette (as used in the starter kit):

### Light mode (`:root`)

```css
--background: oklch(1 0 0);           /* #ffffff — White */
--foreground: oklch(0.145 0 0);       /* #0a0a0a — Near black */
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
--destructive: oklch(0.704 0.191 22.216); /* ~#f43f5e lighter for dark */
--border: oklch(1 0 0 / 10%);        /* White with 10% alpha */
--input: oklch(1 0 0 / 15%);         /* White with 15% alpha */
--ring: oklch(0.556 0 0);            /* #737373 */
```

## Conversion Tips

### Hex to OKLch

1. Use browser DevTools: type hex, click color swatch, switch to OKLch
2. CSS: `oklch(from #hex l c h)` (relative color syntax, widely supported)
3. Online: oklch.com or colorjs.io

### OKLch Manipulation

| Operation | What to do |
|-----------|-----------|
| **Lighten** | Increase L (e.g. `0.5` → `0.7`) |
| **Darken** | Decrease L (e.g. `0.5` → `0.3`) |
| **More saturated** | Increase C (e.g. `0.15` → `0.25`) |
| **Less saturated** | Decrease C (e.g. `0.25` → `0.10`) |
| **Complementary color** | h + 180° (e.g. `25` → `205`) |
| **Analogous colors** | h ± 30° |
| **Triadic** | h, h+120°, h+240° |

### Dark Mode Transformation Rules

| Variable | Light → Dark transformation |
|----------|---------------------------|
| `background` | L: high → low (`1` → `0.145`) |
| `foreground` | L: low → high (`0.145` → `0.985`) |
| `primary` | Invert L, keep C, keep h |
| `primary-foreground` | Opposite of primary |
| `secondary/muted/accent` | L: ~0.97 → ~0.269 |
| `destructive` | Increase L for readability, slightly decrease C |
| `border` | Solid → alpha transparency (`oklch(1 0 0 / 10%)`) |
| `input` | Slightly higher alpha than border (`/ 15%`) |
| `chart-*` | Higher chroma, adjusted hues for dark background |

### Required Conventions

1. **Always hex comment**: `--primary: oklch(0.556 0.249 277.023); /* #635bff */`
2. **Verify visually**: Open browser DevTools → Computed Styles → check color
3. **L validation**: L must be between 0 and 1
4. **C validation**: C must be between 0 and ~0.4 (most colors < 0.3)
5. **h validation**: h must be between 0 and 360
6. **Neutral colors**: C = 0, h = 0 (or omitted)
