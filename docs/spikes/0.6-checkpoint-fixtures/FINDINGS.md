# Spike 0.6 — Checkpoint Fixtures Findings

**Date**: 2026-04-04
**Result**: Fixture pattern validated with 2 of 5 fixtures.

## Approach

Each fixture is a setup script that creates a temp repo via `mktemp -d`,
populates it with known state (git history, tk tickets, handoffs, protocol
files), and prints the path. No repos-within-repos — just scripts that
produce throwaway directories.

## What Works

- **Setup scripts**: create fully functional repos with git history, tk
  tickets with dependencies, handoffs, and protocol files. Deterministic
  state every run.
- **State validation**: runner confirms repo structure, ticket counts, and
  tk state (ready/blocked/in_progress) match expectations.
- **Teardown**: `rm -rf` on the temp dir. No cleanup needed.
- **Integration with 0.5 harness**: runner can invoke assert-sequence.sh
  and assert-artifacts.sh from the protocol test harness against the
  fixture repo (via `--exercise` flag, manual Claude run for now).

## Fixtures Built

| Fixture | tk State | Expected Behavior |
|---------|----------|-------------------|
| fresh-pour | 2 ready, 2 blocked, 0 in_progress | Implementer picks ready task |
| blocked-deps | 0 ready, 3 blocked, 0 in_progress | PM escalation, nothing to do |

## Remaining Fixtures (not built, pattern proven)

- `mid-implementation`: task in_progress, partial code files
- `review-pending`: implementation done, no review yet
- `post-spec-no-pour`: approved task files without tk tickets

These follow the same pattern — only the setup.sh contents differ.

## Design Decisions

- **Temp dirs over worktrees**: simplest, no git state pollution, works
  without a parent repo
- **stdout = repo path**: setup.sh prints the path on its last line.
  All other output (tk dep messages) goes to stderr.
- **expected.json is declarative**: describes what assertions should pass,
  not how to run them. Runner interprets.
- **Exercise mode is manual**: `--exercise` pauses for a human to run
  Claude in the fixture repo, then asserts. Full automation would need
  Claude SDK / headless mode — out of scope for Phase 0.
