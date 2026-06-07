# ADR-006: Unified Task Lifecycle

**Date**: 2026-06-07
**Status**: Accepted
**Supersedes**: ADR-004 (Spec and Ticket Namespaces Stay Separate),
ADR-001 (tk over Beads as Task Backend)

## Context

Socrates encodes a task's lifecycle across two namespaces joined by a
mandatory `/pour` step. Design-phase tasks live as files under
`docs/specs/<spec>/<id>.md`; work-phase tasks live as files under
`.tickets/<id>.md`. The `/pour` command is the one-way gate between them:
it compiles coupling prose into dependency edges, freezes the spec files
write-once, and writes the `epic:` completion anchor.

ADR-004 established this split and its load-bearing invariant: after
`/pour`, there is exactly one mutable source of truth per task. The
invariant is sound. Its encoding as filesystem location is the root cause
of the problems that follow.

### What changed since ADR-004

The INTERACTIVE protocol was added, legitimizing human-driven work
directly against spec task files. An author moving between interactive
and autonomous (RALPH) modes now maintains two representations of the
same task, and a task's form depends on which mode last touched it.
Three root causes drive this:

1. **The freeze invariant is encoded as filesystem location, not state
   (RC1).** Two directories joined by `/pour` mean every mode must agree
   on *where* a task lives. Moving between RALPH and INTERACTIVE exposes
   the seam: a task's representation depends on which mode last acted.

2. **Dependency edges live in prose, so promotion must compile them
   (RC2).** Coupling is authored as prose in the `Shared Surfaces`
   subsection of `_overview.md`. `/pour` parses it into a graph once.
   Any design that removes `/pour` without relocating the edges leaves
   frontier discovery undefined.

3. **Identity is overloaded with position and name (RC3).** The task id
   `ordinal-hex-slug` fuses sequence position, stable handle, and human
   label. Two of the three are mutable during design. Edges and `Refs:`
   that key on the composite go stale on reorder or rename.

### The `tk` finding

`tk` is an opaque external dependency (`wedow/ticket`, a bash binary
wrapped through Nix) that hardcodes `.tickets/` as its store. There is
no directory indirection. Forking it to read task status and edges from
`docs/specs/` would mean owning a fork of an external tool forever. The
in-repo `spec` CLI already exists, is tested, parses task frontmatter,
and is ours to extend. This makes `tk` retirement feasible and desirable
once the `spec` CLI gains a frontier query.

## Decision

Collapse the spec/ticket namespace split into a single task artifact per
spec. The changes:

1. **Freeze as status, not location.** A `status` field on the task
   artifact encodes the freeze transition (`draft → approved → closed`,
   plus `cancelled`). The `draft → approved` transition is the freeze
   point: after it, a task's contract fields (Outcome, Verification,
   dependency edges) are write-once until explicitly reopened to `draft`.
   Both RALPH and INTERACTIVE read the same field, so the freeze
   survives mode switches.

2. **Dependency edges in frontmatter.** Edges move from prose in
   `_overview.md` into a structured `deps` field in each task's YAML
   frontmatter. They are parsed once (at authoring time, not at query
   time), eliminating the fragile live-parse option and the need for a
   compile step.

3. **Identity decoupled from position and name.** The task id retains a
   stable opaque token. The ordinal and slug become cosmetic — renaming
   or reordering a task does not invalidate edges or `Refs:` citations.

4. **`spec` CLI as the frontier tool.** The in-repo `spec` CLI is
   extended with `ready` (compute the unblocked frontier for an
   assignee) and `dependents` (list tasks downstream of a given task).
   This replaces `tk ready -a ralph` as the work source for the
   autonomous loop.

5. **Mechanical defenses re-aimed at status.** The `commit-msg.sh` hook
   re-aims from `.tickets/` file existence to task status (warn if the
   referenced task is not `approved`). The `spec-read-guard.sh`
   PreToolUse hook is retired: the `spec ready` status filter only
   surfaces approved tasks, and the commit-msg hook catches commits
   against non-approved tasks, making a third defense layer redundant.

6. **Spec completion re-homed.** The `epic:` field written by `/pour`
   (used by the PM Spec Lifecycle Sweep) is replaced by a spec-scoped
   query: a spec is complete when all its tasks are `closed`.

7. **`/pour` removed.** With the freeze in status, edges in frontmatter,
   and the frontier query in the `spec` CLI, the `/pour` command has no
   remaining purpose. It is removed and its authoring concerns are
   reconciled into `/spec` and `/init`.

8. **`tk` retired via drain-then-retire.** The project's `.tickets/`
   directory is already fully drained (zero open tickets). `tk` is
   removed cleanly — the Nix derivation, the `.tickets/` directory, and
   all references — rather than migrated. This supersedes ADR-001's
   choice of `tk` as the task backend.

### How the freeze invariant survives

ADR-004's invariant — one mutable source of truth per task per lifecycle
phase — is preserved. What changes is its encoding:

| Aspect | ADR-004 (old) | ADR-006 (new) |
| --- | --- | --- |
| Freeze signal | File moved from `docs/specs/` to `.tickets/` | `status` field transitions from `draft` to `approved` |
| Mutable source | `.tickets/<id>.md` | The same `docs/specs/<spec>/<id>.md` file, gated by status |
| Bypass defense (after the fact) | `commit-msg.sh` checks `.tickets/` for `Refs:` id | `commit-msg.sh` checks task `status` for `Refs:` id |
| Bypass defense (prevention) | `spec-read-guard.sh` blocks reads under `RALPH_SESSION` | `spec ready` only surfaces `approved` tasks; guard retired |
| Completion anchor | `epic:` field in `_overview.md`, written by `/pour` | Spec-scoped query: all tasks `closed` |

The invariant is stronger in the new model: reopening an `approved` task
to `draft` to mutate its contract flags affected dependents (via
`spec dependents`), which the directory-move model could not express.

## Consequences

**Gained:**
- One task artifact across both modes. No representation drift.
- No `/pour` ceremony for interactive work. Authors implement directly
  against the task file once it is `approved`.
- Dependency edges have a schema, not prose. Frontier computation is
  deterministic and does not depend on a fragile parser.
- `spec ready` replaces `tk ready` with a tool the project owns and
  controls.
- Reopen-to-draft is an explicit, auditable action that flags
  dependents, closing a gap the old model silently ignored.

**Lost:**
- The simplicity of ADR-004's "two directories = two states" model.
  Status requires the frontier tool and hooks to read frontmatter.
- Large migration blast radius: hooks, protocols, CLI, existing specs,
  and `/pour` all change.
- `tk`'s proven dependency graph commands (`tk dep`, `tk ready`,
  `tk blocked`) are replaced by new code in the `spec` CLI.

**Accepted tradeoff:** The blast radius is concentrated in implementation
effort, not ongoing risk. The invariant that ADR-004 protected is
preserved with a more expressive encoding. The migration is a one-time
cost; the namespace split it removes is a recurring one.
