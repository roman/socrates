# Unified Task Lifecycle — Poured (8/8)

Poured the `2026-06-06-unified-task-lifecycle` spec at the driver's
request, against the spec's own bootstrap note that says to execute it
interactively. Decision was deliberate (see below).

Epic `soc-bjda`; eight task tickets; edges wired; all nine numbered
spec files frozen (`status: poured`, `ticket: <id>`).

## Why we poured despite the bootstrap note

The spec's Direction phase says "execute interactively (driven by task
file path, not poured)". I flagged this before acting. Two facts made
"pour anyway" the right call:

- ✅ **Verified** — `RALPH.md:96-100` makes `tk ready -a ralph` the
  *only* valid work source. Without pour, RALPH sees nothing, switches
  to PM, and messages the human to run `/pour`.
- ✅ **Verified** — `spec-read-guard.sh:33-42` blocks Read/Edit/Write
  on numbered spec files under `RALPH_SESSION=1`. Even bypassing the
  work-source rule, RALPH can't read the source.

So: without pour, RALPH cannot work tasks 1–6 autonomously. The
bootstrap note's "execute interactively" assumes the driver is willing
to drive every task by hand. Pouring 1–6 lets RALPH chew through the
mechanical work while the driver supervises 7–8 (which delete `/pour`
and `tk` and so cannot run autonomously).

## Tickets (dep-ordered)

```
soc-bjda [epic]    Unified Task Lifecycle
├── soc-fjro p0    Record the unified-lifecycle decision
├── soc-gfdy p0    Define the unified task artifact schema
├── soc-hrj1 p1    Extend the spec CLI with frontier and dependent queries
│                  └── deps: soc-gfdy
├── soc-06lq p1    Re-aim mechanical defenses to task status
│                  └── deps: soc-gfdy
├── soc-7wqf p2    Migrate existing specs to the unified schema
│                  └── deps: soc-gfdy, soc-hrj1
├── soc-wm99 p2    Rewrite protocols for the unified lifecycle
│                  └── deps: soc-hrj1, soc-06lq
├── soc-30rr p3    Remove pour and reconcile spec and init authoring
│                  └── deps: soc-gfdy, soc-hrj1, soc-7wqf, soc-wm99
└── soc-ix31 p4    Retire the tk dependency
                   └── deps: soc-30rr
```

## Edge source — note for future pours

This spec has no `#### Shared Surfaces` subsection (which the current
`/pour` procedure parses). It records edges as an explicit
`#### Dependencies` block (`_overview.md:497-507`). I used that block
as the authoritative edge source. A strict reading of `/pour` would
have produced zero edges — the procedure assumes `Shared Surfaces` is
present. This mismatch will be obsolete once tasks 7+ land (the new
schema moves edges into task frontmatter), but it is real today.

## Hand-off rules for execution

- **Tasks 1–6**: safe for RALPH. `tk ready -a ralph` will surface them
  in dep order. Standard cycle.
- **Task 7 (`soc-30rr`)**: drive interactively. Deletes `/pour` and
  rewrites `/spec` Design authoring. The moment `/pour` is gone, the
  spec text "execute interactively" applies to the rest of the work.
- **Task 8 (`soc-ix31`)**: drive interactively. Deletes the `tk` Nix
  package and removes `.tickets/` from setup. After this lands,
  `tk ready -a ralph` no longer exists; switching back to RALPH
  requires `spec ready` from task 3 to be in place.

## Open after this commit

- `PENDING.md` (untracked) and `.claude/settings.local.json` (untracked)
  are not part of the pour. Left alone.
- The `pr-review-loop` follow-up: still complete and archived
  (`9e4bc91`); not touched.

Refs: soc-bjda
