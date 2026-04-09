## soc-9vi9 — /pour derives ordering from Shared Surfaces

Rewrote Procedure step 3 of `plugins/socrates/commands/pour.md` so
`/pour` no longer reads `depends_on:` from task frontmatter. Edges
are now derived by parsing the `Shared Surfaces` subsection of
`_overview.md` and looking for `(surface owner)` markers on the
linked tasks.

### Derivation rules baked in

- Locate the `Shared Surfaces` heading by text (any level) inside
  `## Design`. Missing/empty → empty edge set, fall back to
  filename ordinal order.
- Bullet boundary defined explicitly (`^\s*[-*]\s` start, runs
  through wrapped/indented continuation lines) so wrapped bullets
  in real specs are not split or merged.
- Owner detection is whitespace- and emphasis-tolerant: the literal
  `(surface owner)` token may sit anywhere in the bullet between a
  link and the next link, ignoring `*`/`_` emphasis and line
  wraps. Avoids silent owner-drop on wrapped bullets.
- 0 owners → mutual read, no edges. ≥1 owner → consumer × owner
  cross product. Owner-wins on duplicate task ids in one bullet.
- Dangling references (link to a non-existent approved task file)
  stop pour with a report rather than silently dropping the edge.
- Filename order is primary; surface edges layer on as topo
  constraints. Empty edge set collapses to pure ordinal order.
- Cycle detection preserved. Cross-run `spec-task-id → tk-id`
  map seeding from already-poured tasks preserved.

### Code-critic findings addressed

Spawned code-critic (opus). Two majors flagged and fixed:

- M1: parser was "immediately after on the same bullet" — fragile
  on wrapped lines and italicized markers. Now whitespace/wrap/
  emphasis tolerant, anchored "between this link and the next."
- M2: bullet boundary was undefined. Now spelled out as a literal
  markdown rule.

Also adopted S1 (filename order primary, edges layered on) and the
extra Q3 dangling-reference guard.

### Not touched

- pour.md per-task action subsection (creates ticket, captures id,
  runs `tk dep`) was edited only to source dep ids from the
  derived edge set instead of `depends_on:` frontmatter.
- Existing legacy spec task files still carry `depends_on:` in
  their frontmatter; the new procedure ignores it explicitly.
- No code changes — `/pour` is a markdown procedure executed by
  the Claude Code agent.

### Next

soc-9vi9 → close. Parent soc-z4r9 (depends-on-smell epic) has no
remaining open children visible in `tk ready`; PM cycle next time
should run the Spec Lifecycle sweep on the
`2026-04-08-depends-on-smell` spec.
