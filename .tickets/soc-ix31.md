---
id: soc-ix31
status: open
deps: [soc-30rr]
links: []
created: 2026-06-06T22:53:01Z
type: task
priority: 4
assignee: ralph
parent: soc-bjda
tags: [infrastructure]
---
# Retire the tk dependency

Spec overview: docs/specs/2026-06-06-unified-task-lifecycle/_overview.md
Spec task:     docs/specs/2026-06-06-unified-task-lifecycle/8-1109-retire-tk-dependency.md

## Outcome

- The tk (wedow/ticket) Nix package and its wiring are removed from the
  flake. The project's `.tickets/` directory is already fully drained
  (zero open tickets), so this is a removal, not a migration; the task
  verifies zero open at execution rather than waiting for a drain.
- No protocol surface, command, hook, or installed script invokes `tk`
  after removal; the in-repo `spec` CLI is the only task-state tool.
- The project's own `.tickets/` directory is reconciled: closed tickets
  are preserved in history, and the directory is removed from the
  working setup.
- This project's CLAUDE.md and any contributor documentation stop
  pointing at `tk ready -a ralph` as the work-source command and point
  at `spec ready` instead.

## Verification

- The flake no longer builds or references the tk package, and a fresh
  dev shell does not provide `tk`.
- A search across the plugin and project docs for `tk ` returns no
  operative command references.
- `.tickets/` is confirmed to contain zero open tickets at the point of
  removal.
- CLAUDE.md directs contributors to `spec ready` for finding work.

