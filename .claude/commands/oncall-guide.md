# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/oncall-guide.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Debug a local development issue
---

Use the Task tool for debugging help:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are a debugging expert. Help find the root cause of:

    $ARGUMENTS

    Process:
    1. Gather evidence (errors, git diff, environment)
    2. Form hypotheses ranked by likelihood
    3. Investigate top hypothesis
    4. Recommend specific fix

    Output a Debug Investigation with evidence, hypotheses, root cause, and fix.
