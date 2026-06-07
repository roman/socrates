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
Each task file is the single artifact for that unit of work across both
interactive and autonomous modes — there is no second representation.

### Frontmatter

```yaml
---
id: a1b2-setup-middleware       # identity token + cosmetic slug
status: draft                   # draft | approved | closed | cancelled
priority: 2                     # 0 (highest) to 4
category: functional            # functional | style | infrastructure | documentation
assignee:                       # who works this task (e.g. "ralph", a human name, or empty)
deps: [c4d5-worker-queue]       # list of identity tokens (or full ids) this task depends on
---
```

### Body

```markdown
# <Task title>

## Outcomes

- What the implementer must achieve — the target state, not the procedure.

## Verification

- Observable criterion one
- Observable criterion two

<review></review>
```

### Identity

A task id has two parts: a stable **identity token** and a cosmetic
**human slug**.

- **Identity token**: first 4 hex characters of the SHA-256 hash of the
  original title. This token is the stable handle — it never changes, even
  if the task is reordered or the slug is rewritten.
- **Human slug**: a 2-3 word kebab-case suffix for readability. The slug
  can be renamed freely; it carries no semantic weight.

```bash
echo -n "Setup auth middleware" | sha256sum | cut -c1-4
# → "a1b2" → id: a1b2-setup-middleware
```

Commits reference the identity token in `Refs:` lines (e.g.
`Refs: a1b2-setup-middleware`). Because the token is position-independent,
reordering tasks or renaming slugs does not invalidate references.

### Dependencies

Dependency edges live in the `deps` frontmatter field as a YAML list.
Each entry is the identity token (or full id) of a task that must reach
`closed` before this task becomes eligible for work. A parser can read
edges directly from frontmatter — no overview prose is required for an
edge to be machine-readable.

```yaml
deps: [c4d5-worker-queue, e6f7-schema-migration]
```

An empty list (`deps: []`) means the task has no dependencies.

### Status Lifecycle

| Status | Meaning | Who sets it |
|--------|---------|-------------|
| `draft` | Generated or iterating, not yet reviewed | `/spec` (Design phase) |
| `approved` | Contract is frozen, task is eligible for work | User (manual edit) |
| `closed` | Work is complete | Implementer |
| `cancelled` | Abandoned; will not be done | User (manual edit) |

#### The freeze transition

`draft → approved` is the freeze point. Once a task is `approved`, its
contract fields — Outcomes, Verification, and `deps` — are write-once.
Both interactive and autonomous modes honour this: `approved` means "the
task is settled and safe to implement against."

#### Reopening an approved task

To change an `approved` task's contract, reopen it to `draft` first.
Reopening signals that the contract has changed and affected dependents
should be re-checked (the `spec dependents` query identifies which tasks
depend on a given task). After editing, re-approve to re-freeze.

### Review Workflow

1. User writes feedback in the `<review>` section
2. Run `/spec <task-file>` to process feedback
3. AI regenerates `## Outcomes` and `## Verification`, clears `<review>`
4. Repeat until satisfied, then set `status: approved`
