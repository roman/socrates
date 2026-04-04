# ADR-003: /spec and /design Merged into One Command

**Date**: 2026-04-04
**Status**: Accepted

## Context

The initial design had separate `/spec` and `/design` commands. `/spec` would cover
Describe through Direction (the first 4 D's), producing an `_overview.md`. `/design`
would read the overview and generate task files.

Code-critic review identified this as an artificial seam: what we called `/design` was
not Hickey's Design phase (system design) but task decomposition — the natural final
step of the same journey. Splitting it into a separate command added a command to
remember, an exit-and-reenter friction point, and a risk that the overview schema
wouldn't be parsed consistently.

## Decision

A single `/spec` command drives the full journey: Describe → Diagnose → Delimit →
Direction → Design (task decomposition). The Design phase is the final step of the same
session. The command resumes at the first incomplete phase using `[DRAFT]`/`[COMPLETE]`/
`[APPROVED]` markers in section headers.

## Consequences

**Gained:**
- Problem discovery is built into the spec flow, not optional.
- Fewer commands to remember (4 vs 6).
- Resume capability: `/spec <name>` picks up exactly where it left off.
- The Delimit gate ensures tasks are never generated without an approved problem statement.

**Lost:**
- No way to run task decomposition independently without going through the D1-D5 journey.
  If you already know what to build and want to skip straight to tasks, the Delimit gate
  requires at minimum an explicit approval of the problem statement before proceeding.

**Accepted tradeoff:** The friction of stating the problem before decomposing it is a
feature, not a bug. The cases where you'd want to skip it are cases where you're
probably making a mistake.
