# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/code-simplifier.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Simplify code in the specified path
---

Use the Task tool to simplify code:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: |
    You are a code simplification expert. Review and simplify:

    $ARGUMENTS

    Look for: unnecessary abstractions, deep nesting, dead code, magic values.
    Provide concrete before/after examples for each suggestion.

    Output a Code Simplification Review with specific suggestions and impact assessment.
