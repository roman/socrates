# 1109 — Retire the tk dependency

Removed the tk (wedow/ticket) Nix package, `.tickets/` directory, and all
operative `tk` references from the project. The `spec` CLI is now the sole
task-state tool.

## What Was Done

### Removed
- `nix/packages/ticket/default.nix` — the tk Nix derivation
- `.tickets/` — 25 ticket files (3 closed at removal, 22 already closed)
- `docs/gaps/protocol-prose-traversal-rewrites.md` — obsolete gap subsumed
  by the unified-task-lifecycle spec

### Edited (tk package references)
- `nix/modules/devenv/socrates.nix` — removed `ticket` from packages list
- `nix/modules/nixos/sandbox-vm.nix` — removed `ticket` from system packages

### Edited (operative tk command references)
- `CLAUDE.md` — rewrote Source of Truth and Session Discipline to use
  `spec ready` instead of `tk ready -a ralph`; removed `.tickets/` and
  pour references
- `README.md` — rewrote workflow, prerequisites, and status sections
- `docs/commands.md` — rewrote /init, removed /pour section, updated
  /harvest and ralph.sh descriptions
- `docs/workflow.md` — rewrote from 4-phase (Spec/Pour/Ralph/Harvest) to
  3-phase (Spec/Ralph/Harvest); removed all pour and tk references
- `docs/spec-cli.md` — rewrote as standalone doc; removed tk companion
  framing, added `ready` and `dependents` commands
- `RATIONALE.md` — updated goals, tradeoffs, and conventions to reflect
  task-file-based workflow
- `plugins/socrates/commands/harvest.md` — removed "Create tk ticket"
  option from gap processing
- `plugins/socrates/commands/init.md` — removed `tk init` reference
- `plugins/socrates/templates/handoff.md` — changed `tk IDs` to `task IDs`
- `plugins/socrates/templates/ralph.sh` — replaced `tk query` with spec
  CLI equivalent
- `plugins/socrates/templates/spec.test.sh` — removed `tk` patterns from
  read-only check

### Not changed (historical/archival)
- `docs/plans/` — historical planning docs, kept as-is
- `docs/spikes/` — historical spike fixtures, kept as-is

## What's Next

All 8 tasks in the unified-task-lifecycle spec are now closed. The PM
sweep should archive the spec on its next cycle.

## Learnings

The `.tickets/` directory had 3 stale `open` tickets that were tk-side
shadows of spec tasks already completed. This confirms the dual-namespace
drift that motivated the spec.

Refs: 1109-retire-tk-dependency
