---
description: Complete PRD workflow — interview, draft, review, finalize. Builds a requirements document through conversational interview, 3-agent review loop, and approval process.
---

# PRD Workflow — Conversational Interview → Draft → Review → Approve

Use the slash command `/prd` to start the complete workflow. This command orchestrates a 4-phase process:

1. **Interview (7 targeted questions)** — Gather context via AskUserQuestion
2. **Draft PRD** — Fill template based on answers
3. **Review Loop (max 3 iterations)** — 3 agents review in parallel (product, technical, risk)
4. **Finalize** — Approve and save

---

## Phase 1: PRD Interview (7 Questions)

Start the interview with AskUserQuestion. **Each question separately, one at a time.**

### Question 1: Problem & Context
**Text**: "What problem are we solving? For whom? Why now?"

**Challenge rule**: If the answer is vague ("an AI tool", "improve user experience"), probe explicitly:
- "What specific problem do [persona] experience right now?"
- "What is the impact on [persona] if this isn't solved?"
- "Why is this urgent now?"

### Question 2: Vision & Goals
**Text**: "What does success look like for this project? Give 2-3 concrete, measurable goals."

**Challenge**: If goals are not SMART:
- "How do you measure 'better user experience'?"
- "What is the target value and timeframe?"

### Question 3: Target Audience
**Text**: "Who are the users? Define 1-3 personas: role, goal, pain point."

**Challenge**: If too vague:
- "What specific pain point does [persona] have?"
- "How would you know this pain point is solved?"

### Question 4: Features (MVP)
**Text**: "Which features must be in this MVP? Mark priority per feature: Must/Should/Could/Won't."

**Challenge**: Too many Must-features (more than 5-6):
- "What is the absolute minimum to solve [core problem]?"
- "Can you move 1-2 features to Should or Could?"

### Question 5: Scope Boundaries
**Text**: "What is NOT in scope for this MVP? Why?"

**Challenge**: If out-of-scope items feel crucial:
- "Can you truly postpone this feature, or is it fundamentally needed?"

### Question 6: Data & Integrations
**Text**: "What data, APIs, or external services are needed? Where does data come from?"

**Challenge**: If unclear:
- "Which API/tool do you have in mind?"
- "What does the data flow look like?"

### Question 7: Risks & Open Issues
**Text**: "What don't you know yet? What assumptions are you making? What external dependencies?"

**Challenge**: If too vague:
- "Which specific open questions have priority?"
- "Which assumptions could be critical?"

---

## Phase 2: Draft PRD

After all 7 questions are answered:

1. **Determine the PRD number** (NNNN): Count existing files in `docs/planning/prd/` to determine the next number.

2. **Fill the template** (`docs/planning/prd/_template.md`):
   - Problem: Summary from question 1
   - Goals & Success Metrics: From question 2 (ensure SMART metrics)
   - Target Audience: From question 3 (table format: Persona | Goal | Pain Point)
   - Features & Requirements: From question 4 (table format: Feature | Priority | Description)
   - User Stories: Create 1-2 per Must/Should feature (Happy path + error scenario for Must)
   - Scope (In/Out): From question 5
   - Open Issues: From question 7
   - Decisions: Add if relevant

3. **Write to file**: `docs/planning/prd/NNNN-short-name.md`
   - Status: `draft`
   - Owner: `(to be determined)`
   - Date: Today

4. **Show the draft** to the user. Ask: "Does this look right? Any changes before we activate reviewers?"

---

## Phase 3: Review Loop (Max 3 Iterations)

After the user approves the draft (or wants no changes):

### Spawn 3 Agents in Parallel

Use Task tool to spawn 3 agents in parallel (each subagent_type: "general-purpose"):

| Agent | Prompt | Model |
|-------|--------|-------|
| **PRD Product Reviewer** | File: `.claude/agents/prd-product-reviewer.md` system prompt + PRD text | sonnet |
| **PRD Technical Reviewer** | File: `.claude/agents/prd-technical-reviewer.md` system prompt + PRD text | sonnet |
| **PRD Risk Analyst** | File: `.claude/agents/prd-risk-analyst.md` system prompt + PRD text | sonnet |

**Agent prompt template**:
```
[System prompt from agent YAML]

## PRD for Review

[PRD text]

[Agent will respond in the defined format with verdict]
```

### Verdict Logic

After all 3 agents:

| Scenario | Action |
|----------|--------|
| All 3 = APPROVED | → Phase 4 (Finalize) |
| 1+ = APPROVED WITH CHANGES | → Address critical issues → Repeat review loop (iteration +1) |
| 1+ = NEEDS REVISION | → Rewrite PRD based on feedback → Repeat review loop (iteration +1) |
| After 3 iterations without full APPROVED | → Ask user: "What do we want to do? Continue, seal at current state, or start over?" |

### Handling per Iteration

1. **Show verdicts** to the user
2. **Highlight critical issues** (MUST FIX)
3. **Ask**: "Shall we address this?" → User provides feedback
4. **Update PRD** based on feedback
5. **Loop back** to agent spawning (if not approved)

---

## Phase 4: Finalize

After all 3 agents give APPROVED:

1. **Update PRD file**:
   - Status: `draft` → `approved`
   - Owner: Enter (user decides)
   - Add: brief note of review iterations

2. **Show summary**:
   ```
   PRD Approved!

   - Title: [PRD name]
   - File: docs/planning/prd/NNNN-name.md
   - Iterations: [N]
   - Key improvements: [bullet points]

   Review verdicts:
   - Product: APPROVED
   - Technical: APPROVED
   - Risk: APPROVED
   ```

3. **Ask next step**: "What do we want to do next?
   - Epic (roadmap) for this PRD?
   - Design Doc (technical design)?
   - Implementation plan (developer planning)?
   - Nothing, done for now?"

---

## Implementation Details

### Interview Logic (Challenge Rule)

Pseudo-code for question handler:

```
while (isVague(answer)) {
  showChallenge(context)
  answer = askFollowUp()
}
recordAnswer(question, answer)
```

Vague answers are: generic ("better", "faster"), non-specific ("tool", "feature"), unmeasurable ("users will love it").

### PRD Numbering

```python
existing_prds = glob("docs/planning/prd/NNNN-*.md")
next_number = max(extract_number(prd) for prd in existing_prds) + 1
filename = f"docs/planning/prd/{next_number:04d}-{slug(title)}.md"
```

### Agent Spawning

```python
# Parallel spawn
product_review = Task(
  subagent_type="general-purpose",
  model="sonnet",
  prompt=combine(prd_product_reviewer_system, prd_content)
)
technical_review = Task(...)
risk_review = Task(...)

# Collect results
results = [product_review.result, technical_review.result, risk_review.result]
verdicts = [extract_verdict(r) for r in results]
```

### Verdict Determination

```python
if all(v == "APPROVED" for v in verdicts):
  return "APPROVED"
elif any(v == "NEEDS REVISION" for v in verdicts):
  return "NEEDS_REVISION"  # → Rewrite
elif any(v == "APPROVED WITH CHANGES" for v in verdicts):
  return "APPROVED_WITH_CHANGES"  # → Fix, then recheck
```

---

## Verification Steps

After implementation:

1. In a project: type `/prd`
2. Interview starts → question 1 appears
3. Go through 7 questions → save answers
4. Draft PRD appears → show preview → approval
5. Review starts → 3 agents spawn in parallel
6. Verdicts appear → iteration logic
7. Check APPROVED status → update PRD file
8. Show summary → offer next steps

---

## Notes

- **Non-blocking**: User may abort the interview and resume later (save progress)
- **Transparency**: PRD file is always visible; no "behind the scenes" decisions
- **Max 3 iterations**: After 3 review loops without full approval, ask the user for direction
