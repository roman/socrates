---
title: <spec name>
created: <date>
epic:
archived:
delimit_approved: false
---

<!-- Voice and structure follow plugins/socrates/voice.md. -->

## Describe [DRAFT]

<Situation description. What is happening? What is the context?
No interpretation, no proposed solutions.>

## Diagnose [DRAFT]

<What is the real problem? Hypotheses tested. Diagnosed items
identified. "We don't have feature X" is never a valid problem
statement.>

### Diagnosed items

<!--
Each item below carries a typed prefixed identifier (RC1, NC1, AC1,
...) so subsequent phases can reference it precisely. The decision
matrix in Direction tags every row with the item ID it traces to,
or with [ID] for rows that aren't tied to a specific diagnosed
item (implementation concerns: effort, risk, reversibility).

Each item gets a stable anchor (e.g., <a id="rc1"></a>) so links
from the matrix don't break when headings are reworded.
-->

#### Legend

| Prefix | Name | Meaning |
| --- | --- | --- |
| **RC** | Root Cause | A real reason the problem exists. Each one needs to be solved (or deliberately left out) by the chosen approach. |
| **NC** | Non-Cause | Looked like a cause; turned out not to be. Listed so approaches don't get credit for "solving" it. |
| **AC** | Adjacent Constraint | A rule from outside this spec that we have to respect. Approaches are judged on whether they preserve it. |
| **ID** | Implementation Detail | A practical concern (effort, risk, reversibility, time-to-value) not tied to a specific diagnosed item. Used to prefix matrix rows for these criteria. |

<!-- Items go here, e.g.:

<a id="rc1"></a>
#### RC1 — <short title>

<Explanation of what the root cause is and how it manifests.>

<a id="nc1"></a>
#### NC1 — <short title>

<Explanation, with a clear "Implication for Direction" line.>

-->

## Delimit [DRAFT]

<Crisp problem statement: unmet user objectives and their causes.
1-2 sentences. If you can't write this clearly, you're not ready
to proceed.>

## Direction [DRAFT]

### Approaches

<!--
Approaches use sequential, predictable naming: A1, A2, A3, ...
Don't number by phase or status. Don't leave gaps when reordering.
A1 is always status quo. Each approach gets a short tag describing
its center of gravity.
-->

<Enumerated approaches, including status quo as A1.>

### Decision Matrix

<!--
Render the matrix in chat first, refine, then persist. Use one
table. Each row's "Criterion" cell prefixes the criterion text
with a typed link, e.g. [[RC1](#rc1)] for criteria that trace to
a diagnosed item, or [ID] for implementation concerns. The legend
in Diagnose explains the prefixes.

Cells use 🟢🟡🔴 for ranked aspects, ⚪ for not-applicable, and
a brief explanation alongside the indicator.
-->

<Decision matrix.>

### Chosen Approach

<!--
The chosen approach and the rationale go in a blockquote so they
stand out visually and are easy to scan when re-reading the spec.

> **Chosen: A2 — <approach name>.** <One-sentence rationale tying
> back to the diagnosed items.>

The blockquote may extend across multiple lines if the rationale
needs more than one sentence.
-->

<Chosen approach, in a blockquote.>

### Use Cases

<What users could accomplish if the problem were solved. Focus on
intentions, not implementation.>

| Actor | Intent | Outcome |
| --- | --- | --- |

## Design [DRAFT]

### Context

<Codebase patterns, integration points, conventions discovered
during research. Added by parallel sub-agents.

When an Adjacent Constraint (AC) from Diagnose dictates a specific
encoding (where, how, in which surface), call that out in this
section.>

### Tasks

<Summary of generated task files and their relationships.>

### Execution Order

<Topo-sorted bulleted narrative of task files. Each bullet is a
clickable link to the task file plus one sentence explaining why
this task comes next — its purpose in the sequence, not a restatement
of its title.>

### Glossary

<Terms used consistently throughout this spec. Definitions that
matter for implementation.>

#### Shared Surfaces

<Narrative bulleted list naming cross-task touchpoints by surface
only — a file, a type name, a config key, a sentinel. Each bullet
names the surface, links to the tasks that touch it, and says in
one sentence why the coupling matters.

One linked task per entry may be annotated `(surface owner)` — the
task that creates or owns that surface; other linked tasks are
readers and follow it. Absence of any marker means the surface is
a mutual read and contributes no ordering. Multiple owners are
allowed but rare. The marker must be written explicitly on the
link itself so it survives link reordering during refinement.

Shapes, literal values, type definitions, and concrete config keys
do NOT belong here — only the surface name.>

## Technical Addendum

<!--
This section holds concrete file paths, line numbers, exact
identifier strings, and the quantitative basis for claims in the
prose above. The spec body omits these to stay readable; this
addendum is where they live.

Organize by topic, not chronologically. Use A.1, A.2, ... as
section labels. Each label gets a stable anchor (e.g.,
<a id="a1"></a>) so the body can reference them with anchored
links: "(See [Addendum A.3](#a3) for the catalog.)"

Example shape:

<a id="a1"></a>
### A.1 — <topic>

<Files, paths, identifiers, evidence.>

<a id="a2"></a>
### A.2 — <topic>

...
-->
