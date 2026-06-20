---
id: 85ae-spec-discipline-via-spec-preamble
status: approved
priority: 1
category: functional
assignee: ralph
deps: []
---

# Spec discipline kernel delivered via /spec preamble

## Outcomes

- The `/spec` command body carries the spec discipline kernel inline
  as preamble. The kernel content is:
  - the directive hierarchy rule (Describe and Diagnose carry the
    durable why; a task file's Outcome is a slice; task-ordering
    language is sequencing, not why);
  - the code-critic-before-commit gate for non-trivial changes;
  - any other mode-agnostic guidance from `claude-gates.md`'s
    "Spec discipline" section.
- The mode-fork content from `claude-gates.md` (the "read RALPH.md
  if autonomous, read INTERACTIVE.md if interactive" selector) is
  not in the kernel. The fork is obsolete after the split because
  each entry point loads its own protocol directly: `ralph.sh`
  bootstraps RALPH.md; the task-entry command from T3 bootstraps
  the interactive protocol.
- `plugins/socrates/templates/claude-gates.md` is removed once the
  kernel content has been moved into `/spec`'s body. The plugin no
  longer ships the gates file.
- References to `claude-gates.md` inside
  `plugins/socrates/commands/spec-support/phases/design.md` (the
  Comprehension Test materials list) are rewired to name `/spec`
  itself as the kernel source.
- The kernel content is the source of truth for what T3's
  task-entry command also inlines. A comment in `/spec`'s body
  flags the duplication so future edits update both commands.

## Verification

- Invoking `/spec` in a fresh session causes Claude to load the
  discipline kernel; this is observable by asking Claude to
  summarize the directive hierarchy after `/spec` runs but before
  phase work starts, and getting an answer grounded in the three
  bullets named above.
- In a fresh session that opens a file under `docs/specs/` *without*
  first invoking `/spec`, Claude cannot summarize the directive
  hierarchy from prior context. This is the denial test that
  confirms the gate only fires through the explicit-invocation
  vector.
- `plugins/socrates/templates/claude-gates.md` is absent from the
  plugin tree.
- A repo-wide grep for `claude-gates.md` returns no live references
  inside `plugins/socrates/`; matches inside `docs/specs/archive/`
  are acceptable historical context.

<review></review>
