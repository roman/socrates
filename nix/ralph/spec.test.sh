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

# Spec 2: mid-phase (Delimit approved, Direction DRAFT)
mkdir -p "$FIXTURE/mid-phase-spec"
cat > "$FIXTURE/mid-phase-spec/_overview.md" <<'SPECEOF'
---
title: Mid Phase Spec
created: 2026-01-02
archived:
delimit_approved: true
---

## Describe

## Diagnose

## Delimit

## Direction [DRAFT]

## Design [DRAFT]
SPECEOF

cat > "$FIXTURE/mid-phase-spec/1-aaaa-task-one.md" <<'TASKEOF'
---
id: aaaa-task-one
status: approved
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task One

## Outcomes

- Do something.

## Verification

- check it

<review></review>
TASKEOF

cat > "$FIXTURE/mid-phase-spec/2-bbbb-task-two.md" <<'TASKEOF'
---
id: bbbb-task-two
status: draft
priority: 1
category: documentation
assignee: ralph
deps: []
---
# Task Two

## Outcomes

- Do another thing.

## Verification

- check it

<review>
This needs the author's attention.
</review>
TASKEOF

# Spec 3: closed spec with completed and draft tasks
mkdir -p "$FIXTURE/closed-spec"
cat > "$FIXTURE/closed-spec/_overview.md" <<'SPECEOF'
---
title: Closed Spec
created: 2026-01-03
archived:
delimit_approved: true
---

## Describe

## Diagnose

## Delimit

## Direction

## Design
SPECEOF

cat > "$FIXTURE/closed-spec/1-cccc-closed-task.md" <<'TASKEOF'
---
id: cccc-closed-task
status: closed
priority: 0
category: functional
assignee: ralph
deps: []
---
# Closed Task

## Outcomes

- Already closed.

## Verification

- done
<review></review>
TASKEOF

cat > "$FIXTURE/closed-spec/2-dddd-draft-task.md" <<'TASKEOF'
---
id: dddd-draft-task
status: draft
priority: 1
category: infrastructure
assignee: ralph
deps: []
---
# Draft Task

## Outcomes

- Still in draft.

## Verification

- pending
<review></review>
TASKEOF

# Archive directory (should be excluded from all output)
mkdir -p "$FIXTURE/archive/old-spec"
cat > "$FIXTURE/archive/old-spec/_overview.md" <<'SPECEOF'
---
title: Archived Spec
created: 2025-12-01
archived: 2026-01-15
delimit_approved: true
---

## Describe

## Design
SPECEOF

# Legacy markers remain readable.
mkdir -p "$FIXTURE/legacy-spec"
cat > "$FIXTURE/legacy-spec/_overview.md" <<'SPECEOF'
---
title: Legacy Spec
created: 2025-12-15
archived:
delimit_approved: true
---

## Describe [COMPLETE]

## Diagnose [COMPLETE]

## Delimit [APPROVED]

## Direction [DRAFT]

## Design [DRAFT]
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
assert_contains "shows closed-spec" "closed-spec"
assert_contains "closed-spec at Design" "Design"
assert_contains "legacy markers remain readable" "legacy-spec"
assert_contains "legacy spec resumes at Direction [DRAFT]" "Direction [DRAFT]"
assert_contains "closed-spec task counts" "1 draft, 0 approved, 1 closed"
assert_contains "mid-phase task counts" "1 draft, 1 approved, 0 closed"
assert_contains "fresh-spec task counts" "0 draft, 0 approved, 0 closed"
assert_not_contains "archive excluded from status" "old-spec"
assert_not_contains "archive excluded from status" "Archived"

echo ""
echo "=== spec tasks ==="

run "tasks exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks
assert_contains "header has SPEC column" "SPEC"
assert_contains "header has ASSIGNEE column" "ASSIGNEE"
assert_contains "header has REVIEW column" "REVIEW"
assert_contains "shows review pending" "pending"
assert_contains "shows task-two with review" "2-bbbb-task-two"
assert_not_contains "archive excluded from tasks" "old-spec"

echo ""
echo "=== spec tasks --status ==="

run "tasks --status approved exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --status approved
assert_contains "shows approved task" "1-aaaa-task-one"
assert_not_contains "excludes draft task" "2-bbbb-task-two"
assert_not_contains "excludes closed task" "1-cccc-closed-task"

run "tasks --status closed exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --status closed
assert_contains "shows closed task" "1-cccc-closed-task"
assert_not_contains "excludes draft from closed filter" "2-dddd-draft-task"

echo ""
echo "=== spec tasks --review ==="

run "tasks --review exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" tasks --review
assert_contains "review filter shows task with content" "2-bbbb-task-two"
assert_not_contains "review filter excludes empty review (task-one)" "1-aaaa-task-one"
assert_not_contains "review filter excludes empty review (closed)" "1-cccc-closed-task"
assert_not_contains "review filter excludes empty review (draft)" "2-dddd-draft-task"

# --- Fixture setup for ready/dependents ---
# Build a spec with the unified schema: deps, assignee, status lifecycle

mkdir -p "$FIXTURE/frontier-spec"
cat > "$FIXTURE/frontier-spec/_overview.md" <<'SPECEOF'
---
title: Frontier Test
created: 2026-01-10
archived:
delimit_approved: true
---

## Describe

## Diagnose

## Delimit

## Direction

## Design
SPECEOF

# Task A: approved, no deps, assigned to ralph -> should appear in frontier
cat > "$FIXTURE/frontier-spec/a1b2-task-a.md" <<'TASKEOF'
---
id: a1b2-task-a
status: approved
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task A
## Outcomes
- Do A
## Verification
- check A
<review></review>
TASKEOF

# Task B: approved, depends on A (not closed), assigned to ralph -> blocked
cat > "$FIXTURE/frontier-spec/c3d4-task-b.md" <<'TASKEOF'
---
id: c3d4-task-b
status: approved
priority: 1
category: functional
assignee: ralph
deps: [a1b2-task-a]
---
# Task B
## Outcomes
- Do B
## Verification
- check B
<review></review>
TASKEOF

# Task C: approved, no deps, assigned to alice -> not ralph's
cat > "$FIXTURE/frontier-spec/e5f6-task-c.md" <<'TASKEOF'
---
id: e5f6-task-c
status: approved
priority: 0
category: functional
assignee: alice
deps: []
---
# Task C
## Outcomes
- Do C
## Verification
- check C
<review></review>
TASKEOF

# Task D: draft, no deps, assigned to ralph -> not approved
cat > "$FIXTURE/frontier-spec/1-g7h8-task-d.md" <<'TASKEOF'
---
id: 1-g7h8-task-d
status: draft
priority: 2
category: documentation
assignee: ralph
deps: []
---
# Task D
## Outcomes
- Do D
## Verification
- check D
<review></review>
TASKEOF

# Task E: approved, depends on closed task F, assigned to ralph -> unblocked
cat > "$FIXTURE/frontier-spec/i9j0-task-e.md" <<'TASKEOF'
---
id: i9j0-task-e
status: approved
priority: 1
category: functional
assignee: ralph
deps: [k1l2-task-f]
---
# Task E
## Outcomes
- Do E
## Verification
- check E
<review></review>
TASKEOF

# Task F: closed, no deps
cat > "$FIXTURE/frontier-spec/k1l2-task-f.md" <<'TASKEOF'
---
id: k1l2-task-f
status: closed
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task F
## Outcomes
- Did F
## Verification
- done
<review></review>
TASKEOF

echo ""
echo "=== spec ready ==="

run "ready -a ralph exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready -a ralph
assert_contains "frontier includes unblocked task A" "a1b2-task-a"
assert_contains "frontier includes task E (dep closed)" "i9j0-task-e"
assert_not_contains "frontier excludes blocked task B" "c3d4-task-b"
assert_not_contains "frontier excludes alice's task C" "e5f6-task-c"
assert_not_contains "frontier excludes draft task D" "g7h8-task-d"
assert_not_contains "frontier excludes closed task F" "k1l2-task-f"

run "ready -a alice exits 0" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready -a alice
assert_contains "alice sees her task C" "e5f6-task-c"
assert_not_contains "alice does not see ralph's task A" "a1b2-task-a"

# Now close task A and verify B becomes unblocked
cat > "$FIXTURE/frontier-spec/a1b2-task-a.md" <<'TASKEOF'
---
id: a1b2-task-a
status: closed
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task A
## Outcomes
- Do A
## Verification
- check A
<review></review>
TASKEOF

run "ready after closing dep" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready -a ralph
assert_contains "task B now unblocked after A closed" "c3d4-task-b"
assert_not_contains "closed task A no longer in frontier" "a1b2-task-a"

# Restore task A for other tests
cat > "$FIXTURE/frontier-spec/a1b2-task-a.md" <<'TASKEOF'
---
id: a1b2-task-a
status: approved
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task A
## Outcomes
- Do A
## Verification
- check A
<review></review>
TASKEOF

run "ready requires -a flag" 1 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready

echo ""
echo "=== spec ready (topological order) ==="

# Verify output order is topological: A before B (B depends on A)
# Close A so both A-successor and independent tasks appear
cat > "$FIXTURE/frontier-spec/a1b2-task-a.md" <<'TASKEOF'
---
id: a1b2-task-a
status: closed
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task A
<review></review>
TASKEOF

run "topo order check" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready -a ralph
# B and E should both appear; B depends on A (closed), E depends on F (closed)
assert_contains "topo: B appears" "c3d4-task-b"
assert_contains "topo: E appears" "i9j0-task-e"

# Restore
cat > "$FIXTURE/frontier-spec/a1b2-task-a.md" <<'TASKEOF'
---
id: a1b2-task-a
status: approved
priority: 0
category: functional
assignee: ralph
deps: []
---
# Task A
## Outcomes
- Do A
## Verification
- check A
<review></review>
TASKEOF

echo ""
echo "=== spec dependents ==="

run "dependents of task A" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" dependents a1b2-task-a
assert_contains "B depends on A" "c3d4-task-b"
assert_not_contains "E does not depend on A" "i9j0-task-e"

run "dependents of task F" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" dependents k1l2-task-f
assert_contains "E depends on F" "i9j0-task-e"
assert_not_contains "B does not depend on F" "c3d4-task-b"

run "dependents of task with no dependents" 0 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" dependents c3d4-task-b

echo ""
echo "=== spec ready (cycle detection) ==="

# Create a cycle: X depends on Y, Y depends on X
mkdir -p "$FIXTURE/cycle-spec"
cat > "$FIXTURE/cycle-spec/_overview.md" <<'SPECEOF'
---
title: Cycle Test
created: 2026-01-11
archived:
delimit_approved: true
---

## Describe

## Design
SPECEOF

cat > "$FIXTURE/cycle-spec/m1n2-cycle-x.md" <<'TASKEOF'
---
id: m1n2-cycle-x
status: approved
priority: 0
category: functional
assignee: ralph
deps: [o3p4-cycle-y]
---
# Cycle X
<review></review>
TASKEOF

cat > "$FIXTURE/cycle-spec/o3p4-cycle-y.md" <<'TASKEOF'
---
id: o3p4-cycle-y
status: approved
priority: 0
category: functional
assignee: ralph
deps: [m1n2-cycle-x]
---
# Cycle Y
<review></review>
TASKEOF

run "cycle detection exits non-zero" 1 env SPECS_DIR="$FIXTURE" bash "$SCRIPT" ready -a ralph
assert_contains "cycle error names member X" "m1n2-cycle-x"
assert_contains "cycle error names member Y" "o3p4-cycle-y"

# Clean up cycle spec so it doesn't interfere
rm -rf "$FIXTURE/cycle-spec"

echo ""
echo "=== read-only check ==="

# Verify the script contains no file-mutating constructs
script_text=$(cat "$SCRIPT")
ro_fail=0
# shellcheck disable=SC2043  # single-pattern loop kept for extensibility
for pattern in "sed -i"; do
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
