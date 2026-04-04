# Socrates — Project Instructions

A Claude Code plugin for structured design and autonomous development. We are
building Socrates using Socrates' own principles (dogfooding).

## Source of Truth

WORKPLAN.md drives all task sequencing. Phases are gated by their `Blocked By`
column — do not start a phase until its dependencies are complete. Within a
phase, tasks are numbered and should be done in order unless independent.

We are in Phase 0 (spikes). Spikes are throwaway — validate assumptions, do not
build infrastructure. Keep spike artifacts isolated so they can be deleted
without affecting the project.

## Session Discipline

### Start of session

1. Read this file
2. Read WORKPLAN.md — know what phase we're in and what's next
3. Read the 3 most recent handoffs in `docs/handoffs/`
4. Identify what to work on based on phase status and blocking dependencies

### Before committing

1. **ADR check** — if architectural decisions were made (tool choices, protocol
   changes, structural changes, tradeoffs with alternatives), write an ADR to
   `docs/adrs/NNN-<slug>.md` before the handoff. Number sequentially.
2. **Handoff** — write a session handoff to
   `docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md` covering: what was done, key
   decisions, what's next, learnings, gaps.

Handoffs and ADRs are committed together with the work they describe.

## Commits

- Small and focused — one logical change per commit
- Message explains why, not what (the diff shows what)
- Format: 50 char title, 72 char body wrap
- Include `Refs: Phase X.Y` until tk ticket IDs exist
- No `Co-Authored-By` or `Generated with` lines

## Documentation Scope

All project artifacts (commits, handoffs, ADRs, specs, protocol templates)
must be portable. Never reference machine-local configuration, personal
dotfiles, or single-developer environment setup. If something only applies
to one machine, it does not belong in project history.

## Design Principles

- "We don't have feature X" is never a valid problem statement — state the
  unmet user objective and its cause
- Simplicity over flexibility — prefer the boring approach that works
- Convention over automation — add guardrails only where failure is silent
- File-per-task over monolithic specs
- Protocol as reference (RALPH.md), not embedded per ticket

## Bootstrap Ratchet

After completing a phase, update this CLAUDE.md:
- Replace manual workarounds with the real tooling the phase delivered
- Add conventions the phase enables
- Remove bootstrap scaffolding that is no longer needed

The goal is that this file always reflects what is actually available, not what
is aspirational. Each phase landing is a trigger to ratchet forward.

### Phase completion checklist

- [ ] Phase 0: Replace "WORKPLAN.md drives sequencing" with tk commands
- [ ] Phase 1: Add plugin structure conventions
- [ ] Phase 2: Add ralph loop usage instructions
- [ ] Phase 3: Replace manual setup notes with `/init`
- [ ] Phase 4: Add `/spec` workflow and Design in Practice flow
- [ ] Phase 5: Add `/pour` workflow
- [ ] Phase 6: Add RALPH.md protocol reference, role triage, `.msgs/` inbox
- [ ] Phase 7: Add `/harvest` workflow
