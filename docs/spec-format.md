# Spec Format Reference

Specs live in `docs/specs/<name>/` and consist of an overview file plus
individual task files.

## Overview File (`_overview.md`)

The overview captures the entire Design in Practice journey for a feature.

### Frontmatter

```yaml
---
title: <spec name>
created: <YYYY-MM-DD>
delimit_approved: false    # set to true when Delimit phase is approved
---
```

### Sections and Phase Markers

Each section has a marker in its heading:

| Marker | Meaning |
|--------|---------|
| `[DRAFT]` | Phase not yet completed |
| `[COMPLETE]` | Phase done |
| `[APPROVED]` | Delimit phase explicitly approved by user |

#### `## Describe [DRAFT]`

Situation description. What is happening? What is the context?
No interpretation, no proposed solutions.

#### `## Diagnose [DRAFT]`

Root cause analysis. Hypotheses tested, evidence gathered. "We don't have
feature X" is never a valid problem statement — dig for the unmet user
objective.

#### `## Delimit [DRAFT]`

Crisp 1-2 sentence problem statement: unmet user objectives and their causes.
Uses observable terms. This is the strict gate — requires explicit user approval.
When approved, marker becomes `[APPROVED]` and `delimit_approved: true` is set
in frontmatter.

#### `## Direction [DRAFT]`

Contains four subsections:

- **`### Approaches`** — Enumerated approaches including status quo
- **`### Decision Matrix`** — If non-trivial choice: problem statement as header,
  approaches as columns, criteria as rows, cells use 🟢🟡🔴⬜
- **`### Chosen Approach`** — Which approach and why
- **`### Use Cases`** — User intentions (Actor + Intent + Outcome)

#### `## Design [DRAFT]`

Contains these subsections:

- **`### Context`** — Codebase patterns, integration points, conventions
  discovered during research
- **`### Tasks`** — Summary table of generated task files
- **`### Execution Order`** — Topo-sorted narrative of task files with links
  and a one-sentence purpose for each, so a reader can follow the intended
  build sequence without opening every task
- **`### Glossary`** — Terms used consistently throughout the spec
  - **`#### Shared Surfaces`** — Narrative list of cross-task touchpoints
    named by surface only (files, type names, config keys, sentinel values),
    with links to the tasks that touch each surface and a one-sentence note
    on why the coupling matters. One linked task per entry may be annotated
    `(surface owner)` immediately after the link — the task that creates or
    owns that surface; other linked tasks are readers and are ordered after
    it. Absence of any marker means the surface is a mutual read and
    contributes no ordering edges between its tasks. Multiple owners are
    allowed but rare. The marker must be written explicitly on the link
    itself (not implied by list position) so it survives link reordering
    during refinement. Example:
    > **`config.yaml` `retry` block** — touched by
    > [1-a1b2](1-a1b2-setup.md) (surface owner) and
    > [3-c4d5](3-c4d5-worker.md); the worker reads retry policy the setup
    > task writes.

    **Rot-avoidance rule:** Shared Surfaces must NOT record type shapes,
    literal values, or concrete config keys. That detail lives in task
    files, discovered at implementation time.

### Going Back

When revisiting a completed phase:
1. Target phase marker resets to `[DRAFT]`
2. All subsequent phase markers reset to `[DRAFT]`
3. Previous content preserved under `### Previous (superseded)` sub-heading
4. If Delimit or earlier: `delimit_approved` resets to `false`

## Task File Format

Individual task files live alongside `_overview.md` in the spec directory.

### Frontmatter

```yaml
---
id: a1b2-setup-middleware       # short hash + human suffix
status: draft                   # draft → approved → poured
priority: 2                     # 0 (highest) to 4
category: functional            # functional | style | infrastructure | documentation
ticket: null                    # set to tk ID after pour (last write)
---
```

### Body

```markdown
# <Task title>

<steps>
1. First implementation step
2. Second implementation step
</steps>

<test_steps>
- Verification criterion one
- Verification criterion two
</test_steps>

<review></review>
```

### ID Generation

IDs are first 4 characters of the SHA-256 hash of the title plus a 2-3 word
kebab-case human suffix:

```bash
echo -n "Setup auth middleware" | sha256sum | cut -c1-4
# → "a1b2" → id: a1b2-setup-middleware
```

### Status Lifecycle

| Status | Meaning | Who sets it |
|--------|---------|-------------|
| `draft` | Generated or iterating, not yet reviewed | `/spec` (Design phase) |
| `approved` | Human has signed off, ready to pour | User (manual edit) |
| `poured` | tk ticket created, spec file is now frozen | `/pour` (last write) |
| `cancelled` | Abandoned before pour; will not be done | User (manual edit) |

After pour, the spec file is a write-once artifact. All mutable state lives
in `.tickets/`. `cancelled` is a terminal pre-pour state for tasks that
will never be poured, allowing an epic to reach a fully-closed state
without forcing every task through tk.

### Review Workflow

1. User writes feedback in the `<review>` section
2. Run `/spec <task-file>` to process feedback
3. AI regenerates `<steps>` and `<test_steps>`, clears `<review>`
4. Repeat until satisfied, then set `status: approved`
