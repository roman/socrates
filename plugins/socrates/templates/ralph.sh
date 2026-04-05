#!/usr/bin/env bash
set -uo pipefail

# Socrates Ralph - Autonomous coding loop
# Usage: ./ralph.sh [max_iterations] [--verbose|-v]

MAX_ITERATIONS=100
VERBOSE_FLAG=""

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

while [ $iteration -lt $MAX_ITERATIONS ]; do
  # Graceful exit
  if [ -f ".ralph-stop" ]; then
    echo "Stop file detected. Exiting gracefully."
    rm -f ".ralph-stop"
    exit 0
  fi

  echo ""
  echo "=== Iteration $((iteration + 1)) ==="
  echo "---"

  available=$(tk ready -a ralph 2>/dev/null | wc -l)

  if [ "$available" -eq 0 ]; then
    echo "No ready work available. Done."
    exit 0
  fi

  echo "$available ready task(s) available"
  echo ""

  claude --dangerously-skip-permissions --output-format stream-json --verbose -p "
Run \`tk ready -a ralph\` to see available tasks.

Also run \`tk query '.' | jq -s '[.[] | select(.status == \"in_progress\" and .assignee == \"ralph\")]'\` to see what tasks other Ralph agents are currently working on.

Decide which task to work on next. Selection criteria:
1. Priority - lower number = higher priority
2. Avoid conflicts - if other Ralph agents have tasks in_progress, pick a different area of work. Do NOT work on any task that shares dependencies with an in-progress task.
3. If all high-priority areas are being worked on, pick a lower-priority unrelated task

Pick ONE task, claim it with \`tk start <id>\`, then execute it according to its description.

One iteration = complete the task fully.

IMPORTANT: After the task is done (or if blocked), EXIT immediately. Do NOT pick up another task. The outer loop handles the next iteration.
" 2>&1 | "$(dirname "$0")/ralph-format.sh" $VERBOSE_FLAG || true

  ((iteration++)) || true
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)"
