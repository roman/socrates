---
title: Spec Schema Improvements — Planned /spec Sessions
created: 2026-04-08
status: planning
---

# Spec Schema Improvements — Planned `/spec` Sessions

This document captures three independent `/spec` sessions that emerged from a
deep investigation into the current task schema, comparing the Socrates
corpus against issue-definition literature and against choo-choo-ralph's
approach. The investigation was done in one long session and will not fit
in a single `/spec` context window. This doc exists so each session can be
run later with full context preserved.

**Read this whole doc before running any of the three sessions.** The
threads are separable but share a common diagnosis; running one in
isolation without the others' context will likely re-surface the same
questions from scratch.

## Shared Context (read first, applies to all three sessions)

### What triggered the investigation

The user reviewed their own spec corpus in `project-status-sync` and had
two instincts:

1. Tasks feel too granular and brittle — "easy to break as dependencies
   between them grow due to discoveries while working on them by the
   implementor."
2. The multi-file task layout feels like it's causing navigation pain in
   review — "easy to get lost in the ordering (even with the number
   prefixes)."

Both instincts turned out to be correct but the cause was not what the
symptoms suggested.

### Corpus surveyed

All spec files under `~/Projects/self/project-status-sync/docs/specs/`
including `archive/`. Five specs, ~25 files:

- `2026-04-06-replay-pipeline-on-demand` (6 tasks, current)
- `2026-04-07-haskell-code-analyser` (8 tasks, current)
- `archive/2026-04-05-duplicate-handoffs` (4 tasks)
- `archive/2026-04-05-output-sanitization` (5 tasks)
- `archive/2026-04-06-output-abstraction-level` (3 tasks)

### Key empirical findings from the corpus

1. **Schema is consistent across all specs.** Frontmatter, section
   progression, XML tags are invariant. Drift is *inside* tasks, not in
   the shell.
2. **Procedural drift over time.** Archived specs had outcome-focused task
   titles with minimal steps (e.g., `a1b2 — Add gatherSessionEvents and
   removeSessionHandoff helpers`, 3 terse steps). Current specs trend
   toward detailed procedures with labeled sub-steps (e.g., `3-bbbb —
   Wire up ccs replay subcommand` with 15 sub-steps a–l, including
   brittle prose like "projectDir is the second argument, before project
   and signal").
3. **Self-contradictions inside tasks.** Example: haskell-analyser task
   `6-ed1a` step 1 intro says "do not touch `nix/devenvs/default.nix`"
   then the same step says "Add `python3`, `tree-sitter`, and
   `tree-sitter-haskell` to `nix/devenvs/default.nix` `devTools`."
4. **Hidden coupling that `depends_on` does not capture:**
   - `ProcessConfig` type shape coupling across replay tasks 1/2/3
   - `.complexity.toml` schema split between haskell-analyser task 6
     (reader) and task 7 (writer)
   - `NO_GOAL` sentinel string contract between output-abstraction tasks
     `d2ec` (producer) and `3bd5` (consumer)
   - Delimiter strings chosen in sanitization task `0bbb`, consumed
     implicitly by `cf7d`
5. **Line-number pinning rot risk.** Grandfather list in haskell-analyser
   `_overview.md` captures exact line numbers (`Process.hs:257–331`) at
   spec-authoring time. The moment anyone touches `Process.hs` before
   task 7 ships, those numbers rot.
6. **Ordinal reuse after a task drop.** haskell-analyser originally had
   `2-457f-spike-loc-walker-haskell`. It was dropped without being
   investigated. Ordinal `2` was reused by `2-f04c-setup-python-devenv`
   added during review. This is a human-referent confusion risk, not a
   correctness problem (hash suffix is the real id).

### Crucial correction discovered mid-investigation

Initially the investigation flagged empty `<review>` blocks as schema
debt. **This was wrong.** Reading `plugins/socrates/commands/spec.md`
(Task Review Mode section, lines 472–490) revealed that `<review>` is the
human-to-`/spec` feedback channel: the reviewer writes change requests
into the block, `/spec <task-file>` processes them and regenerates
`<steps>` / `<test_steps>`, then clears the block. **An empty `<review>`
block means "reviewer had no change requests" — it is the success state,
not an unused slot.** Any redesign must preserve this mechanism.

Similarly, `depends_on` was initially critiqued for "not capturing
coupling." That was also misframed. Reading `commands/pour.md` (lines
38–72) revealed `depends_on` is pour-time machinery for topo-sorting tk
ticket creation and wiring `tk dep` edges. It is not making an
INVEST-"I" claim. That reframes the `depends_on` discussion (see session
2) but does not eliminate the smell.

### Load-bearing constraints (inviolable without re-architecture)

These all came from `docs/adrs/004-spec-ticket-namespace-separation.md`
and must be preserved by any schema change unless the ADR itself is
revisited:

1. **The `spec-read-guard.sh` PreToolUse hook is keyed on the filename
   pattern `docs/specs/<dir>/[0-9]+-*.md`.** This hook exists because a
   real bypass bug happened once (commit `bdceea8`, "guard against
   un-poured spec task implementation"). A PreToolUse hook on Read
   cannot protect sections inside a file — Read returns whole files.
   The number-prefixed file layout is load-bearing for this hook.
2. **Per-file `status:` and `ticket:` frontmatter is what makes `/pour`
   cross-run idempotent.** The cross-run `spec-task-id → tk-id` map is
   seeded from the `ticket:` field of already-poured task files. One
   file per task is load-bearing for incremental pour.
3. **`cancelled` as a terminal pre-pour state** lets an epic fully close
   without forcing every task through tk. This is the intended escape
   hatch and explains the dropped `12d0` task in the sanitization spec
   corpus.

**Implication: a full rollback to a single-file-per-spec layout is
blocked by three independent mechanical constraints.** Do not propose
it unless you are also prepared to re-architect the hook, `/pour`, and
ADR-004.

### choo-choo-ralph comparison (existence proof, not template)

Read all of `~/Projects/oss/choo-choo-ralph/docs/spec-format.md` and
`plugins/choo-choo-ralph/commands/pour.md` before session 3. The short
version: choo-choo-ralph uses a **single spec file** with `<task>`
elements and nested `<review>` tags per task. It has:

- No `depends_on:` at all. Ordering is by `priority` attribute plus
  narrative position in the file.
- No per-task `status:` frontmatter. "Review empty" = ready to pour.
- Incremental pour via a `poured: []` array in frontmatter (bead IDs
  appended after each pour; next pour skips entries already in it).
- **Spec tasks ≠ implementation tasks.** ~10 high-level slices per spec.
  `/pour` explodes each into 5–10 molecules (implementation tasks) at
  pour time. Target is 50–100 molecules per spec. See
  `pour.md:91–124` — "Spec tasks are NOT implementation tasks."

This single design choice — **planning layer above implementation
layer** — is what lets choo-choo-ralph put everything in one file. Ten
outcome-shaped slices fit comfortably in one file, read as a feature
narrative, and carry no cross-task dependency machinery because the
dependencies emerge below, at pour time.

Socrates made a different decomposition choice. `/spec`'s sizing rule
is "one task ≈ one focused commit" (`commands/spec.md:398–400`). That
collapses planning and implementation into the same layer, which
forces (a) more tasks per spec, (b) more detail per task, (c) real
cross-task dependencies, (d) per-task status transitions. The multi-file
layout is a *consequence* of that choice, not an independent design
decision.

This is the deepest finding in the investigation and it drives all
three sessions below.

### Literature touchstones (read selectively per session)

- **XP 3Cs (Card/Conversation/Confirmation, Jeffries 2001):**
  <https://ronjeffries.com/xprog/articles/expcardconversationconfirmation/>
  — A card is a placeholder for a conversation; details are meant to
  be co-created during implementation. **For agents without a
  back-channel, this assumption breaks.** Relevant to session 3.
- **Wake on INVEST + self-critique:**
  <https://xp123.com/invest-in-good-stories-and-smart-tasks/>
  <https://xp123.com/articles/all-you-need-is-invest-no/>
  — The "N" (Negotiable) only works because conversation fills in the
  gaps. Relevant to session 3.
- **Klement on Job Stories vs User Stories:**
  <https://jtbd.info/replacing-the-user-story-with-the-job-story-af7cdee10c27>
  — "As X I want Y" bakes in a prescribed action. "When [situation],
  I want [motivation], so [outcome]" moves the mechanism out of the
  frame. Relevant to session 3.
- **Shape Up (Ryan Singer / Basecamp):**
  <https://basecamp.com/shapeup/1.5-chapter-06> (Set the Level of
  Abstraction — why fat-marker sketches beat wireframes);
  <https://basecamp.com/shapeup/3.4-chapter-13> (Scopes — "to-do lists
  grow as the team makes progress");
  <https://basecamp.com/shapeup/1.4-chapter-05> (Risks and Rabbit
  Holes);
  <https://basecamp.com/shapeup/1.2-chapter-03> (Set Boundaries /
  appetite).
  **Strongest answer in the literature to "discoveries during
  implementation invalidate assumptions":** fixed time, variable scope,
  scopes discovered during execution, rabbit-hole pre-mortem at
  shaping time. Relevant to all three sessions but especially 3.
- **Declarative vs imperative Gherkin:**
  <https://cucumber.io/docs/bdd/better-gherkin/>
  <https://itsadeliverything.com/declarative-vs-imperative-gherkin-scenarios-for-cucumber>
  <https://automationpanda.com/2017/01/30/bdd-101-writing-good-gherkin/>
  — Consensus: imperative criteria rewrite whenever implementation
  changes; declarative criteria pin to business rules which are stable.
  Relevant to session 3.
- **Design by Contract (Bertrand Meyer):**
  <https://learn.adacore.com/courses/intro-to-ada/chapters/contracts.html>
  <https://thepragmaticengineer.hashnode.dev/design-by-contract-how-can-this-approach-help-us-build-more-robust-software>
  — Preconditions, postconditions, invariants. **No published ticket
  schema has been built on DbC.** Given/When/Then gestures at it;
  nobody has formalized "ticket = contract the agent verifies before
  starting and before committing." Genuine gap in the literature.
  Relevant to session 3.
- **Hidden coupling / temporal coupling (IEEE study):**
  <https://ieeexplore.ieee.org/document/7070428/>
  — Empirical study showing "degree of freedom for backlog
  prioritization is substantially restricted by interdependencies"
  that declared graphs don't capture. Relevant to session 2.
- **XP Spike:**
  <http://www.extremeprogramming.org/rules/spike.html>
  <https://framework.scaledagile.com/spikes>
  — A spike is "a small story whose output is information, not
  working code." Relevant to session 3.
- **Anthropic context engineering for agents:**
  <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
  — Tickets should be short and *point to* context, not embed it,
  because the agent needs the context window for code. Relevant to
  session 3.

### Existing Socrates files every session should read

- `CLAUDE.md` — project conventions, directive hierarchy, session discipline
- `plugins/socrates/commands/spec.md` — current `/spec` command, especially
  Design phase (lines ~369–470) and Task Review Mode (lines ~472–490)
- `plugins/socrates/commands/pour.md` — current `/pour` command, especially
  lines 38–72 on topo sort and cross-run idempotency
- `plugins/socrates/templates/task.md` — current task template
- `plugins/socrates/templates/_overview.md` — current overview template
- `docs/spec-format.md` — authoritative format reference
- `docs/adrs/003-spec-journey-merged-command.md` — why `/spec` and
  `/design` were merged into one command
- `docs/adrs/004-spec-ticket-namespace-separation.md` — the three
  load-bearing constraints listed above

---

## Session 1 — Navigation Fix via `_overview.md` Enrichment

**Reversibility:** fully reversible. Touches prose and templates only.
**Prereq:** none.
**Run this first.**

### Problem statement (seed for Delimit)

When reviewing a poured spec, the reviewer cannot see cross-task
relationships — ordering, shared contracts, shared surfaces — without
opening and comparing multiple files. The multi-file layout is
load-bearing for the security hook and pour idempotency and should not
change, but nothing in the current layout surfaces the relationships
that live across task boundaries. The ordinal prefix is a weak ordering
signal and doesn't convey *why* the order is what it is.

### What to bring into Describe

- The corpus findings above, especially the hidden-coupling examples
  (`ProcessConfig`, `.complexity.toml` schema, `NO_GOAL` sentinel,
  delimiter strings).
- The user's explicit framing: "the navigation problem is a UX issue —
  if I were using org-mode or wiki markdown in Obsidian, having links
  from the `_overview` would be more than enough."
- The fact that `_overview.md` already contains a dependency graph and
  a glossary — most of the machinery needed for the fix is already
  there, it just isn't being leaned on hard enough.

### Seeded Direction — approaches already surfaced

- **A0 status quo:** ordinal prefixes + `_overview.md` Tasks table.
  Navigation pain as observed.
- **A4 (recommended):** enrich `_overview.md` with (a) a rendered
  execution-order view (topo-sorted task list with titles, not just
  the summary table), (b) a shared-contracts section in the Glossary
  covering sentinels, config schemas, type shapes, and any other
  cross-task contract surfaces, (c) explicit markdown links between
  the overview and each task file. Update `spec.md` Design phase
  guidance to steer authors toward populating these.
- **A2 (deferrable):** add a `/spec --render <spec-dir>` subcommand
  that emits a read-only concatenated view of all task files in
  execution order. Purely additive, no format change. Consider only
  if A4 is insufficient after trying it.

### Concrete seed for Design

1. Update `plugins/socrates/templates/_overview.md` to include:
   - A `### Shared Contracts` subsection inside `### Glossary` with a
     template explaining what goes there (cross-task sentinels,
     config schemas, type shapes — anything two tasks must agree on).
   - A rendered execution-order section (bulleted or numbered, with
     links to task files) below the current Tasks summary table.
2. Update `plugins/socrates/commands/spec.md` Design phase instructions
   to:
   - Prompt the author to identify shared contracts between tasks and
     record them in the Glossary.
   - Require the rendered execution-order section to be written after
     the dependency graph is known.
3. Update `docs/spec-format.md` to document the new subsection.
4. **Do not** change the task template, the pour command, or the hook.
   This is a prose-only change.

### Acceptance contract

- A new spec created with the updated `/spec` has a non-empty
  `Shared Contracts` subsection whenever two or more tasks share a
  contract (sentinel, config, type).
- `_overview.md` links to each task file so an Obsidian-style reader
  can click through.
- Existing poured specs are not touched (this change is forward-only).

### Known risks

- Glossary fatigue: authors may not identify shared contracts at spec
  time because they haven't thought about them yet. Mitigation: the
  `/spec` command should prompt explicitly during Design research,
  and the prompt should include examples drawn from the corpus.
- Overfitting to one reader: the Obsidian-style link hygiene assumes a
  reader that resolves wiki links. Plain markdown in a terminal still
  works, it's just less fluid.

### Sources

- Corpus: `~/Projects/self/project-status-sync/docs/specs/` (all five
  specs). The `NO_GOAL` example is in
  `archive/2026-04-06-output-abstraction-level/d2ec-handoff-prompt-goal.md`
  and `3bd5-process-no-goal-wiring.md`.
- `docs/spec-format.md` — current overview section structure.
- `plugins/socrates/commands/spec.md` Design phase (lines ~369–470).

---

## Session 2 — `depends_on` Smell Diagnosis

**Reversibility:** mostly reversible. Touches `/pour` and task template
frontmatter but not the hook or file layout.
**Prereq:** session 1 helpful but not required.

### Problem statement (seed for Delimit)

The `depends_on:` field in task frontmatter is doing two jobs and
neither well: (a) mechanical topo-sort input for `/pour` to wire
`tk dep` edges between tickets with genuine artifact dependencies,
and (b) an authoring-time sequencing hint from the human reviewer to
ralph about execution order. Empirically in the corpus, most edges in
the graph encode job (b) — "I imagine ralph works through these in this
order" — not job (a). Expressing sequencing preferences as graph edges
gives them false precision, makes specs look more constrained than
they are, and produces edges that rot as discoveries invalidate the
imagined ordering.

### What to bring into Describe

- **Empirical evidence from the corpus.** In
  `2026-04-07-haskell-code-analyser`, the graph is `6 → [1,2]`,
  `7 → [6]`, `8 → [3,4,5,7]`. Only some of these are real artifact
  dependencies. Task 6 genuinely requires task 2 (walker needs
  runtime). Task 7 genuinely requires task 6 (wiring needs the
  binary). Most others are sequencing preferences.
- **Replay spec is almost linear `1→2→3→4→5→6`.** That shape is
  suspicious: truly linear DAGs often mean the author is encoding
  narrative order, not dependency.
- **`depends_on` is actually used by `/pour`.** Read `pour.md:38–72`
  carefully before diagnosing — the topo sort exists because `tk dep`
  edges between newly-created tickets need a valid creation order.
  The mechanical job is real; it just may not need a full graph to
  do it.
- **choo-choo-ralph uses `priority` + file order with no graph** and
  pours successfully. Existence proof that the machinery isn't
  mandatory at all granularities (they run at slice granularity, see
  session 3).
- **INVEST "Independent" is aspirational not observable.** IEEE study
  on multi-team backlogs (linked above) finds declared graphs
  systematically understate real coupling. The current `depends_on`
  field isn't trying to capture coupling in the INVEST sense, but
  readers may mistake it for one.

### Seeded Diagnose — hypotheses worth testing

- **H1:** most edges in current specs are sequencing hints, not
  artifact dependencies. *Test by re-reading each edge in the corpus
  and asking: "would task B literally fail to compile, run, or merge
  if task A were not done first?"* If yes → real dep. If no →
  sequencing hint.
- **H2:** the sizing rule inflates the graph. At commit-sized tasks,
  tasks share file surfaces more often, producing defensive edges.
  At slice-sized tasks (see session 3), true dep edges thin out.
- **H3:** the field name `depends_on` biases authors toward over-use.
  If the field were named `after:` (soft) alongside a separate
  `requires:` (hard), authors might use them differently.

### Seeded Direction — approaches to compare

- **A0 status quo:** single `depends_on:` field, same machinery.
- **A1 split the field:** introduce `requires: []` (genuine artifact
  deps — pour uses these for `tk dep` edges) and `after: []` (soft
  sequencing hints — pour uses these for topo sort order but does
  not wire them as tk dep edges). Requires pour rewrite.
- **A2 drop `depends_on` entirely:** use `priority:` + narrative file
  order (lexicographic ordinal prefix) as the pour ordering. Requires
  pour rewrite and loss of mechanical tk dep wiring — authors would
  need to record real deps in prose or via a different mechanism.
- **A3 keep `depends_on` but redefine it** to mean "artifact
  dependency only" and add prose guidance in `spec.md` Design phase
  telling authors not to encode sequencing preferences as edges.
  Minimal mechanical change, maximum burden on author discipline.
- **A4 compute deps from `touches:`:** introduce a `touches:` field
  (behavioral surfaces or file globs) and let pour derive the
  dependency graph from overlap. This is the `touches:` idea from
  the earlier investigation. Most ambitious, probably over-engineered.

### Known risks

- **Cycle detection lives in pour.** Whatever solution you pick must
  still let pour detect cycles before creating tk tickets.
- **tk dep edges are observable in tk, not just in the spec.** Once
  an edge is wired into tk, changing the spec semantics post-pour
  does not unwire it. Any schema change is forward-only.
- **The sizing rule investigation (session 3) may make this moot.**
  If sizing rises to slice level, most graphs flatten and `depends_on`
  may shrink to empty lists without any redesign. Consider running
  session 3 first if the two feel entangled. **But** — the smell
  exists at current sizing too, and diagnosing it on its own merits
  is valuable regardless.

### Sources

- `plugins/socrates/commands/pour.md` lines 38–72 (topo sort and
  cross-run id map)
- `~/Projects/self/project-status-sync/docs/specs/2026-04-07-haskell-code-analyser/_overview.md`
  — explicit dependency graph for empirical analysis
- `~/Projects/oss/choo-choo-ralph/plugins/choo-choo-ralph/commands/pour.md`
  — no-depends_on alternative
- IEEE study on backlog dependencies:
  <https://ieeexplore.ieee.org/document/7070428/>
- Temporal coupling writeup:
  <https://www.javacodegeeks.com/2026/03/temporal-couplingthe-hidden-dependency-that-breaks-systems.html>

---

## Session 3 — Sizing Rule Investigation

**Reversibility:** least reversible of the three. Touches `spec.md`
Design phase instructions, task template, `/pour` semantics, and the
shape of every future spec. May touch the hook if the layout changes.
**Prereq:** sessions 1 and 2 provide useful context but are not
blocking. Running 3 first will subsume the other two and probably
swallow them; running 3 last is the cleaner separation.

### Problem statement (seed for Delimit)

The current `/spec` Design phase sizing rule is "one task ≈ one
focused commit" (`commands/spec.md:398–400`). This collapses planning
and implementation into the same layer. Empirically, it produces tasks
that drift toward procedural recipes, pin to implementation mechanics
(line numbers, parameter order, type shapes), and carry brittle
assumptions that rot when mid-implementation discoveries invalidate
them. The review loop (`<review>` blocks, regeneration via `/spec
<task-file>`) iterates on this brittle content rather than on durable
outcome contracts. Procedural drift is observable in the corpus:
archived specs are outcome-focused (task titles + 3 terse steps),
current specs are procedural (15 sub-steps a–l inside one task). The
drift got worse as `/spec`'s Design instructions became more explicit
about referencing "actual file paths and function names from the
Context research" (`spec.md:428`).

### What to bring into Describe

All of the shared context above, plus:

- **The procedural drift is observable over time** in the corpus, not
  just at one point. Archive → current is a monotone trend toward
  more mechanical detail per task.
- **choo-choo-ralph's two-layer decomposition is the strongest
  counter-example.** Spec tasks are ~10 coarse feature slices; `/pour`
  explodes each into 5–10 molecules at pour time. Total molecules per
  spec: 50–100. Per-task file is a narrative slice, not a recipe.
  Read `~/Projects/oss/choo-choo-ralph/plugins/choo-choo-ralph/commands/pour.md`
  lines 91–124 especially.
- **The literature agrees** that procedural/imperative task specs are
  brittle (Gherkin consensus, Shape Up, Cohn, DbC). The sources above
  cover this. The most load-bearing argument is Shape Up's "to-do
  lists grow as the team makes progress" — the answer in the
  literature is fixed appetite + variable scope + scopes discovered
  during execution, not better up-front decomposition.
- **The review loop preserves the conversation channel that XP's 3Cs
  assumes** — but it iterates on the wrong content shape. If `<steps>`
  are procedural, reviewer feedback is "change step 3 to X." If
  `<steps>` are outcome-shaped, reviewer feedback is "the postcondition
  should also cover Y." The loop is more valuable with declarative
  content.

### Load-bearing constraints (do not violate)

- **Spec-read-guard hook pattern `docs/specs/<dir>/[0-9]+-*.md`** must
  keep a referent. Any layout change must leave the hook something to
  key on, OR rework the hook as part of the session.
- **`/pour` cross-run idempotency via per-file `ticket:` field** must
  be preserved OR replaced with an equivalent (e.g., choo-choo-ralph's
  `poured: []` array approach).
- **Per-task incremental approval** (`status: draft → approved →
  poured`) is what made the user split files originally. Any layout
  change that loses this re-introduces the original pain the split
  was solving.
- **ADR-004 namespace split** must hold. Spec ids and ticket ids stay
  in different shapes so the `commit-msg.sh` hook can tell them apart
  and the `spec-read-guard.sh` hook has a referent.

### Seeded Direction — approaches to compare

Build a decision matrix. Candidate approaches:

- **A0 status quo:** one task ≈ one commit, multi-file, procedural
  `<steps>` allowed.
- **A1 collapse to single file (REJECTED by ADR-004 constraints):**
  listed only to document why it is not viable. Breaks the hook,
  breaks pour idempotency, loses incremental approval.
- **A2 rename `<steps>` → `<outcome>` / `<postconditions>`:**
  minimal change, prose-only, but the sizing rule still pulls authors
  toward implementation detail and the tag rename fights the pull
  without winning.
- **A3 raise sizing one level — "one task ≈ one outcome slice":**
  keep multi-file, keep all the mechanical constraints, but a spec
  task becomes a slice (outcome + verification contract) that may
  span multiple commits. The implementer (ralph or a human) decides
  how many commits. `<steps>` are naturally outcome-shaped because
  that's all the level of abstraction can hold. Reviewer sees
  fewer, shorter files per spec (~5, not 10). This is the
  recommendation from the investigation.
- **A4 full choo-choo-ralph two-layer model:** spec tasks are
  high-level slices, `/pour` does runtime decomposition into
  implementation tasks. Retires `depends_on` at the spec level.
  Biggest re-architecture. May require reworking the hook and
  `/pour` from scratch.

Criteria rows to consider:

- Reduces procedural drift in `<steps>`
- Reviewer sitting ergonomics (how much to read at once)
- Preserves ADR-004 constraints (hook, pour, namespace)
- Preserves review loop (`<review>` regeneration)
- Changes required to `/spec` Design phase instructions
- Changes required to `/pour`
- Changes required to task template
- Compatibility with existing poured specs
- Alignment with literature (Shape Up, DbC, Klement)
- Authoring effort per spec

### Seeded Design notes (if A3 is chosen)

The investigation converged on A3 as the most likely winner. If that
holds, the Design phase will need to address:

- **Update `commands/spec.md`** Design phase sizing rule from "one
  task ≈ one focused commit" to "one task ≈ one outcome slice."
  Provide examples of both shapes drawn from the corpus (archived
  specs are closer to slice-shaped; current specs are commit-shaped).
- **Update the task template** body to guide authors toward outcome
  statements. Options considered:
  - Rename `<steps>` → `<outcome>` and `<test_steps>` → `<verification>`.
  - Keep the tag names (to avoid breaking `/pour` parsing) but change
    the template body text to model outcome-shaped content.
  - Introduce explicit `<preconditions>` / `<postconditions>` /
    `<invariants>` sub-tags inside `<steps>` as a DbC formalization.
- **Shared contracts live in `_overview.md` Glossary** (from session
  1) — task bodies reference glossary terms instead of restating
  contracts. This is how the `NO_GOAL` sentinel and `.complexity.toml`
  schema would have been caught.
- **`/pour` may not need to change** if slice-sized tasks still map
  1:1 to tk tickets. The implementer breaks a slice into commits
  during execution, not at pour time. This is the cheapest version of
  A3 — no pour changes.
- **Alternatively, A3.5:** slice-sized spec tasks, and `/pour` creates
  an "epic-sized" tk ticket per slice that ralph decomposes at
  dispatch time. More complex, but closer to choo-choo-ralph's model
  without fully adopting it.

### A potentially original contribution

**No published ticket schema has been built on Design-by-Contract.**
Given/When/Then gestures at it (pre/post); Cohn's AC vs DoD gestures
at it (postcondition vs invariants); nobody has formalized "ticket =
contract the agent verifies before starting and before committing."
If A3 chooses to formalize `<preconditions>` / `<postconditions>` /
`<invariants>` as first-class sub-structures, Socrates would be the
first schema the investigation found that commits to that framing
explicitly. Worth considering whether that's a direction worth
betting on.

### Known risks

- **Slice-sized tasks may be too vague to act on.** The risk is the
  mirror of procedural drift: too-procedural tasks are brittle; too-
  vague tasks leave the implementer guessing. A3 must include
  concrete guidance in `spec.md` Design phase on what a slice looks
  like and how to know when one is small enough.
- **Existing poured specs become stylistically inconsistent** with
  new ones. This is cosmetic only — the poured specs are frozen
  artifacts — but reviewers may find the shift jarring.
- **The review loop needs to work with outcome-shaped content.**
  Currently the review loop regenerates `<steps>` and `<test_steps>`
  based on human feedback. If the shape changes, verify that the
  feedback loop still composes (e.g., "the postcondition should also
  cover Y" must be a valid review comment the loop can act on).
- **Ralph's execution behavior may need to change.** Currently ralph
  reads a poured ticket body (copied from `<steps>` / `<test_steps>`)
  and treats it as instructions. If those become outcome contracts,
  ralph needs to decompose into commits itself. That may require
  updating `RALPH.md` or the commit discipline expected of ralph.
  **This is the most under-investigated risk and is the best
  candidate for a spike inside the session.**

### Sources

- `plugins/socrates/commands/spec.md` Design phase (especially
  `spec.md:398–400` sizing rule)
- `plugins/socrates/templates/task.md` — current task template
- Corpus: procedural drift comparison between archive and current
  specs in `~/Projects/self/project-status-sync/docs/specs/`
- `~/Projects/oss/choo-choo-ralph/docs/spec-format.md` and
  `~/Projects/oss/choo-choo-ralph/plugins/choo-choo-ralph/commands/pour.md`
  (especially lines 91–124 on spec tasks vs implementation tasks)
- Shape Up chapters linked above — especially Ch 13 (Scopes) and
  Ch 6 (Set the Level of Abstraction)
- Klement on Job Stories (linked above)
- Declarative Gherkin sources (linked above)
- Meyer on Design by Contract (linked above)
- XP 3Cs (Jeffries, linked above) — the conversation assumption that
  breaks for agents without a back-channel
- Anthropic context engineering (linked above)

---

## Suggested Order

1. **Session 1 first (navigation fix).** Cheap, reversible, no
   dependencies. Addresses the user's most immediate pain. Exercising
   the updated overview template on one real spec will surface
   whether session 2 and 3 need to adjust.
2. **Session 2 second (`depends_on` smell).** Narrower than session 3,
   but the diagnosis may inform how session 3 handles sequencing in
   slice-sized tasks.
3. **Session 3 last (sizing rule).** Biggest, least reversible,
   highest-leverage. Doing it last means sessions 1 and 2 have
   already validated the surrounding machinery and you're not
   changing everything at once.

**Alternative ordering to consider:** run session 3 first if the
procedural drift is actively causing bugs in current work. The other
two sessions will then compose with whatever session 3 decides. This
is higher risk (session 3 is the biggest change) but higher reward.

## Meta-note for future agents running these sessions

The investigation that produced this document was thorough but lives
in a conversation transcript that won't be available when you run the
sessions. If you find yourself re-asking questions that this document
already answers, something is wrong with the document, not with you —
update it. If you find yourself in disagreement with a claim in this
document, trust your fresh reading of the corpus over this document's
summary. The corpus is the ground truth; this document is a lossy
compression of one pass through it.
