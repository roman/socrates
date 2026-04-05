---
description: Extract learnings and gaps from session handoffs into durable artifacts
---

# /harvest — Learnings & Gaps → Durable Artifacts

Scan recent session handoffs, extract learnings and gaps, and help the user
promote them into persistent locations (skills, CLAUDE.md, docs, tickets).

## Step 1 — Identify Unharvested Handoffs

1. Check for `.last-harvest` marker file in the project root
   - If it exists: read the filename stored in it (the last harvested handoff)
   - If it doesn't exist: all handoffs are unharvested

2. List handoff files in `docs/handoffs/` sorted by filename (chronological
   since filenames start with `YYYY-MM-DD-HHmm`)

3. Filter to handoffs newer than `.last-harvest` marker
   - Compare filenames lexicographically — newer handoffs sort after the marker

4. If no unharvested handoffs: tell the user everything is up to date and stop

5. Report: "Found N unharvested handoffs since <last-harvest-date>"

## Step 2 — Extract Learnings and Gaps

For each unharvested handoff:

1. Read the file
2. Extract the `## Learnings` section content (everything between `## Learnings`
   and the next `##` heading)
3. Extract the `## Gaps` section content (same approach)
4. Skip handoffs that have empty or missing Learnings/Gaps sections

Compile two lists:
- **All learnings** — each with its source handoff filename
- **All gaps** — each with its source handoff filename

Present the summary to the user:
```
Harvesting N handoffs (since <date>):

## Learnings (M items)
1. <learning> — from <handoff>
2. ...

## Gaps (K items)
1. <gap> — from <handoff>
2. ...
```

## Step 3 — Promote Learnings

Process each learning one at a time. For each, use AskUserQuestion with options:

- **"Create/update skill"** — Create or update a skill file in `.claude/skills/`
- **"Add to CLAUDE.md"** — Append to CLAUDE.md or a folder-level CLAUDE.md
- **"Add to docs"** — Write to an appropriate file in `docs/`
- **"Skip"** — Not worth persisting

### If "Create/update skill"

1. Ask for a skill name (or suggest one based on the learning content)
2. Check if `.claude/skills/<name>.md` exists
   - If exists: read it and append the learning
   - If new: create the skill file with the learning as content
3. Confirm the write

### If "Add to CLAUDE.md"

1. Ask which CLAUDE.md (root, or a specific folder like `docs/CLAUDE.md`)
2. Read the target file
3. Append the learning under an appropriate section
4. Confirm the write

### If "Add to docs"

1. Ask which doc file (or suggest one based on content)
2. Read the target file (or create new)
3. Write the learning
4. Confirm the write

## Step 4 — Process Gaps

Process each gap one at a time. For each, use AskUserQuestion with options:

- **"Create tk ticket"** — Create a new ticket for this gap
- **"Add to spec"** — Add to an existing spec for the next Design phase
- **"Skip"** — Not actionable or already addressed

### If "Create tk ticket"

1. Ask for a title (or suggest one based on the gap)
2. Create the ticket:
   ```bash
   tk create "<title>" -t task -a ralph --tags gap
   ```
3. Report the ticket ID

### If "Add to spec"

1. List existing specs in `docs/specs/`
2. Ask which spec to add to
3. Append the gap as a note in the spec's `_overview.md` under a
   `### Harvested Gaps` sub-heading in the Design section
4. These gaps become input for the next `/spec` Design iteration

## Step 5 — Mark Harvested

After all learnings and gaps are processed:

1. Write the filename of the most recent harvested handoff to `.last-harvest`:
   ```
   <most-recent-handoff-filename>
   ```
   This is a single line — just the filename, no path prefix.

2. Report summary:
   ```
   Harvest complete:
     Learnings: N promoted, M skipped
     Gaps: K ticketed, J added to specs, L skipped
     Last harvest marker: <filename>
   ```

The `.last-harvest` file should be committed to the repo so that future
sessions (and other team members) know what's been processed.
