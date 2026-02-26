# shadcn/ui CSS Variables Reference

Complete list of all shadcn/ui CSS variables. Use as checklist: every design system MUST define all these variables in both `:root` and `.dark`.

## Variables Overview

### Core

| Variable | Description | `:root` default (OKLch) | `.dark` default (OKLch) |
|----------|-------------|------------------------|------------------------|
| `--background` | Page background | `oklch(1 0 0)` | `oklch(0.145 0 0)` |
| `--foreground` | Default text | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--primary` | Primary actions, links, buttons | `oklch(0.205 0 0)` | `oklch(0.922 0 0)` |
| `--primary-foreground` | Text on primary background | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--secondary` | Secondary actions | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--secondary-foreground` | Text on secondary background | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--muted` | Muted backgrounds | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--muted-foreground` | Muted text (placeholders, helpers) | `oklch(0.556 0 0)` | `oklch(0.708 0 0)` |
| `--accent` | Accent background (hover states) | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--accent-foreground` | Text on accent background | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--destructive` | Destructive/error actions | `oklch(0.577 0.245 27.325)` | `oklch(0.704 0.191 22.216)` |

### Surface

| Variable | Description | `:root` default | `.dark` default |
|----------|-------------|----------------|----------------|
| `--card` | Card background | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--card-foreground` | Text on cards | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--popover` | Popover/dropdown background | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--popover-foreground` | Text in popovers | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |

### UI Elements

| Variable | Description | `:root` default | `.dark` default |
|----------|-------------|----------------|----------------|
| `--border` | Default borders, dividers | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |
| `--input` | Input borders | `oklch(0.922 0 0)` | `oklch(1 0 0 / 15%)` |
| `--ring` | Focus ring color | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` |

### Charts

| Variable | Description | `:root` default | `.dark` default |
|----------|-------------|----------------|----------------|
| `--chart-1` | Chart color 1 | `oklch(0.646 0.222 41.116)` | `oklch(0.488 0.243 264.376)` |
| `--chart-2` | Chart color 2 | `oklch(0.6 0.118 184.704)` | `oklch(0.696 0.17 162.48)` |
| `--chart-3` | Chart color 3 | `oklch(0.398 0.07 227.392)` | `oklch(0.769 0.188 70.08)` |
| `--chart-4` | Chart color 4 | `oklch(0.828 0.189 84.429)` | `oklch(0.627 0.265 303.9)` |
| `--chart-5` | Chart color 5 | `oklch(0.769 0.188 70.08)` | `oklch(0.645 0.246 16.439)` |

### Sidebar

| Variable | Description | `:root` default | `.dark` default |
|----------|-------------|----------------|----------------|
| `--sidebar` | Sidebar background | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--sidebar-foreground` | Sidebar text | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-primary` | Sidebar active item | `oklch(0.205 0 0)` | `oklch(0.488 0.243 264.376)` |
| `--sidebar-primary-foreground` | Text on sidebar active | `oklch(0.985 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-accent` | Sidebar hover state | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--sidebar-accent-foreground` | Text on sidebar hover | `oklch(0.205 0 0)` | `oklch(0.985 0 0)` |
| `--sidebar-border` | Sidebar borders | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |
| `--sidebar-ring` | Sidebar focus ring | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` |

### Radius

| Variable | Description | Default |
|----------|-------------|---------|
| `--radius` | Base radius value | `0.625rem` (10px) |

All other radii are calculated via `calc()`:
- `--radius-sm`: `calc(var(--radius) - 4px)`
- `--radius-md`: `calc(var(--radius) - 2px)`
- `--radius-lg`: `var(--radius)`
- `--radius-xl`: `calc(var(--radius) + 4px)`
- `--radius-2xl`: `calc(var(--radius) + 8px)`
- `--radius-3xl`: `calc(var(--radius) + 12px)`
- `--radius-4xl`: `calc(var(--radius) + 16px)`

## Dark Mode Patterns

Key observations from the defaults:

1. **Background/foreground invert**: `--background` and `--foreground` swap from light to dark
2. **Primary shifts**: light `0.205` → dark `0.922` (L value inverts)
3. **Border uses alpha transparency**: dark mode `oklch(1 0 0 / 10%)` instead of a solid color
4. **Input slightly more visible**: dark mode `oklch(1 0 0 / 15%)` — higher alpha than border
5. **Destructive becomes lighter**: light `0.577` → dark `0.704` (higher L for readability)
6. **Chart colors change completely**: different hues and higher chroma for readability on dark background
7. **Card/popover = elevated surface**: in dark mode `0.205` (lighter than background `0.145`)

## Completeness Checklist

When generating a design system, verify that **all these variables** are present:

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
├── --chart-1 through --chart-5
├── --sidebar / --sidebar-foreground
├── --sidebar-primary / --sidebar-primary-foreground
├── --sidebar-accent / --sidebar-accent-foreground
└── --sidebar-border / --sidebar-ring
```

Total: **31 variables** per mode + `--radius`.
