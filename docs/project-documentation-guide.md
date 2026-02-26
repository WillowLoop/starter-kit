# Project Documentation Architecture Guide

Guide for setting up project documentation, optimized for both human developers and LLM agents.

## Core Principle: Context Hygiene

Every piece of information has exactly one place. An LLM agent should never load more context than needed for the current task. Three mechanisms, each with its own role:

| Mechanism | Purpose | When loaded | Token budget |
|---|---|---|---|
| **CLAUDE.md** | Conventions and rules | Always (per directory) | ~100-200 tokens |
| **ADR** | Decision rationale | On-demand, only on "why?" | ~200-400 tokens |
| **Skill** | Complex procedures/workflows | On-demand, for specific task | Unlimited (progressive disclosure) |

---

## CLAUDE.md — Conventions (always loaded)

CLAUDE.md files form a hierarchy per directory. An agent automatically reads the CLAUDE.md of the directory it works in. Keep them short and scannable.

### Root CLAUDE.md (~150 tokens)

```markdown
# [Project Name]

Stack: Next.js 16 (App Router), FastAPI, PostgreSQL, TanStack Query v5
Architecture: Feature-first (vertical slicing)
Monorepo: frontend/ + backend/

## Repo layout
frontend/    → Next.js app
backend/     → FastAPI services
docs/        → C4 docs, ADRs
infra/       → Docker, deployment

## Global rules
- TypeScript strict mode everywhere
- All API calls through typed client (lib/api-client.ts)
- No barrel exports
```

### Directory CLAUDE.md (~100-200 tokens each)

Each directory with its own conventions gets a CLAUDE.md.

Examples in this project:
- `frontend/CLAUDE.md` — frontend conventions (table format)
- `backend/CLAUDE.md` — backend conventions (code-block format)

Both formats (table and code-block) are valid for the Structure section.

Template:

```markdown
# [Directory Name]

Stack: [relevant tech stack]
Package manager: [tool] | Testing: [framework]

## Structure

| Path | Description |
|---|---|
| `path/` | Purpose |

## Patterns

- [Core pattern 1]
- [Core pattern 2]

## File limits

| Type | Max lines |
|---|---|
| [Type] | [N] |

## Rules

- [Fact/rule 1]
- [Fact/rule 2]
```

### Rules of thumb for CLAUDE.md

- **Maximum ~200 tokens** — if it gets longer, split into sub-directory CLAUDE.md's
- **Facts, not explanations** — "barrel exports forbidden", not "we avoid barrel exports because..."
- **Scannable** — tables and short lines, no prose
- **Maintenance** — the planner workflow + technical writer agent keeps this up to date; for manual work: doc-sync skill

---

## ADRs — Decisions (on-demand)

ADRs capture *why* a choice was made. They are only loaded when an agent or developer needs context about a decision.

### When to write an ADR

- Framework or tool choice with serious alternatives (Next.js vs Remix, PostgreSQL vs MongoDB)
- Architecture decisions that are hard to reverse (monorepo vs polyrepo, auth provider)
- Choices you might regret later
- Trade-offs you made deliberately

### When not to write an ADR

- Conventions and style choices → CLAUDE.md
- Feature-first folder structure → CLAUDE.md (unless there was a controversial trade-off)
- Things where the answer to "why?" is one sentence

### ADR template with C4 coupling

```markdown
# ADR-NNN: [Title]

- **Status**: proposed | accepted | superseded | deprecated
- **C4 Level**: L1-Context | L2-Container | L3-Component | L4-Code
- **Scope**: [which container/component this affects]
- **Date**: YYYY-MM-DD

## Context
[What problem needed to be solved?]

## Decision
[What was decided and why?]

## Consequences
[What are the consequences, positive and negative?]

## Alternatives Considered
[Brief: which alternatives were rejected and why?]
```

### C4 level assignment

| C4 Level | Type of decision | Example |
|---|---|---|
| L1-Context | System boundaries, external integrations | "We use Stripe as PSP" |
| L2-Container | Tech stack, deployment units | "Next.js for frontend, FastAPI for backend" |
| L3-Component | Module architecture, patterns | "TanStack Query for server state" |
| L4-Code | Implementation details | Rarely needed — if it's clear in code, no ADR |

---

## Skills — Procedures (on-demand)

Skills are for complex, repeatable workflows that need step-by-step instructions, often with example code.

### When to write a Skill

- Feature scaffolding (creating a new feature with all required files)
- Design system patterns with concrete component examples
- Complex integration workflows (API client setup, auth flow)
- Procedures that touch multiple files and steps

### When not to write a Skill

- Basic conventions → CLAUDE.md
- One-time decisions → ADR
- Information that must always be available → CLAUDE.md

### Skill structure

Skills follow progressive disclosure: the SKILL.md is the entry point, further context is loaded on-demand.

```
.claude/skills/
└── feature-scaffold/
    └── SKILL.md       # Goal, steps, templates
```

---

## /docs/ Directory — Project documentation

```
docs/
├── README.md                          # Index
├── project-documentation-guide.md     # Meta: how docs work
│
├── architecture/                      # HOW the system is built
│   ├── c4/
│   │   ├── context.md                 # L1: system in its environment
│   │   ├── containers.md             # L2: deployment units
│   │   └── components.md             # L3: modules within containers
│   └── adr/
│       ├── _template.md
│       ├── 0001-*.md
│       └── ...
│
├── workflows/                         # HOW we work (for humans)
│   └── _template.md
│
├── research/                          # WHAT we have learned
│   └── _template.md
│
└── planning/                          # WHAT needs to happen
    ├── prd/
    │   ├── _template.md               # Template for PRDs
    │   └── 0001-*.md
    ├── design/
    │   ├── _template.md               # Template for Design Docs
    │   └── 0001-*.md
    ├── plans/                         # Implementation plans (before coding)
    ├── roadmap/
    │   ├── overview.md                # Roadmap overview and status
    │   └── _template.md               # Template for new epics
    └── todo.md
```

C4 L4 (Code level) is not documented separately — that is what CLAUDE.md per directory does.

---

## PRD Workflow — Requirements via Conversational Interview

If you don't have clear requirements for a feature or product yet, use the `/prd` workflow. This is a **conversational interview** (7 questions) → **draft PRD** → **parallel 3-agent review** → **approval**.

### How it works

1. **Interview (7 Questions)**: Claude asks one question at a time via AskUserQuestion. Challenge rule: vague answers are probed before moving to the next question.
   - Problem & Context
   - Vision & Goals (SMART metrics)
   - Target Audience (1-3 personas)
   - Features (MVP, Must/Should/Could/Won't)
   - Scope Boundaries (what is NOT in scope)
   - Data & Integrations
   - Risks & Open Issues

2. **Draft PRD**: Fill in the template (`docs/planning/prd/_template.md`) based on interview answers. Show draft to user.

3. **Review Loop (max 3 iterations)**: 3 agents review in parallel:
   - **PRD Product Reviewer** — PM perspective (customer value, MVP discipline, SMART metrics)
   - **PRD Technical Reviewer** — Architect perspective (feasibility, data/APIs, complexity)
   - **PRD Risk Analyst** — Stakeholder perspective (assumptions, blind spots, scope creep)

   Verdict structure: `APPROVED` → Phase 4 | `APPROVED WITH CHANGES` → Fix + recheck | `NEEDS REVISION` → Rewrite + recheck

4. **Finalize**: Status `draft` → `approved`, summary, next steps (Epic? Design Doc? Plan?).

### When to use `/prd`

✅ New product or large feature with unclear requirements
✅ Scope and priorities need to be aligned
✅ Goals, target audience and success metrics need to be defined
✅ **You're not sure you truly understand the problem**

❌ Do NOT use for small features (go directly to epic or plan)
❌ Do NOT use for technical tasks (go directly to design doc or plan)
❌ Do NOT use when requirements are already clear

### Relationship to Other Documents

| Doc | Purpose | After PRD? |
|-----|---------|------------|
| **PRD** | What & why (product) | ← Start here if unclear |
| **Epic** | What & when (roadmap) | Optional, based on PRD |
| **Design Doc** | How (technical design) | If complex |
| **Plan** | Implementation steps | For developers |

---

## Decision tree: where does this go?

```
Is it a fact/rule that is always valid?
  → CLAUDE.md in the relevant directory

Is it a choice with alternatives you deliberately rejected?
  → ADR in docs/architecture/adr/

Is it a product description with requirements and scope?
  → PRD in docs/planning/prd/ (or start with `/prd` workflow)

Is it a technical design before implementation?
  → Design Doc in docs/planning/design/

Is it a step-by-step implementation plan?
  → Plan in docs/planning/plans/

Is it a step-by-step procedure with templates/examples?
  → Skill in .claude/skills/

Is it a high-level architecture description?
  → C4 doc in docs/architecture/c4/

Is the answer to "why?" less than two sentences?
  → CLAUDE.md (optionally with that one sentence)
```

---

## Maintenance

- **Planner workflow** → technical writer agent keeps CLAUDE.md and README.md up to date automatically
- **doc-sync skill** → audit and synchronize documentation on drift
- **ADRs are immutable** — superseded ADRs are not deleted but get status "superseded" with reference to successor
