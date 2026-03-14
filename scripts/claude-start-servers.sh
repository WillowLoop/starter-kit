#!/bin/bash
export CLAUDE_SESSION_ID="claude-$$"
exec "$(dirname "$0")/start-dev.sh"
