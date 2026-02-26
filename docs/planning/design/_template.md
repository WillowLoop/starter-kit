# Design: [Name]

- **Status**: draft | review | approved
- **PRD**: [link to related PRD, or "n/a"]
- **Owner**: [name]
- **Date**: YYYY-MM-DD

## Overview

[What is being built and why? 2-3 sentences.]

## Architecture

[How does this fit into the existing system? Reference C4 docs.]
[Components, data flow, communication.]

## Detailed Design

[Technical elaboration: data model, API endpoints, or UI flows — depending on the feature.]

## Dependencies

| Dependency | Type | Description |
|---|---|---|
| [dependency] | Internal/External | [what and why] |

## Test Strategy

[Approach and acceptance criteria]

## Migration & Rollout

[How does this get to production? Steps, risks, rollback.]

## Open Issues

- [unanswered technical questions]

<!-- Optional: add sections if relevant -->
<!-- - Error Handling: error scenarios and recovery -->
<!-- - Security: auth, authorization, data protection -->
<!-- - Data Model: separately elaborated schema -->
<!-- - API Design: separately elaborated endpoints -->

---

## When to create a Design Doc

- Feature touches multiple components or services
- Technical approach is non-trivial and needs discussion
- There are significant trade-offs or risks

Small, isolated changes → go directly to a plan or implementation.

## Naming

```
docs/planning/design/NNNN-short-kebab-title.md
```

Numbering starts at `0001`, ascending.

## Relationship to other documents

- **PRD** = what and why (product) — upstream of Design Doc
- **Design Doc** = how (technical design)
- **Plan** = implementation steps (before coding) — downstream of Design Doc

A Design Doc belongs to a PRD, but can also exist standalone for technical initiatives.
