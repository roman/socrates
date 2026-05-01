#!/usr/bin/env bash
# Tests for the spec CLI
set -u

SCRIPT="$(dirname "$0")/spec"
fail=0
LAST_OUTPUT=""

run() {
  local desc="$1" expected_exit="$2"
  shift 2
  local got_exit
  LAST_OUTPUT=$("$@" 2>&1) && got_exit=0 || got_exit=$?
  if [ "$got_exit" = "$expected_exit" ]; then
    echo "ok   - $desc"
  else
    echo "FAIL - $desc (exit: expected $expected_exit, got $got_exit)"
    echo "  output: $LAST_OUTPUT"
    fail=$((fail + 1))
  fi
}

assert_contains() {
  local desc="$1" needle="$2"
  if echo "$LAST_OUTPUT" | grep -qF -- "$needle"; then
    echo "ok   - $desc"
  else
    echo "FAIL - $desc (expected to contain: $needle)"
    echo "  output: $LAST_OUTPUT"
    fail=$((fail + 1))
  fi
}

assert_not_contains() {
  local desc="$1" needle="$2"
  if echo "$LAST_OUTPUT" | grep -qF -- "$needle"; then
    echo "FAIL - $desc (should NOT contain: $needle)"
    echo "  output: $LAST_OUTPUT"
    fail=$((fail + 1))
  else
    echo "ok   - $desc"
  fi
}

# --- Fixture setup ---

FIXTURE=$(mktemp -d)
trap 'rm -rf "$FIXTURE"' EXIT

# Spec 1: fresh at Describe [DRAFT], no tasks
mkdir -p "$FIXTURE/fresh-spec"
cat > "$FIXTURE/fresh-spec/_overview.md" <<'SPECEOF'
---
title: Fresh Spec
created: 2026-01-01
epic:
archived:
delimit_approved: false
---

## Describe [DRAFT]

Some situation.

## Diagnose [DRAFT]

## Delimit [DRAFT]

## Direction [DRAFT]

## Design [DRAFT]
SPECEOF

# Spec 2: mid-phase (Delimit APPROVED, Direction DRAFT)
mkdir -p "$FIXTURE/mid-phase-spec"
cat > "$FIXTURE/mid-phase-spec/_overview.md" <<'SPECEOF'
---
title: Mid Phase Spec
created: 2026-01-02
epic:
archived:
delimit_approved: true
---

## Describe [COMPLETE]

## Diagnose [COMPLETE]

## Delimit [APPROVED]

## Direction [DRAFT]

## Design [DRAFT]
SPECEOF

cat > "$FIXTURE/mid-phase-spec/1-aaaa-task-one.md" <<'TASKEOF'
---
id: 1-aaaa-task-one
status: approved
priority: 0
category: functional
ticket: null
revisions: 0
---
# Task One

<outcome>Do something.</outcome>
<verification>
- check it
</verification>
<review></review>
TASKEOF

cat > "$FIXTURE/mid-phase-spec/2-bbbb-task-two.md" <<'TASKEOF'
---
id: 2-bbbb-task-two
status: draft
priority: 1
category: documentation
ticket: null
revisions: 0
---
# Task Two

<outcome>Do another thing.</outcome>
<verification>
- check it
</verification>
<review>
This needs the author's attention.
</review>
TASKEOF

# Spec 3: poured spec with epic and ticket fields
mkdir -p "$FIXTURE/poured-spec"
cat > "$FIXTURE/poured-spec/_overview.md" <<'SPECEOF'
---
title: Poured Spec
created: 2026-01-03
epic: soc-epic1
archived:
delimit_approved: true
---

## Describe [COMPLETE]

## Diagnose [COMPLETE]

## Delimit [APPROVED]

## Direction [COMPLETE]

## Design [COMPLETE]
SPECEOF

cat > "$FIXTURE/poured-spec/1-cccc-poured-task.md" <<'TASKEOF'
---
id: 1-cccc-poured-task
status: poured
priority: 0
category: functional
ticket: SENTINEL-1
revisions: 0
---
# Poured Task

<outcome>Already poured.</outcome>
<verification>
- done
</verification>
<review></review>
TASKEOF

cat > "$FIXTURE/poured-spec/2-dddd-unpoured-task.md" <<'TASKEOF'
---
id: 2-dddd-unpoured-task
status: draft
priority: 1
category: infrastructure
ticket: null
revisions: 0
---
# Unpoured Task

<outcome>Not poured yet.</outcome>
<verification>
- pending
</verification>
<review></review>
TASKEOF

# Archive directory (should be excluded from all output)
mkdir -p "$FIXTURE/archive/old-spec"
cat > "$FIXTURE/archive/old-spec/_overview.md" <<'SPECEOF'
---
title: Archived Spec
created: 2025-12-01
epic: soc-old
archived: 2026-01-15
delimit_approved: true
---

## Describe [COMPLETE]

## Design [COMPLETE]
SPECEOF

# --- Tests ---

echo "=== spec (usage) ==="

run "no args prints usage and exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT"
assert_contains "usage lists status command" "status"
assert_contains "usage lists tasks command" "tasks"
assert_contains "usage lists --status flag" "--status"
assert_contains "usage lists --review flag" "--review"

echo ""
echo "=== spec status ==="

run "status exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" status
assert_contains "shows fresh-spec" "fresh-spec"
assert_contains "fresh-spec at Describe [DRAFT]" "Describe [DRAFT]"
assert_contains "shows mid-phase-spec" "mid-phase-spec"
assert_contains "mid-phase at Direction [DRAFT]" "Direction [DRAFT]"
assert_contains "mid-phase delimit approved" "approved"
assert_contains "shows poured-spec" "poured-spec"
assert_contains "poured-spec at Design [COMPLETE]" "Design [COMPLETE]"
assert_contains "poured-spec task counts" "1 draft, 0 approved, 1 poured"
assert_contains "mid-phase task counts" "1 draft, 1 approved, 0 poured"
assert_contains "fresh-spec task counts" "0 draft, 0 approved, 0 poured"
assert_not_contains "archive excluded from status" "old-spec"
assert_not_contains "archive excluded from status" "Archived"

echo ""
echo "=== spec tasks ==="

run "tasks exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks
assert_contains "header has SPEC column" "SPEC"
assert_contains "header has TICKET column" "TICKET"
assert_contains "header has REVIEW column" "REVIEW"
assert_contains "shows SENTINEL-1 ticket" "SENTINEL-1"
assert_contains "shows review pending" "pending"
assert_contains "shows task-two with review" "2-bbbb-task-two"
assert_not_contains "archive excluded from tasks" "old-spec"

echo ""
echo "=== spec tasks --status ==="

run "tasks --status approved exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --status approved
assert_contains "shows approved task" "1-aaaa-task-one"
assert_not_contains "excludes draft task" "2-bbbb-task-two"
assert_not_contains "excludes poured task" "1-cccc-poured-task"

run "tasks --status poured exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --status poured
assert_contains "shows poured task" "1-cccc-poured-task"
assert_contains "poured task has SENTINEL-1" "SENTINEL-1"
assert_not_contains "excludes draft from poured filter" "2-dddd-unpoured-task"

echo ""
echo "=== spec tasks --review ==="

run "tasks --review exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --review
assert_contains "review filter shows task with content" "2-bbbb-task-two"
assert_not_contains "review filter excludes empty review (task-one)" "1-aaaa-task-one"
assert_not_contains "review filter excludes empty review (poured)" "1-cccc-poured-task"
assert_not_contains "review filter excludes empty review (unpoured)" "2-dddd-unpoured-task"

echo ""
echo "=== read-only check ==="

# Verify the script contains no file-mutating constructs
script_text=$(cat "$SCRIPT")
ro_fail=0
for pattern in 'sed -i' 'tk close' 'tk edit' 'tk create'; do
  if echo "$script_text" | grep -qF "$pattern"; then
    echo "FAIL - script contains mutating pattern: $pattern"
    ro_fail=$((ro_fail + 1))
  fi
done
# Check for output redirection to docs/ paths (but not >> in heredocs or > /dev/null)
if echo "$script_text" | grep -E '>[^>].*docs/' | grep -v '>/dev/null' | grep -qv '#'; then
  echo "FAIL - script contains output redirection to docs/"
  ro_fail=$((ro_fail + 1))
fi
if [ "$ro_fail" = "0" ]; then
  echo "ok   - script is read-only (no mutating constructs)"
fi
fail=$((fail + ro_fail))

echo ""
if [ "$fail" -eq 0 ]; then
  echo "All tests passed."
else
  echo "$fail test(s) FAILED."
fi

exit "$fail"
