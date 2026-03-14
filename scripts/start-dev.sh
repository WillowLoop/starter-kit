#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
PID_FILE="/tmp/dev-${SESSION_ID}.pids"

find_free_port() {
    local start=$1
    for port in $(seq "$start" $((start + 15))); do
        if ! lsof -i :"$port" -sTCP:LISTEN >/dev/null 2>&1; then
            echo "$port"; return
        fi
    done
    echo "ERROR: no free port in range $start-$((start+15))" >&2; exit 1
}

cleanup() {
    echo ""
    echo "Shutting down servers..."
    if [[ -f "$PID_FILE" ]]; then
        while read -r pid; do
            # Try process group kill first (may not work if process is not group leader).
            # Falls back to direct kill. Child processes (uvicorn workers, Next.js compiler)
            # may survive but will get SIGHUP when terminal closes.
            kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
    echo "Done."
}

# --stop: only stop own servers
if [[ "${1:-}" == "--stop" ]]; then
    if [[ -f "$PID_FILE" ]]; then
        cleanup
        echo "Stopped servers for session $SESSION_ID"
    else
        echo "No running servers found for this session"
    fi
    exit 0
fi

trap cleanup EXIT INT TERM

BE_PORT=$(find_free_port 8000)
FE_PORT=$(find_free_port 3000)

echo "Starting backend on :$BE_PORT, frontend on :$FE_PORT"

# Backend (absolute path)
(cd "$ROOT_DIR/backend" && exec uv run uvicorn app.main:app --reload --host localhost --port "$BE_PORT") &
BE_PID=$!

# Frontend (NEXT_PUBLIC_API_URL works in dev mode — Next.js dev server re-reads env per request)
(cd "$ROOT_DIR/frontend" && exec env NEXT_PUBLIC_API_URL="http://localhost:$BE_PORT" pnpm dev --port "$FE_PORT") &
FE_PID=$!

# Track PIDs
echo "$BE_PID" > "$PID_FILE"
echo "$FE_PID" >> "$PID_FILE"

echo ""
echo "Backend:  http://localhost:$BE_PORT  (PID $BE_PID)"
echo "Frontend: http://localhost:$FE_PORT  → backend :$BE_PORT  (PID $FE_PID)"
echo "Stop:     $0 --stop  OR  Ctrl+C"
echo "PID file: $PID_FILE"
echo ""

wait
