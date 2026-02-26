# Plan: Fix Doc-Check Findings

## Context

The `/doc-check` audit found 1 FAIL and 4 WARNs. The FAIL is a Next.js version mismatch (15 vs 16) across multiple files. The WARNs are minor: word counts, prose in backend/CLAUDE.md, missing ADRs, and duplication risk. This plan fixes the FAIL and the actionable WARNs.

## Step 1: Fix Next.js version — 15 → 16 (FAIL A1)

Root CLAUDE.md (source of truth) says **Next.js 16**. Update all files that still say 15:

| File | Line | Current | Change to |
|---|---|---|---|
| `docs/architecture/c4/containers.md` | 9 | `Next.js 15, TypeScript` | `Next.js 16, TypeScript` |
| `docs/architecture/c4/containers.md` | 35 | `Next.js 15 (App Router)` | `Next.js 16 (App Router)` |
| `docs/architecture/adr/0001-frontend-tech-stack.md` | 14 | `Next.js 15 (App Router)` | `Next.js 16 (App Router)` |
| `docs/architecture/adr/0001-frontend-tech-stack.md` | 23 | `Next.js 15 met App Router` | `Next.js 16 met App Router` |
| `docs/README.md` | 26 | `Next.js 15 + TS` | `Next.js 16 + TS` |
| `docs/project-documentation-guide.md` | 26 | `Next.js 15 (App Router)` | `Next.js 16 (App Router)` |

**Note:** The `project-documentation-guide.md` occurrence is inside a template code block (a generic example of what a root CLAUDE.md might look like). We update it anyway because in a starter-kit the example *is* the project and should reflect reality.

## Step 2: Trim backend/CLAUDE.md prose (WARN D2)

Lines 43-45 contain embedded rationale. Shorten to pure rules:

```
- Local dev: bind `localhost` | Docker/production: bind `0.0.0.0`
- Nooit `0.0.0.0` in local dev
```

Replaces 3 lines with 2, also reduces word count (helps WARN D1).

## Step 3: Trim CLAUDE.md word counts (WARN D1)

After Step 2, backend/CLAUDE.md drops from ~207 to ~185 words. Root (232) and frontend (174) are close enough to the ~150 guideline that trimming risks losing useful info. No changes to root or frontend — the ~150 is a soft guideline, not a hard rule.

## Not fixing (acceptable WARNs)

- **A3 (Missing ADRs)** — Feature-first pattern and state management ADRs are nice-to-have, not blocking. Can be added organically when decisions are revisited.
- **D4 (Duplication)** — Inherent to the C4 + CLAUDE.md structure. The version fix in Step 1 resolves the acute symptom.
- **`arch-check.md` "Next.js 15" references** — `.claude/commands/arch-check.md` contains 3 occurrences of "Next.js 15" (lines 86, 237, 256). These are inside a fenced code block (the audit agent prompt) and used as **illustrative examples** of how version comparison works (e.g., `"Next.js 15" vs next@16.x = FAIL`). They are not version declarations and should not be updated.

## Files affected

| File | Action |
|---|---|
| `docs/architecture/c4/containers.md` | Edit (2 replacements) |
| `docs/architecture/adr/0001-frontend-tech-stack.md` | Edit (2 replacements) |
| `docs/README.md` | Edit (1 replacement) |
| `docs/project-documentation-guide.md` | Edit (1 replacement) |
| `backend/CLAUDE.md` | Edit (trim lines 43-45) |

## Verification

Run `/doc-check` again after changes. Expected: 0 FAILs, reduced WARNs (D1 and D2 should improve or resolve).
