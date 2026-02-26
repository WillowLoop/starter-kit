# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/feature.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Architect and implement a new feature with full validation
---

# Feature Development Workflow

## Phase 1: Architecture Analysis

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are a code architect. Analyze the codebase and design:

    $ARGUMENTS

    Process:
    1. Explore existing patterns with Grep/Glob
    2. Consider 2-3 approaches with tradeoffs
    3. Recommend one approach

    Output an Architecture Analysis with:
    - Existing patterns found
    - Approaches table
    - **Recommendation** with rationale
    - **Files to Create/Modify** (required)
    - Open questions

## Phase 2: Architecture Checkpoint

Present the Architecture Analysis to the user.

Ask: "Ready to implement this approach?"
- If user has questions: Answer them
- If user says no: Stop workflow gracefully
- If user says yes: Continue to Phase 3

## Phase 3: Implementation

Implement the feature following the architecture recommendation.
Use the "Files to Create/Modify" list from Phase 1.
After implementation is complete, continue to Phase 4.

## Phase 4: Build Validation

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are a build validation agent.

    FIRST: Check prerequisites - if no build system detected, report "NO BUILD SYSTEM" and exit.

    Process:
    1. Detect project type (package.json, pyproject.toml, etc.)
    2. Run build command
    3. Run test suite
    4. Run linter if configured

    Output Build Validation Report with PASS/FAIL for each.
    Verdict: BUILD HEALTHY or BUILD BROKEN with prioritized fix list.

**On BUILD BROKEN**:
- If terminal failure (missing dependency, no build system): Stop, explain issue
- If retryable (type error, test failure): Offer to fix, max 2 attempts
- After 2 failed attempts: Stop, ask user for guidance

**On BUILD HEALTHY**: Continue to Phase 5

## Phase 5: App Verification

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are an app verification agent.

    FIRST: Check if runnable - if not, report "NOT RUNNABLE" and exit.

    Process:
    1. Detect app type and start command
    2. Start app (max 30s timeout)
    3. Run health check
    4. Cleanup processes

    Output App Verification Report.
    Verdict: APP WORKS or APP BROKEN or NOT RUNNABLE.

**On NOT RUNNABLE**: Report success (library projects don't need app verification)
**On APP BROKEN**: Report what failed, suggest running `/debug [error]` manually
**On APP WORKS**: Report success, workflow complete

## Rules
- Max 2 build fix attempts (not 3 - avoid wasting time on deterministic failures)
- Always checkpoint after architecture before implementing
- Never auto-chain to /debug - suggest it, let user decide
