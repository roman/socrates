#!/usr/bin/env bash
# Socrates spec-read-guard — PreToolUse hook (Read/Edit/Write).
#
# Blocks access to numbered spec task files (docs/specs/<dir>/<n>-*.md)
# during a ralph cycle, identified by RALPH_SESSION=1 in the env. Outside
# a ralph cycle, the hook is a no-op. See ADR-004.

set -u

# Not in a ralph cycle: allow.
[ -n "${RALPH_SESSION:-}" ] || exit 0

# jq is a hard dep of socrates but we fail open rather than gating the
# loop on it being missing.
if ! command -v jq >/dev/null 2>&1; then
  echo "spec-read-guard: jq not found, skipping check" >&2
  exit 0
fi

input=$(cat)
[ -n "$input" ] || exit 0

file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
tool_name=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)
[ -n "$file_path" ] || exit 0

# Resolve to defeat ../ and symlink trickery. readlink -f returns empty
# for nonexistent paths (e.g. Write of a new file) — fall back to the
# original path in that case.
resolved=$(readlink -f "$file_path" 2>/dev/null || true)
[ -n "$resolved" ] || resolved="$file_path"

if printf '%s' "$resolved" | grep -Eq '/docs/specs/[^/]+/[0-9]+-[^/]+\.md$'; then
  cat >&2 <<EOF
spec-read-guard: blocked ${tool_name:-tool} on ${file_path}
Spec task files are blueprints, not work items. Use:
  tk ready -a ralph    # find unblocked tickets
  /pour <spec-name>    # promote approved tasks to tickets
See ADR-004.
EOF
  exit 2
fi

exit 0
