# Design System Extractor Skill

## Purpose

Extract or generate a complete design system from an external website or existing codebase. The output is a single authoritative markdown document that defines all design tokens and component patterns.

## When to Use

- Starting a new project and want to match an existing site's look
- Documenting an existing codebase's implicit design decisions
- Creating consistency across a project that grew organically
- Onboarding: "here's how our app should look"

## Input Options

| Source | Command | What it does |
|--------|---------|--------------|
| External URL | `Extract design system from [URL]` | Fetches site, analyzes CSS/styles |
| Own codebase | `Extract design system from codebase` | Analyzes existing CSS/Tailwind files |
| From scratch | `Create design system for [description]` | Generates based on requirements |

---

## Process

### Step 1: Gather Source Material

**For external URL:**
```bash
# Fetch the page
web_fetch [URL]

# Look for linked stylesheets in the HTML
# Extract inline styles
# Note: computed styles require rendering, so focus on declared CSS
```

**For codebase:**
```bash
# Find all style-related files
rg --files -g "*.css" -g "*.scss" -g "tailwind.config.*"

# Read existing token files if present
view [path/to/styles]

# Check for existing design documentation
view [path/to/design-docs]
```

### Step 2: Extract Tokens

Analyze the source and extract:

| Token Type | What to Look For |
|------------|------------------|
| **Colors** | `color:`, `background:`, `border-color:`, CSS variables with color values |
| **Typography** | `font-family:`, `font-size:`, `font-weight:`, `line-height:`, `letter-spacing:` |
| **Spacing** | `margin:`, `padding:`, `gap:`, consistent values like 4px, 8px, 16px, 24px |
| **Border Radius** | `border-radius:` values, group into small/medium/large |
| **Shadows** | `box-shadow:` values, identify elevation levels |
| **Breakpoints** | `@media` queries, identify responsive breakpoints |

### Step 3: Identify Patterns

Look for repeated styling combinations on:

- **Buttons**: primary, secondary, ghost, destructive variants
- **Cards**: container styling, padding, shadows
- **Inputs**: text fields, selects, checkboxes
- **Typography**: heading hierarchy, body text, captions
- **Layout**: common spacing patterns, grid systems

### Step 4: Generate Design System Document

Use the template at `templates/design-system-template.md` to create the output.

**Output location:** `[project]/design-system.md` or `[project]/agent-os/standards/design-system.md`

---

## Extraction Techniques

### From CSS Files

```python
# Pseudo-code for extraction logic

# Colors: find all color declarations
colors = extract_pattern(css, r'#[0-9a-fA-F]{3,8}|rgb\([^)]+\)|hsl\([^)]+\)')

# Group similar colors (within threshold)
color_groups = cluster_colors(colors, threshold=10)

# Name semantically based on usage context
# - Used on buttons? -> primary/secondary
# - Used on errors? -> error/destructive
# - Used on backgrounds? -> surface/background
```

### From Tailwind Config

```javascript
// If tailwind.config.js exists, extract directly:
// - theme.colors
// - theme.spacing
// - theme.fontSize
// - theme.borderRadius
// - theme.boxShadow
// - theme.screens (breakpoints)
```

### From External Website

```bash
# 1. Fetch HTML
web_fetch https://example.com

# 2. Find stylesheet links
# <link rel="stylesheet" href="/styles.css">

# 3. Fetch each stylesheet
web_fetch https://example.com/styles.css

# 4. Parse and extract tokens
```

---

## Naming Conventions

### Colors

```markdown
## Semantic (preferred)
primary, primary-hover, primary-active
secondary, secondary-hover
background, surface, surface-elevated
text-primary, text-secondary, text-muted
border, border-strong
success, warning, error, info

## With scales (for flexibility)
gray-50, gray-100, gray-200 ... gray-900
primary-50, primary-100 ... primary-900
```

### Typography

```markdown
## Size scale (t-shirt sizing)
text-xs, text-sm, text-base, text-lg, text-xl, text-2xl, text-3xl, text-4xl

## Semantic alternatives
text-caption, text-body, text-body-lg, text-heading-sm, text-heading, text-heading-lg, text-display
```

### Spacing

```markdown
## Numeric scale (based on 4px grid)
space-0: 0
space-1: 4px (0.25rem)
space-2: 8px (0.5rem)
space-3: 12px (0.75rem)
space-4: 16px (1rem)
space-6: 24px (1.5rem)
space-8: 32px (2rem)
space-12: 48px (3rem)
space-16: 64px (4rem)
```

---

## Quality Checklist

Before finalizing the design system document, verify:

- [ ] **Colors**: All colors have semantic names, not just hex values
- [ ] **Contrast**: Primary text on backgrounds meets WCAG AA (4.5:1)
- [ ] **Typography**: Clear hierarchy from body to h1
- [ ] **Spacing**: Consistent scale (usually 4px or 8px based)
- [ ] **Components**: At minimum: button, card, input patterns defined
- [ ] **Dark mode**: Considered or explicitly excluded with reasoning
- [ ] **Responsive**: Breakpoints defined with use cases

---

## Integration

Once the design system document is generated:

### 1. Place in Project

```
project/
├── design-system.md          # Root level for small projects
└── agent-os/
    └── standards/
        └── design-system.md  # Or in standards for larger projects
```

### 2. Reference in CLAUDE.md

Add to your CLAUDE.md:

```markdown
## Design System

**Authoritative source:** `/design-system.md` (or path)

Before creating any UI component:
1. Check design-system.md for existing tokens
2. Use defined colors, spacing, typography
3. Follow component patterns for buttons, cards, inputs
4. Never hardcode values that exist as tokens
```

### 3. Enforce in Reviews

The design system becomes a checklist:
- Does this component use tokens or hardcoded values?
- Does new UI follow established patterns?
- If introducing new tokens, are they added to the system?

---

## Example Commands

```
"Extract design system from https://linear.app"

"Analyze my codebase and create a design system document"

"Create a design system for a professional accounting SaaS with a luxurious feel"

"Look at https://stripe.com and create a similar design system for my fintech app"
```

---

## Files

- `templates/design-system-template.md` - Empty template with all sections
- `examples/example-design-system.md` - Complete example for reference
