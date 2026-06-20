---
id: 91eb-task-entry-command
status: approved
priority: 1
category: functional
assignee:
deps: [85ae-spec-discipline-via-spec-preamble]
---

# Task-entry command for interactive task work

## Outcomes

- A new slash command `/socrates-task` lives at
  `plugins/socrates/commands/socrates-task.md` and is the explicit
  entry point for human-driven task work. It takes a task identity
  as argument (the `<hash>-<suffix>` value in a task file's `id:`
  frontmatter, accepting common aliases like the full filename).
- The command body inlines the same spec discipline kernel content
  that T2 put into `/spec`. A comment in the body flags the
  duplication so future kernel edits update both commands.
- The command body also inlines the interactive session protocol
  (the content currently in `INTERACTIVE.md`): pause-and-ask
  defaults, user-paced cadence, in-conversation approval gates, the
  failure-category-naming rule, and the no-mandatory-handoff rule.
- On invocation with a valid task argument, the command body
  instructs Claude to read the named task's Outcomes and
  Verification and the spec's overview Describe + Diagnose before
  proposing actions.
- `plugins/socrates/templates/INTERACTIVE.md` is removed once the
  command is in place. The plugin no longer ships the protocol as a
  separate file.

## Verification

- `plugins/socrates/commands/socrates-task.md` exists with a
  frontmatter description that names the command as the entry
  point for interactive task work.
- Invoking `/socrates-task <task-id>` on an approved task in a
  fresh session causes Claude to read the kernel, the interactive
  protocol, and the task's Outcomes and Verification before
  proposing actions.
- Invoking `/socrates-task <task-id>` on a draft task causes Claude
  to warn that the task's contract is not frozen and to ask before
  starting implementation; the warning is advisory and the operator
  can direct Claude to proceed.
- Invoking `/socrates-task <task-id>` on an id that does not
  resolve to a file under `docs/specs/` causes Claude to surface
  the resolution failure rather than silently proceeding.
- `plugins/socrates/templates/INTERACTIVE.md` is absent from the
  plugin tree.
- A repo-wide grep for `INTERACTIVE.md` returns no live references
  inside `plugins/socrates/`; matches inside `docs/specs/archive/`
  are acceptable historical context.

<review></review>
