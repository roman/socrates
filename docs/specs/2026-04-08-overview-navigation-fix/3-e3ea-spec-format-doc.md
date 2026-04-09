---
id: 3-e3ea-spec-format-doc
status: poured
priority: 2
category: documentation
depends_on: [1-2435-overview-template-sections]
ticket: soc-zelc
---

# Document Execution Order and Shared Surfaces in spec-format.md

<steps>
1. Edit `docs/spec-format.md`.
2. In the `## Overview File → Sections and Phase Markers → ## Design`
   block, extend the subsection list to include `### Execution Order`
   (topo-sorted narrative of task files with links and one-sentence
   purposes) between `### Tasks` and `### Glossary`.
3. Under the `### Glossary` bullet, add a nested bullet for
   `#### Shared Surfaces`, describing it as a narrative list of
   cross-task touchpoints named by surface only — files, type names,
   config keys, sentinel values — with links to the tasks that touch
   each surface and a one-sentence note on why the coupling matters.
4. Include the rot-avoidance rule: Shared Surfaces must NOT record
   type shapes, literal values, or concrete config keys. That detail
   lives in task files, discovered at implementation time.
5. Keep all other sections of the doc unchanged.
</steps>

<test_steps>
- `docs/spec-format.md` documents `### Execution Order` and
  `#### Shared Surfaces` under the Design section description.
- The rot-avoidance rule is stated explicitly.
- No other sections of the doc are changed.
</test_steps>

<review></review>
