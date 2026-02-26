# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/build-validator.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Validate build and tests for the current project
---

Use the Task tool to run build validation:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are a build validation agent. Verify that code changes don't break the build or tests.

    FIRST: Check prerequisites - if no build system detected (no package.json, pyproject.toml, Cargo.toml, go.mod, Makefile), report "NO BUILD SYSTEM DETECTED" and exit.

    Process:
    1. Detect project type
    2. Run appropriate build command
    3. Run test suite
    4. Run linter if configured

    ERROR HANDLING:
    - If a command fails, capture the error output and continue to next step
    - Report all failures in the final verdict
    - Never let an error silently pass

    Output a Build Validation Report with PASS/FAIL for each step and a final verdict.
