---
description: Transform approved spec task files into tk tickets
---

# /pour — Approved Tasks → tk Tickets

Mechanical transformation: read approved task files from a spec, create tk
tickets, wire up dependencies, and freeze the spec files. After pour, all
mutable state lives in `.tickets/` — spec files become write-once artifacts.

## Arguments

- **A spec name**: `/pour auth-redesign` — pours approved tasks from `docs/specs/auth-redesign/`
- **No arguments**: lists specs with approved tasks and asks which to pour

## Step 1 — Spec Discovery

### If no arguments provided

1. Scan `docs/specs/` for all spec directories
2. For each, scan task files and count by status (draft, approved, poured)
3. Filter to specs that have at least one `status: approved` task
4. If none: tell the user there are no approved tasks to pour and stop
5. If one: use it automatically
6. If multiple: use AskUserQuestion to ask which spec to pour

### If spec name provided

1. Verify `docs/specs/<name>/` exists
2. If not: tell the user the spec doesn't exist and list available specs

## Step 2 — Collect Approved Tasks

1. Read all `.md` files in `docs/specs/<name>/` (excluding `_overview.md`)
2. Parse YAML frontmatter from each
3. Partition into three groups:
   - `approved` — will be poured this run
   - `poured` — already poured, skip (idempotent)
   - `draft` — not ready, skip
4. Report to user:
   - "Pouring N approved tasks (M draft tasks skipped, K already poured)"
5. If no approved tasks: tell the user and stop

## Step 3 — Epic Creation

Every spec gets an epic ticket so the PM role can later detect spec completion
and archive the spec directory.

1. If `_overview.md` already has a non-empty `epic:` field, reuse that ID
   (idempotent re-pour). Otherwise:
   ```bash
   tk create "<spec-name>" -t epic -a ralph --tags "<spec-name>"
   ```
   The title is the spec name verbatim (matches the directory name without the
   date prefix). Capture the epic ticket ID from tk output.
2. Write the epic ID back into `_overview.md` frontmatter:
   ```yaml
   epic: <epic-id>
   ```
   Use the Edit tool for a targeted frontmatter update.
3. The epic groups all tasks from this spec under one parent. PM archival keys
   off this field.

## Step 4 — Ticket Creation

Process approved tasks in dependency order (tasks with no dependencies first,
then tasks whose dependencies are all processed). This ensures `tk dep` can
reference already-created ticket IDs.

### Dependency ordering

1. Build a dependency graph from `depends_on:` fields
2. Topological sort — tasks with no deps come first
3. If circular dependencies detected: stop and report the cycle to the user

### For each approved task (in order)

1. **Read the task file** — extract title, priority, category, steps, test_steps

2. **Build the description** from task file content. Format:
   ```
   Spec: docs/specs/<spec-name>/<task-file>.md

   ## Steps
   <contents of <steps> section, verbatim>

   ## Verification
   <contents of <test_steps> section, verbatim>
   ```
   The `Spec:` line at the top gives ralph a direct pointer back to
   the source task file, so any future edits to the spec remain
   discoverable from the ticket.

3. **Create the ticket** (always parented to the spec epic). Pass
   the description via `-d` using a heredoc so newlines and
   formatting survive:
   ```bash
   tk create "<title>" \
     -t task \
     -p <priority> \
     -a ralph \
     --tags <category> \
     --parent <epic-id> \
     -d "$(cat <<'EOF'
   Spec: docs/specs/<spec-name>/<task-file>.md

   ## Steps
   <steps content>

   ## Verification
   <test_steps content>
   EOF
   )"
   ```
   Do **not** create the ticket with only a title and then try to
   add the description after — `tk create` is the only moment the
   description can be set cleanly. `tk edit` opens `$EDITOR`
   interactively and does not work from a non-interactive session;
   `tk add-note` appends to notes, not the description body.

4. **Capture the ticket ID** from tk output (`tk create` prints the
   new ID to stdout as its only output on success)

5. **Wire dependencies**: For each ID in `depends_on:`, look up the tk ticket ID
   that was created for that spec task (from the mapping built during this run,
   or from already-poured tasks' `ticket:` field):
   ```bash
   tk dep <new-ticket-id> <dep-ticket-id>
   ```

6. **Freeze the spec file** — this is the last write to the task file:
   - Set `status: poured`
   - Set `ticket:` to the tk ticket ID
   - Use the Edit tool for targeted frontmatter updates

### ID Mapping

Maintain a mapping of `spec-task-id → tk-ticket-id` throughout the pour:
- For newly created tickets: added as each ticket is created
- For already-poured tasks: read from their `ticket:` field in frontmatter

This mapping is needed to resolve `depends_on:` references that point to
tasks poured in a previous run.

## Step 5 — Summary

After all tasks are poured, report:

```
Poured N tasks from spec "<name>":
  Epic: <epic-id> (if created)
  Tasks:
    <ticket-id>  <title>  (depends on: <dep-ids>)
    ...
  Skipped: M draft, K already poured
```

Remind the user of next steps:
- Run `tk ready` to see which tasks are unblocked
- Run `./ralph.sh` to start autonomous implementation
- Remaining draft tasks can be approved and poured later with `/pour` again
