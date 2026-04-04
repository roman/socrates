# Spike 0.1 — tk Reliability Findings

**Date**: 2026-04-04
**Result**: 22/23 assertions passed

## What Works

- **CRUD**: create, start, close, reopen, show — all correct
- **Dependencies**: `tk dep` wires correctly, `tk ready` excludes blocked
  tickets, closing a dep unblocks downstream, `tk dep tree` traverses the
  full graph
- **Filtering**: `tk ready -a ralph` filters by assignee, `tk ls` lists all
- **Output parseability**: `tk query` emits NDJSON (one JSON object per
  line), not a JSON array. Each line has `id`, `status`, `deps`, `tags`,
  `assignee`, `priority` — all fields ralph.sh needs. Use `jq -s` to slurp
  into array for filtering.
- **`tk ready` / `tk ls` output**: table format, first column is ticket ID,
  parseable with `awk '{print $1}'`

## What Doesn't Work

### Concurrent access: no locking (expected)

50 parallel `tk ready | head -1 | tk start` produced 49 double-starts on
the same ticket. `tk start` writes to a markdown file without file locking
— all 50 processes read "open", all 50 write "in_progress".

**Impact on ralph.sh**: Low. Ralph runs as a single sequential loop — one
`tk ready` → one `tk start` → work → `tk close`. No concurrent access in
normal operation. The race only matters if multiple ralph instances run
simultaneously on the same `.tickets/` directory.

**Mitigation if needed**: `flock` wrapper in ralph.sh around the
ready+start sequence. Not needed for Phase 1 — single ralph instance is
the design.

## Key Format Details for ralph.sh

- `tk ready -a ralph` → table, first column is ID: `soc-xxxx [P0][open] - Title`
- `tk query '.'` → NDJSON, one `{"id":"soc-xxxx","status":"open",...}` per line
- `tk show <id>` → human-readable markdown dump
- IDs are `soc-xxxx` format (prefix from directory name + 4-char hash)
