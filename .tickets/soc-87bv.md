---
id: soc-87bv
status: closed
deps: []
links: []
created: 2026-04-09T02:20:05Z
type: task
priority: 0
assignee: ralph
parent: soc-nrtu
tags: [documentation]
---
# Add Execution Order and Shared Surfaces sections to overview template

Spec: docs/specs/2026-04-08-overview-navigation-fix/1-2435-overview-template-sections.md

## Steps
1. Edit `plugins/socrates/templates/_overview.md`.
2. Below the existing `### Tasks` placeholder inside `## Design [DRAFT]`, add a new `### Execution Order` subsection with a placeholder comment describing what goes there: a topo-sorted bulleted narrative of task files, each bullet a clickable link to the task file plus one sentence of purpose (why this task comes next), not a restatement of the title.
3. Inside `### Glossary`, add a `#### Shared Surfaces` subsection with a placeholder comment describing what goes there: a narrative bulleted list naming cross-task touchpoints by surface only (e.g. a file, a type name, a config key, a sentinel). Each bullet names the surface, links to the tasks that touch it, and says in one sentence why the coupling matters. Explicitly note in the placeholder that shapes, literal values, type definitions, and concrete config keys do NOT belong here — only the surface name.
4. Keep all other sections of the template unchanged.

## Verification
- `plugins/socrates/templates/_overview.md` contains `### Execution Order` under `## Design [DRAFT]`, positioned between `### Tasks` and `### Glossary`.
- `### Glossary` contains a `#### Shared Surfaces` subsection.
- Placeholder text for both sections explains what goes there AND what does not (for Shared Surfaces: no shapes, no literal values).
- No other template sections changed.

