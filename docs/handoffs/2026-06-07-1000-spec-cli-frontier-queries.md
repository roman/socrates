# soc-hrj1 — spec CLI frontier and dependent queries

Extended the in-repo `spec` CLI with two new subcommands:

## Changes

### `plugins/socrates/templates/spec`
- Added `fm_list` helper to parse YAML bracket-list frontmatter values
  (e.g. `deps: [a, b, c]`).
- Added `all_task_files` helper that collects all task files across
  non-archived specs (any `.md` except `_overview.md`).
- Added `dep_matches` helper for flexible dep-to-task-id matching
  (handles full id, token-only, ordinal-prefixed forms).
- **`spec ready -a ASSIGNEE`**: computes the unblocked frontier via
  Kahn's algorithm. Filters by `status: approved`, assignee match, and
  all deps `closed`. Reports dependency cycles with the involved task
  ids.
- **`spec dependents ID`**: lists tasks whose `deps` frontmatter
  references the given task id.
- Updated usage text.

### `plugins/socrates/templates/spec.test.sh`
- Added fixture spec `frontier-spec` with 6 tasks exercising: approved
  unblocked, blocked by open dep, wrong assignee, draft status, dep on
  closed task, and the closed task itself.
- Tests: frontier filtering, dep-close unblocking, assignee isolation,
  topological order, dependents query, cycle detection (2-node cycle).
- All 63 tests pass.

## Next

- soc-06lq (re-aim defenses to task status) is the other P1 ready task.
- soc-7wqf and soc-wm99 are now unblocked by this task's completion.

Refs: soc-hrj1
