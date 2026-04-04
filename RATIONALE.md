# Socrates — Rationale

## Why this project exists

Autonomous coding loops (the "Ralph pattern") work: give an AI agent a task, let it
code, verify, commit, and repeat. But the tooling around these loops has two failure
modes:

1. **Too simple** — A markdown file with a task list and a CLAUDE.md. Works for small
   projects, falls apart when you have 30+ tasks, multiple work streams, or need to
   coordinate across sessions. The task list goes stale, there's no queryable state,
   and history is lost.

2. **Too complex** — A full task tracker with databases, daemons, formula engines, and
   multi-agent coordination primitives. Solves the scaling problem but introduces new
   ones: silent data loss, state sync issues in sandboxed environments, protocol
   duplication in every ticket, and opacity about what the system is doing.

Socrates exists because neither extreme is right. We want structured, queryable tasks
without a database. We want a repeatable protocol without embedding it in every ticket.
We want cross-session context without an event extraction pipeline.

## What we learned from prior work

### choo-choo-ralph

A Claude Code plugin that uses Beads (a git-backed task tracker) for autonomous coding.

**What worked:**
- The spec + `<review>` tag flow for interactive task refinement before coding starts
- The phase sequence (bearings → implement → verify → commit) as a repeatable protocol
- The harvest concept — capturing learnings and gaps from completed work
- ralph-format.sh for readable output from Claude's stream-json
- The pour concept — converting a human-reviewed spec into executable tasks

**What didn't work:**
- Beads' SQLite-to-JSONL migration introduced silent write bugs — `bd close` exits 0
  but the file on disk doesn't change. This breaks the entire git-native sync promise.
- Formula expansion embeds the full protocol (~50 lines) into every ticket. Changing
  the protocol after pour has no effect on existing tickets.
- The single-file spec becomes cognitively overwhelming past ~6 tasks. You must review
  all tasks before any can be poured.
- No feedback mechanism for PR review comments to flow back into the loop.
- No structured problem discovery — the spec jumps straight to "what to build" without
  establishing "why" or "what problem we're solving."

### project-status-sync

A Haskell project that uses RALPH.md + WORKPLAN.md + handoffs for autonomous sessions
in a bubblewrap sandbox.

**What worked:**
- RALPH.md as a single protocol file that governs all sessions — not duplicated per task
- Handoffs as per-session narrative documents. Any agent can read 3-4 handoffs and
  reconstruct the full context of recent work. Searchable, human-readable, self-contained.
- Role triage (PM/Architect/Implementer/Reviewer) — the agent decides what hat to wear
  based on current project state
- End-of-session gates that enforce documentation discipline
- `.msgs/` inbox for async human→agent communication

**What didn't work:**
- WORKPLAN.md as the task tracker doesn't scale. It goes stale after tasks complete,
  becomes noisy, and the archive story is not fleshed out.
- EVENTS.jsonl + LLM-based event extraction is over-engineered. Expensive, fragile, and
  handoffs capture the same information with richer context.
- STATUS.md synthesis via LLM adds latency and cost for marginal benefit over just
  reading recent handoffs.

### Rich Hickey's Design in Practice

A methodology for structured software design: Describe → Diagnose → Delimit → Direction
→ Design → Dev. The core insight is that most teams jump to solutions without
understanding the problem, producing features that solve nothing.

**What we adopt:**
- The phase progression as the backbone of the `/spec` command
- Techniques mapped to phases: Reflective Inquiry, Scientific Method, Precise Language,
  Decision Matrix, Use Cases, Socratic Method
- The strict Delimit gate — you cannot proceed to solutions until the problem statement
  is explicitly approved
- "We don't have feature X" is never a valid problem statement
- Writing as thinking — the overview document is not documentation, it's a thinking tool

## Goals

### 1. Structured problem discovery before coding

The `/spec` command walks the user through the full Design in Practice journey:
Describe → Diagnose → Delimit → Direction → Design. It produces an `_overview.md` that
establishes why we're building something, and then decomposes the chosen approach into
individual task files. The entire journey lives in one command with explicit phase
markers and resume capability. This is the core differentiator from choo-choo-ralph,
which starts at "what to build."

### 2. Queryable tasks without a database

We use `tk` (ticket) — a ~1400-line bash script that stores markdown files with YAML
frontmatter in `.tickets/`. It supports dependencies, priority, assignees, and queries
like `tk ready` (unblocked tasks) and `tk blocked`. No SQLite, no daemon, no JSONL
sync layer. Files are the source of truth. Git diff shows exactly what changed.

### 3. Protocol as reference, not as data

The ralph loop follows a phase sequence (bearings → implement → verify → commit) defined
in RALPH.md. Every session reads the same protocol. Tickets only carry what to do, not
how to do it. Changing the protocol changes all future sessions immediately — no need to
re-pour or update existing tickets.

### 4. Narrative history via handoffs

Each ralph session ends with a handoff document in `docs/handoffs/`. Handoffs capture
what was done, decisions made, learnings, and gaps. Any agent can read recent handoffs
to reconstruct context. This replaces both beads' structured comments and
project-status-sync's EVENTS.jsonl pipeline.

### 5. Incremental review without cognitive overload

Specs produce one file per task (not a monolithic spec file). Each task has its own
`<review>` tag and a status lifecycle (draft → approved → poured). You review and
approve tasks individually, pour them incrementally. Five tasks today, five tomorrow.

### 6. PR feedback loop

A helper script pulls GitHub PR comments and adds them to the relevant `tk` tickets as
notes. The next ralph session sees the comments when it reads the ticket, addresses the
feedback, and closes the ticket when the PR is merged or closed. Comments live on the
ticket — no staging area, no separate file pipeline.

### 7. Compounding knowledge

The `/harvest` command reads recent handoffs, extracts learnings and gaps, and promotes
them to durable artifacts: skills, CLAUDE.md entries, documentation, or new tickets.
Knowledge compounds across sessions rather than being trapped in individual handoffs.

## Tradeoffs

### Simplicity over flexibility

- **We choose `tk` over beads.** tk has no dependency graph visualization, no molecule
  templates, no daemon mode, no multi-format export. But it stores plain files, has no
  silent write bugs, and does the three things we need: create, query, close.
- **We choose RALPH.md over formulas.** Formulas allow per-task workflow customization.
  RALPH.md applies one protocol to all tasks, but the protocol adapts its ceremony to
  the task type: feature tasks get the full bearings/implement/verify/commit sequence
  with health checks and smoke tests; docs tasks get a lighter sequence (check existing
  docs, write, lint, commit); infrastructure tasks verify builds instead of UI. The
  agent diagnoses the task type and wears the appropriate hat. This is less flexible
  than arbitrary per-task formulas but covers the real-world cases without per-ticket
  protocol duplication.
- **We choose handoffs over event pipelines.** Handoffs are written by the agent at the
  end of each session. No extraction, no aggregation, no synthesis. The tradeoff is
  that handoff quality depends on the agent following the protocol — there's no
  automated fallback if it skips the handoff.

### Convention over automation, with guardrails where degradation is silent

Convention-based enforcement is simpler than automation but can degrade **silently** —
no error, just missing data discovered downstream. Where degradation is invisible, we
add lightweight guardrails. Where it's visible, we accept convention.

- **Commit messages must include `Refs: <tk-id>`.** Enforced by a **warning hook** that
  prints a warning if `Refs:` is missing but does not block the commit. This makes
  degradation **noisy** — you see the warning immediately — without adding friction to
  every commit. The agent follows the convention via RALPH.md protocol; the hook catches
  the cases where it doesn't.
- **Task status lifecycle is honor-based.** The agent sets `status: approved` → `poured`
  in task file frontmatter. There is no enforcement layer preventing a pour of a draft
  task. The `/pour` command checks status, but a manual `tk create` bypasses it. This
  degradation is visible (you'd see the task file says `draft` when you review it), so
  convention is sufficient.
- **Handoff writing is a protocol gate, not a hard constraint.** The end-of-session
  checklist in RALPH.md requires a handoff. If the agent's context is exhausted
  mid-task, the handoff may be missing or incomplete. This is acceptable — the next
  session detects the gap and the PM role reconciles.

### Guided process over speed

- **The `/spec` flow adds friction intentionally.** Walking through Describe → Diagnose
  → Delimit → Direction takes longer than writing a task list. The bet is that this
  friction pays for itself by preventing wasted work on poorly-understood problems.
- **The Delimit gate is strict.** The AI will not proceed past problem statement
  approval. This can feel blocking when you "just want to build something." That's by
  design — if you can't state the problem, the solution will be wrong.
- **File-per-task adds filesystem overhead.** A 20-task spec creates 21 files (overview
  + 20 tasks). This is more files to manage than a single spec. The tradeoff is
  worthwhile because each file is independently reviewable and poureable.

### Scope boundaries over completeness

- **GitHub only for code review.** The code-review helper uses `gh api`. GitLab,
  Bitbucket, and other forges are not supported. This can be extended later but is not
  a goal for v1.
- **No real-time progress monitoring.** Handoffs are written at session end, not during.
  If you want to know what a ralph session is doing right now, you have ralph-format.sh
  (tool-level output) but no semantic progress indicator. We drop progress.log because
  handoffs capture the same information with richer context. The tradeoff is that
  mid-session visibility is limited to watching the terminal output.
- **No multi-agent coordination.** Socrates supports one ralph instance per project. The
  conflict avoidance in ralph.sh (avoid epics other ralphs are working on) is
  aspirational — it's inherited from choo-choo-ralph but not the primary use case.
- **No automated archival.** Completed specs stay in `notes/specs/`, closed tickets stay
  in `.tickets/`, old handoffs stay in `docs/handoffs/`. There is no automated cleanup
  or archival pipeline. Manual cleanup is expected.

## What Socrates is not

- **Not a project management tool.** It does not replace Jira, Linear, or Asana. It
  manages implementation tasks for a single feature or work stream. Cross-project
  coordination, team assignment, sprint planning, and roadmapping are out of scope.
- **Not a CI/CD system.** The verify phase runs tests locally. It does not integrate
  with GitHub Actions, CircleCI, or any CI provider. If CI fails after push, that's a
  separate feedback loop.
- **Not a code review tool.** The code-review helper gathers PR comments onto tickets —
  it doesn't perform code review. The reviewer role in RALPH.md does lightweight quality
  checks, but it's not a substitute for human code review on a team.
- **Not a design tool.** The `/spec` command facilitates structured thinking about
  problems and approaches. It does not produce architecture diagrams, database schemas,
  or API specifications. Those are artifacts you create during the Direction or Design
  phases if needed.
- **Not framework-specific.** Socrates makes no assumptions about your programming
  language, framework, or toolchain. The phase sequence (bearings → implement → verify
  → commit) adapts to whatever your project uses for tests, linting, and type checking.
  This adaptation happens in RALPH.md and CLAUDE.md, not in Socrates itself.
