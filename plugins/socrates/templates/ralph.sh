#!/usr/bin/env bash
set -uo pipefail

# Socrates Ralph - Autonomous coding loop
# Usage: ./ralph.sh [max_iterations] [--verbose|-v]

MAX_ITERATIONS=100
VERBOSE_FLAG=""
RALPH_MODEL="${RALPH_MODEL:-opus}"

# Signal to spec-read-guard hook that we are inside a ralph cycle.
export RALPH_SESSION=1

for arg in "$@"; do
  case "$arg" in
  --verbose | -v)
    VERBOSE_FLAG="--verbose"
    ;;
  [0-9]*)
    MAX_ITERATIONS="$arg"
    ;;
  esac
done
iteration=0

echo "Starting Ralph loop (max $MAX_ITERATIONS iterations)"

while [ "$iteration" -lt "$MAX_ITERATIONS" ]; do
  # Graceful exit
  if [ -f ".ralph-stop" ]; then
    echo "Stop file detected. Exiting gracefully."
    rm -f ".ralph-stop"
    exit 0
  fi

  echo ""
  echo "=== Iteration $((iteration + 1)) ==="
  echo "---"

  claude --model "$RALPH_MODEL" --dangerously-skip-permissions --output-format stream-json --verbose -p "
Read RALPH.md and follow it. Run the Startup Checklist, then triage and
pick the appropriate role (PM, Engineer, etc.) based on current state.

If you pick Engineer, also check for conflicts with other in-progress
Ralph agents before claiming a task:
  tk query '.' | jq -s '[.[] | select(.status == \"in_progress\" and .assignee == \"ralph\")]'
Avoid tasks that share dependencies with anything already in_progress.

One iteration = complete the chosen work fully (or escalate if blocked).

IMPORTANT: After the work is done, EXIT immediately. Do NOT pick up
another task. The outer loop handles the next iteration. If triage
concludes there is genuinely nothing to do, create \`.ralph-stop\` before
exiting so the loop terminates.
" 2>&1 | "$(dirname "$0")/ralph-format.sh" $VERBOSE_FLAG || true

  ((iteration++)) || true
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)"
