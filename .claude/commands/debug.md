# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/debug.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Investigate and fix a bug with verification
---

# Debug Workflow

## Phase 1: Investigation

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are a debugging expert. Investigate:

    $ARGUMENTS

    Process:
    1. Gather evidence (errors, git diff, environment)
    2. Form hypotheses ranked by likelihood
    3. Investigate top hypothesis

    Output Debug Investigation with:
    - Symptom
    - Evidence table
    - Ranked hypotheses
    - Root cause
    - Proposed fix (specific code/command)
    - Verification steps

## Phase 2: Fix Checkpoint

Present the investigation results to the user.

Ask: "Apply this fix? [yes / modify / no]"
- If yes: Apply the fix
- If modify: Let user describe modification, then apply
- If no: Stop workflow

## Phase 3: Apply Fix

Apply the proposed (or modified) fix.

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

**On APP STILL BROKEN**:
- Capture the new error message
- Report: "Fix applied but issue persists. New error: [error]"
- Suggest: "Run `/debug [new error]` to investigate further"
- Do NOT auto-loop (prevents infinite investigation)

**On APP WORKS**: Report resolution, workflow complete

## Rules
- Max 1 investigation per /debug invocation (no auto-looping)
- Always verify the fix actually resolves the original issue
- Preserve evidence in output (don't summarize away details)
