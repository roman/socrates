# Task Review Mode

When invoked with a task file path (`/spec docs/specs/<name>/<id>.md`):

1. Read the task file
2. Check the `<review>` section for feedback
3. If `<review>` is empty: ask the user what changes they want
4. If `<review>` has content: process the feedback

## Processing Review Feedback

1. Read the review comments in `<review>`
2. Regenerate only the sections the feedback addresses — `## Outcomes`,
   `## Verification`, or both; leave the others unchanged
3. Clear the `<review>` section (set back to empty)
4. Present the changes to the user for confirmation
5. Write the updated task file

The task stays at `status: draft` throughout review iterations. The user manually changes
status to `approved` when satisfied.

## Batch Review

If invoked with a spec directory (`/spec docs/specs/<name>/`), check all task files for
non-empty `<review>` sections and process them sequentially.

## Status Summary

When invoked with `--status` or when the user asks for an overview:

1. Scan `docs/specs/` for all spec directories
2. For each spec, read `_overview.md` and report:
   - Current phase (first `[DRAFT]` section)
   - Whether Delimit is approved
3. For each spec, scan task files and report counts:
   - `draft` — still iterating
   - `approved` — frozen, ready for work
   - `closed` — work complete
4. Present as a summary table:

```
Spec: auth-redesign
  Phase: Direction [COMPLETE] → Design [DRAFT]
  Delimit: approved
  Tasks: 3 draft, 2 approved, 0 closed
```
