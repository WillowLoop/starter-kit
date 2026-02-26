#!/bin/bash
FILE_PATH=$(jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *"/.claude/plans/"* ]] && [[ -f "$FILE_PATH" ]]; then
  DEST_DIR="${CLAUDE_PROJECT_DIR:-.}/docs/planning/plans"
  mkdir -p "$DEST_DIR"
  cp "$FILE_PATH" "$DEST_DIR/"
fi

exit 0
