---
id: a93b-rewrite-protocols
status: approved
priority: 2
category: documentation
assignee: ralph
deps: [1ea5-extend-cli-frontier-queries, de92-reaim-defenses-to-status]
---

# Rewrite protocols for the unified lifecycle

## Outcomes

- RALPH.md and INTERACTIVE.md are rewritten together for the unified
  lifecycle, keeping their existing symmetry. Both protocol files move
  in one pass so they cannot drift apart.
- In RALPH.md, the Implementer work-source rule names `spec ready -a
  ralph` as the source of work and drops the "spec task files are
  blueprints, not tickets" framing. Approved tasks in the spec directory
  are the work items; the rule distinguishes `approved` from `draft`
  rather than spec directory from `.tickets/`. The `Refs:` guidance
  points at the task identity token, not a tk ticket id from `/pour`.
- The Spec Lifecycle Sweep detects completion through a spec-scoped
  query ("all tasks closed") instead of reading an `epic:` field and
  running `tk show`. Archival keys off task status.
- The Reviewer role records review feedback in the task's `<review>`
  block instead of writing comments to a tk ticket.
- INTERACTIVE.md describes working an approved task directly from the
  spec directory as the normal path, with no `/pour` step. It explains
  the freeze in interactive terms: approving a task freezes its
  contract, and reopening it to `draft` is the signal that downstream
  dependents should be re-checked (via `spec dependents`).
- Both files reflect the retirement of the spec-read-guard hook decided
  in the defenses task, so neither describes a guard that no longer
  exists.
- No surface in either protocol file references `/pour`, `.tickets/`,
  `tk`, or the `epic:` field.

## Verification

- A reader following RALPH.md as an Implementer is directed to
  `spec ready -a ralph` and works approved tasks directly from the spec
  directory; the Spec Lifecycle Sweep determines completion from task
  status with no `tk show` or `epic:` lookup; the Reviewer section
  directs feedback into the `<review>` block.
- A reader following INTERACTIVE.md works approved tasks from the spec
  directory without invoking `/pour`, and the protocol states how
  reopening an approved task flags affected dependents.
- Neither protocol file describes the spec-read-guard as an active
  mechanism.
- A search of both files for `pour`, `.tickets`, `tk `, and `epic:`
  returns no operative references.

<review></review>
