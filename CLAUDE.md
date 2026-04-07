# Socrates — Project Instructions

A Claude Code plugin for structured design and autonomous development. We are
building Socrates using Socrates' own principles (dogfooding).

## Source of Truth

Work is tracked as `tk` tickets under `.tickets/`. Use `tk ready -a ralph` to
find what to do next. Specs in `docs/specs/` are blueprints; once poured they
freeze and the ticket is authoritative.

The protocol Socrates installs into target projects is `RALPH.md` (template at
`plugins/socrates/templates/RALPH.md`). Read that file to understand the loop.

## Session Discipline

### Start of session

1. Read this file
2. Read the 3 most recent handoffs in `docs/handoffs/` if context is unclear
3. Run `tk ready -a ralph` to find work

### Before committing

- Spawn `code-critic` (foreground, opus) for non-trivial changes; address
  findings in at most 2 rounds
- Write a handoff to `docs/handoffs/YYYY-MM-DD-HHmm-<topic>.md` only when the
  next session can't reconstruct context from the commit message alone
  (end of work day, blocked, learnings/gaps surfaced, handing off to another
  agent)
- Write an ADR to `docs/adrs/NNN-<slug>.md` only when the decision context
  won't be obvious from the commit body in 6 months. The commit `Refs:` and
  body are usually enough.

## Commits

- Small and focused — one logical change per commit
- Conventional commit format (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`)
- Title explains why; body wraps at 72 chars
- Include `Refs: <tk-id>` in the body
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
- Don't duplicate content across files. If a doc only restates another doc,
  delete it and link instead.
