# RALPH Protocol Reference

RALPH is the autonomous agent protocol. This document describes the protocol
that RALPH.md implements. For the actual protocol file installed into projects,
see `templates/RALPH.md`.

## Startup Sequence

Every session begins with:

1. Read RALPH.md
2. Check `.msgs/` inbox for human messages
3. Read the 3 most recent handoffs in `docs/handoffs/`
4. Run triage to determine role

## Role Triage

Assess the situation and pick one role per task cycle.

### PM

**When**: Pending review comments need triage, task states are inconsistent,
new work needs scoping.

**Actions**: Triage ticket comments, reconcile states, suggest `/spec` or
`/pour` via `.msgs/`.

### Implementer

**When**: `tk ready -a ralph` returns tasks, build is healthy.

**Actions**: Pick a task, follow the Phase Sequence.

### Reviewer

**When**: Implementation complete, quality check needed.

**Actions**: Spawn `code-critic` agent (foreground, opus model), write findings
to handoff, add comments to tk tickets.

## Phase Sequence

Each task follows four phases. Scope adapts to the task type.

### 1. Bearings

Orient before coding. Read the ticket (description + comments), explore
relevant source files, check for conflicting in-progress work, verify build
health.

**Exit**: You understand what to do, where to do it, nothing is broken.

### 2. Implement

Focused changes, minimal scope. Follow existing patterns. One logical change
at a time. Don't refactor surrounding code unless the task requires it.

**Exit**: Change is complete, ready to verify.

### 3. Verify

Run checks appropriate to the task type (see adaptations below). Fix and
re-verify on failure, up to 3 retries. After 3 failures, escalate.

**Exit**: All relevant checks pass.

### 4. Commit

Conventional commit format (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`).
Message explains why. Include `Refs: <tk-id>` in body. One logical change
per commit.

## Task-Type Adaptations

| Phase | Feature | Docs | Infrastructure | Bug Fix |
|-------|---------|------|----------------|---------|
| Bearings | Full: source, tests, build, dev server | Light: existing docs, markdown tooling | Build system, deploy config, CI | Reproduce bug, read error traces |
| Implement | Standard | Standard | Standard | Diagnose root cause first |
| Verify | Type check + tests + lint + UI | Markdown lint + link check | Build + deploy verification | Regression test + existing tests |
| Commit | Standard | Standard | Standard | Standard |

## Decision Protocol

Escalate to the human when:

- Task requires a design decision not in the spec
- 3 verify failures on the same check
- Task depends on something outside the repo
- Task description is wrong or incomplete
- Fix requires changes outside task scope
- Uncertain whether a tradeoff is acceptable

## End-of-Session Gate

Before ending any session, complete all of these in order:

1. **ADR check** — Write `docs/adrs/NNN-<slug>.md` if architectural decisions
   were made (tool choices, protocol changes, structural changes, tradeoffs)
2. **Handoff** — Write `docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md`
3. **tk updates** — Close completed tickets, update in-progress tickets
4. **Commit** — All changes committed; no uncommitted work left behind

## Handoff Format

```
docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md
```

Required sections:

| Section | Content |
|---------|---------|
| What Was Done | Summary, commits, decisions |
| What's Next | Unresolved work, blockers |
| Learnings | Patterns discovered, gotchas |
| Gaps | Missing work, honest assessment |

All content must be portable — no machine-local references.

## Communication

### `.msgs/` Inbox

Human writes to `.msgs/<id>.md`, agent reads at session start, responds in a
`## Response` section, archives to `.msgs/archive/`.

### `.ralph-stop`

Touch `.ralph-stop` in project root. Ralph finishes the current task cycle
then exits. The file is deleted after the loop reads it.

## Discipline Gates

Installed into CLAUDE.md by `/init`. See `templates/claude-gates.md` for the
full template. Key gates:

- Read RALPH.md before starting work
- Know your role before acting
- Code review before commit (code-critic, foreground, opus)
- Docs before ending session
- Commit everything — no uncommitted work
