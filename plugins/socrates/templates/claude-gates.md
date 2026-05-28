## Socrates Discipline

Socrates is installed in this project. Pick the protocol that matches how
you're working and read it at the start of the session before doing anything
else:

- **Autonomous loop** (`ralph.sh` / `ralph-once.sh` driving): read
  `RALPH.md`.
- **Human in the chat driving**: read `INTERACTIVE.md`.

Both protocols inherit the spec discipline below.

Before commits on non-trivial changes: spawn the `code-critic` agent
(foreground, opus model) and address findings in at most 2 rounds.

All other discipline (role triage, phase sequence, handoff/ADR rules,
`.msgs/` inbox, interactive deltas) lives in those protocol files. Do not
duplicate it here.

### Spec discipline (mode-agnostic)

Specs in this project carry a directive hierarchy:

- The overview's **Describe** section names the user-facing pain (the
  durable why).
- The overview's **Diagnose** section names the mechanism (RC/NC/AC).
- A task file's **Outcome** describes a slice of work, not the why.
  Task-ordering language ("prerequisite for X", "must land before Y") is
  sequencing, not why — do not anchor planning, code comments, or PR
  descriptions on it.

Before planning or implementing on a task, reconstruct the why from the
overview's Describe + Diagnose. If the why isn't reconstructible from
those sections, ask before proceeding.
