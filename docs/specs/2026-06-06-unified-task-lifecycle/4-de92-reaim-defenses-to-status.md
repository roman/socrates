---
id: 4-de92-reaim-defenses-to-status
status: draft
priority: 1
category: infrastructure
ticket: null
---

# Re-aim mechanical defenses to task status

## Outcomes

- The commit-msg hook stops keying on `.tickets/<ref>.md` file existence
  and instead validates that a commit's `Refs:` names a real task whose
  `status` is `approved` (or beyond), so a commit referencing a `draft`
  task is flagged. It keeps warning rather than blocking, so an
  autonomous loop cannot be wedged by the hook.
- The spec-read-guard hook is retired. In the unified model an approved
  task is a legitimate work item, so blocking reads by path shape is
  wrong, and the remaining defense is covered by two other layers:
  `spec ready` only surfaces `approved` tasks, and the commit-msg hook
  catches a commit that refs a non-approved task. A third PreToolUse
  layer parsing frontmatter on every read would overlap both. The hook
  file and its installation in `/init` are removed.
- The remaining hook's message references the unified lifecycle and the
  `spec` CLI, with no mention of `/pour` or `.tickets/`.
- The defense covers the failure the directory split used to catch:
  committing against a task whose contract is not yet frozen.

## Verification

- A commit whose `Refs:` names a `draft` task produces a warning; a
  commit referencing an `approved` task does not. (Negative test: the
  draft-ref case is exercised and confirmed to warn.)
- The spec-read-guard hook file no longer exists and `/init` no longer
  installs it; a `RALPH_SESSION=1` session can read an approved task
  file without denial.
- The commit-msg hook's output references neither `/pour` nor
  `.tickets/`.

<review></review>
