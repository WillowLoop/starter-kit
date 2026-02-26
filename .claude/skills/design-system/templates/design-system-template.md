# Design System

> **Source:** [URL or "Internal codebase"]
> **Generated:** [Date]
> **Last Updated:** [Date]

## Overview

[Brief description of the design direction. What feeling should this UI evoke? Professional? Playful? Luxurious? Minimal?]

**Design Principles:**
1. [Principle 1 - e.g., "Clarity over decoration"]
2. [Principle 2 - e.g., "Consistent spacing creates rhythm"]
3. [Principle 3 - e.g., "Color with purpose"]

---

## Colors

### Brand Colors

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#` | Primary actions, links, focus states |
| `primary-hover` | `#` | Hover state for primary elements |
| `primary-active` | `#` | Active/pressed state |
| `secondary` | `#` | Secondary actions, less prominent UI |
| `secondary-hover` | `#` | Hover state for secondary |
| `accent` | `#` | Highlights, badges, decorative elements |

### Neutral Colors

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#` | Page background |
| `surface` | `#` | Cards, panels, elevated containers |
| `surface-elevated` | `#` | Modals, dropdowns, popovers |
| `border` | `#` | Default borders, dividers |
| `border-strong` | `#` | Emphasized borders, input focus |

### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `text-primary` | `#` | Headings, important text |
| `text-secondary` | `#` | Body text, descriptions |
| `text-muted` | `#` | Placeholders, helper text, disabled |
| `text-inverse` | `#` | Text on dark/primary backgrounds |

### Semantic Colors

| Token | Value | Usage |
|-------|-------|-------|
| `success` | `#` | Success states, positive actions |
| `success-bg` | `#` | Success alert backgrounds |
| `warning` | `#` | Warnings, caution states |
| `warning-bg` | `#` | Warning alert backgrounds |
| `error` | `#` | Errors, destructive actions |
| `error-bg` | `#` | Error alert backgrounds |
| `info` | `#` | Informational states |
| `info-bg` | `#` | Info alert backgrounds |

### Color Scale (Optional)

If using a full scale for flexibility:

```
gray-50:  #___   (lightest)
gray-100: #___
gray-200: #___
gray-300: #___
gray-400: #___
gray-500: #___
gray-600: #___
gray-700: #___
gray-800: #___
gray-900: #___   (darkest)
```

---

## Typography

### Font Families

| Token | Value | Usage |
|-------|-------|-------|
| `font-display` | `'___', sans-serif` | Headings, hero text |
| `font-body` | `'___', sans-serif` | Body text, UI elements |
| `font-mono` | `'___', monospace` | Code, technical content |

### Font Sizes

| Token | Size | Line Height | Usage |
|-------|------|-------------|-------|
| `text-xs` | 12px / 0.75rem | 1.5 | Badges, fine print |
| `text-sm` | 14px / 0.875rem | 1.5 | Captions, labels |
| `text-base` | 16px / 1rem | 1.5 | Body text (default) |
| `text-lg` | 18px / 1.125rem | 1.5 | Lead paragraphs |
| `text-xl` | 20px / 1.25rem | 1.4 | H4, card titles |
| `text-2xl` | 24px / 1.5rem | 1.3 | H3 |
| `text-3xl` | 30px / 1.875rem | 1.3 | H2 |
| `text-4xl` | 36px / 2.25rem | 1.2 | H1 |
| `text-5xl` | 48px / 3rem | 1.1 | Display, hero |

### Font Weights

| Token | Value | Usage |
|-------|-------|-------|
| `font-light` | 300 | Subtle text, large display |
| `font-normal` | 400 | Body text |
| `font-medium` | 500 | Emphasis, labels |
| `font-semibold` | 600 | Subheadings, buttons |
| `font-bold` | 700 | Headings, strong emphasis |

### Heading Styles

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| H1 | display | text-4xl | bold | text-primary |
| H2 | display | text-3xl | semibold | text-primary |
| H3 | display | text-2xl | semibold | text-primary |
| H4 | display | text-xl | semibold | text-primary |
| H5 | body | text-lg | semibold | text-primary |
| H6 | body | text-base | semibold | text-secondary |

---

## Spacing

Based on a **[4px / 8px]** grid system.

| Token | Value | Pixels | Common Usage |
|-------|-------|--------|--------------|
| `space-0` | 0 | 0px | Reset |
| `space-0.5` | 0.125rem | 2px | Tight inline spacing |
| `space-1` | 0.25rem | 4px | Icon padding, tight gaps |
| `space-2` | 0.5rem | 8px | Input padding, small gaps |
| `space-3` | 0.75rem | 12px | Button padding, card gaps |
| `space-4` | 1rem | 16px | Section spacing, card padding |
| `space-5` | 1.25rem | 20px | Medium spacing |
| `space-6` | 1.5rem | 24px | Large component padding |
| `space-8` | 2rem | 32px | Section margins |
| `space-10` | 2.5rem | 40px | Large section spacing |
| `space-12` | 3rem | 48px | Page section gaps |
| `space-16` | 4rem | 64px | Hero spacing |
| `space-20` | 5rem | 80px | Major section breaks |
| `space-24` | 6rem | 96px | Page-level spacing |

### Spacing Guidelines

- **Inline elements** (icon + text): `space-1` to `space-2`
- **Form fields** (label to input): `space-1` to `space-2`
- **Card padding**: `space-4` to `space-6`
- **Stack spacing** (between cards): `space-4`
- **Section spacing**: `space-8` to `space-12`
- **Page margins**: `space-4` (mobile) to `space-8` (desktop)

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-none` | 0 | Sharp corners |
| `radius-sm` | 4px / 0.25rem | Subtle rounding, badges |
| `radius-md` | 8px / 0.5rem | Buttons, inputs, small cards |
| `radius-lg` | 12px / 0.75rem | Cards, modals |
| `radius-xl` | 16px / 1rem | Large cards, panels |
| `radius-2xl` | 24px / 1.5rem | Feature sections |
| `radius-full` | 9999px | Circles, pills |

### Radius Guidelines

- **Buttons**: `radius-md`
- **Inputs**: `radius-md`
- **Cards**: `radius-lg`
- **Modals**: `radius-lg` or `radius-xl`
- **Avatars**: `radius-full`
- **Tags/Badges**: `radius-sm` or `radius-full`

---

## Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-none` | none | Flat elements |
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle lift, inputs |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, buttons on hover |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Dropdowns, popovers |
| `shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Modals |
| `shadow-inner` | `inset 0 2px 4px rgba(0,0,0,0.05)` | Pressed states, inputs |

### Elevation Guidelines

| Level | Shadow | Examples |
|-------|--------|----------|
| 0 | none | Flat UI, inline elements |
| 1 | shadow-sm | Cards at rest, inputs |
| 2 | shadow-md | Hovered cards, raised buttons |
| 3 | shadow-lg | Dropdowns, tooltips, popovers |
| 4 | shadow-xl | Modals, dialogs |

---

## Breakpoints

| Token | Value | Target |
|-------|-------|--------|
| `sm` | 640px | Large phones, landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops, tablets landscape |
| `xl` | 1280px | Laptops, desktops |
| `2xl` | 1536px | Large desktops |

### Responsive Strategy

**Mobile-first approach:**
- Default styles = mobile
- Add complexity at larger breakpoints
- Touch targets minimum 44x44px on mobile

**Common patterns:**
- Single column → 2 columns at `md` → 3+ columns at `lg`
- Stack navigation → horizontal nav at `lg`
- Full-width cards → grid at `md`

---

## Component Patterns

### Buttons

#### Primary Button

```
Background: primary
Text: text-inverse (white)
Padding: space-2 horizontal, space-3 vertical (or: py-2 px-4)
Border Radius: radius-md
Font: font-body, text-sm, font-semibold
Shadow: none (or shadow-sm)

Hover: primary-hover, shadow-md
Active: primary-active, shadow-none
Disabled: opacity 50%, cursor not-allowed
```

#### Secondary Button

```
Background: transparent
Border: 1px solid border
Text: text-primary
Padding: space-2 horizontal, space-3 vertical
Border Radius: radius-md
Font: font-body, text-sm, font-semibold

Hover: surface background
Active: surface-elevated background
Disabled: opacity 50%
```

#### Ghost Button

```
Background: transparent
Border: none
Text: text-secondary
Padding: space-2 horizontal, space-3 vertical

Hover: surface background
Active: surface-elevated background
```

#### Destructive Button

```
Background: error
Text: white
[Same dimensions as primary]

Hover: darker error
```

#### Button Sizes

| Size | Padding | Font Size | Min Height |
|------|---------|-----------|------------|
| sm | py-1 px-3 | text-xs | 32px |
| md | py-2 px-4 | text-sm | 40px |
| lg | py-3 px-6 | text-base | 48px |

---

### Cards

#### Default Card

```
Background: surface
Border: 1px solid border (optional)
Border Radius: radius-lg
Padding: space-4 to space-6
Shadow: shadow-sm

Hover (if interactive): shadow-md
```

#### Elevated Card

```
Background: surface
Border: none
Border Radius: radius-lg
Padding: space-4 to space-6
Shadow: shadow-md

Hover: shadow-lg
```

#### Card Anatomy

```
┌─────────────────────────────┐
│  [Header area]              │  ← space-4 padding
│  Title (text-lg, semibold)  │
│  Subtitle (text-sm, muted)  │
├─────────────────────────────┤  ← Optional divider
│                             │
│  [Content area]             │  ← space-4 padding
│  Body text (text-base)      │
│                             │
├─────────────────────────────┤  ← Optional divider
│  [Footer/Actions]           │  ← space-4 padding
│  Buttons aligned right      │
└─────────────────────────────┘
```

---

### Inputs

#### Text Input

```
Background: background (or surface)
Border: 1px solid border
Border Radius: radius-md
Padding: space-2 horizontal, space-2.5 vertical
Font: text-base
Text Color: text-primary
Placeholder Color: text-muted
Height: 40px (or 44px for touch)

Focus: border-color primary, ring (0 0 0 2px primary/20%)
Error: border-color error
Disabled: background gray-100, cursor not-allowed
```

#### Input with Label

```
┌─────────────────────────────┐
│  Label (text-sm, semibold)  │
│  [space-1]                  │
│  ┌───────────────────────┐  │
│  │ Input field           │  │
│  └───────────────────────┘  │
│  [space-1]                  │
│  Helper text (text-xs,      │
│  text-muted or error)       │
└─────────────────────────────┘
```

#### Select

```
Same as text input, plus:
- Chevron icon right-aligned
- Padding-right extra for icon
```

#### Checkbox / Radio

```
Size: 16px or 20px
Border: 1px solid border
Border Radius: radius-sm (checkbox), radius-full (radio)
Checked Background: primary
Checkmark: white

Label: text-base, space-2 from checkbox
```

---

### Alerts / Notifications

```
┌──────────────────────────────────┐
│ [Icon]  Title (semibold)     [X] │
│         Description text         │
└──────────────────────────────────┘

Success: success-bg background, success border-left or icon
Warning: warning-bg background, warning border-left or icon
Error: error-bg background, error border-left or icon
Info: info-bg background, info border-left or icon

Padding: space-4
Border Radius: radius-md
Border-left: 4px solid [semantic-color] (optional)
```

---

### Modal / Dialog

```
Overlay: black at 50% opacity (or background at 80%)
Modal Container:
  Background: surface
  Border Radius: radius-xl
  Shadow: shadow-xl
  Max Width: 500px (sm), 600px (md), 800px (lg)
  Padding: space-6

Header: text-xl semibold, space-4 bottom margin
Content: text-base, space-4 bottom margin
Footer: flex, justify-end, gap space-2
```

---

### Tables

```
Header:
  Background: surface (or gray-50)
  Text: text-sm, font-semibold, text-secondary
  Padding: space-3 horizontal, space-2 vertical
  Border-bottom: 1px solid border

Row:
  Background: background
  Text: text-sm
  Padding: space-3 horizontal, space-3 vertical
  Border-bottom: 1px solid border (light)

Row Hover: surface background
Row Selected: primary at 5% opacity

Cell alignment: left (text), right (numbers)
```

---

## Dark Mode (Optional)

If supporting dark mode, define these overrides:

| Token | Light | Dark |
|-------|-------|------|
| background | #ffffff | #0f0f0f |
| surface | #f9fafb | #1a1a1a |
| surface-elevated | #ffffff | #262626 |
| text-primary | #111827 | #f9fafb |
| text-secondary | #4b5563 | #9ca3af |
| text-muted | #9ca3af | #6b7280 |
| border | #e5e7eb | #374151 |

**Implementation:**
```css
@media (prefers-color-scheme: dark) {
  :root {
    --background: #0f0f0f;
    /* ... */
  }
}
```

---

## Implementation Notes

### CSS Variables

```css
:root {
  /* Colors */
  --color-primary: #_____;
  --color-primary-hover: #_____;
  /* ... */

  /* Typography */
  --font-display: '____', sans-serif;
  --font-body: '____', sans-serif;
  /* ... */

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  /* ... */
}
```

### Tailwind Integration

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        // ...
      },
      fontFamily: {
        display: 'var(--font-display)',
        body: 'var(--font-body)',
      },
      // ...
    }
  }
}
```

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| [Date] | Initial design system created | [Name/Claude] |
