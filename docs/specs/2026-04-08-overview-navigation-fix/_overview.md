---
title: Overview Navigation Fix
created: 2026-04-08
epic: soc-nrtu
archived:
delimit_approved: true
---

## Describe [COMPLETE]

**Situation.** When reviewing a poured spec in Socrates, the reviewer must open
and compare multiple task files to see cross-task relationships (execution
order, shared contracts, shared surfaces). Holding several task files open at
once is cognitively overwhelming — the reviewer loses place, loses the
through-line, and cannot see the spec as a whole. The multi-file task layout
under `docs/specs/<spec>/[0-9]+-*.md` is fixed by other constraints and cannot
change.

**What is known.**

- `_overview.md` already contains a Tasks summary table, a dependency graph,
  and a Glossary — most of the machinery needed to surface cross-task
  relationships is already present, just under-used.
- Real cross-task couplings exist in practice but are invisible from the
  overview — e.g., a type shape shared across sibling tasks, a config schema
  split between a reader task and a writer task, a sentinel-value contract
  between a producer and a consumer, or a string/format constant chosen in
  one task and consumed implicitly by another. None of these surface in the
  current Tasks table or dependency graph.
- Ordinal prefixes (`1-`, `2-`, …) give a weak ordering signal but do not
  convey *why* the order is what it is.
- User framing: "the navigation problem is a UX issue — if I were using
  org-mode or wiki markdown in Obsidian, having links from the `_overview`
  would be more than enough."

**What is not known.**

- Whether authors, prompted at Design time, will reliably identify shared
  contracts they haven't yet implemented.
- Whether plain-markdown rendering (terminal, GitHub) will remain fluid
  enough without an Obsidian-style link resolver, or whether this optimizes
  for one reader.

**Who is affected.** Humans reviewing poured specs (primary); future agents
reading `_overview.md` to orient before working a ticket (secondary). Authors
writing specs bear the added Design-phase work of identifying shared contracts.

## Diagnose [COMPLETE]

**Hypotheses considered.**

- **H1 — The overview is under-used, not under-designed.** `_overview.md`
  already has a Tasks table, dependency graph, and Glossary, but these
  sections are thin: no rendered execution-order view, Glossary rarely
  captures cross-task contracts, no links to task files.
  **Status: Confirmed.** The machinery exists and is observably under-used
  in the corpus.

- **H2 — The root cause is the absence of a single viewing surface.**
  The multi-file layout forces the reviewer to hold several task narratives
  in working memory simultaneously. No artifact today concatenates or
  cross-links them, so cognitive load scales with task count.
  **Status: Confirmed.** This is the user's reported pain
  ("opening multiple files at once to review becomes overwhelming") and
  it explains why structural tweaks inside individual task files would
  not help.

- **H3 — Ordinal prefixes overload one signal with two jobs (id + order)
  and don't explain *why* the order is what it is.**
  **Status: Out of scope.** This is a separate problem. Even with perfect
  ordinal semantics, the cognitive-load issue would remain.

- **H4 — Shared contracts have no home.** Cross-task contracts (types,
  sentinels, config schemas, format constants) live in neither task file
  and are not required by the template.
  **Status: Collapsed into H1.** `_overview.md` *is* the right home; the
  issue is that the template and `/spec` Design phase don't ask authors
  to put them there.

**Root causes.**

1. `_overview.md` does not provide a single viewing surface that holds
   the spec's through-line. It summarizes but does not narrate; it lists
   tasks but does not link to them; it has a Glossary but doesn't
   prompt authors to populate it with cross-task contracts.
2. Consequently, the reviewer must reconstruct the through-line by
   opening individual task files in parallel, which exceeds working
   memory.

**Symptoms vs causes.** The visible symptom is "multi-file review is
overwhelming." The cause is not the multi-file layout itself (which is
fixed and acceptable) but the absence of an overview that absorbs the
cross-task reading work on the reviewer's behalf.

## Delimit [APPROVED]

Reviewers of poured Socrates specs cannot hold the spec's through-line in
working memory because `_overview.md` does not surface execution order,
cross-task contracts, or links to individual task files — forcing them to
open and compare multiple task files in parallel.

## Direction [COMPLETE]

### Approaches

- **A0 — Status quo.** Keep `_overview.md` as-is: summary table, dependency
  graph, sparse Glossary. Multi-file review pain unchanged.
- **A1 — Enrich `_overview.md` (prose-only).** Add three things:
  1. A rendered **execution-order narrative** — a topo-sorted bulleted list
     below the Tasks table, each line linking to a task file and saying
     *why* this task comes next (one sentence of purpose, not a restatement
     of the title).
  2. A **Shared Surfaces** subsection under Glossary — a narrative list of
     cross-task touchpoints named by surface only (no shapes, no literal
     values, no type definitions). Each bullet names the surface, links to
     the tasks that touch it, and says one sentence about why the coupling
     matters.
  3. **Explicit markdown links** from the overview to each task file
     throughout (Tasks table IDs become clickable; execution-order items
     and Shared Surfaces entries are already links).

  Plus: update `/spec` Design phase instructions to prompt for shared
  surfaces during research, and update `docs/spec-format.md` to document
  the new subsection. No changes to task template, `/pour`, or the
  read-guard hook.
- **A2 — `/spec --render <spec-dir>` subcommand.** New command emitting a
  read-only concatenated view of all task files in execution order.
  Purely additive, no format change. Deferred: introduces a second source
  of truth and staleness risk.

### Decision Matrix

**Problem:** Reviewers of poured Socrates specs cannot hold the spec's
through-line in working memory because `_overview.md` does not surface
execution order, cross-task contracts, or links to individual task files.

| Criteria | A0 Status Quo | A1 Enrich `_overview.md` | A2 `/spec --render` |
|---|:---:|:---:|:---:|
| Solves the problem | 🔴 Pain unchanged | 🟢 Overview becomes the through-line | 🟡 Solves load, but output is a separate artifact |
| Scope of change | ⬜ None | 🟢 Prose + template only | 🔴 New command + render logic |
| Reversibility | ⬜ N/A | 🟢 Fully reversible | 🟡 New surface to maintain |
| Touches hook / pour / task template | ⬜ No | 🟢 No | 🟢 No |
| Staleness risk | ⬜ N/A | 🟡 Author keeps overview current (already expected) | 🔴 Generated view stale unless regenerated |
| Author effort at spec time | 🟢 None added | 🟡 Must name shared surfaces during Design | 🟢 None (generated) |
| Reader ergonomics | 🔴 N buffers | 🟢 One file, narrative + links | 🟡 Flat concat loses index role |
| Fit with "Obsidian-style links" framing | 🔴 Misses | 🟢 Direct match | 🟡 Orthogonal |
| Compatibility with existing specs | 🟢 n/a | 🟢 Forward-only | 🟢 Forward-only |

### Chosen Approach

**A1 — Enrich `_overview.md` (prose-only).**

A1 distinguishes on *solves the problem*, *reader ergonomics*, and *fit with
user framing*. Its one yellow — author effort during Design — is inherent
to moving shared-surface identification upstream, and is small: the specer
already knows the decomposition, so naming the shared surfaces is
derivative of that work.

**Considered and rejected within A1:** a fuller "Shared Contracts" variant
that would record type shapes, literal sentinel values, and config keys.
Rejected as overspecification — the specer knows less than the implementer
about the concrete shape of artifacts, so pinning shapes at spec time
creates rot and boxes the implementer in. Shared Surfaces names the
coupling without committing to its shape; nothing in the table can be
falsified by implementation.

**A2 deferred.** A2 remains available as a follow-up only if A1 proves
insufficient in practice.

### Use Cases

| Objective (I wish I could...) | How |
|---|---|
| ...open a single file and understand the spec's through-line without opening any task file | _TBD_ |
| ...click from the overview to any task file | _TBD_ |
| ...see at a glance which surfaces (files, types, config, sentinels) are shared across tasks | _TBD_ |
| ...read tasks in execution order as a narrative, not as a table | _TBD_ |
| ...be prompted, while authoring a spec, to identify shared surfaces I might otherwise leave implicit | _TBD_ |

## Design [COMPLETE]

### Context

The change surface is three files in this repo:

- `plugins/socrates/templates/_overview.md` — the overview template
  that every new spec starts from. Currently has sections for Describe,
  Diagnose, Delimit, Direction, and Design; Design contains Context,
  Tasks, and Glossary subsections. No Execution Order section, no
  Shared Surfaces.
- `plugins/socrates/commands/spec.md` — Step 7 (Design Phase) drives
  codebase research and task decomposition. Currently prompts for
  integration points and conventions but not for cross-task surfaces.
- `docs/spec-format.md` — authoritative format reference. The
  `## Design` block lists Context / Tasks / Glossary as subsections.

No changes needed to the task template, `/pour`, the read-guard hook,
or any existing poured spec. All changes are forward-only and
prose-only.

### Tasks

- **[1-2435 — Add Execution Order and Shared Surfaces sections to overview template](./1-2435-overview-template-sections.md)**
  (priority 0, documentation)
- **[2-d7a7 — Update /spec Design phase to produce Execution Order and Shared Surfaces](./2-d7a7-spec-design-phase-instructions.md)**
  (priority 1, documentation)
- **[3-e3ea — Document Execution Order and Shared Surfaces in spec-format.md](./3-e3ea-spec-format-doc.md)**
  (priority 2, documentation)

### Execution Order

1. **[1-2435 — Add Execution Order and Shared Surfaces sections to overview template](./1-2435-overview-template-sections.md)** — anchors the change by adding the two new placeholders to the template; every downstream reference to these sections assumes this shape exists.
2. **[2-d7a7 — Update /spec Design phase to produce Execution Order and Shared Surfaces](./2-d7a7-spec-design-phase-instructions.md)** — teaches the `/spec` command to fill the new sections the template now exposes, and establishes the "name the surface, not the shape" rule authors must follow.
3. **[3-e3ea — Document Execution Order and Shared Surfaces in spec-format.md](./3-e3ea-spec-format-doc.md)** — mirrors the template and command changes in the authoritative format reference so readers discovering the format outside `/spec` find the same shape documented.

Tasks 2 and 3 share only task 1 as a prerequisite and may run in
parallel once task 1 is merged.

### Glossary

**Execution Order narrative** — a topo-sorted bulleted list inside
`_overview.md` where each bullet is a link to a task file and one
sentence explaining *why* that task comes next (not a restatement of
the title). Complements the Tasks list.

**Shared Surface** — a cross-task touchpoint named by surface only:
a file, a type name, a config key, or a sentinel value that two or
more tasks both rely on. Recorded in `#### Shared Surfaces` under
Glossary.

**Rot-avoidance rule** — Shared Surfaces entries must not record
type shapes, literal values, or concrete config keys. Only the
surface name and the tasks that touch it. Shapes are the
implementer's job to discover; pinning them at spec time creates
stale content and boxes the implementer in.

#### Shared Surfaces

- **`plugins/socrates/templates/_overview.md`** is the anchor touched
  by [1-2435](./1-2435-overview-template-sections.md); tasks
  [2-d7a7](./2-d7a7-spec-design-phase-instructions.md) and
  [3-e3ea](./3-e3ea-spec-format-doc.md) reference the sections added
  there, so if task 1 renames a section, 2 and 3 must follow.
- **The phrase "Shared Surfaces" itself** is a naming contract shared
  across [1-2435](./1-2435-overview-template-sections.md),
  [2-d7a7](./2-d7a7-spec-design-phase-instructions.md), and
  [3-e3ea](./3-e3ea-spec-format-doc.md) — template, command, and
  format doc must all use the same heading and the same rot-avoidance
  wording so a reader moving between files sees one concept, not three.
