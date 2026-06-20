#!/usr/bin/env bash
# Socrates commit-msg hook — warns (does not block) on missing or invalid Refs.
#
# Rules:
#   1. Commit message body should contain a `Refs: <task-id>` line.
#   2. <task-id> must match a task in docs/specs/ whose status is approved
#      or beyond (closed, cancelled). A ref to a draft task is flagged.
#
# The hook scans non-archived spec directories for task files and matches
# the ref against the task's frontmatter `id` field. Matching is flexible:
# full id, token-only, or ordinal-prefixed forms all resolve.

set -u
msg_file="$1"
[ -f "$msg_file" ] || exit 0

SPECS_DIR="${SPECS_DIR:-docs/specs}"

ref=$(grep -E '^Refs:[[:space:]]+' "$msg_file" | head -1 | sed -E 's/^Refs:[[:space:]]+//; s/[[:space:]]+$//')

if [ -z "$ref" ]; then
  echo "warning: commit message has no 'Refs: <task-id>' line" >&2
  exit 0
fi

# Extract a YAML frontmatter value by key from a file.
fm_value() {
  local file="$1" key="$2"
  local fence=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^---[[:space:]]*$ ]]; then
      fence=$((fence + 1))
      if [[ "$fence" -ge 2 ]]; then return; fi
      continue
    fi
    if [[ "$fence" -eq 1 ]]; then
      case "$line" in
        "${key}:"*)
          local val="${line#"${key}:"}"
          val="${val#"${val%%[![:space:]]*}"}"
          echo "$val"
          return
          ;;
      esac
    fi
  done < "$file"
}

# Match a ref against a task id (flexible: full id, token-only, ordinal-prefixed).
ref_matches() {
  local ref="$1" task_id="$2"
  [[ "$ref" == "$task_id" ]] && return 0
  # Extract token (part after optional ordinal prefix)
  local task_token
  if [[ "$task_id" =~ ^[0-9]+-(.+)$ ]]; then
    task_token="${BASH_REMATCH[1]}"
  else
    task_token="$task_id"
  fi
  local ref_token
  if [[ "$ref" =~ ^[0-9]+-(.+)$ ]]; then
    ref_token="${BASH_REMATCH[1]}"
  else
    ref_token="$ref"
  fi
  [[ "$ref_token" == "$task_token" ]] && return 0
  [[ "$ref" == "$task_token" ]] && return 0
  [[ "$ref_token" == "$task_id" ]] && return 0
  return 1
}

# Scan all non-archived spec task files for a matching id.
found=0
matched_status=""
for spec_dir in "$SPECS_DIR"/*/; do
  [ -d "$spec_dir" ] || continue
  dirname="${spec_dir%/}"
  dirname="${dirname##*/}"
  [ "$dirname" = "archive" ] && continue

  for task_file in "$spec_dir"*.md; do
    [ -f "$task_file" ] || continue
    base="${task_file##*/}"
    [ "$base" = "_overview.md" ] && continue

    tid=$(fm_value "$task_file" "id")
    [ -z "$tid" ] && continue

    if ref_matches "$ref" "$tid"; then
      found=1
      matched_status=$(fm_value "$task_file" "status")
      break 2
    fi
  done
done

if [ "$found" -eq 0 ]; then
  echo "warning: Refs: ${ref} does not match any task in ${SPECS_DIR}/" >&2
  echo "  run 'spec tasks' to list known task ids" >&2
  exit 0
fi

# Warn if the task is still in draft — its contract is not yet frozen.
if [ "$matched_status" = "draft" ]; then
  echo "warning: Refs: ${ref} points to a draft task (contract not frozen)" >&2
  echo "  approve the task before committing against it: status: approved" >&2
  echo "  run 'spec ready -a <assignee>' to see the unblocked frontier" >&2
fi

exit 0
