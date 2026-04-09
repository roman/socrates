---
description: Transform approved spec task files into tk tickets
---

# /pour — Approved Tasks → tk Tickets

Mechanical transformation: read approved task files from a spec, create tk
tickets parented to a spec epic, wire dependencies, and freeze the spec
files. After pour, all mutable state lives in `.tickets/` — spec files
become write-once artifacts.

## Arguments

- `/pour <spec-name>` — pours approved tasks from `docs/specs/*-<spec-name>/`
- `/pour` (no args) — find specs with approved tasks; if exactly one, use
  it; otherwise ask via AskUserQuestion. Stop if there are none.

## Procedure

### 1. Collect

Read every `.md` file in the spec directory except `_overview.md`. Partition
by frontmatter `status:` into `approved`, `poured`, and `draft`. Skip the
last two (poured = idempotent; draft = not ready). Report the counts. Stop
if `approved` is empty.

### 2. Epic (create or reuse)

If `_overview.md` has a non-empty `epic:` field, reuse it. Otherwise:

```bash
tk create "<spec-name>" -t epic -a ralph --tags "<spec-name>"
```

Capture the printed id and write it back to `_overview.md` frontmatter as
`epic: <id>`. The PM Spec Lifecycle Sweep keys off this field.

### 3. Pour each approved task (topo-ordered)

Before processing, seed an in-memory `spec-task-id → tk-id` map with the
`ticket:` field from every already-poured task in this spec. This is what
lets cross-run dependencies resolve when the current run has no overlap
with the previous one.

**Derive ordering edges from Shared Surfaces.** Task frontmatter no
longer carries `depends_on:` — coupling lives in the `#### Shared
Surfaces` subsection of `_overview.md`. Parse it as follows:

1. Read `_overview.md` and locate a heading whose text is exactly
   `Shared Surfaces` (any heading level) inside the `## Design`
   section. If the subsection is missing or contains no bullets,
   the edge set is empty — skip to the topo sort below.
2. Split the subsection into bullet entries. A bullet starts at a
   line matching `^\s*[-*]\s` and includes every following line
   (soft-wrapped or indented continuation) up to the next bullet,
   blank line followed by a non-bullet, or the end of the
   subsection.
3. Within each bullet, collect every markdown link to a sibling
   task file (e.g. `[1-a1b2](1-a1b2-setup.md)` → spec-task-id
   `1-a1b2`). A link is an *owner* if the literal substring
   `(surface owner)` — ignoring surrounding `*`/`_` emphasis and
   any whitespace or line wraps — appears anywhere in the bullet
   between that link and the next markdown link (or the end of
   the bullet, for the last link). All other linked tasks in the
   bullet are *consumers*. If the same task id appears more than
   once in a bullet, owner wins.
4. Emit edges:
   - 0 owners on a bullet → no edges (mutual read).
   - ≥1 owner → for every consumer × owner pair, emit
     `consumer depends_on owner`. Multiple owners produce the
     full cross product.
5. Deduplicate edges across bullets. If a linked task id does
   not match any approved task file in this spec, stop and
   report the dangling reference rather than silently dropping
   the edge.

Do **not** read `depends_on:` from task frontmatter anywhere — the
field has been retired from the authoring surface and any residual
value in legacy specs must be ignored.

Order tasks by filename (leading ordinal prefix), then apply the
derived edges as additional constraints via topological sort so
owners exist before consumers reference them. An empty edge set
collapses to pure filename order. Stop and report if a cycle is
detected.

For each task in order:

1. Create the ticket. The description must be passed via `-d` heredoc on
   `tk create` — `tk edit` is interactive and `tk add-note` appends to
   notes, not the body. The `Spec:` line gives ralph a pointer back.

   ```bash
   tk create "<title>" -t task -p <priority> -a ralph \
     --tags <category> --parent <epic-id> \
     -d "$(cat <<'EOF'
   Spec: docs/specs/<spec-dir>/<task-file>.md

   ## Steps
   <steps content>

   ## Verification
   <test_steps content>
   EOF
   )"
   ```

2. Capture the new ticket id from stdout and add it to the map.

3. For each surface-derived edge `this-task depends_on <owner>`,
   resolve `<owner>` to a tk id via the map and run
   `tk dep <new-id> <owner-tk-id>`. Topo order guarantees the owner
   was already poured (in this run or a previous one via the seeded
   map).

4. Freeze the spec task file (last write): set `status: poured` and
   `ticket: <new-id>` in frontmatter via Edit.

### 4. Summary

Report poured count, epic id, ticket ids with their deps, and skipped
counts.
