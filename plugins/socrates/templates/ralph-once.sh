#!/usr/bin/env bash
set -uo pipefail

# Socrates Ralph - Single autonomous iteration
# Usage: ./ralph-once.sh [--verbose|-v]

VERBOSE_FLAG=""

for arg in "$@"; do
  case "$arg" in
  --verbose | -v)
    VERBOSE_FLAG="--verbose"
    ;;
  esac
done

# Signal to spec-read-guard hook that we are inside a ralph cycle.
export RALPH_SESSION=1

echo "=== Ralph Single Iteration ==="

claude --dangerously-skip-permissions --output-format stream-json --verbose -p "
Read RALPH.md and follow it. Run the Startup Checklist, then triage and
pick the appropriate role (PM, Engineer, etc.) based on current state.

One iteration only: complete the chosen work (or escalate if blocked),
then EXIT. Do not pick up additional work.
" 2>&1 | "$(dirname "$0")/ralph-format.sh" $VERBOSE_FLAG || true
