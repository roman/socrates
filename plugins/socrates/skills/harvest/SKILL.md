---
name: harvest
description: Extract learnings, gaps, skill-steering, and workflow-meta from session handoffs and promote them into durable artifacts (skills, CLAUDE.md, docs, specs); also tally which learnings handoffs actually used, to flag unused ones for cleanup. Use at the end of a work cycle to persist what handoffs surfaced.
---

# harvest — Learnings & Gaps → Durable Artifacts

Scan recent session handoffs, extract learnings, gaps, skill-steering, and
workflow-meta, and help the user promote them into persistent locations
(skills, CLAUDE.md, docs). Also review which learnings handoffs actually
cited, to keep the learnings corpus honest.

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

## Step 2 — Extract Learnings, Gaps, Skills & Meta

For each unharvested handoff:

1. Read the file
2. Extract the `## Learnings` section content (everything between `## Learnings`
   and the next `##` heading)
3. Extract the `## Gaps` section content (same approach)
4. Extract the `## Skills and meta` section, keeping its three subsections
   distinct — `Skills used`, `Steering`, and `Meta`. This section is written
   specifically for this step.
5. Read the `learnings_used:` frontmatter list, if present (repo-root-relative
   paths of learnings that informed the session)
6. Skip a section that is empty or missing; skip a handoff entirely only if it
   has none of the above

Compile:
- **All learnings** — each with its source handoff filename
- **All gaps** — each with its source handoff filename
- **All steering entries** — each a candidate skill/agent fix, with its source
- **All meta entries** — each a candidate CLAUDE.md / rule / skill change, with
  its source
- **Learning-usage tally** — the union of `learnings_used:` paths across the
  handoffs, with a count of how many cited each

Present the summary to the user:
```
Harvesting N handoffs (since <date>):

## Learnings (M items)
1. <learning> — from <handoff>
2. ...

## Gaps (K items)
1. <gap> — from <handoff>
2. ...

## Skill & workflow improvements (S items)
1. [steering] <skill/agent> — <what to fix> — from <handoff>
2. [meta] <workflow lesson> — from <handoff>
3. ...

## Learnings cited (from learnings_used)
- <area>/learnings/<file>.md — cited by <n> handoff(s)
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

## Step 4 — Promote Skill & Workflow Improvements

Process each steering entry and each meta item one at a time. For each, use
AskUserQuestion with options:

- **"Fix/enhance a skill"** — the entry names a skill or agent whose output was
  wrong, incomplete, or needed redirection. Open that skill's source and apply
  the fix: a sharper instruction, a missing step, a corrected default. A skill
  installed from an external repo is edited in that repo, not in the installed
  copy — find its source before editing, and note that a rebuild/reinstall is
  needed for the change to take effect.
- **"Add to CLAUDE.md / rule"** — a workflow lesson that should bind future
  sessions; append to the relevant CLAUDE.md or rules file.
- **"Skip"** — noise, or already captured elsewhere.

Steering entries are the highest-yield input in a harvest: each is a concrete,
observed failure of a tool already paired with the correction that worked. Treat
a steering entry that recurs across handoffs as a strong signal to fix the skill
rather than keep re-steering it by hand.

## Step 5 — Process Gaps

Process each gap one at a time. For each, use AskUserQuestion with options:

- **"Add to spec"** — Add to an existing spec for the next Design phase
- **"Skip"** — Not actionable or already addressed

### If "Add to spec"

1. List existing specs in `docs/specs/`
2. Ask which spec to add to
3. Append the gap as a note in the spec's `_overview.md` under a
   `### Harvested Gaps` sub-heading in the Design section
4. These gaps become input for the next `/spec` Design iteration

## Step 6 — Review Learning Usage

Using the learning-usage tally from Step 2, help the user keep the learnings
corpus honest. Citations are a usefulness signal, not a verdict.

1. Learnings cited by `learnings_used:` this cycle earned their keep — no action.
2. Optionally widen the scan: list the repo's `**/learnings/` directories and
   compare against `learnings_used:` across *all* handoffs (not just the
   unharvested ones) to find learnings that no handoff has ever cited.
3. For each never-cited learning, use AskUserQuestion:
   - **"Keep"** — still correct and worth holding even if unused lately
   - **"Merge"** — fold into a related learning and delete the duplicate
   - **"Retire"** — delete; it no longer reflects the system, or never helped
4. Never retire a learning solely because it is uncited — absence of citations
   is a prompt to review it, not to delete it.

## Step 7 — Mark Harvested

After all learnings, improvements, gaps, and usage review are processed:

1. Write the filename of the most recent harvested handoff to `.last-harvest`:
   ```
   <most-recent-handoff-filename>
   ```
   This is a single line — just the filename, no path prefix.

2. Report summary:
   ```
   Harvest complete:
     Learnings: N promoted, M skipped
     Skill/workflow: P applied, Q skipped
     Gaps: J added to specs, L skipped
     Learnings reviewed: R kept, U merged, T retired
     Last harvest marker: <filename>
   ```

Commit the `.last-harvest` file so future sessions (and other team members)
know what's been processed.
