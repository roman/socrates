#!/usr/bin/env bash
# Capture raw hook stdin to a JSONL file for format inspection.
# No transformation — just append exactly what we receive + a timestamp marker.
INPUT=$(cat)
LOG_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo '.')/.claude/protocol-logs"
mkdir -p "$LOG_DIR"
echo "$INPUT" | jq -c '. + {_captured_at: now | todate}' >> "$LOG_DIR/raw-capture.jsonl" 2>/dev/null || echo "$INPUT" >> "$LOG_DIR/raw-capture.jsonl"
exit 0
