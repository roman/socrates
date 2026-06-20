---
id: 23fa-migrate-this-project
status: approved
priority: 1
category: infrastructure
assignee: ralph
deps: [46c0-extract-nix-only-artifacts, 85ae-spec-discipline-via-spec-preamble, 91eb-task-entry-command, e82d-trim-socrates-init]
---

# Migrate this project to the new plugin shape

## Outcomes

- Files that this project carried because the old `/socrates-init`
  copied them are gone from the working tree: `INTERACTIVE.md` is
  deleted; any non-Nix-managed `ralph.sh`, `ralph-once.sh`,
  `ralph-format.sh`, `RALPH.md`, or `.git/hooks/commit-msg` copies
  are deleted. Files that this project consumes through Nix
  symlinks into `/nix/store/` stay (the devenv module manages them
  at the new Nix-only path from T1).
- This project's `CLAUDE.md` no longer contains the spec discipline
  gates block that referenced `INTERACTIVE.md` or `claude-gates.md`.
  Any text that pointed operators at project-local protocol files
  is replaced with text pointing at `/spec` and `/socrates-task` as
  the entry commands.
- This project's `docs/customization.md` (which references
  `templates/handoff.md` as a customization target) is updated so
  its path matches the new Nix-only home for handoff content.

## Verification

- `INTERACTIVE.md` is absent from this project's root.
- This project's `CLAUDE.md` contains no references to
  `INTERACTIVE.md` or `claude-gates.md`.
- Invoking `/socrates-task` on a task in a fresh session on this
  project loads the discipline kernel, the interactive protocol,
  and the task context observable in Claude's first response.
- Invoking `/spec` on this spec in a fresh session loads the
  discipline kernel observable in Claude's first response.
- A Ralph run on this project still works using the devenv-managed
  Ralph artifacts at their new Nix path.

<review></review>
