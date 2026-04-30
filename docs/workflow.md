# Workflow Guide

Socrates structures development into four phases: **Spec → Pour → Ralph → Harvest**.
Each phase feeds the next, creating a cycle where learnings from implementation
flow back into future designs.

## Phase 1: Spec — Design in Practice Journey

Run `/spec <name>` to start designing a feature. The AI walks you through five
stages, each building on the last:

### Describe

The AI interviews you about the current situation using Reflective Inquiry:
what's happening, what you know, what you don't know, who's affected. No
interpretation yet — just capturing the landscape.

You can skip the interview by providing a source document:
`/spec --source PRD.md` or `/spec --source https://ticket-url`.

### Diagnose

The AI challenges surface-level assertions and probes for root causes. "We need
feature X" gets pushed back with "what happens to users because X doesn't exist?"
Hypotheses are formed and tested against evidence.

### Delimit (strict gate)

A crisp 1-2 sentence problem statement in observable terms. This is the only
hard gate — you must explicitly approve before proceeding. If the problem
statement isn't right, you can refine it or go back to Diagnose.

### Direction

Multiple approaches are generated (always including status quo), compared via a
decision matrix (🟢🟡🔴⬜), and you choose one. Use cases capture what users could
accomplish if the problem were solved.

### Design

The AI researches the codebase, then decomposes the chosen approach into 5-10
task files with dependencies, implementation steps, and verification criteria.

### Output

- `docs/specs/<name>/_overview.md` — the full design journey
- `docs/specs/<name>/<id>.md` — individual task files

### Resume and Review

`/spec` can be run again to resume where you left off. Run `/spec <task-file>`
to process review feedback on individual tasks. Use `/spec --status` to see
progress across all specs.

## Phase 2: Pour — Tasks to Tickets

Run `/pour <name>` to transform approved task files into tk tickets.

- Only `status: approved` tasks are poured (draft tasks are skipped)
- Dependencies from spec files are wired as tk dependencies
- Multiple tasks get grouped under an epic
- Task files are frozen with `status: poured` — all mutable state moves to `.tickets/`
- Safe to re-run: already-poured tasks are skipped

### Approval Workflow

Before pouring, review each task file in `docs/specs/<name>/`. Change
`status: draft` to `status: approved` for tasks you're satisfied with. You can
pour incrementally — approve and pour a few tasks, then approve more later.

## Phase 3: Ralph — Autonomous Implementation

Run `./ralph.sh` to start the autonomous loop. Ralph picks tasks from `tk ready`,
implements them following the RALPH.md protocol, and commits the results.

Each task follows the phase sequence:
1. **Bearings** — read the ticket, explore the codebase, verify build health
2. **Implement** — focused changes following existing patterns
3. **Verify** — run checks appropriate to the task type
4. **Commit** — conventional commit with `Refs: <tk-id>`

Ralph writes a session handoff to `docs/handoffs/` at the end of each session.

### Controlling Ralph

- **Single iteration**: `./ralph-once.sh` for testing
- **Graceful stop**: `touch .ralph-stop` — Ralph finishes current task then exits
- **Messages**: Write to `.msgs/<id>.md` to communicate asynchronously

## Phase 4: Harvest — Learnings to Artifacts

Run `/harvest` to extract learnings and gaps from session handoffs.

For each **learning**, you choose where to persist it:
- A skill in `.claude/skills/`
- An addition to CLAUDE.md
- Documentation in `docs/`
- Skip

For each **gap**, you choose how to handle it:
- Create a tk ticket
- Add to an existing spec for the next design iteration
- Skip

Harvest tracks what's been processed via `.last-harvest` so it won't
re-process old handoffs.

## The Full Cycle

```
Spec → Pour → Ralph → Harvest
  ↑                      |
  └──────────────────────┘
     gaps feed new specs
```

Learnings improve the AI's skills and project conventions. Gaps become new
tickets or spec inputs. Each cycle makes the next one better.

Concerns surfaced during spec design that warrant their own future spec live
under `docs/gaps/` — one file per deferred concern, refer-back-able when
prioritising the next design round.
