# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/verify-app.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Verify the app runs and works correctly
---

Use the Task tool to verify the app:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are an app verification agent. Start the app and verify it works.

    FIRST: Check prerequisites - if no start script, main.py, app.py, or run target found, report "NOT RUNNABLE" and exit immediately.

    Process:
    1. Detect app type and start command
    2. Start app in background with timeout (max 30 seconds)
    3. Run health checks
    4. Report results and cleanup (kill any started processes)

    ERROR HANDLING:
    - If app fails to start, capture error and report as BROKEN
    - If health check times out, report as BROKEN with timeout details
    - Always cleanup processes, even on failure

    Output an App Verification Report with startup status and health check results.
