---
id: 2-d7a7-spec-design-phase-instructions
status: poured
priority: 1
category: documentation
depends_on: [1-2435-overview-template-sections]
ticket: soc-n2cw
---

# Update /spec Design phase to produce Execution Order and Shared Surfaces

<steps>
1. Edit `plugins/socrates/commands/spec.md`, Step 7 (Design Phase).
2. In the Codebase Research subsection, add an explicit prompt to
   identify shared surfaces during research: cross-task touchpoints
   named by surface only (files, type names, config keys, sentinel
   values). Include the rot-avoidance rule: name the surface, do not
   pin the shape.
3. In the Writing the Design Section subsection, add a step instructing
   the author to write a rendered `### Execution Order` narrative after
   the dependency graph is known: topo-sorted bulleted list, each line a
   link to the task file plus one sentence of purpose.
4. In the same subsection, add a step instructing the author to
   populate `#### Shared Surfaces` under Glossary with the surfaces
   identified during research. Include a short example of the narrative
   form (surface + linked task ids + one sentence of why the coupling
   matters).
5. Add a note making explicit that Shared Surfaces must NOT contain
   type shapes, literal sentinel values, concrete config keys, or any
   detail that the implementer would be the first to know. If the
   author is tempted to put a shape in, that is a sign the content
   belongs in a task file, not the overview.
</steps>

<test_steps>
- Step 7 of `plugins/socrates/commands/spec.md` mentions shared
  surfaces in both the research prompt and the writing subsection.
- The "name the surface, not the shape" rule appears verbatim or
  equivalent in the instructions.
- Step 7 instructs the author to write an Execution Order narrative
  after the dependency graph is known.
- The instructions reference the template subsections added in
  task 1-2435 by name.
</test_steps>

<review></review>
