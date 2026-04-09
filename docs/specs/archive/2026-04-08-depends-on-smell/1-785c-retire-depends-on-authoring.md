---
id: 1-785c-retire-depends-on-authoring
status: poured
priority: 1
category: documentation
ticket: soc-cirx
---

# Retire depends_on from task authoring surface

<steps>
1. Remove the `depends_on: []` line from
   `plugins/socrates/templates/task.md` frontmatter.
2. Update `plugins/socrates/commands/spec.md` Design phase task
   generation instructions: remove every reference to `depends_on:`
   in the "Fill in" list and the surrounding decomposition guidance,
   and remove the separate "Dependency Graph" subsection (the
   coupling story now lives entirely in Shared Surfaces).
3. Update `plugins/socrates/commands/spec.md` id-generation guidance
   so the ordinal prefix is assigned from the surface-derived topo
   order (the authoring agent computes this the same way `/pour`
   will: parse its own Shared Surfaces section, derive edges, topo
   sort). Note that the ordinal is a readability hint only; `/pour`
   re-derives independently at pour time from the same section.
4. Update the `### Tasks` summary table guidance in `spec.md` to
   drop the `Depends On` column.
5. Update `docs/spec-format.md` task frontmatter example and prose
   to drop `depends_on:` entirely. The task frontmatter is now:
   `id`, `status`, `priority`, `category`, `ticket`.
</steps>

<test_steps>
- `grep -r depends_on plugins/socrates/templates/ plugins/socrates/commands/spec.md docs/spec-format.md` returns no matches (barring any intentional historical note).
- The task template has no `depends_on:` field.
- `spec.md` no longer instructs the authoring agent to populate a
  dependency graph as a separate artifact from Shared Surfaces.
- `spec.md` ordinal-prefix guidance references surface-derived
  ordering.
</test_steps>

<review></review>
