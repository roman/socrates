# 91eb — Task-entry command for interactive task work

Created `/socrates-task` slash command and removed `INTERACTIVE.md`.

## What Was Done

### Created plugins/socrates/commands/socrates-task.md
- Frontmatter description names it as the entry point for interactive
  task work
- Spec discipline kernel inlined with duplication note pointing to
  `/spec` (commands/spec.md)
- Interactive session protocol inlined: defaults table (pause-and-ask,
  user-paced, in-conversation gates, failure-category naming,
  no-mandatory-handoff), phase sequence deltas, plan mode, invariants
- Task resolution logic: searches `docs/specs/` by `id:` frontmatter
  or filename, surfaces resolution failures explicitly
- On invocation: reads task Outcomes/Verification + overview
  Describe/Diagnose/Direction, reconstructs directive hierarchy
- Draft task warning: advisory, user can override
- Approved task contract: frozen, reopen-to-draft flow documented

### Removed
- `plugins/socrates/templates/INTERACTIVE.md` — content now lives
  inline in `/socrates-task`

### Not changed
- `plugins/socrates/commands/init.md` still references
  `INTERACTIVE.md` in four places. T4 removes `/socrates-init`
  entirely, so this is expected dead code.

## Verification
- `socrates-task.md` exists with correct frontmatter description
- Command body inlines kernel + interactive protocol + task context
  loading
- Draft warning is advisory with user override
- Resolution failure surfaces explicitly (no silent proceed)
- `INTERACTIVE.md` is absent from the plugin tree
- Grep for `INTERACTIVE.md` in `plugins/socrates/` returns only
  `init.md` (dead code, removed by T4)

## What's Next
- T4 (e82d-trim-socrates-init) depends on T2+T3 and is now unblocked
- T5 (23fa-migrate-this-project) depends on all

Refs: 91eb-task-entry-command
