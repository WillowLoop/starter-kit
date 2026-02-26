---
name: prd-workflow
description: Complete PRD creation workflow. Conversational interview (7 questions) → draft PRD → parallel 3-agent review (product, technical, risk) → approval. For product requirements at project start.
---

# PRD Workflow Skill

Build Product Requirements Documents (PRDs) through a conversational interview and 3-agent review process. Perfect for project kickoff or major features.

## When to Use This Skill

**Triggers:**
- `/prd` — Start complete PRD workflow
- "Let's set up a PRD"
- "What problem are we solving?" (making sure we understand this properly)
- A feature/project where clarity on requirements is lacking

**Do NOT use for:**
- Small features (go directly to epic or plan)
- Technical tasks (go directly to design doc or plan)
- Features that are already well-defined

## Workflow Overview

```
Phase 1: Interview (7 questions)
   ↓
Phase 2: Draft PRD (fill template)
   ↓
Phase 3: Review Loop (3 agents in parallel, max 3 iterations)
   ↓
Phase 4: Finalize (approval + next steps)
```

## Phase 1: Interview (7 Questions)

Claude asks **one question at a time** via AskUserQuestion. Challenge rule: probe vague answers before moving to the next question.

| # | Question | Purpose |
|---|----------|---------|
| 1 | What problem are we solving? For whom? Why now? | Make problem specific |
| 2 | What does success look like? (2-3 concrete, measurable goals) | Make goals SMART |
| 3 | Who are the users? (1-3 personas) | Define personas clearly |
| 4 | Which features for MVP? (Must/Should/Could/Won't) | Scope boundaries |
| 5 | What is NOT in scope? Why? | Check out-of-scope solidity |
| 6 | What data, APIs, services? | Clarify dependencies |
| 7 | What don't you know? Risks? | Open issues & assumptions |

**Challenge rule for vagueness:**
- Problem vague? → "What specific pain point?"
- Goals not SMART? → "How do you measure success?"
- Personas generic? → "What concrete pain point does [persona] have?"
- Too many Must-features? → "What is the absolute minimum?"

## Phase 2: Draft PRD

After interview:

1. **Determine PRD number** (NNNN): Count existing files in `docs/planning/prd/`
2. **Fill template** with interview answers
3. **Write to** `docs/planning/prd/NNNN-short-name.md`
4. **Show** to user → Approval before review

**PRD Structure** (from template):
- Problem
- Goals & Success Metrics
- Target Audience (personas table)
- Features & Requirements (Must/Should/Could/Won't)
- User Stories (min 1 per Must/Should)
- Scope (In/Out)
- Open Issues
- Decisions (optional)

## Phase 3: Review Loop (Max 3 Iterations)

3 agents review **in parallel** (not sequentially):

| Agent | Perspective | Focus |
|-------|-------------|-------|
| **PRD Product Reviewer** | PM | Customer value, MVP, SMART metrics, persona-feature fit |
| **PRD Technical Reviewer** | Architect | Feasibility, data/APIs, complexity, AI risks |
| **PRD Risk Analyst** | Stakeholder | Assumptions, blind spots, scope creep, dependencies |

**Verdict logic:**

| Verdicts | Action |
|----------|--------|
| All 3: APPROVED | → Phase 4 |
| 1+: APPROVED WITH CHANGES | → Fix critical issues → Review again |
| 1+: NEEDS REVISION | → Rewrite PRD → Review again |
| After 3 iterations: no APPROVED | → Ask user for direction |

**Feedback handling:**
- Show verdicts
- Highlight critical issues
- Ask: "Shall we address this?"
- Update PRD
- Repeat loop

## Phase 4: Finalize

After all 3 agents give APPROVED:

1. **Update PRD**:
   - Status: `draft` → `approved`
   - Owner: Enter
   - Note iterations

2. **Show summary** (title, file, key improvements)

3. **Offer next steps**:
   - Create Epic (roadmap)?
   - Design Doc (technical)?
   - Implementation plan?

## Key Benefits

- **Structured Interview**: 7 questions ensure nothing is missed
- **Challenge Mechanic**: Vague answers are not accepted
- **Parallel Review**: 3 perspectives simultaneously = faster
- **Transparent**: Draft is always visible
- **Iterative**: Max 3 loops before user decides

## Example Output

```
# PRD: User Registration

- Status: approved
- Owner: Product Owner
- Date: 2026-02-21

## Problem
New users cannot register...

[Full PRD content]

---
Review Iterations: 1
Key improvements:
- Email verification must happen same day as registration (was separate)
- 3 instead of 4 onboarding steps (scope reduced)
- Out-of-scope: SSO → future epic
```

## Relation to Other Documents

| Doc | Purpose | After PRD? |
|-----|---------|------------|
| **Epic** | Roadmap: what & when | Yes (optional) |
| **Design Doc** | Technical design: how | Yes (if complex) |
| **Plan** | Implementation steps | Yes (developers) |

A PRD can feed multiple epics/design docs. Always start with PRD when clarity is needed.

---

**Usage**: `/prd` in terminal or "start PRD workflow" in Claude Code.
