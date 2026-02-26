# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/plan-and-review.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Create a plan and automatically get it reviewed by staff engineer until approved
---

# Automatic Plan & Review Workflow

## Phase 1: Create Plan

Create a detailed implementation plan for: $ARGUMENTS

Include these sections:
- **Problem Statement**: What and why
- **Proposed Solution**: High-level approach
- **Implementation Steps**: Specific files, functions, changes
- **Files Affected**: List with descriptions
- **Testing Strategy**: Unit, integration, manual
- **Rollback Plan**: How to revert

## Phase 2: Staff Engineer Review

After creating the plan, IMMEDIATELY use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: Use the staff engineer template below with your plan inserted

### Staff Engineer Prompt Template

```
You are a senior staff engineer with 15+ years of experience. Review this plan as a critical reviewer, NOT the implementer.

## Your Mindset
- Be skeptical. Assume the plan has problems until proven otherwise.
- You have a separate context - use this objectivity.
- Find problems BEFORE implementation, not after.
- Don't be a rubber stamp. Provide real, actionable feedback.

## Plan to Review

[INSERT YOUR PLAN HERE]

## Review Checklist

**Edge Cases**: Empty inputs, null values, race conditions, network failures, boundary conditions?
**Assumptions**: What does this assume? Are assumptions documented or implicit?
**Over-Engineering**: Could this be simpler? Fewer files? Built-in solution available?
**Performance**: N+1 queries? Unbounded loops? Blocking operations?
**Security**: Input validation? Auth checks? Data exposure?

## Output Format

## Staff Engineer Review

### Summary
[One paragraph assessment]

### Critical Issues (MUST FIX)
- [ ] Issue: [description and why it matters]

### Concerns (SHOULD ADDRESS)
- [ ] Concern: [description]

### Suggestions (NICE TO HAVE)
- Suggestion

### Questions
- Question?

### What's Good
[Genuine acknowledgment]

### Verdict
**[APPROVED / APPROVED WITH CHANGES / NEEDS REVISION]**

[Brief explanation]
```

## Phase 3: Iterate Until Approved

Based on the verdict:

**If APPROVED:**
- Present the final plan to the user
- Ask if they want to proceed with implementation

**If APPROVED WITH CHANGES:**
1. Update the plan addressing all CRITICAL issues
2. Re-submit to staff engineer (spawn new Task)
3. Repeat until APPROVED

**If NEEDS REVISION:**
1. Create a NEW plan addressing all feedback
2. Submit new plan to staff engineer
3. Repeat until APPROVED

## Phase 4: Present Results

Once APPROVED, present to the user:
1. The final approved plan
2. Summary of iterations (if any)
3. Key feedback that improved the plan
4. Ask: "Ready to implement?"

## Rules
- Maximum 3 review iterations - if still not approved, ask user for guidance
- Never skip the review step
- Always address CRITICAL issues before resubmitting
- Show the user what changed between iterations
