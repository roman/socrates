#!/usr/bin/env bash
set -uo pipefail

# Socrates Ralph - Single interactive iteration
# Usage: ./ralph-once.sh

# Signal to spec-read-guard hook that we are inside a ralph cycle.
export RALPH_SESSION=1

echo "=== Ralph Single Iteration ==="

claude "
Read RALPH.md and follow it. Run the Startup Checklist, then triage and
pick the appropriate role (PM, Engineer, etc.) based on current state.

One iteration only: complete the chosen work (or escalate if blocked),
then EXIT. Do not pick up additional work.
"
