#!/usr/bin/env bash
set -uo pipefail

# Socrates Ralph - Single interactive iteration
# Usage: ./ralph-once.sh

# Signal to spec-read-guard hook that we are inside a ralph cycle.
export RALPH_SESSION=1

echo "=== Ralph Single Iteration ==="

available=$(tk ready -a ralph 2>/dev/null | wc -l)

if [ "$available" -eq 0 ]; then
  echo "No ready work available."
  exit 0
fi

echo "$available ready task(s) available"
echo ""

claude "
Run \`tk ready -a ralph\` to see available tasks.

Decide which task to work on next. Pick the highest priority one.

Pick ONE task, claim it with \`tk start <id>\`, then execute it according to its description.

After the task is done (or if blocked), EXIT. This is a single iteration.
"
