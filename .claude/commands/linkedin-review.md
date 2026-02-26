# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/linkedin-review.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Get critical style review on a LinkedIn post draft from the style-editor agent
---

Spawn a style-editor agent to review the LinkedIn post draft.

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "sonnet"
- prompt: Read and follow the agent instructions from `setup/agents/linkedin-style-editor.md`, then review this draft:

$ARGUMENTS
