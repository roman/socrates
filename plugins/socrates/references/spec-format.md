# Spec Format Reference

Specs live in `docs/specs/<name>/` and consist of an overview file plus
individual task files.

## Overview File (`_overview.md`)

The overview captures the entire Design in Practice journey for a feature.

### Frontmatter

```yaml
---
socrates_format: 2         # spec-file shape version; absent means 1
title: <spec name>
created: <YYYY-MM-DD>
delimit_approved: false    # set to true when Delimit phase is approved
---
```

### Sections and Phase Markers

Only incomplete phases carry a marker:

| Heading | Meaning |
|--------|---------|
| `## <Phase> [DRAFT]` | Phase not yet completed |
| `## <Phase>` | Phase complete |

Readers may encounter legacy `[COMPLETE]` and `[APPROVED]` markers. Treat both
as complete. New and updated specs remove the marker when a phase completes.
Delimit approval is recorded by `delimit_approved: true` in frontmatter.

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
When approved, remove `[DRAFT]` and set `delimit_approved: true` in frontmatter.

#### `## Direction [DRAFT]`

Contains four subsections:

- **`### Approaches`** — Enumerated approaches including status quo
- **`### Decision Matrix`** — If non-trivial choice: problem statement as header,
  approaches as columns, criteria as rows, cells use 🟢🟡🔴⬜
- **`### Chosen Approach`** — Which approach and why
- **`### Use Cases`** — User intentions (Actor + Intent + Outcome)

#### `## Design [DRAFT]`

Contains these subsections:

- **`### Solution Map`** (conditional) — One small solution diagram when the
  reader must track several components, interactions, transitions, or
  converging inputs. State the question it answers and omit it when prose is
  clearer.
- **`### Context`** — Codebase patterns, integration points, conventions
  discovered during research that materially affect the design and are not
  already clear from Direction or the solution map
- **`### Tasks`** — Topo-sorted table of task links, short outcomes,
  dependencies, and priorities
- **`### Glossary`** (conditional) — Terms with a meaning specific or ambiguous
  in this spec

### Going Back

When revisiting a completed phase:
1. Add `[DRAFT]` to the target phase heading
2. Add `[DRAFT]` to all subsequent phase headings
3. Previous content preserved under `### Previous (superseded)` sub-heading
4. If Delimit or earlier: `delimit_approved` resets to `false`

## Task File Format

Individual task files live alongside `_overview.md` in the spec directory.
Each task file is the single artifact for that unit of work across both
interactive and autonomous modes — there is no second representation.

### Frontmatter

```yaml
---
socrates_format: 2              # task-file shape version; absent means 1
id: a1b2-setup-middleware       # identity token + cosmetic slug
status: draft                   # draft | approved | closed | cancelled
priority: 2                     # 0 (highest) to 4; scale in task-authoring.md
category: functional            # functional | style | infrastructure | documentation
assignee:                       # who works this task (e.g. "ralph", a human name, or empty)
serves: [RC1, AC2]              # diagnosed-item ids from the overview this task addresses
deps: [c4d5-worker-queue]       # list of identity tokens (or full ids) this task depends on
---
```

### Body

```markdown
# <Task title>

## Scope

The boundary of this slice, and the alternative rejected for a design choice
this task makes on its own. Links to the overview for the why — never a copy
of it.

## Outcome

- What the implementer must achieve — the target state, not the procedure.

## Verification

- Observable criterion one, and the setup that produces the observation
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

### Diagnosed-item trace

The `serves` field lists the diagnosed-item ids from the parent overview
(`RC1`, `NC2`, `AC1`, ...) that this task addresses. It is a pointer, not a
copy: the task never restates the diagnosed item, so rewording it in the
overview updates every task that serves it.

```yaml
serves: [RC1, AC2]
```

An empty list means the task traces to no diagnosed item, which is a claim
worth defending — see the priority rules in
[task-authoring.md](task-authoring.md).

`serves` is deliberately outside the frozen contract. Diagnosed items get
renumbered and reworded as a spec matures, and re-pointing a task at the
current id should not require reopening it.

### Shape version

`socrates_format` records which task-file shape a spec was authored in. A file
with no such field is shape 1: no `## Scope`, no `serves`, a plural
`## Outcomes` heading, and a `priority` derived partly from dependency order.
Tools that read task files should treat an absent field as 1 rather than
assuming the current shape.

Existing files are not migrated. The version marks what a reader should
expect, so an old spec stays readable without being rewritten.

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
contract fields — Scope, Outcome, Verification, and `deps` — are
write-once. `serves` and `priority` stay editable: the first tracks a moving
overview, the second is a planning judgment that changes as scope shifts.
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
3. AI regenerates the sections the feedback addresses — `## Scope`,
   `## Outcome`, `## Verification` — and clears `<review>`
4. Repeat until satisfied, then set `status: approved`
