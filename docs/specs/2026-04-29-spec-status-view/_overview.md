---
title: Spec Status View
created: 2026-04-29
epic: soc-qzop
archived:
delimit_approved: true
---

## Describe [COMPLETE]

### Situation

The Socrates project organizes design work as directories under
`docs/specs/`, each containing an `_overview.md` (phase-tagged
narrative of Describe → Diagnose → Delimit → Direction → Design)
and one Markdown file per implementation task (`status:
draft|approved|poured`). Open deferred concerns live separately
under `docs/gaps/` as standalone files. Tasks may surface review
notes inside a `<review>` block awaiting the spec author's
attention.

While dogfooding Socrates, the project has reached the point
where more than one spec is live simultaneously (one unpoured
spec, one open gap, and a third about to start). Multiple actors
need to answer "where are we across all specs?" today — the human
spec author, the RALPH PM role, the agent running
`/socrates-spec`, and the agent running `/pour`. None of them
have a unified affordance; each does its own ad-hoc traversal of
the same files.

For the human, this means opening each `_overview.md`, scanning
phase markers, then opening every task file to read `status:`
frontmatter and check for `<review>` content — N × (1 + M) file
opens for one sweep, and the same dance to *change* a status. For
agents, it means re-implementing the traversal in
prose-and-bash each time.

### Known facts and constraints

- Per-spec status is split across two surfaces: the overview's
  phase markers (`[DRAFT]` / `[COMPLETE]` / `[APPROVED]` plus
  `delimit_approved:` frontmatter) and per-task `status:`
  frontmatter (`draft` / `approved` / `poured`).
- Open review attention lives inside individual task files as
  the `<review>` block — invisible without opening the file.
- Open deferred concerns live as files under `docs/gaps/` —
  their presence is the lifecycle (no status field).
- Archived specs live under `docs/specs/archive/` and are out of
  scope for any "current state" view.
- `tk` exists for ticket-level state but does not speak about
  specs or gaps. Precedent for terse status views (`tk ready -a
  ralph`) is established and used every session.
- RALPH.md already prescribes a "Spec Lifecycle Sweep" the PM
  role runs every cycle: iterate `docs/specs/*/`, read each
  overview's frontmatter, call `tk show <epic-id>` per spec.
  This is hand-rolled traversal, not a tool call.
- `/socrates-spec` resume detection scans the same directories
  and re-implements the phase-marker parser in agent prose at
  every session. `/pour` does its own scan to find approved
  tasks.
- The human author has tried no workaround; today's loop is
  "open each file by hand".

### Open questions

- **Single interface or two?** Human and agents both traverse
  the same files for similar information. Whether they need
  *one* affordance or *separate* ones (e.g., a CLI for humans,
  a documented protocol for agents) is unresolved and will be
  tested in Diagnose.
- **Read-only or read-write?** The author has not separated
  awareness ("show me") from mutation ("flip this task to
  approved"). Both are felt; the right scope is unknown.
- **Where do gaps fit?** The author wants gaps visible
  alongside specs. Whether that is the same view, a sibling
  view, or a join is undefined.
- **Granularity unit.** What is the natural unit when the
  author asks "where are we?" — the spec, the task, a
  recency-ordered mixed list? Unknown.

### Stakeholders and impact

- **Spec author (current dogfood user)**: orients each session
  by opening files one by one; cost grows linearly with live
  specs.
- **RALPH PM role**: runs the Spec Lifecycle Sweep every cycle
  by re-implementing traversal in prose-and-bash; brittle,
  repetitive, and silently re-derived per session.
- **Agent running `/socrates-spec`**: re-derives "what specs
  exist and what phase each is at" at every invocation, by
  reading and parsing files directly.
- **Agent running `/pour`**: scans for approved tasks via
  ad-hoc traversal of the same files.
- **Future Socrates users**: inherit the same friction the
  moment they run more than one concurrent spec.

## Diagnose [COMPLETE]

### Hypotheses

**H1 — There is no machine-readable index of spec/task state.**
*Status: Confirmed.*
`tk` covers ticket state but knows nothing about specs or gaps.
No file aggregates spec phase, task status, or review notes.
Every reader (human, RALPH PM, `/socrates-spec`, `/pour`) opens
directories and parses Markdown ad-hoc. Disproof would require
finding an existing index — none exists.

**H2 — Status is fragmented across surfaces (phase markers in
section headers, `delimit_approved:` in frontmatter, `status:`
in task frontmatter, `<review>` in task body, gaps as bare
files).**
*Status: Confirmed as constraint, not as separate root cause.*
The fragmentation is real and a tool must handle it, but it is
not the cause of the friction — even a single, uniform status
field would still require ad-hoc traversal in the absence of
H1. H2 is a *shape constraint* on any solution to H1.

**H3 — Only the human suffers; agents function fine with
prose-and-bash.**
*Status: Rejected.*
Agent flows technically work but pay the same cost: RALPH.md
prescribes a multi-step traversal in prose at every PM cycle;
`/socrates-spec` re-implements a phase-marker parser at every
session resume; `/pour` re-scans for approved tasks each
invocation. Each is brittle (drifts when the markdown shape
changes) and silently re-derived. The pain shape differs
(humans feel time; agents feel correctness risk and prose
bloat) but the cause is shared.

**H4 — The friction is a volume problem; archive discipline
solves it.**
*Status: Rejected.*
The human author already feels the friction at three live
specs, and any future Socrates user hits it at *any* volume >
1. Archive discipline reduces the working set but does not
address the re-derivation cost agents pay every cycle, nor the
fragmentation across surfaces.

### Root cause

- **R1 — No machine-readable index of spec/task state.** Every
  actor that needs to answer "where are we?" opens files and
  parses Markdown ad-hoc. The cost is felt as time by the human
  and as prose-and-bash brittleness by the agents.

### Symptoms (downstream of R1)

- Human opens N × (1 + M) files for one status sweep.
- RALPH PM re-implements the Spec Lifecycle Sweep in prose
  every cycle; the parser drifts when overview shape changes.
- `/socrates-spec` and `/pour` each re-derive a similar
  traversal, with no shared definition of "phase" or "task
  status".
- Aggregate queries — "all approved-but-unpoured tasks across
  all specs", "all tasks with open `<review>` blocks", "open
  gaps" — are not expressible without a tool.
- Status mutation (e.g., flipping `draft` → `approved`)
  requires opening the file in `$EDITOR` and editing
  frontmatter by hand.

### Constraints on the solution

- **C1 — Markdown remains canonical.** Files under
  `docs/specs/` and `docs/gaps/` are the source of truth. The
  index is a *derived view* of file state — re-derivable,
  drift-free, no new authoritative store. Any mutation flows
  back to the file.
- **C2 — Status fragmentation must be handled by the tool, not
  flattened in the data model.** Phase markers, task
  frontmatter, `<review>` blocks, and gap files all stay where
  they are; the tool reads each and presents a unified
  surface.
- **C3 — Both human and agent must benefit from the same
  affordance.** Per the Describe open-question test: agents
  re-implementing traversal pay a real cost (H3 rejected), so
  the same tool that serves the human should also be callable
  from RALPH.md prose, `/socrates-spec`, and `/pour` to remove
  the prose-bash duplication.

## Delimit [APPROVED]

The Socrates project has no machine-readable index of spec or
task state, forcing every actor that needs to orient across live
specs — the human author, RALPH's PM role, `/socrates-spec`, and
`/pour` — to open Markdown files and re-implement ad-hoc
traversal each time, which scales linearly with the number of
live specs and silently drifts when the file shape changes.

## Direction [COMPLETE]

### Approaches

**A1 — Status Quo.** No index. Every actor keeps opening files
and parsing Markdown. Cost grows linearly with live-spec count;
agent prose stays brittle. Baseline.

**A2 — A `tk`-style CLI: a new command that derives the index
from filesystem state on each invocation.** Reads
`docs/specs/*/_overview.md` and task files, parses phase markers
and frontmatter, emits a list/table. Read-only subcommands for
filters (`--phase`, `--status`, `--review`, gaps). Markdown
stays canonical (C1); the CLI is a pure derived view (re-runs
re-derive). Both human and agents call it (C3). Scope: a small
script under `bin/` or shipped with the plugin.

**A3 — An auto-generated index file (`docs/specs/_INDEX.md`)
committed to the repo.** A script (run via Make target,
pre-commit hook, or `/socrates-spec` housekeeping) walks the
tree and rewrites the index. Humans read the file directly;
agents `cat` it. Queryable by `grep`. Risk: drift if forgotten;
one more thing to keep current. Markdown stays canonical (C1).

**A4 — A `/socrates-status` slash command (no shell command).**
A new plugin slash command that, when invoked, loads agent
context with the parsed state and renders it. No CLI — only
callable inside Claude Code. Misses C3 partially: RALPH's PM
sweep is a prose protocol executing shell, not interactive
slash commands.

**A5 — Extend `tk` itself.** Add `tk specs`, `tk gaps`
subcommands. Co-locates with the existing ticket affordance the
author already trusts. Risk: bleeds Socrates concerns into
`tk`, which is a general-purpose ticket store; couples the two
tools.

### Decision Matrix

*Problem: Socrates has no machine-readable index of spec or
task state, forcing every actor to re-implement ad-hoc Markdown
traversal.*

| Criterion | A1 Status Quo | A2 CLI (derived) | A3 Generated index | A4 Slash command | A5 Extend tk |
|---|---|---|---|---|---|
| Addresses R1 | 🔴 | 🟢 | 🟢 | 🟢 | 🟢 |
| Both human + agent (C3) | 🔴 | 🟢 | 🟢 | 🔴 | 🟢 |
| Markdown stays canonical (C1) | 🟢 | 🟢 | 🟢 | 🟢 | 🟢 |
| No drift (re-derivable) | 🟢 | 🟢 | 🔴 (can stale) | 🟢 | 🟢 |
| No bleed into other tools | 🟢 | 🟢 | 🟢 | 🟢 | 🔴 (couples tk) |
| Implementation complexity | 🟢 (none) | 🟡 (small CLI) | 🟡 (script + hook) | 🟡 (plugin command) | 🔴 (cross-repo) |
| Ergonomic for ad-hoc shell | 🔴 | 🟢 | 🟡 (grep) | 🔴 (Claude only) | 🟢 |

**Notes on the matrix**

- A3's drift risk is real: a committed `_INDEX.md` either gets
  stale or requires a hook everyone runs. Each new hook adds
  friction.
- A4 fails C3 specifically for the RALPH PM sweep: RALPH
  executes prose protocol in shell, not slash commands. A
  slash-only affordance leaves the PM cycle still
  re-implementing traversal.
- A5 couples Socrates state into `tk`'s state machine, which is
  intentionally general-purpose.

### Chosen Approach

**A2 — Read-only CLI (derived view).** Smallest change that
addresses R1 directly. Pure derivation from Markdown means no
drift and no new authoritative store (C1). Callable from human
shells, RALPH.md prose, and slash commands invoking `Bash`,
serving every actor uniformly (C3). Read-only by design (see
Resolved scope decisions below).

### Use Cases

| Actor | Intent | Outcome | How |
|---|---|---|---|
| Spec author | Orient across all live specs at session start | One command output shows every spec, its current phase, and per-task status; no file-by-file scan | (Design) |
| Spec author | Know what's ready to `/pour` without opening every task file | Filter shows approved-but-unpoured tasks across all specs | (Design) |
| Spec author | See where their attention is wanted | Filter shows tasks with non-empty `<review>` blocks | (Design) |
| RALPH PM role | Drive the Spec Lifecycle Sweep without re-implementing traversal | The PM section in RALPH.md replaces hand-rolled iteration with a tool call that lists candidate-completed specs | (Design) |
| `/socrates-spec` resume detection | Detect a spec's current phase without re-implementing the parser | The slash command shells out for phase data; the parser lives in one place | (Design) |
| `/pour` command | Find approved-but-unpoured tasks deterministically | Same shell-out, same single source of derivation | (Design) |

### Resolved scope decisions

- **Read-only.** The CLI does not mutate spec or task files.
  Approving a task or marking a phase complete remains a
  deliberate manual act in an editor, where the author can read
  the full context before changing state. This resolves the
  Describe open question on read vs read-write.
- **Gaps are intentionally not a CLI subcommand.** `ls
  docs/gaps/` already lists open gaps adequately; adding a
  `spec gaps` subcommand would duplicate that with little
  added value. If a future need surfaces (e.g., showing
  `discovered_in` in a single line), it can be added to a
  follow-up spec.
- **Markdown is the source of truth (C1).** The CLI re-derives
  from filesystem state on every call; no persisted index file,
  no new state store.
- **Service-shape:** a shell-callable command (not slash-only),
  so RALPH's prose protocol and `/socrates-spec`/`/pour` agent
  flows can all invoke it uniformly (C3).
- **Tool placement, command name, language, and exact subcommand
  surface** are all deferred to Design.

## Design [COMPLETE]

### Context

The chosen approach (A2) ships a small read-only bash CLI that
re-derives spec/task/gap state from filesystem files on every
invocation. Codebase research (`docs/specs/2026-04-29-spec-status-view/`)
established the following grounding:

- **Language is bash + `jq`.** Every existing script in the
  plugin uses bash with `set -uo pipefail` and reaches for `jq`
  when JSON parsing is needed. Examples:
  `plugins/socrates/templates/ralph.sh`,
  `plugins/socrates/templates/spec-read-guard.sh`. No other
  language ships with the plugin.
- **CLI source script lives under
  `plugins/socrates/templates/`.** This is the home for
  shipped shell scripts; the existing Socrates plugin Nix
  package at `nix/packages/skills/socrates/default.nix`
  (lines 11–23) copies `templates/` wholesale into
  `$out/share/claude/skills/socrates/templates/`, so a
  source-script copy lives there for browsing and for
  non-Nix consumers. The runtime install path is a
  separate Nix package built with
  `pkgs.writeShellApplication` (or equivalent) that exposes
  the binary as `spec` on `PATH`; this also runs shellcheck
  during the build, gating quality of any bash that ships.
- **Naming convention.** Slash commands follow `socrates-*`
  (`nix/modules/devenv/socrates.nix:29`); installed binaries
  use a short, unprefixed name (the user explicitly chose
  `spec` over `socrates-status` for ergonomics in the
  human-facing shell).
- **Test convention is bash + `jq` + exit codes.** Tests live
  alongside the script as `<name>.test.sh` and use a hand-rolled
  `run()` helper. See
  `plugins/socrates/templates/spec-read-guard.test.sh` for the
  established pattern. No external test framework is in use.
- **Source-of-truth file shapes are stable and documented.**
  Spec frontmatter
  (`docs/specs/2026-04-29-pr-review-loop/_overview.md` lines
  1–7), task frontmatter
  (`plugins/socrates/templates/task.md` lines 1–11), gap
  frontmatter
  (`docs/gaps/socrates-upgrade-flow.md` lines 1–6), and phase
  markers (`[DRAFT]` / `[COMPLETE]` / `[APPROVED]` in section
  headers) are the parser's input grammar.
- **The parser logic the CLI replaces lives in three protocol
  surfaces today**: the resume-detection prose at
  `plugins/socrates/commands/spec.md:112–126`, the approved-task
  partition at `plugins/socrates/commands/pour.md:20–26`, and
  the PM Spec Lifecycle Sweep at
  `plugins/socrates/templates/RALPH.md:40–50`. Each will become
  a CLI invocation.
- **No CLI executables exist in the plugin yet.** This script is
  the first; the implementer is establishing the
  pattern future CLIs will follow.
- **`.pre-commit-config.yaml` is Nix-managed.** The file is a
  read-only symlink into the Nix store, generated by
  `git-hooks.nix` from the configuration in
  `nix/devenvs/default.nix` (see the existing
  `git-hooks.hooks.nixfmt` block for the established
  pattern). Adding a shellcheck hook means adding a new
  `git-hooks.hooks.shellcheck` block to that Nix file — *not*
  editing the yaml. The header of the yaml itself says
  "DO NOT MODIFY".

### Tasks

| ID | Title | Priority | Category |
|---|---|---|---|
| [1-ac32](1-ac32-build-cli.md) | Build the spec-status CLI | 0 | functional |

### Execution Order

- [1-ac32](1-ac32-build-cli.md) is the only task. It builds
  the `spec` CLI as one coherent change: source script at
  `plugins/socrates/templates/spec`, packaged as a Nix-built
  binary via `pkgs.writeShellApplication` (which runs
  shellcheck at build time), with a sibling pre-commit
  shellcheck hook added in `nix/devenvs/default.nix`
  (`git-hooks.hooks.shellcheck`). Pins the subcommand
  surface (`spec`, `spec status`, `spec tasks
  [--status STATUS] [--review]`), the human-text output
  format including the `TICKET` column, and example outputs
  derived from the project's current state. Tests follow
  the existing bash harness pattern against a fixture tree
  (not the real project state).

### Scope explicitly deferred

The design review council surfaced two pieces of work that
*could* land in this spec but were cut to keep the smallest
shipping increment:

- **Rewrite of four tooling surfaces to call the CLI** —
  RALPH.md PM Spec Lifecycle Sweep, `/socrates-spec` resume
  detection, `/socrates-spec --status` summary, and `/pour`
  approved-task partition all currently re-implement the
  parser in prose. They will continue to do so until a
  follow-up spec wires them to the CLI. Recorded as a gap at
  `docs/gaps/protocol-prose-traversal-rewrites.md` so the
  deferral is visible and re-discoverable.
- **`--json` machine-readable output** — not added in this
  spec because no agent caller exists yet (per the
  deferral above). When the protocol-rewrite spec is
  written, the JSON output and the agent-side parser
  contract get designed together; doing it now would
  freeze a contract before observed use.

### Glossary

- **`spec`** — the new read-only bash CLI introduced by this
  spec, installed on `PATH` as a Nix-built binary.
  Re-derives spec/task/gap state from filesystem files on
  every invocation. Markdown stays canonical.
- **Phase marker** — the `[DRAFT]` / `[COMPLETE]` /
  `[APPROVED]` token attached to a section header in
  `_overview.md`. Together with the `delimit_approved:`
  frontmatter field, it identifies which Design-in-Practice
  phase a spec is currently in.
- **Task status** — the `status:` frontmatter field on a task
  file: one of `draft`, `approved`, `poured`, or
  `cancelled`.
- **Open gap** — any `*.md` file present under `docs/gaps/`.
  Existence is the lifecycle; deletion (via `git rm`) is the
  close.

#### Shared Surfaces

This spec ships one task; there are no cross-task surfaces
to record. The CLI's subcommand surface, output columns, and
packaging shape are pinned in the task's `<outcome>` so a
future spec wiring agent consumers (see the deferred
protocol-prose-traversal-rewrites gap) has a fixed contract
to read.

### Boundary notes

- **`/socrates-spec --status` composition.** The existing
  `/socrates-spec --status` invocation (documented in
  `plugins/socrates/commands/spec.md`) describes a status
  summary the slash command renders. It is not in this
  spec's scope; once the CLI exists, a future change can
  rewrite that section to shell out to `spec status`, but
  until then both coexist with no conflict.
- **`tk` boundary.** The CLI knows nothing about ticket
  state; it parses spec/task/gap Markdown only. The PM
  Spec Lifecycle Sweep continues to call `tk show` for
  epic/children closure. When the protocol-rewrite
  follow-up lands, the protocol composes the two — CLI
  answers "what specs have epics set" and `tk` answers
  "is the epic closed".
- **First-executable precedent.** No CLI has shipped from
  the Socrates plugin before. This spec establishes the
  pattern future CLIs follow: source script under
  `plugins/socrates/templates/`, packaged as a Nix-built
  binary using `pkgs.writeShellApplication` (so shellcheck
  runs at build time), and gated by a shellcheck pre-commit
  hook. Binary names are short and unprefixed (`spec`),
  while slash commands keep the `socrates-` prefix.
