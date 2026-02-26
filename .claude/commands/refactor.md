# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/refactor.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Simplify code with validation
---

# Refactor Workflow

## Phase 1: Code Analysis

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are a code simplification expert. Review:

    $ARGUMENTS

    Find: unnecessary abstractions, deep nesting, dead code, magic values.
    Output Code Simplification Review with:
    - Assessment
    - Numbered suggestions with before/after code
    - Impact rating (high/medium/low)

## Phase 2: Selection Checkpoint

Present the suggestions to the user.

Ask: "Which changes to apply? [all / numbers like 1,3,4 / none]"
- If all: Apply all suggestions
- If numbers: Apply only selected
- If none: Stop workflow

## Phase 3: Apply Changes

Apply the selected simplifications one at a time.
After each change, continue to Phase 4.

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

**On BUILD BROKEN from a specific change**:
- Rollback that specific change
- Report which suggestion broke the build
- Continue with remaining suggestions

**On BUILD HEALTHY**: Continue to Phase 5

## Phase 5: App Verification (Conditional)

Only run if changes affect runtime behavior (not just imports/formatting).

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
- Apply changes atomically (one at a time)
- Rollback on failure, continue with others
- Skip verify-app for pure cleanup (dead imports, formatting)
