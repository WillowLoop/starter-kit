# ADR-NNNN: [Title]

- **Status**: proposed | accepted | superseded | deprecated
- **C4 Level**: L1-Context | L2-Container | L3-Component | L4-Code
- **Scope**: [which container/component this affects]
- **Date**: YYYY-MM-DD

## Context

[What problem are we solving? What forces are at play?]

## Decision

[The chosen approach. Committed.]

## Reasoning Chain

[Multi-step reasoning, at least 2 steps]
- [Premise] → [Implication] → [Conclusion]

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| [approach A] | [concrete reason] |
| [approach B] | [concrete reason] |

## Consequences

- [What becomes easier]
- [What becomes harder]
- [What constraints this creates for future decisions]

---

## When to create an ADR

- Decision affects more than one directory (cross-cutting or system-wide)
- Decision constrains future architecture choices
- Decision was non-obvious and the reasoning must be preserved

Local decisions (single module) can go in the `CLAUDE.md` of that directory.

## Naming

```
docs/architecture/adr/NNNN-short-kebab-title.md
```

Numbering starts at `0001`, ascending.

## C4 coupling

The **C4 Level** field links each ADR to the correct architecture level:

| C4 Level | Example decision |
|---|---|
| L1-Context | "System X communicates via REST with external party Y" |
| L2-Container | "Frontend runs on Next.js, backend on FastAPI" |
| L3-Component | "Auth module uses bcrypt for password hashing" |
| L4-Code | "All API clients use a shared base class" |

## Lifecycle

```
Proposed → Accepted → [lives as reference] → Deprecated/Superseded
```

An ADR is never deleted — mark as deprecated/superseded to preserve reasoning history.
