---
name: ralph-guide
description: Quick reference for the Ralph autonomous workflow. Covers phase sequence with task-type adaptations, tk commands, handoff writing, role triage, and troubleshooting.
---

# Ralph Guide Skill

Quick reference for operating as Ralph — the autonomous development agent.
Consult this when implementing tasks, writing handoffs, or triaging work.

## When Active

This skill applies when running `ralph.sh`, `ralph-once.sh`, or when the
RALPH.md protocol is being followed.

## Role Triage Quick Reference

| Signal | Role | First Action |
|--------|------|-------------|
| `tk ready -a ralph` has tasks | Implementer | Pick highest-priority task |
| Ticket comments need response | PM | Triage comments, update states |
| Implementation done, no review | Reviewer | Spawn code-critic (foreground, opus) |
| All tasks blocked | PM | Escalate via `.msgs/` |
| `.msgs/` has unread messages | Any | Respond before starting work |

## tk Commands

```bash
tk ready -a ralph          # show tasks assigned to ralph, ready to start
tk start <id>              # mark task as in_progress
tk close <id>              # mark task as done
tk show <id>               # show task details + comments
tk comment <id> "<text>"   # add comment to task
tk query '.' | jq -s       # list all tasks as JSON array
tk dep <id> <dep-id>       # add dependency
```

## Phase Sequence Cheat Sheet

### 1. Bearings — Orient before coding

| Task Type | Check |
|-----------|-------|
| Feature | Source files, tests, build, dev server |
| Docs | Existing docs, markdown tooling |
| Infrastructure | Build system, deploy config, CI |
| Bug fix | Reproduce bug, read error traces |

Read the ticket description AND comments. Check for conflicting in-progress work.

### 2. Implement — Focused changes

- Follow existing patterns
- One logical change at a time
- Don't refactor beyond task scope
- Bug fixes: diagnose root cause before writing fix

### 3. Verify — Confirm it works

| Task Type | Checks |
|-----------|--------|
| Feature | Type check + tests + lint + UI |
| Docs | Markdown lint + link check |
| Infrastructure | Build + deploy verification |
| Bug fix | Regression test + existing tests |

Max 3 retries. After 3 failures → escalate.

### 4. Commit

```
<type>: <why, not what>

<body — 72 char wrap>

Refs: <tk-id>
```

Types: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`

**One commit per task cycle.** Run the End-of-Session Gate (handoff, ADR,
tk updates) *before* `git commit`, then stage code + docs + handoff
together. Never split impl from its docs.

## Handoff Writing

File: `docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md`

Required sections:

1. **What Was Done** — summary, commits, key decisions
2. **What's Next** — unresolved work, blockers
3. **Learnings** — patterns discovered, gotchas
4. **Gaps** — missing work, honest assessment

Include `**Tasks**: <tk-ids>` in the header. Keep all content portable — no
machine-local paths.

## Escalation Triggers

Stop and escalate to human when:

- Design decision not covered by the spec
- 3 verify failures on the same check
- Dependency on something outside the repo
- Task description is wrong or incomplete
- Change would exceed task scope
- Uncertain about a tradeoff

Write to `.msgs/` or include in handoff.

## End-of-Session Checklist

1. ADR if architectural decisions were made → `docs/adrs/NNN-<slug>.md`
2. Handoff → `docs/handoffs/`
3. tk updates → close/update tickets
4. Commit everything — no uncommitted work left behind
