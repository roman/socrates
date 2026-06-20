# Socrates

A Claude Code plugin for structured design and autonomous development.

Socrates combines Rich Hickey's [Design in Practice](https://www.youtube.com/watch?v=fTtnx1AAJ-c)
methodology with a file-per-task spec system and the Ralph loop pattern for
autonomous coding sessions.

## Philosophy

Autonomous coding loops work — but the tooling around them tends toward two
failure modes: too simple (a markdown task list that goes stale) or too complex
(databases, daemons, and protocol duplication in every task). Socrates aims
for the middle ground: structured and queryable without a database, repeatable
without embedding the protocol in every task.

Key principles:
- **Socratic method** — challenge assertions, examine ideas dispassionately
- **Design before code** — the `/spec` journey ensures the problem is understood
  before solutions are proposed
- **Protocol as reference** — RALPH.md is the single source of truth for session
  behavior, not duplicated per task
- **File-per-task** — specs decompose into individual task files that track their
  own lifecycle

## Workflow

```
/spec → approve tasks → ralph loop → /harvest
```

1. **`/spec`** — Design in Practice journey through five phases:
   Describe → Diagnose → Delimit → Direction → Design.
   Produces an `_overview.md` and individual task files.

2. **Approve tasks** — Review generated task files and set `status: approved`
   to freeze their contract. The `spec ready` CLI shows the unblocked frontier.

3. **Ralph loop** — Autonomous sessions pick up ready tasks, implement,
   verify, commit, and hand off context for the next session. Specs that
   opt into review mode extend the loop through external code review and
   merge.

4. **`/harvest`** — Extracts learnings and gaps from session handoffs into
   durable artifacts (skills, docs, specs).

## Installation

```bash
claude plugin add /path/to/socrates/plugins/socrates
```

No project setup step is needed. Run `/spec` to start designing; the plugin
creates `docs/specs/` on first use.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Status

Initial build complete; the project is now dogfooding itself. Work is tracked
as task files under `docs/specs/`.
