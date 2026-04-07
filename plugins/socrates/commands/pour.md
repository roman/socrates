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

Topologically sort the approved tasks by `depends_on:` so deps exist before
dependents reference them. Stop and report if a cycle is detected.

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

3. For each id in `depends_on:`, resolve to a tk id via the map and run
   `tk dep <new-id> <dep-tk-id>`.

4. Freeze the spec task file (last write): set `status: poured` and
   `ticket: <new-id>` in frontmatter via Edit.

### 4. Summary

Report poured count, epic id, ticket ids with their deps, and skipped
counts.
