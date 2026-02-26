---
name: website-to-design-system
description: >-
  Generate a complete, ready-to-use design system from a website URL as
  inspiration. Analyzes the visual design language and produces a design system
  document, OKLch CSS variables (Tailwind CSS 4 compatible), and font setup.
  Use for: "create design system from [URL]", "use [URL] as design
  inspiration", or "/design-from-website [URL]".
  Note: For Tailwind 3 projects (tailwind.config.ts), use design-system-bootstrap.
---

# Website-to-Design-System

Generate a complete design system from a website URL as inspiration. Produces:
1. A design system markdown document (project-local skill)
2. OKLch CSS variables in `globals.css` (Tailwind CSS 4 + shadcn/ui compatible)
3. Google Font setup in `layout.tsx`

## When to Use

- "Create a design system based on [URL]"
- "Use [URL] as design inspiration"
- `/design-from-website [URL]`
- "I want a design like [URL] but with [adjustments]"

## When NOT to Use

- **Tailwind 3 projects** (with `tailwind.config.ts` and `extend.colors`) → use `design-system-bootstrap`
- **Only component structure** → use `ui-component-creator`
- **Only creative direction** → use `front-end-design`

## Related Skills (reference, don't duplicate)

| Skill | What it delivers | How this skill uses it |
|-------|-----------------|----------------------|
| `design-system` | Token extraction, naming conventions | Phase 2: extraction techniques |
| `design-system/templates/design-system-template.md` | Document structure (536 lines) | Phase 4: template for output |
| `design-system/examples/example-design-system.md` | Quality reference: Tailwind classes, do's/don'ts | Phase 4: quality standard |
| `front-end-design` | Creative direction: Purpose/Tone/Constraints | Phase 3: aesthetic analysis |
| `ui-component-creator` | Component patterns: forwardRef, cn(), CVA, a11y | Component section in document |
| `mobile-friendly-design` | Responsive and touch target patterns | Responsive section in document |

---

## Phase 1: Input & Detection

### Input

The user provides:
- **Required**: One website URL as inspiration
- **Optional**: Project name, aesthetic keywords ("minimal", "playful", "premium")

### Actions

**1. Accept the URL** from the user.

**2. Detect the target project:**

```
Find: components.json in working directory or subdirectories
  ↓
Read: tailwind.css path from components.json
  ↓ IMPORTANT: resolve relative to components.json location
  ↓ e.g. frontend/components.json with css: "src/app/globals.css"
  ↓      → frontend/src/app/globals.css
  ↓
Read: globals.css → confirm Tailwind 4:
  - @import "tailwindcss" present
  - @theme inline block present
  ↓
Check: does a *-design-system.md skill already exist?
  → Yes: ask user: replace or merge?
  ↓
Check: does a tailwind.config.ts with custom colors exist?
  → Yes: warn that this is a Tailwind 3 pattern
  → Suggest: use design-system-bootstrap for Tailwind 3
```

**3. Determine project name:**
- Read `name` from `package.json` in the project root
- Or ask the user

### Quick Mode (Fallback)

If WebFetch fails or the user already knows what they want ("make a design like Stripe but with green accents"):
- Accept direct input: 3-5 key colors (hex) + font name + aesthetic direction
- Skip Phase 2 → go directly to Phase 3

### Output

Config context: project path, globals.css path, layout.tsx path, project name, existing variables.

---

## Phase 2: Website Analysis

### Goal

Extract visual design language from the inspiration website.

### Actions

**1. Fetch the website:**

```
WebFetch main URL → analyze HTML for:
├── <link rel="stylesheet"> URLs → fetch each stylesheet (max 5)
├── Inline <style> blocks (SSR sites emit critical CSS inline)
├── CSS custom properties (--var: value)
├── Google Fonts links (families + weights)
└── <meta name="theme-color">
```

**2. Extract tokens from collected CSS:**

| Token Type | What to look for | How to group |
|-----------|-----------------|-------------|
| **Colors** | `color:`, `background:`, `border-color:`, CSS vars with color values | primary / secondary / neutral / semantic |
| **Typography** | `font-family`, `font-size`, `font-weight`, `line-height` | Identify heading hierarchy |
| **Spacing** | `margin`, `padding`, `gap` values | Determine grid basis (4px or 8px) |
| **Border radius** | `border-radius` values | small / medium / large |
| **Shadows** | `box-shadow` | Elevation levels |

**3. Identify component patterns:**
Buttons, cards, inputs, navigation.

### Fallback for Limited CSS

Many sites use CSS-in-JS, bundled CSS, or are SPAs. When CSS is insufficient:

1. **Try common CSS paths:**
   - `/styles.css`
   - `/_next/static/css/*.css` (Next.js)
   - `/assets/css/*.css`

2. **Analyze rendered markdown** for visual hints:
   - Color words, font names, layout description

3. **If insufficient — explicitly ask the user for:**
   - 3-5 key colors (hex): primary, secondary/accent, text, background
   - Font name (display + body)
   - Desired mood (minimal, playful, premium, etc.)

4. **Combine** what could be extracted with the user input.

### Output

Extracted tokens (raw): colors, fonts, spacing, radii, shadows.

---

## Phase 3: Creative Direction & Token Refinement

### Goal

Transform raw data into an intentional design system.

### 3.1 Aesthetic Analysis

Analyze via the `front-end-design` thinking framework:
- **Purpose**: What does this design communicate? (trustworthy, playful, premium, minimal)
- **Tone**: What aesthetic archetype?
- **Differentiation**: What makes this design distinctive?

### 3.2 Token Refinement

1. **Deduplicate** similar colors
2. **Assign semantic names** matching ALL shadcn/ui variables.

Full variable list (see `references/shadcn-variables.md` for details):

```
Core:       background, foreground, primary, primary-foreground,
            secondary, secondary-foreground, muted, muted-foreground,
            accent, accent-foreground, destructive
Surface:    card, card-foreground, popover, popover-foreground
UI:         border, input, ring
Charts:     chart-1 through chart-5
Sidebar:    sidebar, sidebar-foreground, sidebar-primary,
            sidebar-primary-foreground, sidebar-accent,
            sidebar-accent-foreground, sidebar-border, sidebar-ring
Radius:     --radius (base value)
```

3. **Normalize typography** to standard Tailwind scale
4. **Define base `--radius` value** (all other radii are calculated via `calc()`)

### 3.3 OKLch Conversion

Convert all colors to `oklch(L C h)` format. Use `references/oklch-guide.md` as reference.

**Required**: hex comment next to each OKLch value:
```css
--primary: oklch(0.556 0.249 277.023); /* #635bff */
```

Generate `:root` (light) and `.dark` variants.

### 3.4 Dark Mode Generation

Use the proven structure from the existing `globals.css` as reference, NOT a naive inversion:

| Variable | Light → Dark transformation |
|----------|---------------------------|
| `--background` | Dark background (L ~0.145) |
| `--foreground` | Light text (L ~0.985) |
| `--primary` | **Lighter** version (increase L) |
| `--primary-foreground` | **Darker** version (decrease L) |
| `--card` / `--popover` | Elevated surface (L ~0.205, lighter than background) |
| `--secondary` / `--muted` / `--accent` | L ~0.269 |
| `--destructive` | Increase L, slightly decrease C for readability |
| `--border` | **Alpha transparency**: `oklch(1 0 0 / 10%)` |
| `--input` | Slightly higher alpha: `oklch(1 0 0 / 15%)` |
| `--chart-*` | Higher chroma, adjusted hues for dark background |

### 3.5 Design Principles

Formulate 3-4 design principles based on the analysis.

### Output

Refined design system spec: all tokens, dark mode, principles.

---

## Phase 4: Design System Document + Review Checkpoint

### Goal

Generate the authoritative design system markdown document.

### Actions

**1. Use template and quality reference:**
- Template: `design-system/templates/design-system-template.md`
- Quality: `design-system/examples/example-design-system.md`

**2. Fill all sections:**

| Section | Content |
|---------|---------|
| Overview | Design principles, aesthetic direction |
| Colors | OKLch values + hex equivalents, semantic names |
| Typography | Families, scale, weights, heading styles |
| Spacing | System (4px or 8px grid) |
| Border radius & Shadows | Radii with calc() relationship, elevation levels |
| Component patterns | Button, card, input, modal — as **Tailwind class combinations** |
| Animations & transitions | Timing, easing, motion patterns |
| Accessibility | Focus states, touch targets 44px min, ARIA |
| Responsive | Mobile-first patterns, breakpoints |
| Do's and Don'ts | Concrete examples |
| Quick reference | Import snippets, commonly used combinations |

**3. Tailwind 4 specific:**
All implementation notes use CSS variables + `@theme inline` pattern, NOT `tailwind.config.ts`.

**4. Quality Checklist:**

- [ ] All colors have semantic names
- [ ] Contrast check: primary text on backgrounds WCAG AA (4.5:1)
- [ ] Typography hierarchy complete (h1 through h6 + body)
- [ ] Spacing consistent on 4px grid
- [ ] Minimum: button, card, input patterns defined
- [ ] Dark mode defined for all variables
- [ ] Breakpoints defined with use cases
- [ ] All 31 shadcn/ui variables present in both `:root` and `.dark`

### REVIEW CHECKPOINT

**Present summary to the user:**

```
Design System Preview
━━━━━━━━━━━━━━━━━━━━━━━━

Colors:
  Primary:   [hex] ████ — [description]
  Secondary: [hex] ████ — [description]
  Accent:    [hex] ████ — [description]

Font:
  Display: [font name]
  Body:    [font name]

Design Principles:
  1. [Principle]
  2. [Principle]
  3. [Principle]

Example Button:
  [Tailwind classes]

Example Card:
  [Tailwind classes]
```

**Ask**: "Would you like to adjust anything? (warmer colors, different font, more/less contrast, etc.)"

**On feedback:**
- Return to Phase 3 with adjustment, regenerate Phase 4
- Communicate iteration count: "This is refinement 2/3"
- **Max 3 refinement iterations** — on 4th request: ask user to be more specific

**On "looks good"** → proceed to Phase 5.

### Output

Design system document → save as:
`{project}/.claude/skills/{projectName}-design-system.md`

This is project-local (not global) so the design system stays with the project.

---

## Phase 5: Code Implementation + Verification

### 5a. Update `globals.css`

**Replace ONLY the `:root` and `.dark` CSS variable blocks.**

**DO NOT modify:**
- `@import "tailwindcss"`
- `@import "tw-animate-css"`
- `@import "shadcn/tailwind.css"`
- `@custom-variant dark (...)`
- `@theme inline { ... }` structure — the mappings (`--color-primary: var(--primary)` etc.) remain UNCHANGED
- `@layer base { ... }`
- Any user-added custom variables

**DO modify if fonts change:**
- `--font-sans` in `@theme inline` → `var(--font-{newname})`

### 5b. Update `layout.tsx` (if font changes)

**First verify** that the font is available via `next/font/google`.

If the font is proprietary (San Francisco, Söhne, Circular, Graphik, etc.):
1. Inform the user
2. Suggest the closest Google Fonts alternative
3. Only apply after approval

For available fonts:
- Replace the Google Font import
- Update the `variable` name: `--font-{name}` must match `globals.css`

### 5c. Verification

**1. Read generated/modified files back:**
- No placeholders left behind
- All 31 shadcn/ui variables present in `:root` AND `.dark`
- `@theme inline` block structurally intact
- OKLch values valid: L: 0-1, C: 0-0.5, h: 0-360

**2. Component compatibility:**
Existing shadcn/ui components (button, card, input) use semantic classes (`bg-primary`, `text-foreground`) → automatically inherit the new design system.

**3. Present summary:**

```
Design System Implemented
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Modified files:
  - [path]/globals.css (CSS variables)
  - [path]/layout.tsx (font import)

New files:
  - .claude/skills/[project]-design-system.md

Highlights:
  - Primary: [color description]
  - Font: [font name]
  - [X] variables defined

Next step:
  pnpm dev → open localhost:3000 → verify visually:
  1. Primary button color correct
  2. Card background and text color
  3. Dark mode (if .dark class toggle present)
  4. Font rendering
```

---

## globals.css Structure Reference

The `globals.css` has this exact structure that must be preserved:

```css
@import "tailwindcss";
@import "tw-animate-css";
@import "shadcn/tailwind.css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);        /* ← THIS MAY CHANGE */
  --font-mono: var(--font-geist-mono);
  --color-sidebar-ring: var(--sidebar-ring);
  /* ... all other --color-* mappings ... */
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
  /* ... REPLACE THESE VALUES ... */
}

.dark {
  --background: oklch(...);
  /* ... REPLACE THESE VALUES ... */
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

## Example Invocations

```
"Create a design system based on https://linear.app"

"Use https://stripe.com as inspiration for our fintech project"

"/design-from-website https://vercel.com"

"Make a design like Notion but with warmer colors and a serif font"

"Design system from https://cal.com — I want the same clean look but in blue"
```

---

## Full Variables Checklist

When generating `:root` and `.dark`, verify that ALL variables are present:

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

Total: **31 variables** per mode + `--radius`. Repeat the same block for `.dark`.
