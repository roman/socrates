---
title: Unified Task Lifecycle
created: 2026-06-06
tags: []
archived:
delimit_approved: true
---

<!-- Voice and structure follow plugins/socrates/voice.md. -->

## Describe [COMPLETE]

Socrates today splits a task's life across two namespaces. Specs live
as files under `docs/specs/<spec>/<id>.md`. Tickets live as files under
`.tickets/<id>.md`. The `/pour` command is the one-way gate between
them: it parses the spec, materializes tickets, wires their
dependencies, and freezes the spec files write-once. ADR-004 records
why the split exists and treats it as load-bearing.

### How the author actually works

The author has been running the Socrates design protocol in a separate
work project, driving an agent directly against the generated task
files, and never running `/pour`. There is no ralph loop in that
project. The agent reads a task file and implements against it, and the
work gets done. The INTERACTIVE protocol, added recently, already
sanctions most of this: the read-guard hook is RALPH-only, reading task
files is the intended path, and the work source is "the user names the
task by file path" rather than `tk ready -a ralph`.

So the protocol already supports working directly off spec files when a
human steers. What it has not done is reconcile that mode with the
machinery ADR-004 built for the autonomous loop. The two coexist as
parallel worlds.

### What the author wants to change

Three protocol decisions are under challenge:

1. **The namespace split.** Tickets live in `.tickets/` to satisfy the
   `tk` binary. For interactive work, `/pour` and the second namespace
   buy nothing the author values; the agent works the file directly.
2. **Global task identity.** Task ids carry an opaque hex
   (`1-cc1e-synthesis-prompt-caps`) for a global namespace. If identity
   is scoped to its spec, the hex looks redundant.
3. **The mode boundary itself.** The author moves between RALPH and
   INTERACTIVE on the same work. Two directories and two id shapes mean
   a task's representation depends on which mode last touched it. That
   invites repetition and drift.

### Known facts

- ✅ **Verified** — `/pour` is the only promotion path and is mandatory
  (ADR-004; `pour.md`).
- ✅ **Verified** — Task dependencies are not in task frontmatter.
  `depends_on:` was retired; coupling lives as prose in the
  `#### Shared Surfaces` subsection of `_overview.md`, and `/pour`
  parses that prose into `tk dep` edges (`pour.md`, lines 45-79).
- ✅ **Verified** — Two mechanical defenses key on the namespace split:
  `commit-msg.sh` distinguishes spec ids from ticket ids by shape, and
  `spec-read-guard.sh` blocks reading spec task files under
  `RALPH_SESSION=1`.
- ✅ **Verified** — A real bypass bug occurred: an agent implemented a
  spec task directly and committed `Refs:` with a spec task id; no
  ticket existed. This motivated ADR-004 (commits `bdceea8`, `b7ac7ff`).
- ✅ **Verified** — `/pour` writes the `epic:` field the PM Spec
  Lifecycle Sweep keys off to detect spec completion.
- 🟨 **High confidence** — A spec holds tens of tasks, not hundreds.
  Parsing the whole spec on every frontier query is microseconds.

### Folded-in gap

The open gap `protocol-prose-traversal-rewrites` (tooling adoption of
the `spec` status CLI) is subsumed here. It worried that four traversal
surfaces re-implement spec/task parsing in prose. Collapsing the
namespaces and removing `/pour` forces those surfaces to be rewritten
anyway, so its concern is folded into this spec's Design rather than
solved separately.

### Stakeholders

- The author, working interactively today and autonomously later.
- The autonomous loop (ralph), which depends on the freeze invariant
  and on `tk ready` resolving an unblocked frontier.

## Diagnose [COMPLETE]

### Surface assertions, challenged

The opening ask was "remove `/pour`, collapse `.tickets/`, drop the
hex." Each was challenged against the failure it would reintroduce.

**"Pour buys nothing interactively."** Partly true. Pour's low value
when a human steers is real. But pour does three things nothing else
does: it compiles coupling prose into a dependency graph, it freezes
the task contract, and it writes the `epic:` completion anchor. The
weak claim (low interactive value) holds; the strong claim (it is pure
ceremony) does not.

**"The namespace exists only to satisfy `tk`."** The namespace carries
the freeze invariant, not `tk`. `tk` lives in `.tickets/`
incidentally. The directory was the crudest possible implementation of
a freeze transition: move the file, and it is frozen.

**"`tk` is simple; reimplement or extend it."** Granted, after
challenge. Frontier discovery is a topological sort over tens of nodes.
The "own it forever" objection was overstated and withdrawn. The real
cost is not the sort; it is where the sort gets its edges.

### Hypotheses tested

**H1: The split is fundamentally about two directories.** Disproved.
The directory is a proxy. The thing that matters is a freeze
*transition* — the moment a task's contract stops being mutable design
surface and becomes something work executes against. A file move is one
way to encode that transition; a status field is another.

**H2: Removing `/pour` removes only ceremony.** Disproved. Pour is a
compiler. Its prose→graph parse of Shared Surfaces is the source of the
dependency edges the frontier sort runs against. Delete the command and
the edges have no source. They must move somewhere with a schema, or
get re-parsed from prose on every query (the worst option: fragile and
repeated).

**H3: Spec-scoped identity can drop the opaque token.** Disproved as
stated. Scoping to one spec does make collisions unlikely, so the
*ordinal* can go. But moving identity onto the human-authored slug
re-creates instability: the slug is the field most likely to be
reworded during Design, and edges reference tasks by id. A stable
opaque token with a cosmetic slug keeps identity position- and
rename-independent.

### Diagnosed items

#### Legend

| Prefix | Name | Meaning |
| --- | --- | --- |
| **RC** | Root Cause | A real reason the problem exists. |
| **NC** | Non-Cause | Looked like a cause; turned out not to be. Limit to 2-3. |
| **AC** | Adjacent Constraint | A rule from outside this spec that we must respect. |
| **ID** | Implementation Detail | Effort, risk, reversibility — not tied to a diagnosed item. |

#### RC1 — The freeze invariant is encoded as filesystem location, not state

ADR-004 protects "one mutable source of truth per task per lifecycle
phase." It implements that as two directories joined by `/pour`. Since
location is the encoding, every mode that touches a task must agree on
*where* the task lives, and moving between RALPH and INTERACTIVE means a
task's representation depends on which mode last acted. The invariant is
sound; its encoding as location is the root cause of the duplication and
drift the author hit.

#### RC2 — Dependency edges live in prose, so promotion must compile them

Because coupling is authored as prose in `_overview.md`, something has
to parse it into a graph before a frontier can be computed. Today that
something is `/pour`, run once. Any design that removes `/pour` without
relocating the edges leaves frontier discovery undefined.

#### RC3 — Identity is overloaded with position and name

The task id `ordinal-hex-slug` fuses three things: sequence position
(ordinal), stable handle (hex), and human label (slug). Two of the three
are mutable during Design. Edges and `Refs:` that key on the composite
go stale when a task is reordered or renamed.

#### NC1 — The `tk` binary is the reason for the second namespace

Looked like the cause; it is not. `tk` is a consumer of `.tickets/`,
not the reason it exists. Replacing or extending `tk` does not address
the freeze invariant, which is the actual purpose of the split.

#### NC2 — Performance of parsing the spec on every query

Considered as a cost of live frontier computation; ruled out. Tens of
tasks parsed per query is microseconds. The objection to live-parsing is
failure mode (fragile prose parser breaking `tk ready` at runtime), not
speed.

#### AC1 — The freeze must survive mode switches

Whatever replaces the directory split must still freeze a task's
contract once approved, in a way both RALPH and INTERACTIVE honor. A
half-written Outcome is dangerous regardless of who picks it up. The
freeze cannot be a RALPH-only concern.

#### AC2 — Mechanical bypass detection must keep a referent

ADR-004's hooks (`commit-msg.sh`, `spec-read-guard.sh`) key on the
namespace split. Collapsing it removes their referent. The defense they
provided (catch work against an unsettled task) must be re-aimed at the
new signal — task status — rather than silently dropped. We have already
paid for one bypass bug.

#### AC3 — The completion anchor must be re-homed

`/pour` writes the `epic:` field the PM Spec Lifecycle Sweep reads to
detect a finished spec. Removing `/pour` orphans that anchor. Completion
detection must re-point at a spec-scoped query.

### Boundary checkpoint

Does RC1 explain why this surfaces now? Yes. INTERACTIVE.md was added
recently and legitimized human-driven work off spec files. That is what
exposed the location-based freeze as the seam between the two modes. The
problem is here-and-now because the second mode now exists and the
author moves between both.

## Delimit [APPROVED]

Socrates encodes a task's lifecycle — its freeze point, its identity,
and its dependency edges — across two namespaces joined by a mandatory
`/pour` step, so an author moving work between interactive and
autonomous modes maintains two representations of the same task and the
task's form depends on which mode last touched it.

## Direction [COMPLETE]

### Approaches

#### A1 — Status quo

Keep ADR-004 as-is: `docs/specs/` for design, `.tickets/` for work,
`/pour` as the mandatory compile-and-freeze gate between them. Zero
work, battle-tested, bypass bug stays fixed. The author keeps
maintaining two representations and the mode-switch drift persists.
Addresses none of RC1–RC3. Scope: none.

#### A2 — Status as the freeze boundary

One task artifact lives under the spec directory. A `status` field
encodes the freeze transition (`draft → approved → closed`, plus
`cancelled`), replacing the directory move. Dependency edges move into
task frontmatter with a schema. The `tk` frontier query is forked or
extended to read status and edges directly from the spec directory. The
`commit-msg` and read-guard defenses re-aim from path/id-shape to
status. `/pour` is removed; spec completion becomes a spec-scoped query
("all tasks closed"). One representation across both modes; freeze
survives mode switches. Largest blast radius. Scope: large.

#### A3 — Defer `/pour`, keep the split

Leave both namespaces and `/pour` intact but make pour lazy: interactive
work runs against the spec file in place, and pour runs only when
handing to ralph. Small change, ADR-004 invariant untouched, removes
interactive ceremony. The two representations still appear the moment
pour runs; RC1's location encoding and the mode-switch seam remain.
Treats the symptom. Scope: small.

#### A4 — Collapse namespace, keep edges in overview prose

Single artifact and status freeze like A2, but leave dependency edges as
Shared Surfaces prose in `_overview.md` and live-parse them on every
frontier query instead of moving them to frontmatter. Humans author
coupling in one narrative place; no frontmatter edge schema to design.
Promotes a one-time compile error into a recurring runtime parser in
`tk ready`'s hot path. Half-addresses RC2. Scope: medium.

### Decision Matrix

Problem: a task's freeze point, identity, and edges are split across two
namespaces joined by mandatory `/pour`, forcing two representations
whose form depends on the last mode to touch them.

| Criterion | A1 — Status quo | A2 — Status freeze, frontmatter edges | A3 — Defer pour | A4 — Collapse, prose edges |
| --- | --- | --- | --- | --- |
| Freeze as state not location (RC1) | 🔴 location-encoded | 🟢 status field is the freeze | 🔴 still location-encoded | 🟢 status field is the freeze |
| Edges have a source after pour removed (RC2) | ⚪ pour still compiles them | 🟢 frontmatter schema, parsed once | ⚪ pour retained | 🔴 live-parses prose every query |
| Identity decoupled from position/name (RC3) | 🔴 ordinal-hex-slug composite | 🟢 opaque token, cosmetic slug | 🔴 composite retained | 🟡 token possible, not the focus |
| Freeze survives mode switch (AC1) | 🔴 two reps, form depends on mode | 🟢 one rep, one freeze signal | 🔴 two reps once poured | 🟢 one rep, one freeze signal |
| Bypass defense keeps a referent (AC2) | 🟢 hooks key on split as-is | 🟡 re-aimed to status | 🟢 split intact | 🟡 re-aimed to status |
| Completion anchor re-homed (AC3) | 🟢 `epic:` written by pour | 🟡 spec-scoped query, sweep rewrite | 🟢 `epic:` retained | 🟡 spec-scoped query |
| Implementation cost [ID] | 🟢 none | 🔴 large blast radius | 🟢 small | 🟡 medium |
| Runtime robustness [ID] | 🟢 compile-once errors | 🟢 compile-once errors | 🟢 compile-once errors | 🔴 fragile parser in hot path |

A1 scores well only on criteria the status quo itself defined (AC2, AC3,
cost) and is red on every root cause. A3 defers the seam rather than
closing it. A4 matches A2 on the freeze but takes two reds (RC2 and
runtime robustness) to keep edges in prose. A2 is the only column with
no red on a root cause; its costs are concentrated in implementation
effort and two defenses that need re-aiming, which is work, not risk.

### Chosen Approach

> **Chosen: A2 — Status as the freeze boundary.** Move the freeze
> invariant from filesystem location to a task `status` field, collapse
> to a single per-spec artifact, give dependency edges a frontmatter
> schema, and re-aim the bypass defenses at status. This is the only
> approach that addresses all three root causes: it makes the freeze
> survive mode switches (RC1, AC1), gives edges a parsed-once source
> after `/pour` is removed (RC2), and decouples identity from position
> and name via an opaque token with a cosmetic slug (RC3). It
> deliberately accepts a large blast radius and the work of re-homing
> the bypass defenses (AC2) and the completion anchor (AC3).

#### Assumptions that must hold

- A forked or extended `tk` can compute the frontier by reading task
  `status` and frontmatter edges directly from the spec directory,
  rather than owning a separate `.tickets/` store. This is the
  load-bearing technical bet; spike it early in Design.
- The `draft → approved` freeze is mechanically enforced, not merely
  conventional. A hook (or `tk ready` itself) must refuse work against a
  `draft` task, or the collapse reopens the original bypass bug in a new
  shape (AC2).

#### Failure modes

- Re-opening an `approved` task to `draft` to mutate its contract could
  silently invalidate downstream edges. The re-open behavior must flag
  affected dependents rather than mutate quietly.

- **Bootstrap (self-reference).** This spec's own tasks are authored in
  the old system, and tasks 7 and 8 remove the `/pour` and `tk`
  machinery that an autonomous loop would use to execute them. The spec
  must be executed interactively (driven by task file path, not poured),
  and tasks 1-6 must land before 7-8 so the new CLI and protocols exist
  before the old ones are removed. The project's `.tickets/` directory
  is already fully drained (zero open), so no in-flight tk work is at
  risk; the constraint is purely about this spec's own execution order.

#### Residue check

Executing A2 perfectly leaves nothing in RC1–RC3 unaddressed. One
adjacent item stays out of scope: `tk`-native body-editing ergonomics
(ADR-004's noted friction). Single-artifact plain-Markdown editing eases
this in practice, but improving `tk`'s own editor is not this spec's
concern.

### Use Cases

| Actor | Intent | Outcome |
| --- | --- | --- |
| Interactive author | Work a generated task directly without a promotion step | Reads and implements against the single task artifact; no `/pour` to run |
| Interactive author | Refine a task's outcomes after first drafting it | Re-opens the task to `draft`, edits, re-approves; downstream dependents are flagged |
| Author switching to autonomous | Hand the same spec to ralph without re-shaping tasks | ralph reads the identical artifacts; nothing is relocated or reformatted |
| ralph (autonomous) | Pick up the next unblocked task | `tk ready` computes the frontier from status and frontmatter edges in the spec directory |
| ralph (autonomous) | Avoid implementing an unsettled task | A status gate refuses work against any task still in `draft` |
| PM sweep | Detect a finished spec | A spec-scoped query confirms every task is `closed`, with no `epic:` indirection |
| Author referencing past work | Cite a task in a commit months later | The opaque token in `Refs:` still resolves after reorders and slug rewrites |

## Design [COMPLETE]

### Context

Codebase research grounded the decomposition and changed one load-bearing
assumption from Direction.

#### The frontier tool is the in-repo `spec` CLI, not a forked `tk`

`tk` is an opaque external dependency: the `wedow/ticket` bash binary,
fetched and wrapped through Nix. It hardcodes `.tickets/` as its store
with no directory indirection, so A2's "fork or extend `tk`" assumption
would mean owning a fork of an external tool forever. The in-repo `spec`
CLI is the better base: it already exists, is read-only by charter,
is tested, and parses task frontmatter today (it has `status` and `tasks`
subcommands). Extending it with a `ready` frontier query and a
`dependents` query extends something we own. (See [Addendum A.1](#a1) for
both tools' locations and the CLI's current shape.)

This cascades into retiring `tk` entirely. `tk` is not only the frontier
query; it is the mutation and state layer (status changes, dependency
wiring, the review comments the Reviewer role writes). With the task file
as the single source of truth, status becomes a frontmatter edit, edges
live in frontmatter, and review feedback lands in the `<review>` block
already present in the task template. Nothing `tk` does remains. Retiring
it supersedes ADR-001 (tk over beads) as well as ADR-004.

#### The read-guard's purpose inverts

`spec-read-guard.sh` today blocks reading numbered spec task files under
`RALPH_SESSION=1`, because in the old model those files are not work
items. In the unified model an `approved` task *is* the work item, so
blocking reads is wrong. The guard is retired rather than re-aimed: the
`spec ready` status filter only surfaces approved tasks and the
commit-msg hook catches a commit referencing a non-approved task, so a
third PreToolUse layer parsing frontmatter on every read would overlap
both. (See [Addendum A.2](#a2) for the two hooks' match logic.)

#### Where the Adjacent Constraints land

- **AC1 (freeze survives mode switch)** lands in the task schema (task 2):
  the `status` field is the single freeze signal both modes read.
- **AC2 (bypass defense keeps a referent)** lands in task 4: the
  commit-msg hook re-aims from `.tickets/` file existence to task
  status, and the now-redundant read-guard is retired.
- **AC3 (completion anchor re-homed)** lands in the authoring and
  protocol rewrites (tasks 7 and 6): the `epic:` field is removed and
  completion becomes a spec-scoped "all tasks closed" query.

#### Resolved scope decisions

- **Frontier tool**: extend the in-repo `spec` CLI. Confirmed with the
  driver.
- **`tk`'s fate**: retire entirely. Confirmed with the driver.
- **`tk` retirement strategy**: drain, don't migrate. The project's
  `.tickets/` is already fully drained (zero open), so `tk` removal is a
  clean deletion, not a wait. Kept in this spec rather than split to a
  follow-up because the removal is cheap now and yields one coherent
  "tk is gone" end state.
- **Read-guard hook**: retire it (task 4), don't re-aim. The `spec
  ready` status filter and the commit-msg hook already cover the bypass;
  a third PreToolUse layer would overlap both.
- **Existing specs**: a migration task (task 5) converts them to the new
  schema rather than relying on the CLI to tolerate two schemas
  indefinitely.

#### Design review outcome

A `code-critic` + `grug-architect` council reviewed the spec. The
non-controversial fixes (two missing dependency edges, the bootstrap
note, the stale-drain correction, file-overlap entries) were applied
directly. The judgment calls were resolved with the driver: retire the
read-guard, merge the two protocol rewrites into one task, add a
migration task, and keep `tk` retirement and the `dependents` query in
scope.

### Tasks

| ID | Title | Priority | Category |
| --- | --- | --- | --- |
| `1-2e23-record-lifecycle-decision` | Record the unified-lifecycle decision | 0 | documentation |
| `2-b01a-define-task-schema` | Define the unified task artifact schema | 0 | infrastructure |
| `3-1ea5-extend-cli-frontier-queries` | Extend the spec CLI with frontier and dependent queries | 1 | functional |
| `4-de92-reaim-defenses-to-status` | Re-aim mechanical defenses to task status | 1 | infrastructure |
| `5-5760-migrate-existing-specs` | Migrate existing specs to the unified schema | 2 | infrastructure |
| `6-a93b-rewrite-protocols` | Rewrite protocols for the unified lifecycle | 2 | documentation |
| `7-4919-remove-pour-reconcile-authoring` | Remove pour and reconcile spec and init authoring | 3 | functional |
| `8-1109-retire-tk-dependency` | Retire the tk dependency | 4 | infrastructure |

### Execution Order

- [1-2e23](1-2e23-record-lifecycle-decision.md) — Record the decision
  first so the superseding ADR is the reference every later task edits
  against.
- [2-b01a](2-b01a-define-task-schema.md) — Define the artifact schema
  next; the status enum, identity scheme, and frontmatter edges are the
  contract the CLI, hooks, and protocols all depend on.
- [3-1ea5](3-1ea5-extend-cli-frontier-queries.md) — Build the frontier
  and dependent queries against the schema; this is the tool the
  protocols will point at.
- [4-de92](4-de92-reaim-defenses-to-status.md) — Re-aim the commit-msg
  hook to task status and retire the read-guard, which the CLI's status
  filter makes redundant.
- [5-5760](5-5760-migrate-existing-specs.md) — Convert existing specs
  (and this spec's own files) to the new schema so the CLI and hooks
  read consistent fields everywhere they scan.
- [6-a93b](6-a93b-rewrite-protocols.md) — Rewrite RALPH.md and
  INTERACTIVE.md together to use the new CLI command, status-based work
  source, and spec-scoped completion.
- [7-4919](7-4919-remove-pour-reconcile-authoring.md) — Remove `/pour`
  and reconcile `/spec` and `/init` authoring once every consumer of the
  old model has been moved.
- [8-1109](8-1109-retire-tk-dependency.md) — Retire `tk` last, after
  nothing references it and `.tickets/` has drained.

### Glossary

- **Freeze transition** — the `draft → approved` status change after
  which a task's contract fields (Outcomes, Verification, edges) are
  write-once until explicitly reopened to `draft`.
- **Frontier** — the set of tasks that are `approved`, unblocked by any
  incomplete dependency, and assigned to a given assignee; what
  `spec ready` computes.
- **Identity token** — the stable opaque part of a task id, independent
  of ordinal position and the cosmetic slug.
- **Reopen** — moving an `approved` task back to `draft` to change its
  contract; the signal that dependents (via `spec dependents`) should be
  re-checked.
- **Drain-then-retire** — finishing in-flight `.tickets/` work under the
  old system and removing `tk` once the directory is empty, rather than
  migrating ticket data.

#### Files touched by multiple tasks

- `plugins/socrates/templates/spec` — Task 3 (add frontier query),
  Task 7 (drop `poured` from `status` output). The `poured` vocabulary
  is removed in concert with task 2 (template enum) and `spec-format.md`.
- `plugins/socrates/templates/task.md` — Task 2 (schema, including the
  `status` enum comment that still names `poured`)
- `plugins/socrates/templates/commit-msg.sh`,
  `plugins/socrates/templates/spec-read-guard.sh` — Task 4 (re-aim or
  retire). Task 8 verifies no residual `tk`/`.tickets/` referent
  remains, so task 4 must fully de-`tk` whatever it keeps.
- `plugins/socrates/templates/RALPH.md` — Task 6 (protocol rewrite)
- `plugins/socrates/templates/INTERACTIVE.md` — Task 6 (protocol rewrite)
- `plugins/socrates/commands/init.md` — Task 4 (drop read-guard
  install), Task 7 (authoring), Task 8 (tk removal from setup)
- `docs/spec-format.md` — Task 2 (schema semantics), Task 7 (pour
  removal)
- `docs/adrs/` — Task 1 (new ADR, supersede 004 and 001)

#### Dependencies

Task 2 -> Task 3
Task 2 -> Task 4
Task 2 -> Task 5
Task 2 -> Task 7
Task 3 -> Task 5
Task 3 -> Task 6
Task 3 -> Task 7
Task 4 -> Task 6
Task 5 -> Task 7
Task 6 -> Task 7
Task 7 -> Task 8

Task 1 has no hard dependency but is sequenced first as the reference
record. Arrow reads "must complete before." Task 5 (migration) follows
the schema (task 2) and CLI (task 3) so it converts files to a defined
target and can verify against the running CLI. Tasks 2 and 3 precede
task 7 because task 7 edits the frontmatter schema and the `spec` CLI
those tasks own.

## Technical Addendum

<a id="a1"></a>
### A.1 — Frontier tools: tk and the spec CLI

- `tk` is `wedow/ticket` v0.3.2, fetched and wrapped as a Nix
  derivation at `nix/packages/ticket/default.nix`. It is a single bash
  binary that hardcodes `.tickets/` as its store; no flag or env var
  redirects the directory.
- Ticket frontmatter schema (from `.tickets/*.md`): `id`, `status`,
  `deps`, `links`, `created`, `type`, `priority`, `assignee`, `parent`,
  `tags`.
- The in-repo `spec` CLI lives at `plugins/socrates/templates/spec`,
  packaged via `nix/packages/spec-cli.nix` as a binary named `spec`.
  It is read-only and re-derives state from the filesystem on every
  call. Current subcommands: `status` (per-spec phase + task counts) and
  `tasks` (with `--status` and `--review` filters). It already parses
  task frontmatter via an `fm_value` helper and scans `<review>` blocks.
  Tests at `plugins/socrates/templates/spec.test.sh`.

<a id="a2"></a>
### A.2 — Mechanical defense hooks

- `plugins/socrates/templates/commit-msg.sh` — greps the commit body
  for `^Refs:[[:space:]]+`, extracts the ref, and warns if
  `.tickets/${ref}.md` does not exist. Warn-only, never blocks.
- `plugins/socrates/templates/spec-read-guard.sh` — a `PreToolUse` hook
  on Read/Edit/Write. No-op unless `RALPH_SESSION=1`. Matches resolved
  paths against `/docs/specs/[^/]+/[0-9]+-[^/]+\.md$` and exits 2 (deny)
  on a match. References ADR-004 in its denial message.

<a id="a3"></a>
### A.3 — Superseded records

- ADR-004 (`docs/adrs/004-spec-ticket-namespace-separation.md`) — the
  namespace-separation decision this spec reverses.
- ADR-001 (`docs/adrs/001-tk-over-beads.md`) — the tk-over-beads
  decision retired when tk is removed.
- The bypass bug that motivated ADR-004: commits `bdceea8` (guard
  against un-poured spec task implementation) and `b7ac7ff`
  (reinforcement).
