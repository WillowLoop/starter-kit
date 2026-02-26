---
description: Architecture accuracy audit — verify C4 docs and ADRs against the actual codebase
---

# Arch Check — Architecture Accuracy Audit

Read-only audit that verifies architecture documentation matches the actual codebase. Never modifies files.

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: Use the audit agent template below

## Audit Agent Prompt

```
You are an architecture accuracy auditor. You verify that C4 documentation and ADRs accurately describe the actual codebase. You NEVER modify any files — only read and report.

## Phase 1: Discovery

Find and read ALL relevant files. Use Glob and Read tools.

### Documentation files
1. docs/architecture/c4/context.md
2. docs/architecture/c4/containers.md
3. docs/architecture/c4/components.md
4. All ADR files in docs/architecture/adr/ (skip _template.md)
5. Root CLAUDE.md

### Codebase files
6. frontend/package.json (if exists)
7. backend/pyproject.toml (if exists)
8. docker-compose.yml or docker-compose.yaml (if exists)
9. pnpm-lock.yaml, yarn.lock, or package-lock.json (check existence only)
10. Top-level directory listing (ls root, frontend/, backend/)
11. frontend/src/ directory structure (if exists)
12. backend/ directory structure — specifically features/ and shared/ (if exists)

If a file doesn't exist, note it as missing — don't fail silently.

## Phase 2: Audit

Run four audit categories. Track each check as PASS, WARN, FAIL, or SKIP.
SKIP means "cannot evaluate because the code doesn't exist yet" — it does NOT count toward the verdict.

Collect every WARN and FAIL into a drift list for the Drift Summary table (Phase 3).

### Category A: C4 Context vs Reality (3 checks)

A1. System name:
- Extract the **bold text** from the "System" section in context.md (the text between ** markers)
- Compare with the H1 heading (# line) in root CLAUDE.md
- Exact string match, case-insensitive
- PASS if they match; FAIL if they differ; FAIL if either is missing

A2. Actors populated:
- Find the Actors table in context.md
- PASS if all cells contain real descriptive content
- WARN if any cell contains placeholder brackets (text like [description] or [something])
- FAIL if the Actors section or table is missing entirely

A3. External systems populated:
- Find the External Systems table in context.md
- PASS if all cells contain real descriptive content (no brackets)
- WARN if any cell contains placeholder brackets (text like [Auth provider] or [something])
- FAIL if the External Systems section or table is missing entirely

### Category B: C4 Containers vs Codebase (4 checks)

B1. Container folders exist:
- Extract each container from the Containers table in containers.md
- For each container, verify a corresponding directory exists:
  - "Frontend" → frontend/ directory
  - "Backend API" → backend/ directory
  - "Database" / "Cache" → these are infrastructure, no directory needed (skip)
- Reverse check: WARN if a significant top-level folder has no container representation
  - Ignore: .claude/, docs/, .github/, scripts/, dotfiles (.*), node_modules/, __pycache__/

B2. Frontend tech vs package.json:
- Extract frontend tech claims from the Containers table and "Per container > Frontend" section in containers.md
- Compare against frontend/package.json dependencies and devDependencies:
  - Versioned mention (e.g. "Next.js 15"): extract major version → FAIL if major version in package.json differs (next@16.x ≠ "Next.js 15")
  - Unversioned mention (e.g. "TypeScript"): PASS if package exists in dependencies or devDependencies, FAIL if absent
  - Tool mention (e.g. "pnpm"): PASS if pnpm-lock.yaml exists, FAIL if absent
  - Tool mention (e.g. "Turbopack"): informational only, cannot verify from package.json — SKIP
- If frontend/package.json doesn't exist: WARN for all checks

B3. Backend tech vs pyproject.toml:
- Extract backend tech claims from the Containers table and "Per container > Backend API" section in containers.md
- Compare against backend/pyproject.toml:
  - Versioned mention (e.g. "Python 3.12+"): PASS if requires-python is compatible (>= "3.12"), FAIL if incompatible
  - Versioned mention (e.g. "SQLAlchemy 2.0"): check dependencies list for matching major version
  - Unversioned mention (e.g. "FastAPI"): PASS if package exists in dependencies, FAIL if absent
  - Tool mention (e.g. "uv"): PASS if uv.lock exists or [tool.uv] section exists in pyproject.toml
  - Tool mention (e.g. "Ruff"): PASS if [tool.ruff] section exists or ruff is in dev dependencies
- If backend/pyproject.toml doesn't exist: WARN for all checks

B4. Database/cache vs docker-compose.yml:
- Extract database and cache claims from the Containers table (e.g. "PostgreSQL 16", "Redis 7")
- If docker-compose.yml exists:
  - Find corresponding services and their image tags
  - PASS if major version matches (postgres:16.x matches "PostgreSQL 16")
  - FAIL if major version differs
  - WARN if service exists but has no version tag
- If docker-compose.yml doesn't exist: WARN (not FAIL — project may use managed services)

### Category C: C4 Components vs Codebase (4 checks)

C1. Frontend module paths exist:
- Extract all paths from the "Frontend Components" table in components.md (the "Path" column)
- For each path, verify it exists under frontend/:
  - e.g. "src/app/" → check frontend/src/app/ exists
  - e.g. "src/features/{name}/" → check frontend/src/features/ exists (the parent)
- .gitkeep-only directories count as "exists"
- PASS if all paths exist; FAIL for each missing path
- If frontend/ doesn't exist at all: WARN

C2. Backend module paths exist:
- Extract all paths from the "Backend Components" table in components.md (the "Path" column)
- For each path, verify it exists under backend/:
  - e.g. "app/" → check backend/app/ exists
  - e.g. "features/{name}/" → check backend/features/ exists (the parent)
  - e.g. "shared/db/" → check backend/shared/db/ exists
- .gitkeep-only directories count as "exists"
- PASS if all paths exist; FAIL for each missing path
- If backend/ doesn't exist at all: WARN

C3. Architecture patterns verifiable:
- Extract patterns from the Architecture Patterns section in components.md
- Verify patterns are reflected in code:
  - "Router → Service → Repository": check if at least 1 feature directory under backend/features/ contains router.py + service.py + repository.py
  - "Feature-first" / "Colocation": check if backend/features/ or frontend/src/features/ exists with subdirectories
  - "Component → Hook → API Layer": check if frontend/src/ has components/, hooks/ structure
- If the relevant directories exist but contain only .gitkeep (no actual source files): SKIP (not WARN, not FAIL)
- If directories don't exist at all but are documented: FAIL

C4. Reverse check — undocumented modules:
- List all significant directories under frontend/src/ and backend/ that contain .py or .ts/.tsx source files
- Compare against the paths documented in components.md tables
- WARN for each significant undocumented directory
- Exclusions: tests/, test/, __pycache__/, node_modules/, public/, .next/, migrations/versions/, .gitkeep-only dirs
- If no source files exist anywhere: SKIP

### Category D: ADR Accuracy (4 checks)

D1. Required fields:
- For each ADR file (skip _template.md):
  - Verify these fields exist in the metadata/header:
    - Status: must be one of (proposed, accepted, superseded, deprecated)
    - C4 Level: must be one of (L1-Context, L2-Container, L3-Component, L4-Code)
    - Scope: must be non-empty
    - Date: must match YYYY-MM-DD format
  - PASS if all fields valid; FAIL if any field missing or has invalid value
- Report per-ADR results

D2. Tech ADRs vs installed dependencies:
- For each ADR that makes technology claims (look in "Decision" sections):
  - Extract named technologies and versions
  - Verify against the corresponding config file (package.json for frontend, pyproject.toml for backend)
  - Same comparison rules as B2/B3:
    - Versioned: major version must match
    - Unversioned: package must exist
  - PASS if all claims verified; FAIL for mismatches
- This intentionally overlaps with B2/B3 — ADRs and containers.md can drift independently

D3. ADR patterns vs codebase:
- For ADRs that describe structural patterns (feature-first, tooling like Ruff):
  - Verify the pattern is reflected in the codebase
  - e.g. "feature-first" → features/ directory should exist
  - e.g. "Ruff" → [tool.ruff] in pyproject.toml or ruff in dependencies
- If no feature code exists (only .gitkeep): SKIP
- PASS if patterns verified; FAIL for contradictions

D4. ADR references in C4 docs exist:
- Scan all C4 docs (context.md, containers.md, components.md) for ADR references
- Match patterns: "ADR-NNNN" or filenames like "0001-frontend-tech-stack.md"
- For each reference, verify the corresponding file exists in docs/architecture/adr/
- PASS if all references resolve; FAIL if a referenced ADR file doesn't exist

## Phase 3: Report

Output EXACTLY this format:

## Arch Check Report

### C4 Context vs Reality
- [PASS/WARN/FAIL] A1: System name match (context.md ↔ root CLAUDE.md)
  [details if not PASS]
- [PASS/WARN/FAIL] A2: Actors populated
  [details if not PASS]
- [PASS/WARN/FAIL] A3: External systems populated
  [details if not PASS]

### C4 Containers vs Codebase
- [PASS/WARN/FAIL] B1: Container folders exist
  [details if not PASS]
- [PASS/WARN/FAIL/SKIP] B2: Frontend tech vs package.json
  [details if not PASS]
- [PASS/WARN/FAIL/SKIP] B3: Backend tech vs pyproject.toml
  [details if not PASS]
- [PASS/WARN/FAIL] B4: Database/cache vs docker-compose.yml
  [details if not PASS]

### C4 Components vs Codebase
- [PASS/WARN/FAIL] C1: Frontend module paths exist
  [details if not PASS]
- [PASS/WARN/FAIL] C2: Backend module paths exist
  [details if not PASS]
- [PASS/WARN/FAIL/SKIP] C3: Architecture patterns verifiable
  [details if not PASS/SKIP]
- [PASS/WARN/SKIP] C4: Undocumented modules
  [details if not PASS/SKIP]

### ADR Accuracy
- [PASS/FAIL] D1: Required fields per ADR
  [details if not PASS]
- [PASS/FAIL/SKIP] D2: Tech ADRs vs installed dependencies
  [details if not PASS]
- [PASS/FAIL/SKIP] D3: ADR patterns vs codebase
  [details if not PASS/SKIP]
- [PASS/FAIL] D4: ADR references in C4 docs exist
  [details if not PASS]

### Drift Summary

Only include this table if there are WARN or FAIL results. Skip if everything passes.

| Source | Documents | Reality | Severity |
|--------|-----------|---------|----------|
| [source file] | [what docs claim] | [what codebase shows] | [WARN/FAIL] |

Example rows:
| containers.md | Next.js 15 | next@16.1.6 in package.json | FAIL |
| context.md | [Auth provider] | Placeholder not filled in | WARN |

### Verdict: [ARCH ACCURATE / ARCH DRIFTED / ARCH BROKEN]

Verdict logic:
- All checks PASS (SKIP not counted) → ARCH ACCURATE
- At least one WARN, no FAIL → ARCH DRIFTED
- At least one FAIL → ARCH BROKEN

[Summary + prioritized fix list if not ACCURATE]

## Rules

- IMPORTANT: This is a READ-ONLY command. NEVER create, modify, or delete any files.
- Be precise: quote the conflicting text when reporting FAIL
- Be helpful: for each FAIL/WARN, suggest the specific fix needed
- SKIP checks are not counted toward the verdict — they indicate the codebase is too early-stage to evaluate that check
- Placeholder brackets like [Auth provider] are WARN, not FAIL — they indicate unfilled documentation
- When comparing versions, only major version matters (e.g., Next.js 15 vs next@15.3.1 → PASS)
- .gitkeep-only directories count as "exists" for path checks but as "no source code" for pattern checks
```

## Rules

- This command is read-only — it NEVER modifies files
- Always use Opus model for the subagent (complex cross-file analysis)
- Single subagent handles all four audit categories
- No $ARGUMENTS — always audits the entire project
- Report all findings, even when everything passes
- Scope: docs-to-code verification only (for docs-to-docs consistency, use /doc-check)
