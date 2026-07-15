# Writing Effective Tasks

The standard for socrates task files (`task.md`). A task that follows it reads
clearly and slots cleanly into its spec.

The overview is the source of the durable why; a task is a slice of it. The
implementer reads the overview for full context — a task never replaces it.
Restate only the minimum from the overview needed to make the slice
self-contained, and link rather than duplicate the rest.

A socrates task is an **engineering task**, not a user story. It may name the
chosen approach, but only when it also shows why, so the reader can tell a
decision from an assumption.

See [task-authoring-examples.md](task-authoring-examples.md) for worked
bad-versus-good examples.

## The nine checks

Every task passes these. They come from INVEST (Wake), Cohn's *User Stories
Applied*, BDD acceptance criteria (North), and the Scrum Definition of Done,
adapted to the `task.md` shape (frontmatter, title, Context, Outcomes,
Verification).

1. **Valuable** — the task names whose pain it relieves, in concrete terms.
2. **Problem-first** — the title and opening state the problem or outcome, not
   the mechanism. Lead with what's broken; let the fix follow.
3. **Testable** — Verification lists facts someone can check, never "works
   correctly."
4. **Small** — one deliverable. If you find yourself writing "and," suspect two
   tasks.
5. **Independent** — dependencies are declared in `deps:`, not implied by prose.
6. **Estimable** — enough detail to size; no unresolved load-bearing unknown.
7. **Bounded** — what's out of scope is stated, not left to guess.
8. **Done is distinct from tested** — the Outcomes say when it's finished; the
   Verification says how you'd confirm it. They are not the same sentence.
9. **Negotiable** — when a design choice was made, the rejected alternative and
   its reason are visible.

## The title states the problem, not the fix

A problem-shaped title makes a task list readable by outcome. Name what's
broken; the fix follows in the body.

- Don't: *Stop auto-triggering the airproject pipeline on push*
- Do: *Airproject races CD Configs on push and bootstraps a stale cluster list*

The chosen fix still belongs in the task, in the Context or Outcomes, where its
rationale sits next to it. It just isn't the headline.

## Separate "done" from "how you'd check it"

The Outcomes are the end state: what is true about the system when the task is
finished. The Verification is the set of observations that would convince a
skeptic. If a Verification bullet would read identically as an Outcomes bullet,
one of them is redundant.

- Outcome: *The opt-out path tears down the setup ApplicationSet on the next
  reconcile, so a disabled project generates no setup Applications.*
- Verification: *After removing the flag, the ApplicationSet is absent and the
  AirProject no longer advertises `ApplicationSetReconciled`.*

## Make dependencies explicit

Dependency edges live in the `deps:` frontmatter field — that list is the
single source of truth a parser reads to schedule the work. A task that depends
on another's output without an edge in `deps:` is the hardest kind to schedule.

Declare the edge in frontmatter, then let the body explain *why* it matters:
"the ApplicationSet this guards is created by `3-aa66`" tells the reader what
the edge is for. The prose explains; the `deps:` field is what binds.

## One deliverable per task

A task that bundles a decision, two spikes, a migration, and a runbook can't be
estimated, and its Verification reads as four tickets stapled together. Split on
the seams: a spike that resolves an unknown is its own task; the work that
depends on the answer is another. If a task carries an unresolved load-bearing
question, that question is a precondition — pull it into Open decisions or a
spike task rather than leaving the implementer blocked mid-task.

## What good Verification looks like

- Name concrete artifacts: real CR names, status fields, golden-output
  assertions, observable states ("single owner, no flap"). Never "works
  correctly."
- Ground the why in the observed failure that motivated the task — a support
  incident, a dated live test.
- State non-goals. Naming what stays unchanged ("the finalizer is left in
  place," "AppProject restriction stays on `control-plane.enabled`") is what
  makes scope unambiguous.

## Before marking a task ready

Run the nine checks. The `<review>` tag is reserved for human ticket feedback;
never fill it.
