#!/usr/bin/env bash
# Parse a protocol JSONL log and check ordering invariants.
# These define what "correct protocol behavior" means.
#
# Usage: ./assert-sequence.sh <log-file>
# Exits 0 if all pass, 1 if any fail.

set -uo pipefail

LOG_FILE="${1:?Usage: assert-sequence.sh <log-file>}"

if [ ! -f "$LOG_FILE" ]; then
  echo "ERROR: log file not found: $LOG_FILE"
  exit 2
fi

PASS=0
FAIL=0

assert() {
  local desc="$1" result="$2"
  if [ "$result" = "true" ]; then
    echo "  PASS: $desc"
    ((PASS++))
  else
    echo "  FAIL: $desc"
    ((FAIL++))
  fi
}

# Extract ordered tool events (line number = sequence position)
# Each line: tool_name event_type file_path(if applicable)
EVENTS=$(jq -r '[.hook_event_name, .tool_name, (.tool_input.file_path // .tool_input.command // .tool_input.pattern // "")] | @tsv' "$LOG_FILE" 2>/dev/null)

echo "=== Sequence Assertions ==="
echo "  ($(echo "$EVENTS" | wc -l) events in log)"

# Helper: line number of first event matching pattern
first_line() {
  echo "$EVENTS" | grep -n "$1" | head -1 | cut -d: -f1
}

# Helper: check if any event matches pattern
has_event() {
  echo "$EVENTS" | grep -q "$1"
}

# --- Invariant 1: Read RALPH.md before any Edit ---
echo ""
echo "--- Invariant: Read RALPH.md before any Edit ---"
FIRST_READ_RALPH=$(first_line "PreToolUse.*Read.*RALPH.md")
FIRST_EDIT=$(first_line "PreToolUse.*Edit")

if [ -n "$FIRST_EDIT" ]; then
  if [ -n "$FIRST_READ_RALPH" ]; then
    assert "Read RALPH.md (line $FIRST_READ_RALPH) before first Edit (line $FIRST_EDIT)" \
      "$([ "$FIRST_READ_RALPH" -lt "$FIRST_EDIT" ] && echo true || echo false)"
  else
    assert "Read RALPH.md before first Edit" "false"
  fi
else
  assert "Read RALPH.md before first Edit (no edits in session)" "true"
fi

# --- Invariant 2: Read handoffs before editing src ---
echo ""
echo "--- Invariant: Read handoffs before Edit src ---"
FIRST_READ_HANDOFF=$(first_line "PreToolUse.*Read.*docs/handoffs/")
FIRST_EDIT_SRC=$(first_line "PreToolUse.*Edit.*src/")

if [ -n "$FIRST_EDIT_SRC" ]; then
  if [ -n "$FIRST_READ_HANDOFF" ]; then
    assert "Read handoff (line $FIRST_READ_HANDOFF) before first src Edit (line $FIRST_EDIT_SRC)" \
      "$([ "$FIRST_READ_HANDOFF" -lt "$FIRST_EDIT_SRC" ] && echo true || echo false)"
  else
    assert "Read handoffs before first src Edit" "false"
  fi
else
  assert "Read handoffs before Edit src (no src edits in session)" "true"
fi

# --- Invariant 3: tk ready before tk start ---
echo ""
echo "--- Invariant: tk ready before tk start ---"
FIRST_TK_READY=$(echo "$EVENTS" | grep -n "tk ready\|tk  *ready" | head -1 | cut -d: -f1)
FIRST_TK_START=$(echo "$EVENTS" | grep -n "tk start\|tk  *start" | head -1 | cut -d: -f1)

if [ -n "$FIRST_TK_START" ]; then
  if [ -n "$FIRST_TK_READY" ]; then
    assert "tk ready (line $FIRST_TK_READY) before tk start (line $FIRST_TK_START)" \
      "$([ "$FIRST_TK_READY" -lt "$FIRST_TK_START" ] && echo true || echo false)"
  else
    assert "tk ready before tk start" "false"
  fi
else
  assert "tk ready before tk start (no tk start in session)" "true"
fi

# --- Invariant 4: Handoff file written before session ends ---
echo ""
echo "--- Invariant: Handoff written during session ---"
HANDOFF_WRITE=$(echo "$EVENTS" | grep -c "Write.*docs/handoffs/\|Edit.*docs/handoffs/")
assert "handoff file written during session (count: $HANDOFF_WRITE)" \
  "$([ "$HANDOFF_WRITE" -gt 0 ] && echo true || echo false)"

# --- Invariant 5: ADR written when docs/adrs/ was modified ---
echo ""
echo "--- Invariant: ADR written if adrs dir touched ---"
ADR_EDITS=$(echo "$EVENTS" | grep -c "docs/adrs/")
if [ "$ADR_EDITS" -gt 0 ]; then
  ADR_WRITES=$(echo "$EVENTS" | grep -c "Write.*docs/adrs/\|Edit.*docs/adrs/")
  assert "ADR file was written (not just read)" \
    "$([ "$ADR_WRITES" -gt 0 ] && echo true || echo false)"
else
  assert "ADR check (no ADR activity in session — OK if no arch decisions)" "true"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
