# Writing Effective Tasks

The standard for socrates task files (`task.md`). A task that follows it reads
clearly and slots cleanly into its spec.

The overview is the source of the durable why; a task is a slice of it. The
implementer reads the overview for full context — a task never replaces it.

A task therefore points at the overview instead of copying it. `serves:` names
the diagnosed items it addresses, and the body links to the sections that
explain them. This is not a style preference: a spec keeps moving after its
tasks are written, and a task holding a snapshot of the overview goes stale
without anyone noticing. A pointer cannot.

A socrates task is an **engineering task**, not a user story. It may name the
chosen approach, but only when it also shows why, so the reader can tell a
decision from an assumption.

See [task-authoring-examples.md](task-authoring-examples.md) for worked
bad-versus-good examples.

## The nine checks

Every task passes these. They come from INVEST (Wake), Cohn's *User Stories
Applied*, BDD acceptance criteria (North), and the Scrum Definition of Done,
adapted to the `task.md` shape (frontmatter, title, Scope, Outcome,
Verification).

1. **Valuable** — `serves:` names the diagnosed items whose pain the task
   relieves, and they resolve to real entries in the overview.
2. **Outcome-first** — the title names the result or deliverable, not a code
   mechanism or a dramatic restatement of the diagnosed problem.
3. **Testable** — Verification lists facts someone can check, never "works
   correctly."
4. **Small** — one deliverable. If you find yourself writing "and," suspect two
   tasks.
5. **Independent** — dependencies are declared in `deps:`, not implied by prose.
6. **Estimable** — enough detail to size; no unresolved load-bearing unknown.
7. **Bounded** — Scope states what is excluded, not left to guess.
8. **Done is distinct from tested** — the Outcome says when it's finished; the
   Verification says how you'd confirm it. They are not the same sentence.
9. **Negotiable** — when a design choice was made, the rejected alternative and
   its reason are visible.

## The title names the outcome

A task list should tell the reader what the work will produce. Diagnose already
records what is broken, so repeating the deficiency in every task title makes
the list harder to scan and encourages slogans such as "has nowhere to live."

- Don't: *Shipping the controller image auto-activates fanout on every
  production principal*
- Do: *Let projects opt into setup ApplicationSet fanout*

Name the observable result or concrete deliverable. A short imperative is fine
when it is the clearest form. Keep implementation details in Scope or Outcome,
where their rationale sits next to them.

## Scope carries the slice, not the spec

Scope is the shortest section in the file, and the one authors most want to
overfill. It holds exactly two things:

- **The boundary.** What a reader might reasonably assume is in this task and
  is not. Name the excluded work; do not leave it to be discovered mid-implementation.
- **The rejected alternative** for a design choice this task makes on its own —
  with the reason, so a decision reads as a decision rather than an assumption.

Everything else is a link. The user-facing pain, the diagnosed items, the
chosen approach and its rationale all live in the overview and stay there. If a
sentence in Scope would still be true written in the overview, it belongs in
the overview.

A worked contrast:

- Don't: *The CLI currently fails to schedule work because dependency edges are
  implied by prose rather than declared, which forces every consumer to parse
  the overview.* — that is RC2, restated. In three weeks it will disagree with
  RC2.
- Do: *Scope is the parser and its edge cases; the CLI's output formatting is
  untouched (see [RC2](_overview.md#rc2)). Edges are read from frontmatter
  rather than a generated lockfile, because a lockfile needs a regeneration
  step no one would remember to run.*

## Separate "done" from "how you'd check it"

The Outcome is the end state: what is true about the system when the task is
finished. The Verification is the set of observations that would convince a
skeptic. If a Verification bullet would read identically as an Outcome bullet,
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

## Priority answers one question

`priority` records what cutting the task would do to the outcome named in
Delimit. Nothing else.

| Value | Cut it and… |
|-------|-------------|
| 0 | the spec does not deliver its Delimit outcome at all |
| 1 | the outcome ships, but a named Use Case cannot be completed |
| 2 | every Use Case still completes, worse — the default |
| 3 | this spec's outcome is unchanged; the task serves a later one |
| 4 | nobody notices; the task is a candidate for `cancelled` |

Two rules keep the field from collapsing into a second copy of the schedule:

- **Priority is not order.** A task is not `0` because it runs first, and not
  `4` because it runs last. Sequencing lives in `deps:`.
- **A task serving nothing starts low.** With an empty `serves:`, open at `3`
  and argue upward. A task that traces to no diagnosed item has to say what it
  is doing in the spec at all.

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
- **Say how the observation gets staged.** A criterion nobody can produce on
  demand is not yet a criterion. "Two projects on one principal, one opted in
  and one not" is a bullet; "the controller behaves correctly for opted-in
  projects" is a wish.

Scope boundaries do not belong here. "The finalizer is left in place" is not
an observation anyone makes — it is the shape of the slice, and it belongs in
Scope.

### The question that finds the holes

Write the list, then ask a second question about it: *if I had to demonstrate
this to someone tomorrow, what would I need?* The answer is usually a fixture,
a seeded record, or an environment nobody has provisioned — and it adds bullets
to the list rather than sitting in the implementer's head. Both questions are
part of the criteria; only the first one is obvious.

## Before marking a task ready

Run the nine checks. The `<review>` tag is reserved for human ticket feedback;
never fill it.
