#!/bin/bash
# Headless batch task runner using claude -p
# Usage: ./scripts/claude-batch-task.sh "your prompt here"
# Note: $1 is passed as a Claude prompt with Bash, Edit, and Write tool access.

set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 \"<prompt>\"" >&2
  exit 1
fi

claude -p "$1" --allowedTools Bash,Edit,Write,Read,Glob,Grep
