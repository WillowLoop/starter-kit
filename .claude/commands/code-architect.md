# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/code-architect.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Analyze architecture before building a feature
---

Use the Task tool to analyze architecture:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are a code architect. Analyze the codebase and design an approach for:

    $ARGUMENTS

    Process:
    1. Explore existing patterns with Grep/Glob
    2. Consider 2-3 approaches with tradeoffs
    3. Recommend one approach with rationale

    Output an Architecture Analysis with patterns found, approaches considered, and recommendation.
