---
id: 5-5760-migrate-existing-specs
status: draft
priority: 2
category: infrastructure
ticket: null
---

# Migrate existing specs to the unified schema

## Outcomes

- Every existing in-repo spec is converted to the unified schema so the
  extended `spec` CLI and the re-aimed defenses read consistent fields:
  the archived and active specs under `docs/specs/`, and this spec's own
  task files.
- Each migrated task file carries the new identity token, `assignee`,
  and frontmatter dependency edges, and its `status` uses the
  `draft / approved / closed` vocabulary with no `poured` value.
- Dependency edges that previously lived in an overview's prose
  (`Shared Surfaces` / `Dependencies`) are moved into the relevant task
  files' frontmatter, and the `epic:` field is removed from migrated
  overviews.
- Archived specs are migrated in place without un-archiving them, so the
  CLI does not encounter old-schema files anywhere it scans.

## Verification

- `spec ready` and `spec status` run against the full `docs/specs/` tree
  (including this spec) without erroring on missing or legacy fields.
- No task file under `docs/specs/` carries `status: poured` or a
  `ticket:` value tied to the retired system.
- This spec's own task files express their dependencies in frontmatter
  matching the overview's recorded edges.
- No migrated `_overview.md` retains an `epic:` field.

<review></review>
