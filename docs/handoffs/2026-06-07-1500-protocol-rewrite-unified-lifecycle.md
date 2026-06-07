# soc-wm99 — Rewrite protocols for the unified lifecycle

Rewrote both RALPH.md and INTERACTIVE.md templates to use the unified
task lifecycle. The old two-namespace model (specs + .tickets/) is fully
replaced by the single-artifact, status-based model.

## Changes

### RALPH.md

- **Work source rule**: `spec ready -a ralph` replaces `tk ready -a ralph`.
  Approved tasks in the spec directory are the work items. Draft tasks are
  not eligible. Tasks tagged `awaiting-review` are explicitly excluded.
- **Spec Lifecycle Sweep**: reads every task file's `status` field directly.
  Completion = all tasks `closed` or `cancelled`. No `epic:` field or
  `tk show` call.
- **Reviewer role**: directs feedback into the task's `<review>` block
  instead of tk ticket comments.
- **Refs guidance**: identity token from task frontmatter, not tk ticket id.
- **Review Mode**: all references updated from "ticket" to "task" — task
  mutation, external-ref, tags, notes, and the self-evident view example.
- **Removed**: all references to `/pour`, `.tickets/`, `tk`, `epic:`,
  `spec-read-guard`, and the "spec task files are blueprints" framing.

### INTERACTIVE.md

- **Work source**: user names a task file under `docs/specs/<dir>/<task>.md`.
- **Freeze contract**: explains that `approved` freezes the contract and
  reopening to `draft` flags dependents via `spec dependents <id>`.
- **Review workflow**: added `<review>` block reference for iterative
  refinement.
- **Refs guidance**: identity token from task frontmatter.
- **Removed**: all references to `/pour`, `.tickets/`, `tk`, `epic:`,
  and `spec-read-guard`.

## Code-critic findings addressed

- Added explicit exclusion of `awaiting-review` tasks from implementer
  pickup in RALPH.md work-source rule.
- Added `<review>` block mention to INTERACTIVE.md for task refinement.

## Next

- soc-30rr (remove pour and reconcile spec and init authoring) is now
  unblocked by this task's completion.

Refs: a93b-rewrite-protocols
