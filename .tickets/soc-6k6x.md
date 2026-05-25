---
id: soc-6k6x
status: closed
deps: [soc-rc5m]
links: []
created: 2026-05-25T00:43:14Z
type: task
priority: 1
assignee: ralph
parent: soc-ooy8
tags: [functional]
---
# Stamp review_mode default in spec _overview.md template

Spec overview: docs/specs/2026-04-29-pr-review-loop/_overview.md
Spec task:     docs/specs/2026-04-29-pr-review-loop/2-e75b-init-stamp-review-mode.md

## Outcomes

The spec `_overview.md` template at
`plugins/socrates/templates/_overview.md` carries `review_mode:
false` in its frontmatter so that every newly created spec — both
through the `/spec` discoverability hook (which may overwrite the
value based on the operator's answer) and through any path that
copies the template directly — starts with the field present and
defaulted off. A one-line comment beside the field names what it
controls and points the reader to RALPH.md for the full semantics.

This task is the one-line "defense in depth" companion to task 1's
`/spec` hook: even if the hook is skipped, refactored, or bypassed,
the template carries the field with a safe default, and the
RALPH.md resolver established by task 1 treats the absence of the
field as `false` anyway.

## Verification

- `plugins/socrates/templates/_overview.md` frontmatter contains
  `review_mode: false`.
- A one-line comment near the field names what it controls and
  links to RALPH.md for the full semantics.
- Creating a new spec via `/spec` produces an `_overview.md` whose
  frontmatter carries `review_mode` (its value set by the
  `/spec` hook from task 1; the template default is the fallback).
- Existing specs that predate this change keep working: they have
  no `review_mode` field, and the RALPH.md resolver from task 1
  treats the absence as `false`, preserving today's behaviour for
  every existing spec.

