# e82d — Trim /socrates-init for the marketplace path

Removed `/socrates-init` and made `/spec` self-bootstrapping.

## What Was Done

### Removed
- `plugins/socrates/commands/init.md` — the `/socrates-init` slash
  command no longer ships with the plugin.

### Updated /spec (plugins/socrates/commands/spec.md)
- Added "Auto-create spec directory" section at the top of Step 1,
  before any spec discovery. Runs `mkdir -p docs/specs` so a fresh
  project needs no pre-step.

### Cleaned up live documentation
- `README.md` — removed `/socrates:init` install step, replaced with
  "run `/spec` to start"; removed `jq` and `gh` from prerequisites
  (Ralph-only).
- `docs/commands.md` — removed the `/init` command section; updated
  shell scripts intro to say "Nix-only" instead of "installed by
  `/init`".
- `docs/workflow.md` — removed install-path note referencing `/init`.
- `docs/customization.md` — removed `/init` reference in Nix
  integration section.
- `nix/modules/devenv/socrates.nix` — updated option description to
  remove stale `/init` reference.

### Not changed
- Handoffs, specs, and archived docs that reference `/init`
  historically are left as-is (archival record).

## Verification
- `init.md` absent from plugin tree
- No live code/docs reference `/socrates-init` or `/init` as a
  command
- `/spec` includes `mkdir -p docs/specs` before discovery
- Plugin installs no files into the project tree

## What's Next
- T5 (23fa-migrate-this-project) depends on all prior tasks and is
  now unblocked

Refs: e82d-trim-socrates-init
