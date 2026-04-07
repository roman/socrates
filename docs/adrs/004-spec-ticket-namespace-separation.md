# ADR-004: Spec and Ticket Namespaces Stay Separate

**Date**: 2026-04-07
**Status**: Accepted

## Context

Specs live as files under `docs/specs/<name>/<id>.md`. Tickets live as files
under `.tickets/<id>.md`. Both are markdown with frontmatter, and the spec
task file's `<steps>`/`<test_steps>` content is the same content that ends up
in the ticket body after `/pour`. They look like the same kind of artifact.

A recurring instinct is to collapse them: have `/spec` create `tk` tickets
directly (perhaps with a `triage` tag for "not ready"), and skip `/pour`
entirely. The argument is that ticket files are also editable text, so the
extra hop looks like ceremony.

A previous ralph iteration exposed why the hop exists. Ralph ran
`tk ready -a ralph`, found insufficient work, went looking, read a spec task
file directly, implemented it, and committed with `Refs: cc1e-synthesis-prompt-caps`
— a *spec task id*, not a ticket id. No ticket ever existed for that work.
The bug was caught and fixed in commit `bdceea8` ("guard against un-poured
spec task implementation"), with reinforcement in `b7ac7ff`.

The fix is layered:

1. **RALPH.md "Work source rule (strict)"** — prose rule in the Implementer
   role saying the only valid work source is `tk ready -a ralph`, and that
   spec task files are blueprints, not tickets.
2. **`commit-msg.sh` hook** — parses `Refs:` from the commit body and warns
   if the id does not match a real file under `.tickets/`. Warn rather than
   block, so an autonomous loop cannot be wedged by the hook itself.

Both layers depend on the same structural fact: **spec task ids and ticket
ids live in different namespaces with different shapes**. Spec task ids look
like `1-cc1e-synthesis-prompt-caps` (ordinal + 4-hex + kebab). Ticket ids
look like `nw-7a2d` (tk prefix + 4 chars). The hook can tell them apart
mechanically; the prose rule has a referent ("don't read from
`docs/specs/`") only because the directories are distinct.

## Decision

Specs and tickets stay in separate namespaces and separate directories.
`/pour` is the only one-way gate that promotes a spec task into a ticket,
and it is mandatory — there is no path from "approved spec task" to
"implemented work" that bypasses it.

The freeze invariant is the load-bearing piece: after `/pour` writes
`status: poured` and `ticket: <id>` into a spec file, that file is a
write-once artifact. All mutable state lives in `.tickets/`. There is
exactly one source of truth per task at any point in its lifecycle.

## Consequences

**Gained:**
- Safe iteration zone: you can rewrite a spec task's `<steps>` twenty times
  without polluting `tk ready` or risking ralph picking up half-baked work.
- Mechanical bypass detection: the commit-msg hook can distinguish spec ids
  from ticket ids structurally, so a bypass commit is caught at commit time.
- Spec lifecycle archival has something to key off (`epic:` field in
  `_overview.md`, written by `/pour`).
- Cross-run idempotency: `/pour` can be run multiple times against the same
  spec as more tasks reach `approved`, and the cross-run id map handles
  dependencies between batches.

**Lost:**
- An extra command in the workflow (`/pour`) and an extra status transition
  (`approved` → `poured`).
- Two file formats to understand instead of one.
- Edit friction during the ticket phase: `tk` has no good in-place body
  editor (`tk edit` is interactive, `tk add-note` writes notes not body),
  so substantial edits to a poured ticket are awkward. This is real but
  fixable with tooling and is not the load-bearing concern.

**Accepted tradeoff:** The friction of one extra command pays for a
mechanically-enforceable invariant. Without the namespace split, both the
prose rule and the commit-msg hook lose their teeth — the rule has no
referent and the hook cannot tell spec ids from ticket ids. We have already
paid for one bypass bug; the guardrails work because the two namespaces
stayed separate.

## Defense Layers (current and future)

- **Current — prose**: RALPH.md Implementer role "Work source rule (strict)"
- **Current — mechanical (after the fact)**: `commit-msg.sh` warns on
  unknown `Refs:` ids
- **Future — mechanical (prevention)**: a `PreToolUse` hook on `Read` that
  refuses paths matching `docs/specs/*/[0-9]*-*.md` when the active role is
  Implementer. This would catch the bypass *before* the commit, not after.
  Tracked as a follow-up; not yet implemented.

## Alternatives Considered

**Triage tag on tickets created directly by `/spec`.** Half-solves the
visibility problem (`tk ready` could filter out `triage`), breaks
everything else: edit friction during iteration is worse not better,
namespace collapse retires both defense layers, and there is no longer an
epic-id binding for the PM Spec Lifecycle Sweep to detect completion
against. Cheap to add a tag, expensive to lose four other things.

**Hard-block (not warn) in the commit-msg hook.** Rejected because
hard-blocking commits in an autonomous loop can wedge ralph in a way that
is worse than the original bug. A warning that surfaces in commit output
and audit passes is the right level of teeth for this defense layer.
