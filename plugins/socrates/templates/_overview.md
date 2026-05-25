---
title: <spec name>
created: <date>
tags: []
epic:
archived:
delimit_approved: false
review_mode: false # gates post-merge review loop; see RALPH.md § Review Mode
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
...) so it can be referenced as vocabulary in discussion and the
decision matrix.
-->

#### Legend

| Prefix | Name | Meaning |
| --- | --- | --- |
| **RC** | Root Cause | A real reason the problem exists. |
| **NC** | Non-Cause | Looked like a cause; turned out not to be. Limit to 2-3. |
| **AC** | Adjacent Constraint | A rule from outside this spec that we must respect. |
| **ID** | Implementation Detail | Effort, risk, reversibility — not tied to a diagnosed item. |

<!-- Items go here, e.g.:

#### RC1 — <short title>

<Explanation of what the root cause is and how it manifests.>

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
Render the matrix in chat first, refine, then persist. Each
criterion should trace to a diagnosed item using the prefix as
vocabulary (e.g., "Addresses RC1"). Use [ID] for implementation
concerns.

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

#### Files touched by multiple tasks

<List files that more than one task will modify:

- `src/middleware/auth.ts` — Task 1, Task 3
- `src/api/routes.ts` — Task 2, Task 4
>

#### Dependencies

<Explicit task ordering using arrow notation:

Task 1 -> Task 3
Task 2 -> Task 4

Arrow reads "must complete before." Only document dependencies
that aren't obvious from file overlap.>

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
