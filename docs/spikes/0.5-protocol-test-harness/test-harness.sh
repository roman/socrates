#!/usr/bin/env bash
# Verify the protocol test harness components work with synthetic data.
set -uo pipefail

SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Spike 0.5: Protocol Test Harness ==="

# --- Component 1: Hook script ---
echo ""
echo "--- Component 1: Hook logging ---"

LOG_DIR=$(mktemp -d)
export CLAUDE_PROJECT_DIR="$LOG_DIR"
mkdir -p "$LOG_DIR/.claude/protocol-logs"

# Simulate hook stdin
echo '{"session_id":"test-001","hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"RALPH.md"}}' \
  | bash "$SPIKE_DIR/hooks/log-protocol.sh"

echo '{"session_id":"test-001","hook_event_name":"PostToolUse","tool_name":"Read","tool_input":{"file_path":"RALPH.md"},"tool_response":{}}' \
  | bash "$SPIKE_DIR/hooks/log-protocol.sh"

echo '{"session_id":"test-001","hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"docs/handoffs/2026-01-01-0100-test.md"}}' \
  | bash "$SPIKE_DIR/hooks/log-protocol.sh"

echo '{"session_id":"test-001","hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"src/main.ts"}}' \
  | bash "$SPIKE_DIR/hooks/log-protocol.sh"

echo '{"session_id":"test-001","hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"docs/handoffs/2026-01-01-0200-session.md"}}' \
  | bash "$SPIKE_DIR/hooks/log-protocol.sh"

LOG_FILE="$LOG_DIR/.claude/protocol-logs/test-001.jsonl"

if [ -f "$LOG_FILE" ]; then
  LINE_COUNT=$(wc -l < "$LOG_FILE")
  VALID_JSON=$(jq -e '.' "$LOG_FILE" >/dev/null 2>&1 && echo true || echo false)
  HAS_TS=$(jq -e '.ts' "$LOG_FILE" >/dev/null 2>&1 && echo true || echo false)
  echo "  PASS: Log file created with $LINE_COUNT entries"
  echo "  $([ "$VALID_JSON" = true ] && echo PASS || echo FAIL): All entries are valid JSON"
  echo "  $([ "$HAS_TS" = true ] && echo PASS || echo FAIL): Entries have timestamp"
else
  echo "  FAIL: Log file not created"
fi

# --- Component 3: Sequence assertions (good log) ---
echo ""
echo "--- Component 3: Sequence assertions (should pass) ---"
bash "$SPIKE_DIR/assert-sequence.sh" "$LOG_FILE"
SEQ_EXIT=$?
echo "  Exit code: $SEQ_EXIT (expected 0)"

# --- Component 3: Sequence assertions (bad log — edit before read) ---
echo ""
echo "--- Component 3: Sequence assertions (bad order — should fail) ---"
BAD_LOG=$(mktemp)
echo '{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"src/main.ts"}}' > "$BAD_LOG"
echo '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"RALPH.md"}}' >> "$BAD_LOG"
bash "$SPIKE_DIR/assert-sequence.sh" "$BAD_LOG"
BAD_EXIT=$?
echo "  Exit code: $BAD_EXIT (expected 1)"

# --- Component 2: Artifact assertions (on this repo) ---
echo ""
echo "--- Component 2: Artifact assertions (on socrates repo) ---"
REPO_DIR="$(cd "$SPIKE_DIR/../../.." && pwd)"
bash "$SPIKE_DIR/assert-artifacts.sh" "$REPO_DIR"

# --- Cleanup ---
rm -rf "$LOG_DIR" "$BAD_LOG"

echo ""
echo "=== Spike 0.5 complete ==="
