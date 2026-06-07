# soc-7wqf — Migrate existing specs to the unified schema

Migrated all 18 task files and 6 overview files from the old
pour-based schema to the unified task lifecycle schema.

## Changes to task files

For every task file under `docs/specs/` (active and archived):

- **id**: stripped ordinal prefix (`1-abc4-slug` -> `abc4-slug`)
- **status**: `poured` -> `closed` (archived + completed tasks) or
  `approved` (active spec tasks 5-8)
- **deps**: added with identity-token references, derived from:
  - `depends_on:` fields where they existed (overview-navigation-fix)
  - Shared Surfaces `(surface owner)` markers in overview prose
  - Explicit `#### Dependencies` block (unified-task-lifecycle)
- **assignee**: added as `ralph` (all tasks were ralph-assigned)
- **Removed**: `ticket:`, `revisions:`, `depends_on:` fields

## Changes to overview files

Removed `epic:` field from all 6 `_overview.md` files.

## Verification

- `spec status` and `spec ready -a ralph` run clean
- `spec dependents` confirms edge wiring matches overview records
- No `status: poured`, `ticket:`, or `epic:` in any spec file

## Next

- soc-wm99 (rewrite protocols) is now unblocked
- soc-30rr depends on both soc-7wqf (done) and soc-wm99

Refs: soc-7wqf
