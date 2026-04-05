#!/usr/bin/env bash
# Test runner for checkpoint fixtures.
# Usage: ./run-fixture.sh <fixture-dir> [--exercise]
#
# Without --exercise: setup → validate fixture state → teardown
# With --exercise: setup → print prompt → wait for manual Claude run →
#                  assert sequence → assert artifacts → teardown
#
# The spike validates that fixtures set up correctly and assertions
# can run against them. Full Claude exercise is manual for now.
set -uo pipefail

FIXTURE_DIR="${1:?Usage: run-fixture.sh <fixture-dir> [--exercise]}"
EXERCISE="${2:-}"
SPIKE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARNESS_DIR="$(cd "$SPIKE_ROOT/../0.5-protocol-test-harness" && pwd)"

FIXTURE_NAME=$(basename "$FIXTURE_DIR")
echo "=== Fixture: $FIXTURE_NAME ==="

# --- Setup ---
echo ""
echo "--- Setup ---"
REPO=$(bash "$FIXTURE_DIR/setup.sh" | tail -1)
if [ $? -ne 0 ] || [ -z "$REPO" ] || [ ! -d "$REPO" ]; then
  echo "FAIL: setup.sh did not produce a valid directory"
  exit 2
fi
echo "  Repo created at: $REPO"

# --- Validate fixture state ---
echo ""
echo "--- Fixture state validation ---"

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

# Git repo exists and has commits
assert "is a git repo" "$(git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 && echo true || echo false)"
COMMIT_COUNT=$(git -C "$REPO" rev-list --count HEAD 2>/dev/null || echo 0)
assert "has commits ($COMMIT_COUNT)" "$([ "$COMMIT_COUNT" -gt 0 ] && echo true || echo false)"

# RALPH.md exists
assert "RALPH.md exists" "$([ -f "$REPO/RALPH.md" ] && echo true || echo false)"

# .tickets/ exists with tickets
TICKET_COUNT=$(ls "$REPO/.tickets/"*.md 2>/dev/null | wc -l)
assert "has tickets ($TICKET_COUNT)" "$([ "$TICKET_COUNT" -gt 0 ] && echo true || echo false)"

# Handoffs exist
HANDOFF_COUNT=$(ls "$REPO/docs/handoffs/"*.md 2>/dev/null | wc -l)
assert "has handoffs ($HANDOFF_COUNT)" "$([ "$HANDOFF_COUNT" -gt 0 ] && echo true || echo false)"

# expected.json exists and is valid
assert "expected.json exists" "$([ -f "$FIXTURE_DIR/expected.json" ] && echo true || echo false)"
assert "expected.json is valid JSON" "$(jq empty "$FIXTURE_DIR/expected.json" 2>/dev/null && echo true || echo false)"

# prompt.txt exists
assert "prompt.txt exists" "$([ -f "$FIXTURE_DIR/prompt.txt" ] && echo true || echo false)"

# Fixture-specific state checks
READY_COUNT=$(TICKETS_DIR="$REPO/.tickets" tk ready -a ralph 2>/dev/null | wc -l)
BLOCKED_COUNT=$(TICKETS_DIR="$REPO/.tickets" tk blocked -a ralph 2>/dev/null | wc -l)
IN_PROGRESS=$(TICKETS_DIR="$REPO/.tickets" tk ls --status=in_progress 2>/dev/null | wc -l)

echo ""
echo "  tk state: $READY_COUNT ready, $BLOCKED_COUNT blocked, $IN_PROGRESS in_progress"

case "$FIXTURE_NAME" in
  fresh-pour)
    assert "has ready tasks for ralph" "$([ "$READY_COUNT" -gt 0 ] && echo true || echo false)"
    assert "no tasks in_progress" "$([ "$IN_PROGRESS" -eq 0 ] && echo true || echo false)"
    ;;
  blocked-deps)
    assert "no ready tasks for ralph" "$([ "$READY_COUNT" -eq 0 ] && echo true || echo false)"
    assert "has blocked tasks" "$([ "$BLOCKED_COUNT" -gt 0 ] && echo true || echo false)"
    ;;
esac

# --- Exercise (manual) ---
if [ "$EXERCISE" = "--exercise" ]; then
  echo ""
  echo "--- Exercise mode ---"
  echo "  Fixture repo: $REPO"
  echo "  Prompt:"
  echo ""
  sed 's/^/    /' "$FIXTURE_DIR/prompt.txt"
  echo ""
  echo "  Run Claude manually in $REPO, then press Enter to assert."
  read -r

  # Run assertions if protocol log exists
  LOG_FILE=$(ls "$REPO/.claude/protocol-logs/"*.jsonl 2>/dev/null | head -1)
  if [ -n "$LOG_FILE" ]; then
    echo ""
    echo "--- Sequence assertions ---"
    bash "$HARNESS_DIR/assert-sequence.sh" "$LOG_FILE"
  else
    echo "  SKIP: No protocol log found (hooks not configured?)"
  fi

  echo ""
  echo "--- Artifact assertions ---"
  bash "$HARNESS_DIR/assert-artifacts.sh" "$REPO"
else
  echo ""
  echo "  (Use --exercise to run manual Claude session + assertions)"
fi

# --- Teardown ---
echo ""
echo "--- Teardown ---"
rm -rf "$REPO"
echo "  Cleaned up $REPO"

echo ""
echo "=== $FIXTURE_NAME: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
