# Design System — Luxe Finance

> **Source:** Inspired by Linear, Stripe, Mercury
> **Generated:** December 2025
> **Last Updated:** December 2025

## Overview

A sophisticated, premium design language for financial software. The UI should feel **trustworthy, modern, and effortlessly elegant** — like a well-tailored suit. Every element earns its place.

**Design Principles:**
1. **Quiet confidence** — Premium feels subtle, not loud. Avoid gratuitous decoration.
2. **Clarity first** — Financial data must be scannable. Hierarchy through spacing and weight.
3. **Purposeful color** — Color draws attention; use it sparingly and meaningfully.
4. **Generous whitespace** — Let elements breathe. Density ≠ professionalism.

---

## Colors

### Brand Colors

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#6366F1` | Primary actions, links, focus states |
| `primary-hover` | `#4F46E5` | Hover state for primary elements |
| `primary-active` | `#4338CA` | Active/pressed state |
| `secondary` | `#8B5CF6` | Accent, highlights |
| `secondary-hover` | `#7C3AED` | Hover state for secondary |

### Neutral Colors

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#FAFAFA` | Page background |
| `surface` | `#FFFFFF` | Cards, panels, elevated containers |
| `surface-elevated` | `#FFFFFF` | Modals, dropdowns, popovers |
| `border` | `#E5E7EB` | Default borders, dividers |
| `border-strong` | `#D1D5DB` | Emphasized borders, input focus |

### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `text-primary` | `#111827` | Headings, important text |
| `text-secondary` | `#4B5563` | Body text, descriptions |
| `text-muted` | `#9CA3AF` | Placeholders, helper text, disabled |
| `text-inverse` | `#FFFFFF` | Text on dark/primary backgrounds |

### Semantic Colors

| Token | Value | Usage |
|-------|-------|-------|
| `success` | `#10B981` | Success states, positive values |
| `success-bg` | `#ECFDF5` | Success alert backgrounds |
| `warning` | `#F59E0B` | Warnings, pending states |
| `warning-bg` | `#FFFBEB` | Warning alert backgrounds |
| `error` | `#EF4444` | Errors, negative values |
| `error-bg` | `#FEF2F2` | Error alert backgrounds |
| `info` | `#3B82F6` | Informational states |
| `info-bg` | `#EFF6FF` | Info alert backgrounds |

### Neutrals Scale

```
gray-50:  #F9FAFB
gray-100: #F3F4F6
gray-200: #E5E7EB
gray-300: #D1D5DB
gray-400: #9CA3AF
gray-500: #6B7280
gray-600: #4B5563
gray-700: #374151
gray-800: #1F2937
gray-900: #111827
```

---

## Typography

### Font Families

| Token | Value | Usage |
|-------|-------|-------|
| `font-display` | `'Inter', system-ui, sans-serif` | Headings, hero text |
| `font-body` | `'Inter', system-ui, sans-serif` | Body text, UI elements |
| `font-mono` | `'JetBrains Mono', monospace` | Code, amounts, technical |

**Note:** Inter for both display and body provides consistency. Hierarchy comes from weight and size, not font switching.

### Font Sizes

| Token | Size | Line Height | Usage |
|-------|------|-------------|-------|
| `text-xs` | 0.75rem (12px) | 1.5 | Badges, metadata |
| `text-sm` | 0.875rem (14px) | 1.5 | Labels, captions, table data |
| `text-base` | 1rem (16px) | 1.5 | Body text (default) |
| `text-lg` | 1.125rem (18px) | 1.5 | Lead paragraphs, emphasis |
| `text-xl` | 1.25rem (20px) | 1.4 | H4, card titles |
| `text-2xl` | 1.5rem (24px) | 1.3 | H3 |
| `text-3xl` | 1.875rem (30px) | 1.25 | H2 |
| `text-4xl` | 2.25rem (36px) | 1.2 | H1 |
| `text-5xl` | 3rem (48px) | 1.1 | Display, hero amounts |

### Font Weights

| Token | Value | Usage |
|-------|-------|-------|
| `font-normal` | 400 | Body text |
| `font-medium` | 500 | Labels, table headers |
| `font-semibold` | 600 | Subheadings, buttons, emphasis |
| `font-bold` | 700 | Headings, strong emphasis |

### Heading Styles

| Element | Size | Weight | Letter Spacing |
|---------|------|--------|----------------|
| H1 | text-4xl | bold | -0.025em |
| H2 | text-3xl | semibold | -0.02em |
| H3 | text-2xl | semibold | -0.015em |
| H4 | text-xl | semibold | -0.01em |
| H5 | text-lg | semibold | 0 |
| H6 | text-base | semibold | 0 |

**Amounts & Numbers:** Use `font-mono` for financial figures to ensure alignment. Consider tabular-nums for tables.

---

## Spacing

Based on a **4px** grid system.

| Token | Value | Pixels | Common Usage |
|-------|-------|--------|--------------|
| `space-0` | 0 | 0px | Reset |
| `space-0.5` | 0.125rem | 2px | Hairline gaps |
| `space-1` | 0.25rem | 4px | Icon gaps, tight spacing |
| `space-2` | 0.5rem | 8px | Input padding, small gaps |
| `space-3` | 0.75rem | 12px | Button padding |
| `space-4` | 1rem | 16px | Card padding, form spacing |
| `space-5` | 1.25rem | 20px | Medium gaps |
| `space-6` | 1.5rem | 24px | Card padding (luxe), section items |
| `space-8` | 2rem | 32px | Section margins |
| `space-10` | 2.5rem | 40px | Large section spacing |
| `space-12` | 3rem | 48px | Page section gaps |
| `space-16` | 4rem | 64px | Major section breaks |
| `space-20` | 5rem | 80px | Hero spacing |

### Spacing Philosophy

For a "luxe" feel, err on the side of **more whitespace**, not less:
- Card padding: `space-6` (not space-4)
- Section gaps: `space-12` to `space-16`
- Let numbers breathe in tables

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-none` | 0 | Data tables, sharp elements |
| `radius-sm` | 0.25rem (4px) | Badges, tags |
| `radius-md` | 0.5rem (8px) | Buttons, inputs |
| `radius-lg` | 0.75rem (12px) | Cards, panels |
| `radius-xl` | 1rem (16px) | Modals, large cards |
| `radius-2xl` | 1.5rem (24px) | Hero sections, feature cards |
| `radius-full` | 9999px | Avatars, pills |

**Design note:** Avoid mixing many different radii. Pick 2-3 and use consistently.

---

## Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.04)` | Subtle lift, inputs |
| `shadow-md` | `0 4px 8px rgba(0,0,0,0.06)` | Cards at rest |
| `shadow-lg` | `0 8px 24px rgba(0,0,0,0.08)` | Hovered cards, dropdowns |
| `shadow-xl` | `0 16px 48px rgba(0,0,0,0.12)` | Modals |

**Philosophy:** Shadows should be barely perceptible. The "luxe" feel comes from restraint — shadows suggest depth without shouting.

---

## Breakpoints

| Token | Value | Target |
|-------|-------|--------|
| `sm` | 640px | Large phones |
| `md` | 768px | Tablets |
| `lg` | 1024px | Laptops |
| `xl` | 1280px | Desktops |
| `2xl` | 1440px | Large displays |

**Content max-width:** `1200px` for main content, `1440px` for full-bleed sections.

---

## Component Patterns

### Buttons

#### Primary Button

```css
background: var(--primary);           /* #6366F1 */
color: white;
padding: 10px 16px;                   /* space-2.5 space-4 */
border-radius: var(--radius-md);      /* 8px */
font-size: var(--text-sm);            /* 14px */
font-weight: 600;
border: none;
box-shadow: 0 1px 2px rgba(0,0,0,0.05);
transition: all 150ms ease;

/* Hover */
background: var(--primary-hover);     /* #4F46E5 */
box-shadow: 0 4px 8px rgba(99,102,241,0.25);
transform: translateY(-1px);

/* Active */
background: var(--primary-active);    /* #4338CA */
transform: translateY(0);
box-shadow: none;

/* Disabled */
opacity: 0.5;
cursor: not-allowed;
```

#### Secondary Button

```css
background: white;
color: var(--text-primary);
padding: 10px 16px;
border-radius: var(--radius-md);
font-size: var(--text-sm);
font-weight: 600;
border: 1px solid var(--border);
box-shadow: 0 1px 2px rgba(0,0,0,0.04);

/* Hover */
background: var(--gray-50);
border-color: var(--border-strong);

/* Active */
background: var(--gray-100);
```

#### Ghost Button

```css
background: transparent;
color: var(--text-secondary);
padding: 10px 16px;
border: none;

/* Hover */
background: var(--gray-100);
color: var(--text-primary);
```

#### Destructive Button

```css
background: var(--error);
color: white;
/* Same dimensions as primary */

/* Hover */
background: #DC2626;  /* darker red */
```

---

### Cards

#### Default Card

```css
background: white;
border: 1px solid var(--border);
border-radius: var(--radius-lg);      /* 12px */
padding: var(--space-6);              /* 24px - luxe padding */
box-shadow: var(--shadow-sm);

/* Interactive hover (optional) */
transition: all 200ms ease;
&:hover {
  box-shadow: var(--shadow-lg);
  border-color: var(--border-strong);
}
```

#### Stats Card (Dashboard)

```
┌────────────────────────────┐
│  Total Revenue             │  ← text-sm, text-muted
│  $124,500.00               │  ← text-3xl, font-mono, font-bold
│  ↑ 12.5% from last month   │  ← text-sm, success color
└────────────────────────────┘

Padding: space-6
Background: white
Border: 1px solid border
Radius: radius-lg
```

---

### Inputs

#### Text Input

```css
background: white;
border: 1px solid var(--border);
border-radius: var(--radius-md);
padding: 10px 12px;                   /* space-2.5 space-3 */
font-size: var(--text-base);
color: var(--text-primary);
height: 44px;                         /* Touch-friendly */
transition: all 150ms ease;

/* Placeholder */
&::placeholder {
  color: var(--text-muted);
}

/* Focus */
border-color: var(--primary);
box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
outline: none;

/* Error */
border-color: var(--error);
box-shadow: 0 0 0 3px rgba(239,68,68,0.15);

/* Disabled */
background: var(--gray-50);
color: var(--text-muted);
cursor: not-allowed;
```

#### Input with Label

```
Label                              ← text-sm, font-medium, text-secondary
[space-1.5]
┌─────────────────────────────┐
│ Placeholder text            │    ← Input
└─────────────────────────────┘
[space-1.5]
Helper or error text              ← text-sm, text-muted or error
```

---

### Tables

```css
/* Header */
th {
  background: var(--gray-50);
  color: var(--text-secondary);
  font-size: var(--text-xs);
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid var(--border);
}

/* Rows */
td {
  padding: 16px;
  font-size: var(--text-sm);
  color: var(--text-primary);
  border-bottom: 1px solid var(--gray-100);
}

/* Numbers/Amounts */
.amount {
  font-family: var(--font-mono);
  font-variant-numeric: tabular-nums;
  text-align: right;
}

/* Positive/Negative values */
.positive { color: var(--success); }
.negative { color: var(--error); }

/* Row hover */
tr:hover td {
  background: var(--gray-50);
}
```

---

### Modal

```css
/* Overlay */
.overlay {
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
}

/* Modal */
.modal {
  background: white;
  border-radius: var(--radius-xl);    /* 16px */
  box-shadow: var(--shadow-xl);
  max-width: 500px;
  width: 90%;
  padding: var(--space-6);
}

/* Header */
.modal-title {
  font-size: var(--text-xl);
  font-weight: 600;
  margin-bottom: var(--space-4);
}

/* Footer */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
  margin-top: var(--space-6);
}
```

---

## Implementation

### CSS Variables

```css
:root {
  /* Colors - Brand */
  --color-primary: #6366F1;
  --color-primary-hover: #4F46E5;
  --color-primary-active: #4338CA;

  /* Colors - Neutral */
  --color-background: #FAFAFA;
  --color-surface: #FFFFFF;
  --color-border: #E5E7EB;
  --color-border-strong: #D1D5DB;

  /* Colors - Text */
  --color-text-primary: #111827;
  --color-text-secondary: #4B5563;
  --color-text-muted: #9CA3AF;

  /* Colors - Semantic */
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;

  /* Typography */
  --font-display: 'Inter', system-ui, sans-serif;
  --font-body: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;

  /* Border Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.04);
  --shadow-md: 0 4px 8px rgba(0,0,0,0.06);
  --shadow-lg: 0 8px 24px rgba(0,0,0,0.08);
  --shadow-xl: 0 16px 48px rgba(0,0,0,0.12);
}
```

---

## Changelog

| Date | Change |
|------|--------|
| Dec 2025 | Initial design system created |
