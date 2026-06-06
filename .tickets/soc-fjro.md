---
id: soc-fjro
status: open
deps: []
links: []
created: 2026-06-06T22:36:51Z
type: task
priority: 0
assignee: ralph
parent: soc-bjda
tags: [documentation]
---
# Record the unified-lifecycle decision

Spec overview: docs/specs/2026-06-06-unified-task-lifecycle/_overview.md
Spec task:     docs/specs/2026-06-06-unified-task-lifecycle/1-2e23-record-lifecycle-decision.md

## Outcome

- A new ADR records the decision to collapse the spec/ticket namespace
  split: one task artifact per spec, freeze encoded as a `status` field,
  dependency edges in task frontmatter, and the in-repo `spec` CLI as the
  frontier tool.
- The ADR supersedes ADR-004 (namespaces stay separate) and ADR-001
  (tk over beads), with both marked superseded and pointing forward to
  the new record.
- The ADR states how the freeze invariant survives the collapse: it
  moves from filesystem location to the `draft -> approved` status
  transition, and the mechanical bypass defense re-aims from path/id
  shape to task status.
- The ADR records the drain-then-retire decision for tk: in-flight
  `.tickets/` work finishes under the old system; tk is removed once the
  directory is empty, not migrated.

## Verification

- A new file under `docs/adrs/` carries the decision, a status of
  Accepted, and a date.
- ADR-004 and ADR-001 each show a Superseded status and a link to the
  new ADR.
- The new ADR names the freeze invariant and explains the status-based
  encoding that preserves it.
- A reader who knows only ADR-004 can read the new ADR and understand
  why the namespace split was removed without losing the invariant it
  protected.

