# Plan: Add 6 global skills to project `.claude/skills/`

## Context

The project has 3 skills (`plan-review-workflow`, `prd-workflow`, `staff-engineer-review`). After scanning `~/.claude/skills/` (58 entries), 4 skills were selected. A staff engineer review identified that 3 of those 4 have broken cross-references to missing skills. To resolve all dependencies, 2 additional skills are added: `front-end-design` and `design-system`.

## Skills to add (6 total)

### 1. `front-end-design/SKILL.md` (NEW — resolves dependency)
- **Source:** `~/.claude/skills/front-end-design/SKILL.md` (45 lines)
- **Target:** `.claude/skills/front-end-design/SKILL.md`
- **Why:** Referenced by `ui-component-creator`, `mobile-friendly-design`, and `website-to-design-system`
- **Edits:** Strip auto-gen header

### 2. `design-system/` (NEW — resolves dependency)
- **Source:** `~/.claude/skills/design-system/`
- **Target:** `.claude/skills/design-system/`
- **Files:**
  - `SKILL.md` (247 lines) — extraction process, naming conventions, quality checklist
  - `templates/design-system-template.md` (536 lines) — empty template used operationally by `website-to-design-system` Phase 4
  - `examples/example-design-system.md` (496 lines) — "Luxe Finance" example, used as quality reference
- **Why:** `website-to-design-system` Phase 4 reads the template. `ui-component-creator` directs users to create a design system first.
- **Edits:** Strip auto-gen header

### 3. `ui-component-creator/SKILL.md`
- **Source:** `~/.claude/skills/ui-component-creator/SKILL.md` (191 lines)
- **Target:** `.claude/skills/ui-component-creator/SKILL.md`
- **Edits:**
  - Strip auto-gen header
  - Update "How This Skill Relates to Others" table: remove `auditswipe-components` example, replace with generic "Project-specific skill"

### 4. `mobile-friendly-design/` (SKILL.md + 2 references)
- **Source:** `~/.claude/skills/mobile-friendly-design/`
- **Target:** `.claude/skills/mobile-friendly-design/`
- **Files:**
  - `SKILL.md` (227 lines)
  - `references/layout-patterns.md` (236 lines)
  - `references/interaction-patterns.md` (411 lines)
- **Edits:** Strip auto-gen header

### 5. `website-to-design-system/` (SKILL.md + 2 references)
- **Source:** `~/.claude/skills/website-to-design-system/`
- **Target:** `.claude/skills/website-to-design-system/`
- **Files:**
  - `SKILL.md` (503 lines)
  - `references/shadcn-variables.md` (114 lines)
  - `references/oklch-guide.md` (171 lines)
- **Edits:**
  - Update Phase 4 template path: `~/.claude/skills/design-system/templates/...` → `design-system/templates/design-system-template.md` (relative to skills dir)
  - Replace `allinco-design-system.md` quality reference → `design-system/examples/example-design-system.md`
  - Update "Gerelateerde Skills" table to use relative paths

### 6. `skill-creator/SKILL.md`
- **Source:** `~/.claude/skills/skill-creator/SKILL.md` (354 lines)
- **Target:** `.claude/skills/skill-creator/SKILL.md`
- **Edits:** Strip auto-gen header
- **Note:** References `scripts/init_skill.py` and `scripts/package_skill.py` from Anthropic's skill-creator distribution (not bundled). Kept as-is per user request — the conceptual guidance is the primary value.

## Summary

| Skill | Files | ~Lines |
|-------|-------|--------|
| `front-end-design` | 1 | 45 |
| `design-system` | 3 | 1,279 |
| `ui-component-creator` | 1 | 191 |
| `mobile-friendly-design` | 3 | 874 |
| `website-to-design-system` | 3 | 788 |
| `skill-creator` | 1 | 354 |
| **Total** | **12 files** | **~3,531** |

## Edits applied to all files

1. **Strip auto-generation headers** — remove `# DO NOT EDIT - Auto-generated from ...` lines (these are project-local copies now)
2. **Fix absolute paths** — replace `~/.claude/skills/...` with relative paths within the project's `.claude/skills/`
3. **Remove project-specific references** — replace `auditswipe-components` with generic wording, replace `allinco-design-system.md` with `design-system/examples/example-design-system.md`

## Cross-reference resolution status

| Reference | Referenced by | Resolution |
|-----------|--------------|------------|
| `front-end-design` | skills 3, 4, 5 | Added as skill 1 |
| `design-system` | skills 3, 5 | Added as skill 2 |
| `design-system/templates/...` | skill 5 (Phase 4) | Bundled in skill 2 |
| `allinco-design-system.md` | skill 5 (quality ref) | Replaced with `design-system/examples/example-design-system.md` |
| `mobile-friendly-design` | skills 1, 3 | Added as skill 4 |
| `ui-component-creator` | skills 1, 4, 5 | Added as skill 3 |
| `scripts/init_skill.py` | skill 6 | Unresolved (Anthropic distro) — kept as-is |
| `../developer-planning/...` | skill 6 | Unresolved (soft ref) — degrades gracefully |

## Verification

1. Confirm all 12 files exist at their target paths
2. Grep for `~/.claude/skills/` in all new files — should return 0 matches (all converted to relative)
3. Grep for `allinco` — should return 0 matches
4. Grep for `auditswipe` — should return 0 matches
5. Verify skills appear in Claude Code's skill list
