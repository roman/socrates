# Handoff — 2026-04-07 17:18 — Spec Read Guard Hook (planned)

## What was done this session

Process-cleanup pass driven by user-flagged friction with `/pour` and
`/spec`. Three commits landed:

- `9b037b1` **chore: cut accidental complexity from process** — deleted
  WORKPLAN.md (fossilized), docs/protocol.md and docs/architecture.md
  (duplicated other docs), spec-journey and ralph-guide skills (each was
  a third copy of content already in commands/spec.md and
  templates/RALPH.md). Rewrote CLAUDE.md to point at `tk ready -a ralph`
  instead of WORKPLAN, dropped the never-pulled bootstrap ratchet
  checklist, softened ADR/handoff rules to "only when commit body isn't
  enough." Collapsed claude-gates.md to a 9-line pointer at RALPH.md.
  Trimmed RALPH.md spec lifecycle sweep to drop the speculative
  `git mv` archival and "10 most recent" pruning.
- `e74c936` **refactor: slim pour.md from 162 to 80 lines** — pour.md
  was mostly documenting which bash to write. Compressed to load-bearing
  behaviors only: epic create-or-reuse + writeback, topo-ordered
  creation seeded with the cross-run spec-task-id map, the
  heredoc-on-create trap, freeze writeback. Code-critic pass caught a
  weakened cross-run dep behavior; fixed.
- `5aec213` **docs: add task sizing rule to /spec decomposition** —
  recovered the one piece of unique content from the deleted
  spec-journey skill ("one task ≈ one focused commit").

Then user asked about defending against the bypass bug from `bdceea8`
(ralph reading spec task files directly). Wrote ADR-004 capturing the
namespace-separation decision and the three-layer defense model:

- `3f58275` **docs: ADR-004 spec/ticket namespace separation** — covers
  why `/pour` exists as a one-way gate, the freeze invariant, both
  current defense layers (RALPH.md prose rule + commit-msg hook), and
  why both depend on the namespace split. Lists the future PreToolUse
  hook as defense layer 3 ("not yet implemented").

## Where we are

Building defense layer 3. Plan is **approved and ready to implement**:

- **Plan**: `docs/plans/2026-04-07-spec-read-guard-hook.md`
- **ADR for context**: `docs/adrs/004-spec-ticket-namespace-separation.md`
- **Tracking**: claude task #3 ("Build PreToolUse Read hook to block
  spec task reads in Implementer role") — note: title pre-dates the
  signal change, the hook now keys on `RALPH_SESSION` env var, not
  role state. Update or ignore the title.

## Key decisions in the plan (and why)

The first draft proposed a `.ralph-role` file written at triage. Both
code-critic and grug-architect independently flagged it as circular:
a state file maintained by convention, defending against failures of
convention. Replaced with simpler signals locked in:

- **Signal**: `RALPH_SESSION=1` exported by `ralph.sh`. Env propagates
  to the hook subprocess. Zero new state. /spec, /pour, code-critic,
  human work all run outside ralph.sh and are unaffected.
- **Tool coverage**: Read, Edit, **and** Write. Blocking only Read
  leaves a hole — Implementer with the path in context could still
  Write the implementation. Cover all three.
- **Block (exit 2), not warn** — safe because blocked tool result just
  bounces back to Claude.
- **Devenv-only install** — zero non-Nix users today; /init gets one
  sentence of documentation, no jq merge.

The plan covers the hook script, ralph.sh changes, RALPH.md update,
devenv module changes, init.md doc line, and ADR-004 update with
honest scope statement (Glob/Grep are explicitly out of scope; the
hook is defense in depth, not perimeter security).

## What's next

Implement the plan. Files to touch are listed in the plan's "Files to
Create / Modify" table. Unit test sketch is in the Verification
section. Prior art for hook style: `templates/commit-msg.sh`. Prior
art for devenv `.claude/settings.json` write:
`~/Projects/self/project-status-sync/nix/modules/devenv/session-tracking.nix`.

Suggested commit shape: one commit. The plan deliberately scopes out
the commit-msg.sh devenv migration and the discoverability startup
check so this stays small and focused.

## Open follow-ups

- Task #3 title still says "block spec task reads in Implementer role"
  — should be updated to reflect the env-var signal, or just retitled
  to "build spec-read-guard PreToolUse hook." Not blocking.
- After this hook ships, consider whether the commit-msg.sh devenv
  migration is worth doing in a follow-up (asymmetric install pattern
  is debt).

## Learnings

- Two critics in parallel converged on the same simplification (drop
  `.ralph-role`, use existing invariants) without coordination. When
  that happens, the simplification is almost certainly correct.
- The first instinct on "defend against forgotten convention" is to
  invent more convention. The right move is to find an existing
  invariant that is already load-bearing for some other reason and
  ride on it. `RALPH_SESSION` from ralph.sh is exactly that — it
  costs nothing because ralph.sh has to exist anyway.
