# spec CLI — Spec Inspection Tool

A lightweight CLI for querying spec and task files under `docs/specs/`.
The `spec` CLI is read-only and re-derives state from the filesystem on
every call.

## Commands

### `spec status [<spec-name>]`

Lists each task file in the spec with its `status:` frontmatter value
(`draft`, `approved`, `closed`, `cancelled`). When `<spec-name>` is omitted,
lists all specs under `docs/specs/` with summary counts.

---

### `spec review [<spec-name>]`

Prints the file path and `<review>` body for each task that has feedback
waiting. Exits 0 with no output when there is nothing to review.

---

### `spec ready [-a <assignee>]`

Shows the unblocked frontier: tasks whose status is `approved`, whose
`deps` are all `closed`, and (if `-a` is given) whose `assignee` matches.
This is the work-source command for both the Ralph loop and interactive
sessions.

---

### `spec dependents <task-id>`

Lists tasks that depend on the given task ID. Useful when reopening a
task to `draft` — dependents should be re-checked.

---

### `spec overview <spec-name>`

Prints a compact summary of phase completion (which phases are
`[COMPLETE]`/`[APPROVED]` vs `[DRAFT]`) and task counts by status.

---

## Notes

- All commands operate on `docs/specs/` relative to the current git root.
- `<spec-name>` matches any `docs/specs/*-<spec-name>/` directory
  (date-prefix is ignored for lookup).
- The CLI is strictly read-only — it does not mutate any files.
