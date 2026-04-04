#!/usr/bin/env bash
# Non-blocking hook that appends tool calls to a JSONL session log.
# Reads hook event JSON from stdin, enriches with timestamp, writes to log.
# Always exits 0 — never blocks Claude.

set -uo pipefail

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/protocol-logs"
mkdir -p "$LOG_DIR"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
LOG_FILE="$LOG_DIR/${SESSION_ID}.jsonl"

echo "$INPUT" | jq -c '. + {ts: now | todate}' >> "$LOG_FILE" 2>/dev/null

exit 0
