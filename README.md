# Socrates

A Claude Code plugin for structured design and autonomous development.

Socrates combines Rich Hickey's [Design in Practice](https://www.youtube.com/watch?v=fTtnx1AAJ-c)
methodology with a git-native task system (`tk`) and the Ralph loop pattern for
autonomous coding sessions.

## Philosophy

Autonomous coding loops work — but the tooling around them tends toward two
failure modes: too simple (a markdown task list that goes stale) or too complex
(databases, daemons, and protocol duplication in every ticket). Socrates aims
for the middle ground: structured and queryable without a database, repeatable
without embedding the protocol in every task.

Key principles:
- **Socratic method** — challenge assertions, examine ideas dispassionately
- **Design before code** — the `/spec` journey ensures the problem is understood
  before solutions are proposed
- **Protocol as reference** — RALPH.md is the single source of truth for session
  behavior, not duplicated per ticket
- **File-per-task** — specs decompose into individual task files that track their
  own lifecycle

## Workflow

```
/spec → /pour → ralph loop → /harvest
```

1. **`/spec`** — Design in Practice journey through five phases:
   Describe → Diagnose → Delimit → Direction → Design.
   Produces an `_overview.md` and individual task files.

2. **`/pour`** — Converts approved task files into `tk` tickets.
   Spec files freeze after pour; mutable state lives in `.tickets/`.

3. **Ralph loop** — Autonomous sessions pick up ready tickets, implement,
   verify, commit, and hand off context for the next session.

4. **`/harvest`** — Extracts learnings and gaps from session handoffs into
   durable artifacts (skills, docs, new tickets).

## Installation

```bash
claude plugin add /path/to/socrates/plugins/socrates
```

Then in your project:

```bash
/socrates:init
```

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [tk](https://github.com/wedow/ticket) — git-native ticket tracker
- `jq`
- `gh` (GitHub CLI)

## Status

Early development. See [WORKPLAN.md](WORKPLAN.md) for current progress.
