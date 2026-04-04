#!/usr/bin/env bash
set -uo pipefail

SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"
export TICKETS_DIR="$SPIKE_DIR/.tickets"

# Clean slate
rm -rf "$TICKETS_DIR"
mkdir -p "$TICKETS_DIR"

echo "=== Phase 0.1: tk reliability spike ==="
echo ""

# -------------------------------------------------------
# 1. Create 25 tickets across several dependency layers
# -------------------------------------------------------
echo "--- 1. Creating 25 tickets ---"

# Layer 0: no deps (foundations)
T01=$(tk create "Database schema design" -t task -p 0 -a ralph --tags infrastructure)
T02=$(tk create "Auth service API contract" -t task -p 0 -a ralph --tags infrastructure)
T03=$(tk create "CI pipeline setup" -t task -p 1 -a ralph --tags infrastructure)
T04=$(tk create "Logging framework" -t task -p 1 -a ralph --tags infrastructure)
T05=$(tk create "Error handling conventions" -t task -p 2 -a ralph --tags infrastructure)

# Layer 1: depends on layer 0
T06=$(tk create "User table migration" -t task -p 0 -a ralph --tags backend)
T07=$(tk create "Auth token generation" -t task -p 0 -a ralph --tags backend)
T08=$(tk create "Request middleware" -t task -p 1 -a ralph --tags backend)
T09=$(tk create "Config management" -t task -p 1 -a ralph --tags backend)
T10=$(tk create "Test fixtures setup" -t task -p 2 -a ralph --tags testing)

# Layer 2: depends on layer 1
T11=$(tk create "User CRUD endpoints" -t task -p 0 -a ralph --tags backend)
T12=$(tk create "Login endpoint" -t task -p 0 -a ralph --tags backend)
T13=$(tk create "Session management" -t task -p 1 -a ralph --tags backend)
T14=$(tk create "Rate limiting" -t task -p 2 -a ralph --tags backend)
T15=$(tk create "Health check endpoint" -t task -p 2 -a ralph --tags backend)

# Layer 3: depends on layer 2
T16=$(tk create "User profile page" -t task -p 1 -a ralph --tags frontend)
T17=$(tk create "Login page" -t task -p 1 -a ralph --tags frontend)
T18=$(tk create "Admin dashboard" -t task -p 2 -a ralph --tags frontend)
T19=$(tk create "API documentation" -t task -p 2 -a ralph --tags documentation)
T20=$(tk create "Integration tests" -t task -p 1 -a ralph --tags testing)

# Layer 4: depends on layer 3
T21=$(tk create "E2E test suite" -t task -p 1 -a ralph --tags testing)
T22=$(tk create "Performance benchmarks" -t task -p 3 -a ralph --tags testing)
T23=$(tk create "Security audit" -t task -p 0 -a ralph --tags security)
T24=$(tk create "Deployment runbook" -t task -p 2 -a ralph --tags documentation)
T25=$(tk create "Release v1.0" -t task -p 1 -a ralph --tags release)

echo "Created 25 tickets: $T01 .. $T25"

# -------------------------------------------------------
# 2. Wire up dependencies
# -------------------------------------------------------
echo ""
echo "--- 2. Setting up dependencies ---"

# Layer 1 deps
tk dep "$T06" "$T01"  # User table <- DB schema
tk dep "$T07" "$T02"  # Auth token <- Auth API contract
tk dep "$T08" "$T04"  # Middleware <- Logging
tk dep "$T08" "$T05"  # Middleware <- Error handling
tk dep "$T09" "$T04"  # Config <- Logging
tk dep "$T10" "$T01"  # Test fixtures <- DB schema

# Layer 2 deps
tk dep "$T11" "$T06"  # User CRUD <- User table
tk dep "$T11" "$T08"  # User CRUD <- Middleware
tk dep "$T12" "$T07"  # Login endpoint <- Auth token
tk dep "$T12" "$T08"  # Login endpoint <- Middleware
tk dep "$T13" "$T07"  # Session mgmt <- Auth token
tk dep "$T14" "$T08"  # Rate limiting <- Middleware
tk dep "$T15" "$T08"  # Health check <- Middleware

# Layer 3 deps
tk dep "$T16" "$T11"  # Profile page <- User CRUD
tk dep "$T17" "$T12"  # Login page <- Login endpoint
tk dep "$T18" "$T11"  # Admin dashboard <- User CRUD
tk dep "$T18" "$T13"  # Admin dashboard <- Session mgmt
tk dep "$T19" "$T11"  # API docs <- User CRUD
tk dep "$T19" "$T12"  # API docs <- Login endpoint
tk dep "$T20" "$T11"  # Integration tests <- User CRUD
tk dep "$T20" "$T12"  # Integration tests <- Login endpoint
tk dep "$T20" "$T10"  # Integration tests <- Test fixtures

# Layer 4 deps
tk dep "$T21" "$T20"  # E2E <- Integration tests
tk dep "$T21" "$T16"  # E2E <- Profile page
tk dep "$T21" "$T17"  # E2E <- Login page
tk dep "$T22" "$T20"  # Perf benchmarks <- Integration tests
tk dep "$T23" "$T12"  # Security audit <- Login endpoint
tk dep "$T23" "$T13"  # Security audit <- Session mgmt
tk dep "$T24" "$T21"  # Deployment runbook <- E2E
tk dep "$T25" "$T21"  # Release <- E2E
tk dep "$T25" "$T23"  # Release <- Security audit
tk dep "$T25" "$T24"  # Release <- Deployment runbook

echo "Dependencies wired."

# -------------------------------------------------------
# 3. Verify CRUD and dependency behavior
# -------------------------------------------------------
echo ""
echo "--- 3. CRUD & dependency verification ---"

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

# 3a. tk ls should show all 25
COUNT=$(tk ls | wc -l)
assert "tk ls shows 25 tickets" "$([ "$COUNT" -eq 25 ] && echo true || echo false)"

# 3b. tk ready should show only layer-0 tickets (no unmet deps)
READY=$(tk ready -a ralph)
READY_COUNT=$(echo "$READY" | wc -l)
assert "tk ready shows 5 layer-0 tickets" "$([ "$READY_COUNT" -eq 5 ] && echo true || echo false)"

# 3c. Blocked tickets with deps should not appear in ready
assert "T06 (has dep) NOT in ready" "$(echo "$READY" | grep -q "$T06" && echo false || echo true)"
assert "T25 (has dep) NOT in ready" "$(echo "$READY" | grep -q "$T25" && echo false || echo true)"

# 3d. Layer-0 tickets should appear in ready
assert "T01 (no dep) in ready" "$(echo "$READY" | grep -q "$T01" && echo true || echo false)"
assert "T03 (no dep) in ready" "$(echo "$READY" | grep -q "$T03" && echo true || echo false)"

# 3e. Close a layer-0 ticket, verify its dependents become unblocked
tk close "$T01"
tk close "$T02"
READY2=$(tk ready -a ralph)
# T06 depends only on T01 (closed) -> should be ready now
assert "T06 ready after T01 closed" "$(echo "$READY2" | grep -q "$T06" && echo true || echo false)"
# T07 depends only on T02 (closed) -> should be ready now
assert "T07 ready after T02 closed" "$(echo "$READY2" | grep -q "$T07" && echo true || echo false)"
# T11 depends on T06 (open) and T08 (open) -> still blocked
assert "T11 still blocked" "$(echo "$READY2" | grep -q "$T11" && echo false || echo true)"

# 3f. Start a ticket, verify status change
tk start "$T06"
STATUS=$(tk show "$T06" | grep -i "status" | head -1)
assert "T06 status is in_progress" "$(echo "$STATUS" | grep -qi "in_progress" && echo true || echo false)"

# 3g. Close T06, verify downstream
tk close "$T06"
STATUS2=$(tk show "$T06" | grep -i "status" | head -1)
assert "T06 status is closed" "$(echo "$STATUS2" | grep -qi "closed" && echo true || echo false)"

# 3h. Dep tree works
TREE=$(tk dep tree "$T25" 2>&1)
assert "dep tree for T25 produces output" "$([ -n "$TREE" ] && echo true || echo false)"
assert "dep tree mentions T21 (direct dep)" "$(echo "$TREE" | grep -q "$T21" && echo true || echo false)"

# 3i. tk show has expected fields
SHOW=$(tk show "$T03")
assert "show has title" "$(echo "$SHOW" | grep -qi "CI pipeline" && echo true || echo false)"
assert "show has priority" "$(echo "$SHOW" | grep -qi "priority" && echo true || echo false)"
assert "show has assignee" "$(echo "$SHOW" | grep -qi "ralph" && echo true || echo false)"

# 3j. Reopen works
tk reopen "$T01"
STATUS3=$(tk show "$T01" | grep -i "status" | head -1)
assert "T01 reopened" "$(echo "$STATUS3" | grep -qi "open" && echo true || echo false)"

# -------------------------------------------------------
# 4. Output parseability (JSON via tk query)
# -------------------------------------------------------
echo ""
echo "--- 4. Output parseability ---"

# 4a. tk query produces valid NDJSON (one JSON object per line)
QUERY_OUT=$(tk query '.' 2>&1)
FIRST_LINE_VALID=$(echo "$QUERY_OUT" | head -1 | jq -e '.id' >/dev/null 2>&1 && echo true || echo false)
ALL_LINES_VALID=$(echo "$QUERY_OUT" | jq -e '.id' >/dev/null 2>&1 && echo true || echo false)
assert "tk query produces valid NDJSON" "$ALL_LINES_VALID"

# 4b. Can extract IDs from query (NDJSON — jq processes line by line)
QUERY_IDS=$(echo "$QUERY_OUT" | jq -r '.id' 2>/dev/null)
QUERY_ID_COUNT=$(echo "$QUERY_IDS" | wc -l)
assert "query NDJSON has 25 ticket IDs" "$([ "$QUERY_ID_COUNT" -eq 25 ] && echo true || echo false)"

# 4c. Can filter by status via jq (slurp NDJSON into array first)
OPEN_COUNT=$(echo "$QUERY_OUT" | jq -s '[.[] | select(.status == "open")] | length')
assert "query can filter open tickets" "$([ "$OPEN_COUNT" -gt 0 ] && echo true || echo false)"

# 4d. tk ready output is parseable (extract first ID)
READY3=$(tk ready -a ralph)
FIRST_READY_ID=$(echo "$READY3" | head -1 | awk '{print $1}')
assert "ready output first field is ticket ID" "$(tk show "$FIRST_READY_ID" >/dev/null 2>&1 && echo true || echo false)"

# 4e. tk ls is parseable
LS_FIRST=$(tk ls | head -1 | awk '{print $1}')
assert "ls output first field is ticket ID" "$(tk show "$LS_FIRST" >/dev/null 2>&1 && echo true || echo false)"

# -------------------------------------------------------
# 5. Concurrent access test
# -------------------------------------------------------
echo ""
echo "--- 5. Concurrent access (50 iterations) ---"

# Reset: reopen all, so we have a clean pool
for id in $T03 $T04 $T05; do
  tk reopen "$id" 2>/dev/null || true
done

# Track which tickets get started
STARTED_LOG="$SPIKE_DIR/concurrent-starts.log"
> "$STARTED_LOG"

# Run 50 concurrent ready+start pairs
# Each tries to grab and start the first ready ticket
for i in $(seq 1 50); do
  (
    FIRST=$(tk ready -a ralph 2>/dev/null | head -1 | awk '{print $1}')
    if [ -n "$FIRST" ]; then
      tk start "$FIRST" 2>/dev/null && echo "$i:$FIRST" >> "$STARTED_LOG"
    fi
  ) &
done
wait

# Check for double-starts: same ticket started by multiple iterations
echo "  Started entries: $(wc -l < "$STARTED_LOG")"
UNIQUE_TICKETS=$(awk -F: '{print $2}' "$STARTED_LOG" | sort -u | wc -l)
TOTAL_STARTS=$(wc -l < "$STARTED_LOG")

# With file-based storage, race conditions are possible.
# We're testing whether they actually occur in practice.
if [ "$UNIQUE_TICKETS" -eq "$TOTAL_STARTS" ]; then
  echo "  No double-starts detected"
  assert "no double-starts in 50 concurrent runs" "true"
else
  DUPES=$((TOTAL_STARTS - UNIQUE_TICKETS))
  echo "  WARNING: $DUPES double-start(s) detected"
  echo "  Duplicate tickets:"
  awk -F: '{print $2}' "$STARTED_LOG" | sort | uniq -d
  assert "no double-starts in 50 concurrent runs" "false"
fi

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  echo "SPIKE RESULT: ISSUES FOUND — see failures above"
  exit 1
else
  echo "SPIKE RESULT: ALL CHECKS PASSED"
fi
