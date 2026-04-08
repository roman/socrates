#!/usr/bin/env bash
# Tests for spec-read-guard.sh
set -u

HOOK="$(dirname "$0")/spec-read-guard.sh"
fail=0

run() {
  local desc="$1" expected="$2" env_set="$3" stdin="$4"
  local got
  if [ "$env_set" = "1" ]; then
    got=$(printf '%s' "$stdin" | RALPH_SESSION=1 bash "$HOOK" 2>/dev/null; echo $?)
  else
    got=$(printf '%s' "$stdin" | env -u RALPH_SESSION bash "$HOOK" 2>/dev/null; echo $?)
  fi
  got=${got##*$'\n'}
  if [ "$got" = "$expected" ]; then
    echo "ok   - $desc"
  else
    echo "FAIL - $desc (expected $expected, got $got)"
    fail=1
  fi
}

json() { printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2"; }

run "RALPH_SESSION unset, spec task file" 0 0 "$(json Read /tmp/docs/specs/foo/1-abcd-bar.md)"
run "RALPH_SESSION=1, _overview.md allowed" 0 1 "$(json Read /tmp/docs/specs/foo/_overview.md)"
run "RALPH_SESSION=1, numbered spec task blocked (Read)" 2 1 "$(json Read /tmp/docs/specs/foo/1-abcd-bar.md)"
run "RALPH_SESSION=1, numbered spec task blocked (Edit)" 2 1 "$(json Edit /tmp/docs/specs/foo/2-deef-baz.md)"
run "RALPH_SESSION=1, numbered spec task blocked (Write)" 2 1 "$(json Write /tmp/docs/specs/foo/3-cafe-qux.md)"
run "RALPH_SESSION=1, unrelated source file" 0 1 "$(json Read /tmp/src/main.rs)"
run "RALPH_SESSION=1, missing file_path" 0 1 '{"tool_name":"Read","tool_input":{}}'
run "RALPH_SESSION=1, garbage stdin" 0 1 "not json at all"
run "RALPH_SESSION=1, empty stdin" 0 1 ""

exit $fail
