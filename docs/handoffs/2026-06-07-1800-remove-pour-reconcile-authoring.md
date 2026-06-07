# 4919 — Remove pour and reconcile spec and init authoring

Removed the `/pour` command and reconciled all authoring surfaces for the
unified task lifecycle.

## Changes

### Deleted
- `plugins/socrates/commands/pour.md` — the entire `/pour` command file

### Edited (pour/epic/poured removal)
- `plugins/socrates/commands/spec.md` — removed `epic:` line from overview
  frontmatter guidance
- `plugins/socrates/commands/spec-support/phases/design.md` — removed
  `/pour` from post-design summary options
- `plugins/socrates/commands/spec-support/patterns/task-review-mode.md` —
  replaced `poured` status with `closed` in status summary example
- `plugins/socrates/commands/init.md` — removed tk CLI check, `tk init`
  step, `.tickets/` directory, and `/pour` from next-steps guidance
- `plugins/socrates/templates/_overview.md` — removed `epic:` field
- `docs/spec-format.md` — removed `Shared Surfaces` subsection (the old
  prose-based edge authoring with `(surface owner)` markers); deps now
  live exclusively in task frontmatter

### Edited (spec CLI)
- `plugins/socrates/templates/spec` — replaced `poured` with `closed` in
  status counting; replaced `TICKET` column with `ASSIGNEE` in tasks output
- `plugins/socrates/templates/spec.test.sh` — updated all fixtures to use
  the unified schema (`assignee`, `deps`, no `ticket`/`revisions`/`epic`);
  updated assertions for `closed` vocabulary and `ASSIGNEE` column. All 63
  tests pass.

## Verification
- Zero grep matches for `/pour`, `epic:`, `.tickets/`, `poured`, or
  `Shared Surfaces` across the entire plugin directory
- `spec status` output uses `draft / approved / closed` vocabulary
- All spec CLI tests pass

## Next
- 8-1109 (retire tk dependency) is now unblocked

Refs: 4919-remove-pour-reconcile-authoring
