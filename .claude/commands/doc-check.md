# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/doc-check.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Full documentation audit — verify anchored decisions, consistency, coverage, and format
---

# Doc Check — Full Documentation Audit

Read-only audit of all project documentation. Never modifies files.

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: Use the audit agent template below

## Audit Agent Prompt

```
You are a documentation auditor. You perform a read-only audit of the project's documentation ecosystem. You NEVER modify any files — only read and report.

## Phase 1: Discovery

Find and read ALL documentation files. Use Glob and Read tools.

1. All CLAUDE.md files: root, frontend/, backend/, and any sub-directories
2. docs/architecture/c4/context.md, docs/architecture/c4/containers.md, docs/architecture/c4/components.md
3. docs/project-documentation-guide.md
4. docs/README.md
5. All files in docs/architecture/adr/ (including _template.md)

If a file doesn't exist, note it as missing — don't fail silently.

## Phase 2: Audit

Run four audit categories. Track each check as PASS, WARN, or FAIL.

### Category A: Anchored Decisions

Root CLAUDE.md is the single source of truth for fixed tech stack and patterns.

A1. Tech stack consistency:
- Extract tech stack entries from root CLAUDE.md (the Stack: line and any framework/library mentions)
- Verify each appears consistently in:
  - frontend/CLAUDE.md (frontend stack items)
  - backend/CLAUDE.md (backend stack items)
  - docs/architecture/c4/components.md (Architectuurpatronen section)
  - docs/architecture/c4/containers.md (Per container section)
- FAIL if a fixed tech choice is missing or contradicted in any of these files
- Placeholder brackets like [Next.js / React / ...] in C4 docs count as "not yet filled in" — WARN, not FAIL

A2. Pattern consistency:
- Extract fixed patterns from root CLAUDE.md and directory CLAUDE.md files:
  - Feature-first / vertical slicing
  - Router → Service → Repository (backend)
  - Component → Hook → API Layer (frontend)
  - Server Components default (frontend)
- Verify these patterns appear consistently in docs/architecture/c4/components.md
- FAIL if a pattern is contradicted; WARN if simply not mentioned

A3. ADR backing:
- Each fixed tech/pattern choice should have a corresponding ADR in docs/architecture/adr/
- If the ADR exists with real content → PASS
- If there's an ADR-NNNN placeholder (in components.md, containers.md, or elsewhere) → WARN
- If no ADR and no placeholder exists for a major decision → FAIL

### Category B: Consistency

B1. Backend structure paths:
- Compare the directory structure described in backend/CLAUDE.md with:
  - The "Backend Components" table in docs/architecture/c4/components.md
  - The backend example in docs/project-documentation-guide.md (if present)
- FAIL if paths contradict each other (e.g., different directory names for the same module)

B2. Frontend structure paths:
- Compare the directory structure described in frontend/CLAUDE.md with:
  - The "Frontend Components" table in docs/architecture/c4/components.md
  - The frontend example in docs/project-documentation-guide.md (if present)
- FAIL if paths contradict each other

B3. File size limits:
- Collect file size limits from:
  - frontend/CLAUDE.md (File limieten table)
  - backend/CLAUDE.md (File limieten table)
  - docs/architecture/c4/components.md (File Size Limieten table)
- Verify the max values match across files
- FAIL if limits contradict; WARN if a type exists in one file but not the other

### Category C: Coverage

C1. Required CLAUDE.md files:
- frontend/CLAUDE.md must exist
- backend/CLAUDE.md must exist
- Root CLAUDE.md must exist
- FAIL for each missing file

C2. C4 representation:
- Both frontend and backend must appear in docs/architecture/c4/components.md (separate tables/sections)
- Both must appear in docs/architecture/c4/containers.md (in the containers table)
- FAIL if either is missing from either file

C3. Bootstrap checklist completeness:
- docs/README.md must have a Bootstrap Checklist section
- The checklist should reference: root CLAUDE.md, frontend/CLAUDE.md, backend/CLAUDE.md, context.md, containers.md, components.md
- WARN if a reference is missing

C4. File type coverage in size limits:
- docs/architecture/c4/components.md File Size Limieten table should cover:
  - Frontend types: Component, Hook (at minimum)
  - Backend types: Router, Service, Repository (at minimum)
- WARN for each type category not covered

### Category D: Token & Format

D1. Word count per CLAUDE.md:
- Count words in each CLAUDE.md file (approximate: split on whitespace)
- WARN if any CLAUDE.md exceeds ~150 words (proxy for ~200 tokens)
- Report exact word count for each

D2. No prose in CLAUDE.md:
- Scan each CLAUDE.md for explanatory prose indicators:
  - Words like "omdat", "want", "doordat", "because", "since", "the reason"
  - Paragraphs longer than 3 lines without bullet points or table formatting
- WARN if prose detected (CLAUDE.md should be facts/rules, not explanations)

D3. Decision tree compliance:
- CLAUDE.md files should NOT contain architecture descriptions (that belongs in C4 docs)
- ADR files should NOT contain coding conventions (that belongs in CLAUDE.md)
- WARN for violations

D4. Content duplication:
- Check for significant content blocks that appear verbatim (or near-verbatim) in multiple files
- WARN if the same information is maintained in multiple places (increases drift risk)

## Phase 3: Report

Output EXACTLY this format:

## Doc Check Report

### Anchored Decisions
- [PASS/FAIL] A1: Tech stack consistent (root CLAUDE.md → directory CLAUDE.md → C4 docs)
  [details if not PASS]
- [PASS/FAIL] A2: Patterns consistent (feature-first, Router→Service→Repository, Component→Hook→API)
  [details if not PASS]
- [PASS/WARN/FAIL] A3: ADR backing for fixed choices
  [details if not PASS]

### Consistency
- [PASS/FAIL] B1: Backend structure paths consistent
  [details if not PASS]
- [PASS/FAIL] B2: Frontend structure paths consistent
  [details if not PASS]
- [PASS/FAIL/WARN] B3: File size limits match across files
  [details if not PASS]

### Coverage
- [PASS/FAIL] C1: All required CLAUDE.md files present
  [details if not PASS]
- [PASS/FAIL] C2: Frontend + Backend in components.md + containers.md
  [details if not PASS]
- [PASS/WARN] C3: Bootstrap checklist complete
  [details if not PASS]
- [PASS/WARN] C4: File type coverage in size limits
  [details if not PASS]

### Token & Format
- [PASS/WARN] D1: CLAUDE.md word counts
  - root CLAUDE.md: X words (max ~150)
  - frontend/CLAUDE.md: X words
  - backend/CLAUDE.md: X words
- [PASS/WARN] D2: No prose in CLAUDE.md files
  [details if not PASS]
- [PASS/WARN] D3: Decision tree compliance
  [details if not PASS]
- [PASS/WARN] D4: No content duplication
  [details if not PASS]

### Verdict: [DOCS HEALTHY / DOCS NEED ATTENTION / DOCS BROKEN]

[Summary + prioritized fix list if not HEALTHY]

## Verdict Logic

- All PASS → DOCS HEALTHY
- At least one WARN, no FAIL → DOCS NEED ATTENTION
- At least one FAIL → DOCS BROKEN

## Rules

- IMPORTANT: This is a READ-ONLY command. NEVER create, modify, or delete any files.
- Be precise: quote the conflicting text when reporting FAIL
- Be helpful: for each FAIL/WARN, suggest the specific fix needed
- Placeholders (text in square brackets like [Next.js / React / ...]) are expected in a starter-kit — WARN, not FAIL
- ADR-NNNN placeholders are expected early in a project — WARN, not FAIL
- Count only real ADR files (not _template.md) when checking ADR backing
```

## Rules

- This command is read-only — it NEVER modifies files
- Always use Opus model for the subagent (complex cross-file analysis)
- Single subagent handles all four audit categories
- No $ARGUMENTS — always audits the entire project
- Report all findings, even when everything passes
