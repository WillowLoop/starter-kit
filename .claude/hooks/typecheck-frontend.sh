#!/bin/bash
# Hook: auto-run TypeScript type checks after editing frontend files
# Reads file path from stdin JSON (PostToolUse hook format)

FILE_PATH=$(jq -r '.tool_input.file_path // empty')

# Skip if no file path, not in frontend/, or not a .ts/.tsx file
if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" != *frontend/* ]]; then
  exit 0
fi
if [[ "$FILE_PATH" != *.ts ]] && [[ "$FILE_PATH" != *.tsx ]]; then
  exit 0
fi

cd "$(git rev-parse --show-toplevel)/frontend" 2>/dev/null || exit 0

# Guard: skip if no tsconfig.json
[[ -f tsconfig.json ]] || exit 0

# Run tsc, show only first 15 lines of errors to keep output manageable
OUTPUT=$(npx tsc --noEmit 2>&1)
LINES=$(echo "$OUTPUT" | wc -l)
echo "$OUTPUT" | head -15
if [[ "$LINES" -gt 15 ]]; then
  echo "... ($((LINES - 15)) more lines truncated)"
fi
