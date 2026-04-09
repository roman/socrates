---
id: 2-4968-pour-derives-from-surfaces
status: poured
priority: 0
category: functional
ticket: soc-9vi9
---

# Derive pour ordering from Shared Surfaces

<steps>
1. Rewrite Procedure step 3 of `plugins/socrates/commands/pour.md`
   so `/pour` no longer reads `depends_on:` from task frontmatter.
   Instead, parse the `#### Shared Surfaces` subsection of
   `_overview.md` and derive a set of ordering edges: for each
   surface entry with exactly one `(producer)` marker, emit
   `consumer depends_on producer` for every other linked task; for
   entries with multiple producers, emit the cross product (every
   consumer depends on every producer); for entries with no
   producer marker, emit nothing (mutual read).
2. Fall back cleanly when Shared Surfaces is empty or absent:
   `/pour` emits zero `tk dep` calls and orders tickets by
   filename (ordinal prefix). This is a valid state meaning "no
   cross-task coupling" and must not fail.
3. Preserve cycle detection: run a topological sort over the
   derived edge set and stop + report if a cycle is detected.
4. Preserve the cross-run `spec-task-id → tk-id` map seeded from
   already-poured tasks (Procedure step 3 prelude); surface-derived
   edges resolve against the same map.
5. Update pour.md's procedure prose so Step 3 describes the new
   derivation explicitly, including the fallback behavior and the
   "no `depends_on:` in frontmatter" expectation.
</steps>

<test_steps>
- Run `/pour` on a spec with a Shared Surfaces section containing
  producer markers; confirm `tk dep` is called for each derived
  consumer→producer edge and only those edges.
- Run `/pour` on a spec with empty or absent Shared Surfaces;
  confirm no `tk dep` calls are made and tickets are created in
  filename (ordinal) order.
- Run `/pour` on a spec where derived edges form a cycle; confirm
  it stops and reports the cycle.
- Confirm `/pour` does not read `depends_on:` from task
  frontmatter anywhere in its procedure.
- Confirm cross-run idempotency: re-running `/pour` after some
  tasks are already `poured` still resolves surface-derived edges
  against the seeded map.
</test_steps>

<review></review>
