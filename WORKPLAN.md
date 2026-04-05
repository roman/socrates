# Socrates — WORKPLAN

A Claude Code plugin for structured design and autonomous development. Combines Rich
Hickey's Design in Practice methodology with a git-native task system and the Ralph
loop pattern.

**Prior art**: choo-choo-ralph (beads + formulas), project-status-sync (RALPH.md +
handoffs + WORKPLAN).

**Commands**: `/init`, `/spec`, `/pour`, `/harvest`

## Phase Index

| Phase | Description | Status | Blocked By |
|-------|-------------|--------|------------|
| 0 | Spikes — validate assumptions & define protocol expectations | COMPLETE | — |
| 1 | Project scaffold & infrastructure | NOT STARTED | Phase 0 |
| 2 | Shell scripts — ralph loop & formatting | NOT STARTED | Phase 1 |
| 3 | `/init` command | NOT STARTED | Phase 1 |
| 4 | `/spec` command — full Design in Practice journey | NOT STARTED | Phase 1 |
| 5 | `/pour` command — approved tasks → tk tickets | NOT STARTED | Phase 4 |
| 6 | RALPH.md protocol & handoff system | NOT STARTED | Phases 0.5, 2 |
| 7 | `/harvest` command — learnings from handoffs | NOT STARTED | Phase 6 |
| 8 | Documentation | NOT STARTED | Phases 3-7 |
| 9 | Skills & AI guidance | NOT STARTED | Phases 4, 6 |

---

## Phase 0 — Spikes

Validate assumptions before building anything. Each spike is throwaway.

- [x] 0.1: **tk reliability** — Install tk, create 20-30 tickets with deps, run
  `tk ready`, `tk close`, `tk dep tree`. Verify file writes are correct after each
  operation. Test concurrent access: run two simultaneous
  `tk ready -a ralph && tk start $(tk ready -a ralph | head -1 | awk '{print $1}')`
  in a tight loop 50 times, verify no task is started twice. Also verify that
  `tk ready` produces parseable output (JSON or stable table format) that
  ralph.sh can reliably extract task IDs from.
- [x] 0.2: **tk dependency support** — Verify that `tk dep` can express task-to-task
  dependencies, and that `tk ready` correctly excludes tasks whose deps are not
  closed. Test: create A depends-on B, verify A does not appear in `tk ready`
  until B is closed.
- [x] 0.3: **gh API review metadata** — Run `gh api repos/<owner>/<repo>/pulls/<n>/comments`
  on a real PR with line comments. Verify JSON contains: comment body, file path,
  line number, commit SHA, author, thread resolved status.
- [x] 0.4: **tk Nix packaging** — Write a Nix derivation for tk (single bash script + jq dep).
  Verify it works in a sandbox.
- [x] 0.5: **Protocol test harness** — Build the infrastructure to validate that
  Claude sessions follow the protocol. Three components:
  - **Hook-based sequence logging**: PreToolUse/PostToolUse hooks that append
    tool calls (name, params, timestamp) to a JSON log. No blocking, just
    recording. Proves we can capture a full session trace.
  - **Artifact assertion script**: Post-session checks on files and git state.
    Validate: ADR format (sections, frontmatter), handoff format (required
    sections), commit messages (`Refs:` present), tk state transitions
    (ready → in_progress → closed). Pure grep/jq — no LLM.
  - **Sequence assertion script**: Parse the hook log and check ordering
    invariants. Starting set:
    - `Read RALPH.md` before any `Edit`
    - `Read docs/handoffs/*` before any `Edit src/*` (bearings before implement)
    - `tk ready` before `tk start`
    - Handoff file written before session ends
    - ADR file written when `docs/adrs/` was modified during session
  These assertions define what "correct protocol behavior" means. They must
  exist before Phase 6 writes the protocol specs, so that we can validate
  the specs against concrete expectations as they are written.
- [x] 0.6: **Checkpoint fixtures** — Create git repo snapshots representing
  distinct lifecycle states. Each fixture is a script that sets up a repo
  with known tk state, file state, and git history. Starting set:
  - `fresh-pour`: tickets exist, none started → expect Implementer triage
  - `mid-implementation`: task in_progress, partial code → expect resume
  - `review-pending`: implementation done, no review → expect Reviewer triage
  - `blocked-deps`: all ready tasks have unmet deps → expect PM escalation
  - `post-spec-no-pour`: approved tasks not poured → expect PM suggest pour
  Each fixture includes: setup script, exercise prompt, expected sequence
  invariants, expected artifacts. Test runner: setup → run claude →
  assert sequence → assert artifacts → teardown.

---

## Phase 1 — Project scaffold & infrastructure

Set up the plugin structure mirroring choo-choo-ralph's monorepo layout.

- [ ] 1.1: **Plugin manifest** — `plugins/socrates/.claude-plugin/plugin.json` with
  name, version (0.1.0), description, author, keywords.
- [ ] 1.2: **Directory structure** — Create the full tree:
  ```
  plugins/socrates/
    .claude-plugin/plugin.json
    commands/           # user-facing commands
    templates/          # installed into projects
    skills/             # AI guidance
  docs/                 # user documentation
  ```
- [ ] 1.3: **README.md** — Project overview, philosophy (Socratic method + Design in
  Practice + Ralph loop), workflow diagram, quick start.
- [ ] 1.4: **`_overview.md` template** — Define the schema for the spec overview file.
  Exact section headers, expected content format, phase status markers, and
  structured data formats (Decision Matrix, Use Cases). This template is what
  `/spec` fills in progressively. See Appendix A.
- [ ] 1.5: **Task file template** — Define the schema for individual task files.
  Frontmatter fields, body sections, status lifecycle. See Appendix B.

---

## Phase 2 — Shell scripts

Adapt ralph loop scripts from choo-choo-ralph. These use `tk` instead of `bd`.

- [ ] 2.1: **ralph.sh** — Main loop. Adapt from choo-choo-ralph's template:
  - Replace `bd ready --assignee=ralph` with `tk ready -a ralph`
  - Replace `bd update <id> --status in_progress` with `tk start <id>`
  - Replace `bd list --status=in_progress` with `tk query` equivalent
  - Keep: MAX_ITERATIONS, conflict avoidance prompt, stream-json output
- [ ] 2.2: **ralph-once.sh** — Single iteration for testing. Same adaptations.
- [ ] 2.3: **ralph-format.sh** — Copy from choo-choo-ralph as-is. No beads dependency
  in this script — it only parses Claude's stream-json output.

---

## Phase 3 — `/init` command

Scaffold a project for Socrates. Replaces choo-choo-ralph's `/install`.

- [ ] 3.1: **init.md command** — The command should:
  - Check prerequisites: `tk`, `claude`, `jq`, `gh`
  - Run `tk init` (initialize ticket tracker)
  - Copy shell scripts (ralph.sh, ralph-once.sh, ralph-format.sh)
  - Create `docs/` directory structure:
    ```
    docs/
      specs/        # spec overviews + task files
      handoffs/     # per-session narrative context
    ```
  - Generate starter RALPH.md (protocol file)
  - Generate starter CLAUDE.md additions (discipline gates)
  - Install commit-msg warning hook (warns if `Refs:` missing, does not block)
  - Create `.msgs/` inbox directory
  - Handle conflicts (ask user to skip or overwrite)

---

## Phase 4 — `/spec` command

The full Design in Practice journey. This is the core differentiator from
choo-choo-ralph. The AI drives the user through all five D's: Describe → Diagnose →
Delimit → Direction → Design. Produces an `_overview.md` and individual task files.

`/spec` subsumes what was previously two commands (`/spec` + `/design`). The Design
phase (task decomposition) is the natural final step of the same journey.

### Phases and techniques

- [ ] 4.1: **Describe phase** — AI interviews the user or reads a source document.
  Captures the situation without interpreting. Uses Reflective Inquiry technique
  ("where are you at? what do you know? what do you need to know?").
  Output: `## Describe [COMPLETE]` section in `docs/specs/<name>/_overview.md`.
- [ ] 4.2: **Diagnose phase** — AI probes for the real problem. Uses Scientific Method
  (form hypotheses, test them). Challenges "we need feature X" assertions —
  "we don't have feature X" is never a valid problem statement.
  Output: `## Diagnose [COMPLETE]` section added to overview.
- [ ] 4.3: **Delimit phase (strict gate)** — AI helps draft a crisp problem statement.
  Uses Precise Language technique. This is the only strict gate — AI will not
  proceed until user explicitly approves the problem statement. Approval is
  persisted as `delimit_approved: true` in overview frontmatter.
  Output: `## Delimit [APPROVED]` section added to overview.
- [ ] 4.4: **Direction phase** — AI generates approaches, use cases, and optionally a
  decision matrix (🟢🟡🔴⬜ format). Uses Contrast Over Linearity principle — seeing
  differences between approaches triggers thinking. User picks approach.
  Output: `## Direction [COMPLETE]` section with approach, rationale, use cases.
- [ ] 4.5: **Design phase (task decomposition)** — AI breaks the chosen approach into
  individual task files. Launches parallel sub-agents for codebase exploration +
  technology research. Generates task files in `docs/specs/<name>/` with:
  - YAML frontmatter: id (short-hash + human suffix), status (draft), priority,
    category, depends_on (list of task IDs)
  - `<steps>` — implementation steps
  - `<test_steps>` — verification criteria
  - `<review>` — empty, awaiting human review
  - Adds `<context>` to overview with existing patterns, integration points,
    conventions discovered during research.
  - Target: 5-10 implementation tasks per high-level feature. Configurable.
  Output: `## Design [COMPLETE]` section + task files.

### Resume, review, and navigation

- [ ] 4.6: **Resume capability** — `/spec` reads existing overview, detects phase
  completion via `[COMPLETE]`/`[APPROVED]` markers in section headers and
  `delimit_approved` in frontmatter. Resumes at the first incomplete phase.
  Going back: user can request "revisit Delimit" — AI sets target phase header
  to `[DRAFT]`, all subsequent phases to `[DRAFT]`. Previous content preserved
  under `### Previous (superseded)` sub-heading within the section.
- [ ] 4.7: **Task review iteration** — When run on a specific task file
  (`/spec <task-file>`), processes `<review>` feedback and regenerates.
  Same review loop as choo-choo-ralph.
- [ ] 4.8: **Approval workflow** — User changes `status: draft` to `status: approved`
  on individual task files. `/spec` can show summary of task statuses
  (how many draft/approved/poured).
- [ ] 4.9: **Source doc mode** — When a source document is provided (PRD, ticket URL,
  notes file), AI reads it first, pre-fills what it can, then asks clarifying
  questions for gaps.

---

## Phase 5 — `/pour` command

Mechanical transformation: approved task files → tk tickets. Spec task files are
frozen after pour (write-once spec artifacts). All mutable state lives in `.tickets/`.

- [ ] 5.1: **pour.md command — ticket creation** — Reads task files with
  `status: approved`, creates `tk` tickets:
  - `tk create "<title>" -t task -p <priority> -a ralph --tags <category>`
  - Sets description from task file content (steps + test_steps)
  - Reads `depends_on:` from task frontmatter, maps spec task IDs to tk ticket IDs,
    runs `tk dep <new-id> <dep-id>` for each dependency
  - Updates task file frontmatter to `status: poured` with `ticket:` field
    referencing the tk ID. This is the last write to the spec file.
- [ ] 5.2: **pour.md command — epic creation** — If multiple tasks belong to the same
  spec, creates a parent epic ticket. Child tasks get `--parent <epic-id>`.
- [ ] 5.3: **pour.md command — partial pour** — Only pours `status: approved` tasks.
  Draft tasks are left alone. Can be run incrementally.
- [ ] 5.4: **pour.md command — idempotency** — Tasks with `status: poured` are skipped.
  Safe to re-run.

---

## Phase 6 — RALPH.md protocol & handoff system

The protocol that drives autonomous sessions. Adapted from project-status-sync.

- [ ] 6.1: **RALPH.md template** — The protocol file. Contains:
  - Environment description (sandbox expectations)
  - Startup checklist: read RALPH.md, check `.msgs/`, read 3 recent handoffs,
    run triage
  - Role triage — diagnose the current situation and wear the appropriate hat:
    - **PM**: pending review comments on tk tickets need triage, task states need
      reconciliation, new work needs scoping
    - **Implementer**: `tk ready` has tasks, codebase is healthy, clear work to do
    - **Reviewer**: implementation complete, quality check needed, findings to handoff
  - Phase sequence reference (the protocol, not embedded in tickets):
    - **Bearings**: health check + codebase exploration. Scope adapts to task type
      (docs tasks skip dev server/smoke test, only check markdown lint).
    - **Implement**: focused changes, follow patterns, minimal scope.
    - **Verify**: scope adapts to task type. Feature tasks: type check + tests +
      lint + UI verification. Docs tasks: markdown lint + link check. Infrastructure
      tasks: build + deploy verification. Auto-retry logic (max 3).
    - **Commit**: conventional commits with `Refs: <tk-id>`.
  - Decision protocol: when to stop and escalate to human
  - End-of-session gate:
    1. ADR check — if architectural decisions were made during the session
       (new tool choices, protocol changes, structural changes, tradeoffs
       with alternatives considered), write an ADR to `docs/adrs/NNN-<slug>.md`
       before the handoff. Number sequentially from existing ADRs.
    2. Handoff — write session handoff to `docs/handoffs/`
    3. tk updates — close/update tickets worked on
- [ ] 6.2: **PR comment integration** — When `/code-review` adds comments to tk
  tickets, the Implementer role reads ticket comments before starting work.
  After addressing review feedback and PR is merged or closed, the ticket is
  closed. No separate review file pipeline — comments live on the ticket.
- [ ] 6.3: **Handoff format** — Template for session handoff documents in
  `docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md`. Includes:
  - What was done (summary, commits, decisions)
  - What's next (unresolved work, blockers)
  - Learnings section (patterns discovered, gotchas)
  - Gaps section (missing work identified)
  - Task references (tk IDs worked on)
  - Scope constraint: all content must be portable — no references to
    machine-local config, personal dotfiles, or single-developer setup
- [ ] 6.4: **Phase sequence documentation** — Detailed protocol for each phase,
  with task-type-specific adaptations:
  - Feature tasks: full bearings → implement → verify → commit
  - Docs tasks: light bearings (check existing docs) → implement → verify (lint) → commit
  - Infrastructure tasks: bearings (check build/deploy) → implement → verify (build) → commit
  - Bug fixes: diagnose → fix → verify → commit (adapted from choo-choo-ralph's
    bug-fix formula)
- [ ] 6.5: **CLAUDE.md discipline gates template** — Starter CLAUDE.md additions:
  - Read RALPH.md before starting work
  - Documentation before commit (handoff required)
  - Code review gate (spawn code-critic, max 2 rounds)
  - End-of-session checklist
  - Documentation scope rule: project artifacts must be portable, never
    reference machine-local configuration
- [ ] 6.6: **`.msgs/` inbox** — Async human→agent communication. Same mechanism as
  project-status-sync. Write message to `.msgs/{id}.md`, agent reads and replies.
- [ ] 6.7: **Stop file (`.ralph-stop`)** — Graceful loop exit mechanism.

---

## Phase 7 — `/harvest` command

Extract learnings and gaps from handoffs into durable artifacts.

- [ ] 7.1: **harvest.md command — scan handoffs** — Reads recent handoffs (since last
  harvest), extracts `## Learnings` and `## Gaps` sections. Presents summary to
  user.
- [ ] 7.2: **harvest.md command — promote learnings** — For each learning, user decides:
  - Create/update a skill in `.claude/skills/`
  - Add to CLAUDE.md or folder CLAUDE.md
  - Add to `docs/`
  - Skip (not worth persisting)
- [ ] 7.3: **harvest.md command — process gaps** — For each gap:
  - Create a new tk ticket
  - Add to an existing spec for the next `/spec` Design phase
  - Skip
- [ ] 7.4: **harvest.md command — mark harvested** — Track which handoffs have been
  processed to avoid re-harvesting. Use a `.last-harvest` marker file with the
  most recent handoff timestamp/filename.

---

## Phase 8 — Documentation

Mirror choo-choo-ralph's documentation structure, adapted for Socrates.

- [ ] 8.1: **docs/workflow.md** — Complete workflow guide covering all phases:
  Spec (Design in Practice journey) → Pour → Ralph → Harvest.
  Adapted from choo-choo-ralph's workflow.md.
- [ ] 8.2: **docs/commands.md** — Command reference for all 4 commands:
  /init, /spec, /pour, /harvest. With arguments and examples.
  Adapted from choo-choo-ralph's commands.md.
- [ ] 8.3: **docs/spec-format.md** — Overview + task file format reference. Covers
  the `_overview.md` structure (Describe, Diagnose, Delimit, Direction, Design
  sections with phase markers) and individual task file format (frontmatter,
  steps, test_steps, review, depends_on, status lifecycle). Includes the
  `_overview.md` and task file templates from Appendix A and B.
- [ ] 8.4: **docs/protocol.md** — RALPH.md protocol reference. Phase sequence
  (bearings → implement → verify → commit) with task-type adaptations, role
  triage, handoff format, discipline gates.
  Adapted from choo-choo-ralph's formulas.md.
- [ ] 8.5: **docs/customization.md** — How to customize shell scripts, protocol,
  handoff format, phase sequence. Adapted from choo-choo-ralph's customization.md.
- [ ] 8.6: **docs/troubleshooting.md** — Error handling, recovery, debugging.
  Adapted from choo-choo-ralph's troubleshooting.md.

---

## Phase 9 — Skills & AI guidance

Claude Code skills that guide AI behavior during Socrates workflows.

- [ ] 9.1: **spec-journey skill** — Guidance for the `/spec` Design in Practice flow.
  Operationalizes each technique into concrete AI behavior:
  - **Reflective Inquiry**: ask "where are you at? where are you going? what do you
    know? what do you need to know?" — surface these questions at phase transitions
  - **Socratic Method**: challenge assertions, examine ideas dispassionately,
    cooperative truth-seeking — the AI is a source of ideas, not identified with them
  - **Scientific Method**: form hypotheses during Diagnose, test them with evidence,
    don't accept the first explanation
  - **Precise Language**: use consistent terms, maintain a glossary section in overview,
    when terms break or evolve, fix or abandon them
  - **Decision Matrix**: problem statement in header, approaches as columns (include
    status quo), criteria as rows, color-coded aspects (🟢🟡🔴⬜), avoid all-green
    columns (rationalization), find distinguishing criteria
  - **Use Cases**: focus on user intentions not implementation, "I wish I could..."
    not "the user will push a button," blank "How" column filled after approach chosen
  - Boundary: this skill handles Socrates-specific mechanics (file formats, command
    flow, resume, phase markers). The global `design-in-practice` skill handles
    general methodology. Within `/spec` context, spec-journey takes precedence on
    format and flow.
- [ ] 9.2: **ralph-guide skill** — Quick reference for the Ralph workflow. Covers:
  phase sequence with task-type adaptations, tk commands, handoff writing,
  role triage, troubleshooting.
  Adapted from choo-choo-ralph's ralph-guide skill.

---

## Appendix A — `_overview.md` template

```markdown
---
title: <spec name>
created: <date>
delimit_approved: false
---

## Describe [DRAFT]

<Situation description. What is happening? What is the context?
No interpretation, no proposed solutions.>

## Diagnose [DRAFT]

<What is the real problem? Hypotheses tested. Root causes identified.
"We don't have feature X" is never a valid problem statement.>

## Delimit [DRAFT]

<Crisp problem statement: unmet user objectives and their causes.
1-2 sentences. If you can't write this clearly, you're not ready
to proceed.>

## Direction [DRAFT]

### Approaches

<Enumerated approaches, including status quo.>

### Decision Matrix

<If non-trivial choice. Problem statement in header, approaches as
columns, criteria as rows, 🟢🟡🔴⬜ aspects.>

### Chosen Approach

<Which approach and why.>

### Use Cases

<What users could accomplish if the problem were solved.
Focus on intentions, not implementation.>

## Design [DRAFT]

### Context

<Codebase patterns, integration points, conventions discovered
during research. Added by parallel sub-agents.>

### Tasks

<Summary of generated task files and their relationships.>

### Glossary

<Terms used consistently throughout this spec. Definitions that
matter for implementation.>
```

Phase markers: `[DRAFT]`, `[COMPLETE]`, `[APPROVED]` (Delimit only).
When going back, target phase set to `[DRAFT]`, subsequent phases set to `[DRAFT]`,
previous content preserved under `### Previous (superseded)`.

---

## Appendix B — Task file template

```markdown
---
id: <short-hash>-<human-suffix>
status: draft           # draft → approved → poured
priority: <0-4>         # 0 = highest
category: <functional|style|infrastructure|documentation>
depends_on: []          # list of task IDs from this spec
ticket: null            # set to tk ID after pour (last write)
---

# <Task title>

<steps>
1. ...
2. ...
</steps>

<test_steps>
- ...
- ...
</test_steps>

<review></review>
```

Status lifecycle:
- `draft` — generated or still iterating, not yet reviewed
- `approved` — human has signed off, ready to pour
- `poured` — tk ticket created, spec file is now frozen

After pour, the spec file is a write-once artifact. All mutable state lives
in `.tickets/`.

---

## Provenance

What comes from where:

| Source | What we take |
|--------|-------------|
| **choo-choo-ralph** | Plugin structure, ralph-format.sh, review tag workflow, pour concept, harvest concept, phase sequence (bearings→implement→verify→commit), granularity guidance, bug-fix workflow pattern, documentation structure |
| **project-status-sync** | RALPH.md protocol, handoff format, role triage, .msgs/ inbox, .ralph-stop, end-of-session gates, discipline gates in CLAUDE.md |
| **Design in Practice** | Full D1-D5 journey as `/spec` backbone, techniques per phase, strict Delimit gate, Decision Matrix, Use Cases, Socratic Method, Reflective Inquiry, Precise Language, Glossary |
| **New in Socrates** | tk as task backend, overview + file-per-task spec structure, PR comments on tk tickets via `/code-review` helper, draft/approved/poured lifecycle, guided spec interview with phase markers and resume, task-type-adaptive phase sequences |

## What we leave behind

| Dropped | Why |
|---------|-----|
| Beads (SQLite, JSONL, daemon, molecules) | Silent write bugs, over-complex; tk replaces it |
| Formula expansion into tickets | Protocol lives in RALPH.md, not duplicated per task |
| Orchestrator/sub-agent bead pattern | Ralph loop + protocol handles sequencing |
| WORKPLAN.md as task tracker | Doesn't scale; tk replaces it |
| EVENTS.jsonl + aggregation pipeline | Over-engineered; handoffs are sufficient |
| LLM-based event extraction | Expensive; direct handoff writing is simpler |
| Single-file spec with all tasks | Cognitive overload past ~6 tasks; file-per-task with overview |
| progress.log | Handoffs capture the same information with richer context. Tradeoff: we lose real-time progress monitoring during a session — ralph-format.sh shows tool-level output but not semantic progress. Accepted because handoffs are the durable artifact. |
| Separate `/design` command | Merged into `/spec` as the Design phase — task decomposition is the natural final step of the same design journey, not a separate command |
| Separate `/code-review` command | Demoted to helper script. PR comments are added to existing tk tickets. Tickets close when PR is merged or closed. |
| docs/reviews/ pipeline | Over-specified. PR feedback flows directly onto tk tickets as comments, not through a separate file-per-comment staging area. |
