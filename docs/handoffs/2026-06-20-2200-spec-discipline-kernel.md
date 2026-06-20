# 85ae — Spec discipline kernel delivered via /spec preamble

Inlined the spec discipline kernel (directive hierarchy + code-critic
gate) into the `/spec` command body and removed `claude-gates.md`.

## What Was Done

### Added to plugins/socrates/commands/spec.md
- New "Spec discipline kernel" section as preamble, before "Support
  files". Contains the directive hierarchy rule (Describe/Diagnose
  carry the durable why; task Outcome is a slice; task-ordering
  language is sequencing) and the code-critic-before-commit gate.
- Duplication note comment flagging that T3's task-entry command
  should inline the same content.

### Removed
- `plugins/socrates/templates/claude-gates.md` — kernel content now
  lives in `/spec`'s body; mode-fork content is obsolete.

### Rewired references
- `plugins/socrates/commands/spec-support/phases/design.md` —
  Comprehension Test materials list now points to the "Spec
  discipline kernel" section of `/spec` instead of
  `claude-gates.md`.

### Not changed
- `plugins/socrates/commands/init.md` still references
  `claude-gates.md` in a `cat` command. T4 removes `/socrates-init`
  entirely, so this is expected dead code.

## Verification
- `claude-gates.md` is absent from the plugin tree
- Grep for `claude-gates.md` in `plugins/socrates/` returns only
  `init.md` (dead code, removed by T4)
- Kernel content is present in `/spec` preamble

## What's Next
- T3 (91eb-task-entry-command) depends on T2 and is now unblocked
- T4 (e82d-trim-socrates-init) depends on T2+T3
- T5 (23fa-migrate-this-project) depends on all

Refs: 85ae-spec-discipline-via-spec-preamble
