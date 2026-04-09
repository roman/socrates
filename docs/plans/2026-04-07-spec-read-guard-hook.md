# Plan: PreToolUse Hook — Spec Task Bypass Prevention

> **Status**: approved 2026-04-07, ready to implement.
> **Tracking**: tk task #3 (claude task tool list, this session).
> **Related**: ADR-004 `docs/adrs/004-spec-ticket-namespace-separation.md`.

## Context

ADR-004 documents the spec/ticket namespace split and lists three
defense layers against the bypass bug originally caught by commit
`bdceea8`:

1. **Prose** — RALPH.md "Work source rule (strict)" tells Implementer
   never to read spec task files directly.
2. **Mechanical, after the fact** — `commit-msg.sh` warns when `Refs:`
   doesn't match a real `.tickets/` file.
3. **Mechanical, preventive** — *not yet built*. A `PreToolUse` hook
   that refuses spec task file access during a ralph cycle.

This plan implements layer 3. The bug it defends against: ralph runs
`tk ready -a ralph`, finds insufficient work, goes looking, reads
`docs/specs/<dir>/1-cc1e-synthesis-prompt-caps.md`, treats `<steps>` as
a work order, and commits without ever opening a ticket. Layers 1 and 2
catch this *after* the read happens. Layer 3 catches it *before*.

## Decisions Locked In

A first draft of this plan invented a `.ralph-role` file written at
triage time. Both review agents (code-critic and grug-architect)
independently flagged it as circular: a state file maintained by
convention, defending against failures of convention. Replaced.

- **Signal**: `RALPH_SESSION=1` exported by `ralph.sh` before invoking
  Claude. Env propagates to the hook subprocess. PM, Implementer, and
  Reviewer all run *under* ralph.sh; `/spec`, `/pour`, code-critic,
  and human-driven work all run *outside*. Zero new state, no race
  conditions, no cleanup dance, no trust hole.
- **Tool coverage**: Read, Edit, **and** Write. Blocking only Read
  leaves a hole — a confused Implementer with the path in context
  (from a handoff, a Glob, a previous session) could still Write the
  implementation without ever Reading the file. Cover all three.
- **Block, not warn**: hook exits 2 to deny the call. Safe because the
  blocked tool result just bounces back to Claude, which reverts to
  the prose rule + `tk ready -a ralph`. Cannot wedge the loop.
- **Devenv-only install**: zero non-Nix users today. Devenv module
  owns the hook and the `.claude/settings.json` entry. `/init` gets
  one line of documentation pointing at the template for the rare
  manual case. No jq merge logic.

## Approach

### Hook script

New file `plugins/socrates/templates/spec-read-guard.sh`. Reads JSON
from stdin (per `docs/spikes/0.5-protocol-test-harness/FINDINGS.md`).
Decision tree, top-down:

1. If `RALPH_SESSION` env is unset or empty → exit 0 (allow).
   Not in a ralph cycle; legitimate caller.
2. Extract `tool_input.file_path` from stdin JSON via `jq -r`. If
   empty → exit 0 (defensive; shouldn't happen for Read/Edit/Write
   but don't punish surprises).
3. Match `file_path` against the spec task path pattern:

   ```
   regex: /docs/specs/[^/]+/[0-9]+-[^/]+\.md$
   ```

   Anchored to end-of-path. The `[0-9]+-` prefix distinguishes
   numbered task files from `_overview.md` (PM legitimately reads
   `_overview.md` during the Spec Lifecycle Sweep) and from any
   other file users might place under `docs/specs/`.
4. If no match → exit 0 (allow).
5. Match → write a clear message to stderr:

   ```
   spec-read-guard: blocked <tool_name> on <file>
   Spec task files are blueprints, not work items. Use:
     tk ready -a ralph    # find unblocked tickets
     /pour <spec-name>    # promote approved tasks to tickets
   See ADR-004.
   ```

   Exit 2.

**Error handling explicit**:
- Empty/garbage JSON on stdin → exit 0 (fail open, don't poison
  unrelated tool calls).
- Missing `jq` → exit 0 with a warning to stderr (don't gate the
  loop on a missing dep; jq is already in README's dep list).
- Path with `..` or symlinks → match against the *resolved* path so
  trickery doesn't bypass the regex. Use `readlink -f` if available.

### ralph.sh changes

Update `plugins/socrates/templates/ralph.sh` and `ralph-once.sh` to
export `RALPH_SESSION=1` before invoking Claude. Single line each.
This is the *only* place the env is set; nothing else can fake the
flag without explicitly opting in.

### RALPH.md changes

Add one paragraph to the Implementer "Work source rule (strict)"
section pointing at the hook as the mechanical backstop. Keep the
prose rule — defense in depth, and the prose is what teaches the
reader why the hook exists. No new conventions, no role file.

### Devenv install path

Extend `nix/modules/devenv/socrates.nix` to:

1. Use `pkgs.writeShellScript` (or equivalent) to materialize
   `spec-read-guard.sh` in the Nix store. Capture its absolute path.
2. Contribute to `.claude/settings.json` via:

   ```nix
   files.".claude/settings.json".json = {
     hooks.PreToolUse = [
       {
         matcher = "Read|Edit|Write";
         hooks = [{ type = "command"; command = specReadGuardScript; }];
       }
     ];
   };
   ```

   Pattern from
   `/home/roman/Projects/self/project-status-sync/nix/modules/devenv/session-tracking.nix`.
   Devenv `mkMerge` composes contributions from other modules, so this
   does not clobber unrelated hooks.
3. The hook command is the *Nix store path* of the script, not a
   project-local file. This is what the prior art does and is what
   devenv expects.

### Init install path (one-line documentation)

`plugins/socrates/commands/init.md` gets a single sentence under the
hook section: "Non-devenv users: copy
`templates/spec-read-guard.sh` to `.claude/hooks/` and add a
`PreToolUse` matcher for `Read|Edit|Write` in `.claude/settings.json`
pointing at it." No automation. No jq merge. The cost of building it
is higher than the cost of one user copy-pasting four lines.

### ADR-004 update

Two changes:
1. Replace "not yet implemented" with the script path and a pointer
   to the implementing commit.
2. Add a paragraph honestly stating: hook covers Read/Edit/Write
   under `RALPH_SESSION`. Does not cover Glob/Grep (which only
   surface paths, don't access content) or human-driven sessions
   outside ralph.sh (where the prose rule is the only defense).
   Defense in depth, not perimeter security.

## Files to Create / Modify

| File | Action |
|------|--------|
| `plugins/socrates/templates/spec-read-guard.sh` | **Create** — hook script |
| `plugins/socrates/templates/ralph.sh` | **Modify** — export `RALPH_SESSION=1` |
| `plugins/socrates/templates/ralph-once.sh` | **Modify** — same export |
| `plugins/socrates/templates/RALPH.md` | **Modify** — one paragraph in Work source rule pointing at the hook |
| `nix/modules/devenv/socrates.nix` | **Modify** — write hook to store + contribute to `.claude/settings.json` |
| `plugins/socrates/commands/init.md` | **Modify** — one sentence for non-devenv users |
| `docs/adrs/004-spec-ticket-namespace-separation.md` | **Modify** — update Defense Layers; honest scope statement |

## Reused Patterns / Prior Art

- **Hook script style**: `plugins/socrates/templates/commit-msg.sh`
  (`set -u`, stderr messages, jq parsing). Hook protocol from
  `docs/spikes/0.5-protocol-test-harness/FINDINGS.md` and
  `docs/spikes/0.5-protocol-test-harness/hooks/log-protocol.sh`.
- **Devenv `.claude/settings.json` write**:
  `/home/roman/Projects/self/project-status-sync/nix/modules/devenv/session-tracking.nix`,
  `/home/roman/Projects/self/minerva/nix/modules/devenv/beads.nix`.
- **Env var as ralph-cycle signal**: new pattern, but trivial.

## Verification

1. **Unit test** (`plugins/socrates/templates/spec-read-guard.test.sh`
   or similar): pipe synthetic JSON into `spec-read-guard.sh` and
   assert exit codes for each branch:
   - `RALPH_SESSION` unset, any file → exit 0
   - `RALPH_SESSION=1`, file = `docs/specs/foo/_overview.md` → exit 0
   - `RALPH_SESSION=1`, file = `docs/specs/foo/1-abcd-bar.md` → exit 2
   - `RALPH_SESSION=1`, file = `src/main.rs` → exit 0
   - `RALPH_SESSION=1`, file_path absent in JSON → exit 0
   - `RALPH_SESSION=1`, garbage on stdin → exit 0

2. **End-to-end in this repo (dogfood)**: enter the socrates devenv
   shell, confirm `.claude/settings.json` is a symlink to
   `/nix/store/`, contains the PreToolUse entry pointing at the
   store-path script. Run `RALPH_SESSION=1 claude` interactively and
   attempt a Read on a real numbered spec task file (we have none
   yet, so create a throwaway). Confirm refusal. Run again without
   the env var; confirm allowed.

3. **Confirm Edit and Write are also covered**: same dogfood test,
   but attempt an Edit and a Write. Both should be denied under
   `RALPH_SESSION=1`.

4. **PM cycle smoke test**: `_overview.md` reads must still succeed
   under `RALPH_SESSION=1` since the regex requires `[0-9]+-` prefix.

## Out of Scope

- **Glob/Grep coverage**: those tools surface paths but don't access
  content. ADR-004 update will state this explicitly.
- **Human-driven sessions outside ralph.sh**: prose rule remains the
  only defense there. Same as today.
- **commit-msg.sh devenv migration**: separate change, separate
  commit. Don't bundle unrelated work into this one.
- **Discoverability when neither hook layer is installed**: no
  startup check yet. If this becomes a real issue, add a one-liner
  to `ralph.sh` that warns when the hook is missing. Not now.
