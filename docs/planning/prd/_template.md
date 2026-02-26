# PRD: [Name]

- **Status**: draft | review | approved
- **Owner**: [name]
- **Date**: YYYY-MM-DD
- **Epics**: [links to related epics, or "n/a"]

## Problem

[What problem are we solving? Why now?]

## Goals & Success Metrics

| Goal | Metric | Target |
|---|---|---|
| [goal] | [measurable metric] | [target value] |

## Target Audience

| Persona | Goal | Pain point |
|---|---|---|
| [persona] | [what they want to achieve] | [what frustrates them] |

## Features & Requirements

| Feature | Priority | Description |
|---|---|---|
| [feature] | Must/Should/Could/Won't | [short description] |

## User Stories

<!-- Rules:
  - 1 happy-path story per Must/Should feature
  - 1 error scenario per Must feature
  - Could features: max 1 story for illustration
  - Each persona from Target Audience represented at least once
  - Feature must exactly match a name from the Features & Requirements table
-->

| # | Persona | User Story | Feature |
|---|---|---|---|
| US-01 | [persona from Target Audience] | As a [persona] I want [action] so that [result] | [feature from Features] |

## Scope

### In scope
-

### Out of scope
-

## Open Issues

- [unanswered questions]

## Decisions

| Decision | Rationale | Date |
|---|---|---|
| [what was decided] | [why] | YYYY-MM-DD |

<!-- Optional: add sections if relevant -->
<!-- - Designs: links to wireframes/mockups -->
<!-- - Timeline: milestones table -->
<!-- - Dependencies: dependencies -->

---

## When to create a PRD

- New product or feature that needs requirements alignment
- Scope and priorities need to be aligned with stakeholders
- Feature is large enough to define goals, target audience and success metrics

Small features or technical tasks → go directly to an epic or plan.

## Naming

```
docs/planning/prd/NNNN-short-kebab-title.md
```

Numbering starts at `0001`, ascending.

## Relationship to other documents

- **Epic** = what and when (roadmap)
- **PRD** = what and why (product)
- **Design Doc** = how (technical design)
- **Plan** = implementation steps (before coding)

A PRD can have multiple epics and design docs. Links are optional.
