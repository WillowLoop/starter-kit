---
name: plan-review-workflow
description: Orchestrates the three-agent pattern where an architect creates a Blueprint, plans are built from it, and a staff engineer reviews before implementation. Includes documentation lifecycle (bootstrap → use → preserve). Use this workflow for any significant implementation - features, refactors, architectural changes.
---

# Plan Review Workflow

## Overview

Three-agent pattern for design accountability and quality assurance:
1. **Architect Subagent** (opus): Makes decisive design choices, produces a Blueprint
2. **Planning Agent** (you): Turns the Blueprint into a detailed implementation plan
3. **Staff Engineer Subagent** (opus): Reviews with fresh eyes, separate context

Combined with a documentation lifecycle:
- **Phase 0**: Bootstrap minimum viable docs
- **Phases 1a-3**: Use docs for decisions, create knowledge
- **Phase 5**: Preserve knowledge for next time

```
Doc Health Check → Architect Blueprint → Plan → Staff Review → Iterate → Implement → Doc Preserve
```

## When to Use

Use this workflow when:
- Implementing a new feature with architectural decisions
- Refactoring existing code at a structural level
- Making architectural changes
- Any multi-file change where design accountability matters
- Changes that could break existing functionality

Do NOT use for:
- Simple bug fixes (typos, obvious errors)
- Documentation-only changes
- Single-line changes
- Quick additions with no architectural impact (use `/feature` instead)

## The Complete Flow

### Phase 0: Doc Health Check
Quick safety net ensuring minimum viable documentation exists. Bootstraps CLAUDE.md, `docs/decisions/`, and `docs/plans/` if missing. Never blocks the workflow.

### Phase 1a: Architect Blueprint
Architect subagent (opus) explores the codebase following a structured exploration strategy:
1. CLAUDE.md → README.md → ADRs → Grep/Glob
2. Makes one decisive design choice (no option lists)
3. Produces a Blueprint with Decision Log, Rejected Alternatives, Acceptance Criteria, and Invisible Knowledge

### Phase 1b: Create Plan
Main Claude turns the Blueprint into an implementation plan. Inherits Decision Log and Rejected Alternatives verbatim. Adds implementation steps, testing strategy, and rollback plan.

### Phase 2: Staff Engineer Review
Staff engineer subagent (opus) reviews with both the Blueprint and plan as context. New addition: validates Blueprint alignment - checks if the plan follows the architect's decisions.

### Phase 3: Iterate Until Approved
Maximum 3 iterations. Key distinction:
- **Implementation feedback** → update plan, re-submit
- **Architectural feedback** → re-consult architect, get revised Blueprint, then update plan

### Phase 4: Implement
Standard implementation following the approved plan. Includes build-validation and verify-app.

### Phase 5: Doc Preservation
Captures knowledge for future use:
- Decision Log → ADR files in `docs/decisions/`
- Invisible Knowledge → README.md in affected directories
- New files → CLAUDE.md index updates
- Full plan → archive in `docs/plans/`

## Rules

- **Never skip the architect step** — the Blueprint drives everything downstream
- **Never skip the review step** — even if you think the plan is solid
- **Always address CRITICAL issues** — these are non-negotiable
- **Document disagreements** — if you're not incorporating feedback, explain why to the user
- **Maximum 3 iterations** — if still not approved, involve the user
- **Doc preservation is not optional** — capture knowledge for next time

## Knowledge Flow

```
docs/ (existing)  →  Architect reads  →  Blueprint created  →  Plan built  →  Staff reviews
                                                                                    ↓
docs/ (enriched)  ←  Phase 5 writes  ←  Implementation  ←  User approves  ←  Iterate
```

Each run of /plan-and-review enriches the documentation, making the next architect run more informed.

## Integration with EnterPlanMode

When using Claude Code's plan mode:
1. Use EnterPlanMode to explore and create the plan
2. Before ExitPlanMode, spawn staff-engineer to review
3. Only exit plan mode after APPROVED verdict
