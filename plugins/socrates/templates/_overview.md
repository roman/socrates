---
title: <spec name>
created: <date>
epic:
archived:
delimit_approved: false
---

## Describe [DRAFT]

<Situation description. What is happening? What is the context?
No interpretation, no proposed solutions.>

## Diagnose [DRAFT]

<What is the real problem? Hypotheses tested. Root causes identified.
"We don't have feature X" is never a valid problem statement.>

## Delimit [DRAFT]

<Crisp problem statement: unmet user objectives and their causes.
1-2 sentences. If you can't write this clearly, you're not ready
to proceed.>

## Direction [DRAFT]

### Approaches

<Enumerated approaches, including status quo.>

### Decision Matrix

<If non-trivial choice. Problem statement in header, approaches as
columns, criteria as rows, 🟢🟡🔴⬜ aspects.>

### Chosen Approach

<Which approach and why.>

### Use Cases

<What users could accomplish if the problem were solved.
Focus on intentions, not implementation.>

## Design [DRAFT]

### Context

<Codebase patterns, integration points, conventions discovered
during research. Added by parallel sub-agents.>

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
