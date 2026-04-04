# Handoff: Protocol Testing & ADR Enforcement

**Date**: 2026-04-04 12:35

## What Was Done

Investigated why the genesis session produced ADRs automatically, traced it to the
work-documentation agent's explicit ADR template in its prompt. Made ADR creation a
first-class protocol step rather than relying on soft agent heuristics.

Brainstormed how to validate that Claude sessions actually follow the socrates protocol.
Identified the core constraint: assertions must be deterministic tools checking observable
facts, never another LLM judging whether behavior was "correct."

### Changes

- **RALPH protocol end-of-session gate** (WORKPLAN 6.1 + architecture.md) — expanded from
  a one-liner to an ordered checklist: ADR check → handoff → tk updates
- **Phase 0.5: Protocol test harness** — three components added to WORKPLAN:
  - Hook-based sequence logging (PreToolUse/PostToolUse → JSON log)
  - Artifact assertion script (ADR format, handoff sections, commit messages, tk state)
  - Sequence assertion script (ordering invariants on tool call log)
- **Phase 0.6: Checkpoint fixtures** — repo snapshots at lifecycle states (fresh-pour,
  mid-implementation, review-pending, blocked-deps, post-spec-no-pour) with setup scripts,
  exercise prompts, and expected invariants
- **Phase 6 now depends on 0.5** — protocol specs validated against test harness as written

### Key Decisions

1. ADR creation lives in the RALPH protocol as a mechanical step, not in agent heuristics
2. Protocol validation uses three deterministic layers (hooks, artifact checks, fixtures) —
   no LLM-as-judge in the assertion loop
3. Test expectations defined before protocol specs (test-first for protocol design)

## What's Next

- Phase 0 spikes remain the entry point — 0.5 and 0.6 are now part of that gate
- When Phase 6 begins, each protocol rule should have a corresponding assertion in the
  test harness before the spec is finalized

## Learnings

- The work-documentation agent already has ADR creation baked into its prompt (template,
  directory structure, trigger heuristics). The inconsistency was in whether sessions
  invoked it, not in its capability.
- PreToolUse hooks are best suited for hard binary rules (never commit to main, always
  run tests), not judgment calls (was an architectural decision made?). The ADR step
  belongs in the protocol, not in a hook.

## Gaps

- No concrete hook implementation yet — 0.5 is specified but not spiked. The hook JSON
  schema (what fields are available on stdin) needs verification against Claude Code docs.
- Fixture teardown strategy undefined — are fixtures branches, worktrees, or temp dirs?
  Affects CI integration.
