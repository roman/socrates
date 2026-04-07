#!/usr/bin/env bash
# Socrates commit-msg hook — warns (does not block) on missing or invalid Refs.
#
# Rules:
#   1. Commit message body should contain a `Refs: <ticket-id>` line.
#   2. <ticket-id> must correspond to a file `.tickets/<ticket-id>.md`.
#
# Spec task ids (e.g. cc1e-synthesis-prompt-caps) are NOT valid refs — they
# are blueprint identifiers from /spec, not work items. Use the tk ticket id
# produced by /pour instead.

set -u
msg_file="$1"
[ -f "$msg_file" ] || exit 0

ref=$(grep -E '^Refs:[[:space:]]+' "$msg_file" | head -1 | sed -E 's/^Refs:[[:space:]]+//; s/[[:space:]]+$//')

if [ -z "$ref" ]; then
  echo "warning: commit message has no 'Refs: <ticket-id>' line" >&2
  exit 0
fi

# Check that the ref points to an actual tk ticket file. We don't hardcode a
# prefix — any file under .tickets/<ref>.md counts.
if [ ! -f ".tickets/${ref}.md" ]; then
  echo "warning: Refs: ${ref} does not match any file in .tickets/" >&2
  echo "  spec task ids (e.g. cc1e-synthesis-prompt-caps) are not valid refs" >&2
  echo "  run /pour to create tk tickets from approved spec tasks" >&2
fi

exit 0
