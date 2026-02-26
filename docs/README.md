# Documentation Index

## How documentation works

Read first: [Project Documentation Architecture Guide](project-documentation-guide.md)

Three mechanisms, each with its own purpose:
- **CLAUDE.md** — conventions and rules (always loaded)
- **ADR** — decision rationale (on-demand)
- **Skill** — procedures and workflows (on-demand)

---

## Architecture (C4)

| Document | C4 Level | Describes |
|---|---|---|
| [architecture/c4/context.md](architecture/c4/context.md) | L1 — Context | System in its environment |
| [architecture/c4/containers.md](architecture/c4/containers.md) | L2 — Container | Deployment units and tech stack |
| [architecture/c4/components.md](architecture/c4/components.md) | L3 — Component | Modules and their interactions |

## Architecture Decision Records

| Document | Describes |
|---|---|
| [architecture/adr/0001-frontend-tech-stack.md](architecture/adr/0001-frontend-tech-stack.md) | Next.js 16 + TS + Tailwind + shadcn/ui + pnpm + Vitest |
| [architecture/adr/0002-backend-tech-stack.md](architecture/adr/0002-backend-tech-stack.md) | FastAPI + Python 3.12+ + PostgreSQL + SQLAlchemy + uv + Ruff + pytest |
| [architecture/adr/_template.md](architecture/adr/_template.md) | Template for new ADRs |

ADRs grow with the project. Use the template for every significant architecture decision.

## Planning

Epic = what and when, PRD = what and why (product), Design Doc = how (technical), Plan = implementation steps.

### PRD (Product Requirements Document)

| Document | Describes |
|---|---|
| [planning/prd/_template.md](planning/prd/_template.md) | Template for new PRDs |
| [planning/prd/0001-example-prd.md](planning/prd/0001-example-prd.md) | Filled-in example (remove on clone) |

### Design Documents

| Document | Describes |
|---|---|
| [planning/design/_template.md](planning/design/_template.md) | Template for new Design Docs |
| [planning/design/0001-example-design.md](planning/design/0001-example-design.md) | Filled-in example (remove on clone) |

### Roadmap & Epics

| Document | Describes |
|---|---|
| [planning/roadmap/overview.md](planning/roadmap/overview.md) | Roadmap overview and status per epic |
| [planning/roadmap/_template.md](planning/roadmap/_template.md) | Template for new epics |

### Plans & Tasks

| Document | Describes |
|---|---|
| [planning/todo.md](planning/todo.md) | Extension opportunities |

`planning/plans/` contains implementation plans — technical step-by-step plans before coding.

## Workflows

| Document | Describes |
|---|---|
| [workflows/_template.md](workflows/_template.md) | Template for workflow documentation |
| [workflows/cicd-setup.md](workflows/cicd-setup.md) | CI/CD pipeline setup and configuration |

Workflows describe how we work: steps, tools and tips for recurring processes.

## Research

| Document | Describes |
|---|---|
| [research/_template.md](research/_template.md) | Template for research output |

Research captures what we have learned: research questions, findings and conclusions.

---

## .claude/ Directory

The `.claude/` directory contains AI agent configuration for Claude Code:

- `agents/` — AI agent role definitions (used by Claude Code)
- `commands/` — Slash commands invokable via `/command-name`
- `skills/` — Reusable procedure documents for complex workflows

---

## Bootstrap Checklist — New Project

When copying this starter-kit to a new project:

0. **Init script** — `./scripts/init-project.sh` (renames project, resets git, cleans up examples)
1. **Root `CLAUDE.md`** — Fill in placeholders: project name, tech stack, repo layout
2. **`frontend/CLAUDE.md`** — Adapt for your frontend stack (or remove if not applicable)
3. **`backend/CLAUDE.md`** — Adapt for your backend stack (or remove if not applicable)
4. **`docs/architecture/c4/context.md`** — Fill in system, actors and external systems
5. **`docs/architecture/c4/containers.md`** — Document your deployment units
6. **`docs/architecture/c4/components.md`** — Document modules per container
7. **Backend `features/` structure** — Create `features/` directory for first backend feature
8. **`.claude/`** — Review agents, commands and skills; remove what doesn't fit
9. **First ADR** — Document the most important architecture decision: `docs/architecture/adr/0001-*.md`
10. **`docs/planning/roadmap/overview.md`** — (optional) Add first epics to the roadmap
11. **Example PRD and Design Doc** — Remove `docs/planning/prd/0001-example-prd.md` and `docs/planning/design/0001-example-design.md`, or replace with your own first documents
12. **Clean up** — Remove remaining placeholder examples and replace with your own system

### Verification

```bash
# Copy to new project
cp -r starter-kit/ my-new-project/

# Check that all CLAUDE.md files are ≤ 200 tokens
wc -w my-new-project/CLAUDE.md
wc -w my-new-project/frontend/CLAUDE.md
wc -w my-new-project/backend/CLAUDE.md
```
