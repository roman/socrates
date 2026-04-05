#!/usr/bin/env bash
# Fixture: blocked-deps
# State: all ready tasks have unmet dependencies (deps are open, not closed).
# Expect: PM escalation — no work to pick up, should surface the blocker.
set -euo pipefail

REPO=$(mktemp -d)
cd "$REPO"

git init -q
git commit --allow-empty -m "chore: initialize repository" -q

mkdir -p docs/{handoffs,adrs} .tickets

cat > RALPH.md <<'PROTO'
# RALPH Protocol
## Startup
1. Read RALPH.md
2. Check .msgs/
3. Read 3 recent handoffs
4. Run triage
PROTO

cat > docs/handoffs/2026-04-02-0900-api-design.md <<'HO'
# Handoff: API Design Session

**Date**: 2026-04-02 09:00

## What Was Done
Designed API endpoints. Waiting on external dependency (payment provider SDK).

## What's Next
Cannot proceed until payment SDK is available. PM should escalate.

## Learnings
External dependencies should be identified during spec, not during implementation.
HO

# Create tickets where everything is blocked
# Blocker: external dep, not closeable by ralph
T1=$(TICKETS_DIR="$REPO/.tickets" tk create "Integrate payment SDK" -t task -p 0 -a human --tags external)
# These depend on T1
T2=$(TICKETS_DIR="$REPO/.tickets" tk create "Payment endpoint" -t task -p 0 -a ralph --tags backend)
T3=$(TICKETS_DIR="$REPO/.tickets" tk create "Checkout flow" -t task -p 1 -a ralph --tags backend)
T4=$(TICKETS_DIR="$REPO/.tickets" tk create "Payment tests" -t task -p 1 -a ralph --tags testing)

TICKETS_DIR="$REPO/.tickets" tk dep "$T2" "$T1" >&2
TICKETS_DIR="$REPO/.tickets" tk dep "$T3" "$T1" >&2
TICKETS_DIR="$REPO/.tickets" tk dep "$T4" "$T2" >&2

git add -A
git commit -m "feat: pour payment tasks (blocked on external SDK)" -q

echo "$REPO"
