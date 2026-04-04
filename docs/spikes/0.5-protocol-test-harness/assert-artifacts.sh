#!/usr/bin/env bash
# Post-session artifact assertions. Checks files and git state for protocol
# compliance. Pure grep/jq — no LLM.
#
# Usage: ./assert-artifacts.sh [project-dir]
# Exits 0 if all pass, 1 if any fail.

set -uo pipefail

PROJECT_DIR="${1:-.}"
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

echo "=== Artifact Assertions ==="

# --- ADR format ---
echo ""
echo "--- ADRs ---"
for adr in "$PROJECT_DIR"/docs/adrs/*.md; do
  [ -f "$adr" ] || continue
  name=$(basename "$adr")

  # Numbered prefix
  assert "$name has numbered prefix" \
    "$(echo "$name" | grep -qE '^[0-9]+-' && echo true || echo false)"

  # Required sections: Status, Context, Decision, Consequences
  for section in Status Context Decision Consequences; do
    assert "$name has ## $section" \
      "$(grep -qE "^## $section" "$adr" && echo true || echo false)"
  done
done

# --- Handoff format ---
echo ""
echo "--- Handoffs ---"
for handoff in "$PROJECT_DIR"/docs/handoffs/*.md; do
  [ -f "$handoff" ] || continue
  name=$(basename "$handoff")

  # Filename format: YYYY-MM-DD-HHmm-<topic>.md
  assert "$name has correct filename format" \
    "$(echo "$name" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}-' && echo true || echo false)"

  # Required sections
  for section in "What Was Done" "What's Next" "Learnings"; do
    assert "$name has ## $section" \
      "$(grep -qF "## $section" "$handoff" && echo true || echo false)"
  done

  # No machine-local references
  assert "$name has no ~/ references" \
    "$(grep -qE '~/\.' "$handoff" && echo false || echo true)"
done

# --- Commit messages ---
echo ""
echo "--- Recent commits ---"
while IFS= read -r sha; do
  msg=$(git -C "$PROJECT_DIR" log --format='%B' -1 "$sha")
  title=$(echo "$msg" | head -1 | head -c 60)
  assert "commit $sha has Refs: ($title...)" \
    "$(echo "$msg" | grep -qE 'Refs:' && echo true || echo false)"
done < <(git -C "$PROJECT_DIR" log --format='%H' -10)

# --- tk state transitions ---
echo ""
echo "--- tk state ---"
if [ -d "$PROJECT_DIR/.tickets" ]; then
  # No ticket should be in_progress without recent activity
  IN_PROGRESS=$(TICKETS_DIR="$PROJECT_DIR/.tickets" tk ls --status=in_progress 2>/dev/null | wc -l)
  assert "no abandoned in_progress tickets (count: $IN_PROGRESS)" \
    "$([ "$IN_PROGRESS" -le 2 ] && echo true || echo false)"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
