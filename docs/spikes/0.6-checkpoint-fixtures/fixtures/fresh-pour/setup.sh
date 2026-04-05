#!/usr/bin/env bash
# Fixture: fresh-pour
# State: tickets exist (poured from spec), none started.
# Expect: Implementer triage — pick a ready task and start working.
set -euo pipefail

REPO=$(mktemp -d)
cd "$REPO"

git init -q
git commit --allow-empty -m "chore: initialize repository" -q

# Simulate project structure
mkdir -p docs/{handoffs,adrs,specs/auth-system} .tickets

# RALPH.md protocol file
cat > RALPH.md <<'PROTO'
# RALPH Protocol
## Startup
1. Read RALPH.md
2. Check .msgs/
3. Read 3 recent handoffs
4. Run triage
PROTO

# A recent handoff
cat > docs/handoffs/2026-04-01-1400-auth-spec-complete.md <<'HO'
# Handoff: Auth Spec Complete

**Date**: 2026-04-01 14:00

## What Was Done
Completed /spec for auth system. 4 tasks generated and poured.

## What's Next
Implementer should pick up ready tasks.

## Learnings
Spec journey worked well for breaking down auth requirements.
HO

# Spec overview (frozen after pour)
cat > docs/specs/auth-system/_overview.md <<'SPEC'
---
title: Auth System
created: 2026-04-01
delimit_approved: true
---

## Describe [COMPLETE]
Users need to authenticate to access the app.

## Diagnose [COMPLETE]
No auth system exists. Users cannot log in.

## Delimit [APPROVED]
Users cannot access protected resources because no authentication
mechanism exists.

## Direction [COMPLETE]
### Chosen Approach
JWT-based auth with refresh tokens.

## Design [COMPLETE]
### Tasks
4 tasks generated. See individual task files.
SPEC

# Create 4 tickets with dependencies
# Layer 0
T1=$(TICKETS_DIR="$REPO/.tickets" tk create "Database user table" -t task -p 0 -a ralph --tags backend)
T2=$(TICKETS_DIR="$REPO/.tickets" tk create "JWT token service" -t task -p 0 -a ralph --tags backend)
# Layer 1 (depends on layer 0)
T3=$(TICKETS_DIR="$REPO/.tickets" tk create "Login endpoint" -t task -p 1 -a ralph --tags backend)
T4=$(TICKETS_DIR="$REPO/.tickets" tk create "Auth middleware" -t task -p 1 -a ralph --tags backend)

TICKETS_DIR="$REPO/.tickets" tk dep "$T3" "$T1" >&2
TICKETS_DIR="$REPO/.tickets" tk dep "$T3" "$T2" >&2
TICKETS_DIR="$REPO/.tickets" tk dep "$T4" "$T2" >&2

# Commit everything
git add -A
git commit -m "feat: pour auth system tasks" -q
git commit --allow-empty -m "Refs: Phase 5" -q

echo "$REPO"
