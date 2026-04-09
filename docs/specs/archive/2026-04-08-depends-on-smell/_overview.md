---
title: depends-on smell diagnosis
created: 2026-04-08
epic: soc-z4r9
archived: 2026-04-08
delimit_approved: true
---

## Describe [COMPLETE]

**Situation.** Socrates' task frontmatter carries a `depends_on:` field.
`/pour` uses it to topo-sort spec tasks into tk tickets and wire `tk dep`
edges between the created tickets (see
`plugins/socrates/commands/pour.md:38–72`). In practice, the authoring
agent running `/spec` also uses the same field informally as a sequencing
hint — "I imagine these get worked in this order" — rather than strictly
as a declaration of artifact dependency.

**What we know.**

- `depends_on` has one real mechanical consumer: `/pour`'s topo sort and
  `tk dep` edge wiring. That job is genuine — ticket creation needs a
  valid order, and ralph dispatch honors tk deps.
- The field currently conflates two jobs: (a) hard artifact dependencies
  (task B literally cannot compile, run, or merge without task A's
  output), and (b) soft sequencing preferences the authoring agent
  inferred while decomposing.
- Observed spec graphs tend to be denser and more linear than the
  underlying artifact dependencies would justify. Near-linear
  `1→2→3→…` chains are a common shape.
- `priority:` + file-order ordering is a known alternative used by
  adjacent tools; it pours without a dependency graph at all. Existence
  proof that graph machinery is not mandatory, though it operates at a
  different granularity (relevant to Session 3).
- INVEST's "Independent" is aspirational; empirical research on backlog
  dependencies finds declared graphs systematically understate real
  coupling. Socrates' `depends_on` isn't claiming INVEST-I, but readers
  may conflate the two.
- Socrates already has an explicit cross-task coupling declaration in
  `_overview.md`: the `Shared Surfaces` subsection. Each entry names a
  surface — a file, type, config key, sentinel — and links the tasks
  that touch it. This content currently exists for the human reviewer;
  `/pour` does not read it.

**Open questions / uncertainty.**

- Is the smell bad enough to fix on its own, or does it dissolve once
  the sizing rule (Session 3) raises granularity and flattens most
  graphs?
- Is the cost of the status quo purely aesthetic (graphs look
  over-specified), or does it produce observable wrong behavior (pour
  wires spurious `tk dep` edges that block ralph from picking up work
  that is in fact independent)?
- Does the field name `depends_on` itself bias authoring agents toward
  over-use?

**Who is affected.**

- **The authoring agent** running `/spec` — spends reasoning budget
  deciding edges it doesn't actually need to declare.
- **The human driver** reviewing the spec — has to evaluate a denser
  graph than the work requires.
- **`/pour`** — does extra work and may wire edges that don't reflect
  real artifact dependencies.
- **Ralph** — may be blocked from parallelizable work by sequencing-hint
  edges mechanically promoted into hard `tk dep` blockers.

## Diagnose [COMPLETE]

**Hypotheses considered.**

- **H1 — Most declared edges are sequencing hints, not artifact
  dependencies.** *Confirmed.* The authoring agent, lacking a
  distinction between "must happen first" and "feels nicer first,"
  defaults to declaring both as edges. The field's name biases this.
- **H2 — `Shared Surfaces` already encodes the only coupling that
  matters for ordering.** *Confirmed by construction.* If two tasks
  share a surface, one is producer and the others are consumers, and
  that is the real dependency. Any artifact dependency that isn't
  reflected in a shared surface is either a shared surface that
  should have been declared, or a pure sequencing preference that
  will rot under implementer discovery. There is no third category
  `depends_on` uniquely captures.
- **H3 — The rot mechanism is implementer discovery.** *Confirmed.*
  Edges declared at spec time encode the authoring agent's model of
  the work. When the implementer discovers task B no longer needs
  task A's output, the declared edge is wrong — but it has already
  been wired into tk as a hard `tk dep` blocker and will silently
  prevent ralph from picking up work that is in fact ready. Shared
  Surfaces rot less because they describe *what* is touched, not
  *when*.
- **H4 — The field name biases over-declaration.** *Unconfirmed;
  parked.* Plausible but secondary. Even a renamed field would still
  carry the conflation if both jobs live in it. Addressing H1–H3
  subsumes this.
- **H5 — The problem dissolves at slice granularity (Session 3
  entanglement).** *Rejected as a reason to defer.* The rot mechanism
  is independent of granularity. Slice-sized tasks will still have
  occasional real dependencies, and `depends_on` will still be the
  wrong place to record them if `Shared Surfaces` already exists.

**Root causes.**

1. **`depends_on` conflates two distinct relations** (artifact
   dependency vs sequencing preference) into a single graph, and
   `/pour` mechanically promotes *all* of them into hard tk dep
   blockers. There is no way for the authoring agent to express "B
   reads nicer after A" without also telling ralph "B is blocked
   until A closes."
2. **The cross-task coupling `/pour` needs is already declared
   elsewhere.** `Shared Surfaces` is a more durable, more truthful
   declaration of coupling than `depends_on`, because it describes
   observable artifacts rather than the authoring agent's imagined
   order. `/pour` not reading it is the gap.
3. **Authoring-time sequencing guesses rot under implementer
   discovery.** Any mechanism that requires the authoring agent to
   predict execution order at `/spec` time will produce edges that
   are wrong by the time ralph executes. The fix is not better
   prediction — it is removing the requirement to predict.

**Symptoms vs causes.**

- *Symptom:* spec graphs denser and more linear than the work
  requires. *Cause:* conflated field + no alternative outlet for
  sequencing preferences.
- *Symptom:* review feels heavy. *Cause:* the human driver is
  evaluating edges that encode guesses, not facts.
- *Symptom:* ralph may be blocked by spurious edges. *Cause:*
  mechanical promotion of all declared edges into `tk dep` blockers.

## Delimit [APPROVED]

The human driver reviewing or refining a spec has to evaluate and
maintain a dependency graph the authoring agent constructs by guessing
execution order, even though the same coupling is already declared —
more truthfully and more durably — in `Shared Surfaces`. `depends_on`
duplicates that information in a form that rots under implementer
discovery and gets harder to keep consistent with every refinement
pass, inflating review burden with edges that encode no fact the
overview doesn't already contain.

## Direction [COMPLETE]

### Approaches

- **A0 — Status quo.** Keep `depends_on:`, keep `/pour` topo-sorting
  from it. Baseline.
- **A1 — Drop `depends_on:`, `/pour` derives ordering from
  `Shared Surfaces`.** Each surface entry marks one task explicitly
  as producer; `/pour` emits `consumer depends_on producer` edges
  for the other linked tasks. Authoring agent stops guessing
  execution order; it declares surfaces, which it was already doing.
- **A2 — Hybrid: keep `depends_on:` optional and advisory, prefer
  surfaces.** Backward compatible, but pays the cost of both
  mechanisms for the benefit of neither.
- **A3 — Prose discipline: redefine `depends_on:` as artifact-only
  via `spec.md` guidance.** No mechanical change. Duplication and
  refinement burden remain.

### Decision Matrix

Problem: human driver maintains a rotting duplicate graph.

| Criterion | A0 | A1 | A2 | A3 |
|---|---|---|---|---|
| Eliminates duplication with Shared Surfaces | 🔴 | 🟢 | 🟡 | 🔴 |
| Reduces refinement maintenance burden | 🔴 | 🟢 | 🟡 | 🔴 |
| Removes authoring-time execution-order guessing | 🔴 | 🟢 | 🟡 | 🔴 |
| Edges reflect observable artifacts, not guesses | 🔴 | 🟢 | 🟡 | 🔴 |
| Reversibility if wrong | 🟢 | 🟡 | 🟢 | 🟢 |
| `/pour` change required | ⬜ | 🟡 | 🔴 | ⬜ |
| Requires authoring-agent discipline to work | 🟢 | 🟢 | 🟡 | 🔴 |
| Backward compat with existing drafts | 🟢 | 🔴 | 🟢 | 🟢 |
| Conceptual simplicity (one source of truth) | 🔴 | 🟢 | 🔴 | 🔴 |

A1 is the only column that turns every problem row green. A2 pays
the cost of both mechanisms for the benefit of neither. A3 is status
quo with extra prose.

### Chosen Approach

**A1 — drop `depends_on:`, `/pour` derives ordering from
`Shared Surfaces` with an explicit producer marker.**

Each Shared Surface entry in `_overview.md` marks one linked task
explicitly as the producer (e.g., `[1-a1b2] (producer)`). `/pour`
reads the surfaces, and for each surface with a marked producer,
emits `consumer depends_on producer` edges for every other linked
task. Surfaces with no producer mark are treated as mutual reads
and contribute no edges. The resulting edge set is topo-sorted the
same way `depends_on` edges are today.

Rationale: it is the only approach that attacks the root cause in
Delimit (duplication of a rotting graph against a durable
declaration). The explicit producer marker survives link reordering
during refinement, which positional conventions would not.
Information parity holds — `/pour` reads the same overview `/spec`
writes, so nothing needs to be pre-digested into frontmatter.

### Use Cases

- *As the human driver reviewing a spec,* I wish I could read the
  overview's Shared Surfaces section and trust that `/pour`'s
  execution order matches what the surfaces imply, without
  cross-checking a separate graph.
- *As the human driver refining a spec,* I wish I could add or
  reshape a task without maintaining a dependency graph that
  duplicates what the surfaces already say.
- *As the authoring agent running `/spec`,* I wish I could stop
  spending reasoning budget on predicting execution order and focus
  that budget on naming surfaces correctly.
- *As ralph executing work,* I wish tk dep edges reflected only
  real artifact dependencies, so I am never blocked from picking up
  work that is in fact ready.

## Design [COMPLETE]

### Context

- **`_overview.md` template** already has a `#### Shared Surfaces`
  subsection with a narrative format
  (`plugins/socrates/templates/_overview.md:68–76`). Entries look
  like: `**<surface>** — touched by [task-a] and [task-b]; <one
  sentence why>.`
- **`spec.md` Design phase** (lines ~473–485) instructs the
  authoring agent how to populate Shared Surfaces and forbids shape
  content. Needs to be extended to require an explicit producer
  marker per entry.
- **`task.md` template** declares `depends_on: []` as frontmatter
  (`plugins/socrates/templates/task.md:7`). Retiring it touches the
  template, `docs/spec-format.md` task-frontmatter docs (line 96),
  and `spec.md`'s task-generation instructions.
- **`/pour`** (`plugins/socrates/commands/pour.md:38–72`) currently
  topo-sorts using `depends_on:` and calls `tk dep` for each listed
  id. Procedure step 3 must be rewritten to parse `_overview.md`'s
  Shared Surfaces and derive edges there.
- **Ordinal prefix** on task filenames becomes a readability hint
  assigned from the surface-derived topo sort at `/spec` time;
  `/pour` re-derives independently at pour time from the same
  section (information parity).
- **Cycle detection** stays in `/pour`. Surface-derived edges can
  still form cycles if producers are marked inconsistently; `/pour`
  must stop and report.
- **Empty Shared Surfaces is valid.** A spec with fully independent
  tasks legitimately has no cross-task coupling. `/pour` must fall
  back to filename (ordinal) order with zero `tk dep` calls in that
  case, not fail.
- **Forward-only migration.** Existing archived/poured specs are
  frozen artifacts and are unaffected.

### Tasks

| ID | Title | Priority | Category |
|---|---|---|---|
| [1-58c1](1-58c1-producer-marker-format.md) | Add producer marker to Shared Surfaces format | 1 | documentation |
| [1-785c](1-785c-retire-depends-on-authoring.md) | Retire depends_on from task authoring surface | 1 | documentation |
| [2-4968](2-4968-pour-derives-from-surfaces.md) | Derive pour ordering from Shared Surfaces | 0 | functional |

### Execution Order

1. **[1-58c1](1-58c1-producer-marker-format.md)** — Defines the
   producer-marker convention in the template, `spec.md` authoring
   guidance, and `docs/spec-format.md`. Must ship before `/pour`
   can rely on the marker.
2. **[1-785c](1-785c-retire-depends-on-authoring.md)** — Removes
   `depends_on:` from the task template, `spec.md` task-generation
   guidance (including ordinal assignment), and `docs/spec-format.md`
   task-frontmatter docs. Independent of 1-58c1; can ship in
   parallel.
3. **[2-4968](2-4968-pour-derives-from-surfaces.md)** — Rewrites
   `/pour`'s topo-sort step to parse Shared Surfaces from
   `_overview.md` and derive consumer→producer edges. Consumes both
   1-58c1 (marker format) and 1-785c (depends_on retirement).

### Glossary

- **Shared Surface** — A cross-task touchpoint (file, type, config
  key, sentinel) named in `_overview.md`'s `#### Shared Surfaces`
  subsection, with links to the tasks that touch it and a one-
  sentence note on why the coupling matters.
- **Producer marker** — An explicit `(producer)` annotation on one
  linked task within a Shared Surface entry, designating it as the
  task that creates the surface. Other linked tasks are implicit
  consumers. Absence of a producer marker means the surface is a
  mutual read and contributes no ordering edges.
- **Surface-derived edge** — A `consumer depends_on producer`
  dependency emitted by `/pour` for each non-producer task in a
  surface that has a producer marker.

#### Shared Surfaces

- **`_overview.md` Shared Surfaces entry format** — touched by
  [1-58c1](1-58c1-producer-marker-format.md) *(producer)* and
  [2-4968](2-4968-pour-derives-from-surfaces.md); the producer
  defines the marker syntax in template + docs, the consumer parses
  it in `/pour` to derive edges. Both must agree on where the
  marker appears in the entry.
- **`depends_on:` field retirement** — touched by
  [1-785c](1-785c-retire-depends-on-authoring.md) *(producer)* and
  [2-4968](2-4968-pour-derives-from-surfaces.md); the producer
  removes the field from the authoring surface (template, docs,
  guidance), the consumer removes the read path in `/pour`. Both
  must agree the field is gone.
