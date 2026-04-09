## soc-cirx — Retire depends_on from authoring surface

Removed the `depends_on:` field from every place an authoring agent
(or human spec author) would see it. Coupling is now expressed only
via Shared Surfaces in the overview; `/pour` will derive ordering
from there in the next ticket (soc-9vi9).

Files touched:

- `plugins/socrates/templates/task.md` — drop `depends_on: []`
- `plugins/socrates/commands/spec.md` — drop the field from the
  "Fill in" list, drop the standalone `### Dependency Graph`
  subsection, drop `Depends On` column from the Tasks summary
  table, and rewrite the ordinal-prefix guidance to derive ordering
  from Shared Surfaces (parse `(surface owner)` markers, topo
  sort). Added one paragraph noting coupling lives in Shared
  Surfaces, not per-task frontmatter.
- `docs/spec-format.md` — drop `depends_on:` from the task
  frontmatter example.
- `docs/customization.md` — small consequential fix: the field list
  documenting which frontmatter `/pour` uses no longer mentions
  `depends_on`. Outside the literal step list but inside the
  ticket's intent ("retire from authoring surface").

Verification (ticket's grep):

    grep -r depends_on plugins/socrates/templates/ \
        plugins/socrates/commands/spec.md docs/spec-format.md
    # exit 1, no matches

### Not touched on purpose

- `plugins/socrates/commands/pour.md` still reads `depends_on:`
  from frontmatter. That is soc-9vi9's job (rewrite Procedure
  step 3 to parse Shared Surfaces). Until that lands, `/pour`
  will read empty/absent `depends_on:` and produce no edges,
  which matches its current fallback. Specs poured between now
  and soc-9vi9 will get topological ordering only from filename.
- Existing spec task files in `docs/specs/**` and the archived
  `2026-04-08-overview-navigation-fix/` retain `depends_on:` in
  their frontmatter. They are historical artifacts; rewriting
  them is out of scope.
- `.claude/commands/socrates-spec.md` was already modified before
  this session — left alone.

### Next

soc-cirx → close. soc-9vi9 unblocks (deps were soc-a41r + soc-cirx,
both now done). It is the next ralph cycle.
