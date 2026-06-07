---
id: soc-gfdy
status: closed
deps: []
links: []
created: 2026-06-06T22:37:11Z
type: task
priority: 0
assignee: ralph
parent: soc-bjda
tags: [infrastructure]
---
# Define the unified task artifact schema

Spec overview: docs/specs/2026-06-06-unified-task-lifecycle/_overview.md
Spec task:     docs/specs/2026-06-06-unified-task-lifecycle/2-b01a-define-task-schema.md

## Outcome

- The task template defines the single-artifact schema that serves both
  interactive and autonomous modes: a stable opaque identity token, a
  cosmetic human slug that can change without breaking references, a
  `status` field whose `draft -> approved -> closed` transition encodes
  the freeze, and an `assignee` field the frontier query filters on.
- Dependency edges live in task frontmatter with a schema a parser can
  read directly, replacing the prose-derived `Shared Surfaces` edges
  that `/pour` used to compile.
- The `status` enum drops `poured`; the lifecycle is
  `draft -> approved -> closed` plus `cancelled`. `approved` is the
  freeze point after which contract fields (Outcomes, Verification,
  edges) are write-once until the task is explicitly reopened to
  `draft`.
- The spec format documentation (`docs/spec-format.md`) is updated by
  this task to describe the schema, the freeze semantics, the
  reopen-to-mutate path, and how identity stays stable across slug
  rewrites and task reordering. (Task 7 later edits the same file to
  remove `/pour` references; this task owns the schema content.)

## Verification

- The task template frontmatter carries the identity token, slug,
  `status`, `assignee`, and dependency-edge fields, with the `status`
  enum showing `draft | approved | closed | cancelled` and no `poured`.
- The spec format doc explains that editing an `approved` task's
  contract requires reopening it to `draft`, and that reopening flags
  affected dependents.
- The documented identity scheme is position-independent: a reader can
  confirm that reordering tasks or renaming a slug does not change a
  task's id.
- A task authored from the template can express a dependency on another
  task purely through frontmatter, with no entry in the overview's
  prose required for the edge to be machine-readable.

