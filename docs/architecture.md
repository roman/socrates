# Architecture

## Workflow Overview

```
/spec  →  _overview.md + task files (draft)
          ↓ human reviews, sets status: approved
/pour  →  tk tickets (.tickets/)
          ↓
ralph.sh loop:
  tk ready -a ralph → start task → RALPH.md protocol → commit → handoff
          ↓
/harvest →  learnings/gaps → skills, CLAUDE.md, new tickets
```

## Components

### `/spec` — Design in Practice Journey

Drives the user through all five D's in one command:

1. **Describe** — Situational capture, no interpretation (Reflective Inquiry technique)
2. **Diagnose** — Real problem identification (Scientific Method, hypothesis testing)
3. **Delimit** — Strict gate: crisp problem statement explicitly approved before proceeding
4. **Direction** — Approaches, Decision Matrix, Use Cases, chosen approach
5. **Design** — Parallel sub-agents for codebase exploration + research → task files

Output: `docs/specs/<name>/_overview.md` + individual task files.

Phase resume: markers in section headers (`[DRAFT]`/`[COMPLETE]`/`[APPROVED]`) +
`delimit_approved` frontmatter field. Previous content preserved under
`### Previous (superseded)` when revisiting a phase.

### `/pour` — Spec to Tickets

Mechanical transformation of `status: approved` task files into `tk` tickets. Maps
`depends_on:` task IDs to tk dependency graph. Sets `status: poured` + `ticket:` field
— last write to the spec file. Idempotent.

### RALPH.md Protocol

Single file governing all sessions. Not duplicated per ticket. Agent reads it at session
start and wears one of three hats based on triage:

- **PM** — pending review, task reconciliation, new scoping needed
- **Implementer** — `tk ready` has work, codebase healthy
- **Reviewer** — implementation complete, quality check needed

Phase sequence adapts to task type:
- Feature: bearings → implement → verify (tests + lint + type check + UI) → commit
- Docs: light bearings → implement → verify (markdown lint) → commit
- Infrastructure: bearings (check build/deploy) → implement → verify (build) → commit
- Bug fix: diagnose → fix → verify → commit

End-of-session gate (ordered):
1. **ADR check** — if architectural decisions were made (tool choices, protocol changes,
   structural changes, tradeoffs with alternatives considered), write ADR to
   `docs/adrs/NNN-<slug>.md` before the handoff. Sequential numbering.
2. **Handoff** — write session narrative
3. **tk updates** — close/update tickets

### Handoffs

`docs/handoffs/YYYY-MM-DD-<topic>.md`. Written at session end. Contains: what was done,
commits, decisions, what's next, blockers, learnings, gaps, tk IDs.

### `/harvest`

Reads handoffs since `.last-harvest`, presents learnings and gaps to the user. For each:
- Learnings → skill file, CLAUDE.md entry, doc, or skip
- Gaps → new tk ticket, add to existing spec, or skip

### tk (Ticket Tracker)

~1,400-line bash script. Markdown files with YAML frontmatter in `.tickets/`.
Key commands: `tk ready`, `tk start`, `tk close`, `tk dep`, `tk dep tree`.

## File Layout (in target project)

```
<project>/
  .tickets/           # tk state (git-tracked)
  .msgs/              # async human→agent inbox
  .ralph-stop         # graceful loop exit signal
  docs/
    specs/
      <name>/
        _overview.md  # D1-D5 journey, phase markers
        <hash>-<name>.md  # individual task files
    handoffs/
      YYYY-MM-DD-<topic>.md
  RALPH.md            # session protocol
  ralph.sh            # main loop
  ralph-once.sh       # single iteration
  ralph-format.sh     # stream-json formatter
```

## Design Decisions

See ADRs:
- [001 — tk over beads](adrs/001-tk-over-beads.md)
- [002 — RALPH.md protocol over per-ticket formulas](adrs/002-ralph-protocol-over-formulas.md)
- [003 — /spec + /design merged into one command](adrs/003-spec-journey-merged-command.md)
