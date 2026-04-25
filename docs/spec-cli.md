# spec CLI — Spec Inspection and Manipulation

A lightweight CLI for querying and manipulating spec and task files under
`docs/specs/`. Intended as a companion to `tk` — where `tk` owns ticket
state, `spec` owns spec file state.

## Commands

### `spec status [<spec-name>]`

**As a human driver**, I want to see all task statuses across a spec at a
glance, **so that** I know which tasks are ready to approve, still in review,
or already poured without opening each file manually.

Lists each task file in the spec with its `status:` frontmatter value
(`draft`, `approved`, `poured`, `cancelled`). When `<spec-name>` is omitted,
lists all specs under `docs/specs/` with summary counts.

---

### `spec review [<spec-name>]`

**As a human driver or agent**, I want to list every task file with non-empty
`<review>` content, **so that** I can process feedback in batch without
scanning every file to find which ones need attention.

Prints the file path and `<review>` body for each task that has feedback
waiting. Exits 0 with no output when there is nothing to review.

---

### `spec edges <spec-name>`

**As `/socrates-pour` or an agent**, I want to derive the dependency graph
from `#### Shared Surfaces` without running Python inline, **so that** ticket
ordering and `tk dep` wiring can be computed reliably and tested independently
of the pour flow.

Parses `_overview.md`'s Shared Surfaces section, identifies `(surface owner)`
markers, emits edges as `<consumer> depends_on <owner>` pairs, and prints the
topological order. Exits non-zero on cycles or dangling task references.

---

### `spec epic <spec-name> [<tk-id>]`

**As `/socrates-pour`**, I want to read or write the `epic:` field in
`_overview.md` as a single command, **so that** the pour script doesn't need
to manipulate YAML frontmatter inline and the epic assignment is idempotent
across runs.

With no `<tk-id>`: prints the current `epic:` value (empty string if unset).
With `<tk-id>`: writes it into the frontmatter and exits 0 (no-op if already
set to the same value).

---

### `spec overview <spec-name>`

**As a human driver resuming a session**, I want a compact summary of phase
completion (which phases are `[COMPLETE]`/`[APPROVED]` vs `[DRAFT]`) and task
counts by status, **so that** I can orient quickly without reading the full
`_overview.md`.

Prints the phase progression, `delimit_approved` flag, and a task count table
(`draft / approved / poured / cancelled`).

---

## Notes

- All commands operate on `docs/specs/` relative to the current git root.
- `<spec-name>` matches any `docs/specs/*-<spec-name>/` directory
  (date-prefix is ignored for lookup, like `/socrates-spec`).
- The CLI is a read/write tool for spec files only — it does not call `tk`.
  Ticket creation and dependency wiring remain in `/socrates-pour`.
