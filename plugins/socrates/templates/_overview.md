---
# socrates_format: spec-file shape version. Absent means 1.
socrates_format: 2
title: <spec name>
created: <date>
tags: []
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
...) so subsequent phases can reference it precisely.

In Direction, every decision-matrix row is tagged with the
diagnosed-item ID it traces to; rows tied to no specific item use the
[ID] prefix instead (implementation concerns: effort, risk,
reversibility). See the Legend below.

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

<!--
Add `### Solution Map` when a small diagram explains the chosen approach more
clearly than prose. State the question it answers and keep it to roughly 5-8
nodes or participants. Use MermaidJS. Omit the subsection when it would only
repeat the text.
-->

### Context

<Only the codebase patterns, integration points, and conventions that
materially affect the design and are not already clear from Direction or the
solution map.

When an Adjacent Constraint (AC) from Diagnose dictates a specific
encoding (where, how, in which surface), call that out in this
section.>

### Tasks

<Topo-sorted view of the generated task files. Link the task identity in the
first column, use its title as the Outcome when sufficient, and render `deps:`
from task frontmatter. Do not create a second dependency source.>

| Task | Outcome | Depends on | Priority |
| --- | --- | --- | --- |

<!--
Add `### Glossary` only for terms whose meaning is specific or ambiguous in
this spec.
-->

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
