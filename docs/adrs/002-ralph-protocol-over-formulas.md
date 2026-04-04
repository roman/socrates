# ADR-002: RALPH.md Protocol over Per-Ticket Formulas

**Date**: 2026-04-04
**Status**: Accepted

## Context

choo-choo-ralph embeds the full ralph protocol (~50 lines of formula) into every ticket
at pour time. This means changing the protocol after pour has no effect on existing
tickets — every in-flight ticket runs the old protocol until it is manually re-poured.

## Decision

The ralph protocol lives exclusively in RALPH.md — one file read at the start of every
session. Tickets carry only what to do (title, steps, test_steps), not how to do it.
RALPH.md adapts its ceremony to the task type (feature/docs/infrastructure/bug).

## Consequences

**Gained:**
- Protocol changes take effect immediately for all future sessions without re-pouring.
- Tickets are leaner — no 50-line protocol block per ticket.
- Task-type adaptation happens in the protocol, not in per-ticket formulas.

**Lost:**
- No per-task workflow customization. All tasks follow the same protocol with type-based
  variations. Edge cases that need truly custom workflows are not supported.

**Accepted tradeoff:** The type-adaptive protocol (feature/docs/infra/bug) covers the
real-world cases. Per-task customization is more flexibility than we need.
