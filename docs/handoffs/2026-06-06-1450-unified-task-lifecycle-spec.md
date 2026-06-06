# Unified Task Lifecycle — Spec Designed

Designed a spec to collapse Socrates' spec/ticket namespace split. This
resolves the open thread from `2026-05-20-1758-spec-simplification.md`
("Pour/tk architecture — should Socrates own spec-namespaced tickets
directly?") and the task-ID-format question deferred there.

Spec: `docs/specs/2026-06-06-unified-task-lifecycle/`. All five `/spec`
phases complete, design review council run, comprehension test passed.
Tasks are still `status: draft` — nothing approved or implemented yet.

## The decision

The freeze invariant from ADR-004 was encoded as **filesystem location**
(two directories joined by mandatory `/pour`). Root cause: that encoding
forces two representations of a task, and the form depends on which mode
(RALPH vs INTERACTIVE) last touched it.

Chosen approach (A2): move the freeze from location to a task `status`
field, collapse to one per-spec artifact, put dependency edges in task
frontmatter, extend the in-repo `spec` CLI with a `ready` frontier query,
and **retire `tk` entirely**.

Key finding that shaped Design: `tk` is an opaque external binary
(`wedow/ticket`) that hardcodes `.tickets/`. Forking it would mean owning
an external fork forever. The in-repo `spec` CLI is already status-aware,
tested, and ours — so we extend it and drop `tk`. This supersedes both
ADR-004 and ADR-001.

## Task structure (8, dependency-ordered)

1 ADR → 2 schema → 3 CLI (`ready` + `dependents`) → 4 defenses
(re-aim commit-msg, retire read-guard) → 5 migrate existing specs →
6 rewrite RALPH+INTERACTIVE (merged) → 7 remove pour → 8 retire tk.

## Bootstrap constraint (load-bearing)

This spec's own tasks delete the `/pour`/`tk` machinery an autonomous
loop would use to execute them. **Execute interactively (by file path),
not poured**, and land tasks 1-6 before 7-8. The project's `.tickets/`
is already fully drained (0 open), so no in-flight tk work is at risk —
the constraint is purely this spec's execution order.

## Council outcomes (judgment calls resolved with driver)

- **Retire** the read-guard hook (not re-aim) — `spec ready` + commit-msg
  already cover the bypass.
- **Merge** the RALPH + INTERACTIVE rewrites into one task (avoid drift).
- **Add** a migration task for existing old-schema specs.
- **Keep** `tk` retirement and the `dependents` query in scope.

## Next session

- Review task files at your own pace; flip `draft → approved` when ready.
- When implementing: respect the bootstrap order; this is interactive
  work, do not pour it.
- `pr-review-loop` spec remains complete-but-unpoured (2 draft tasks),
  unrelated to this work.
