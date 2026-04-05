## Socrates Discipline Gates

### Session Start

- Read RALPH.md before starting any work
- Check `.msgs/` inbox for human messages
- Read the 3 most recent handoffs in `docs/handoffs/`

### Before Implementation

- Run triage: know your role (PM, Implementer, Reviewer) before acting
- Implementer: read the tk ticket description and comments before coding
- Verify the build is healthy before making changes

### Before Commit

- Code review gate: spawn `code-critic` agent (foreground, opus model), address findings (max 2 rounds)
- Conventional commit format with `Refs: <tk-id>` in body
- One logical change per commit

### Before Ending Session

- ADR check: if architectural decisions were made, write to `docs/adrs/`
- Handoff: write session handoff to `docs/handoffs/`
- tk updates: close completed tickets, update in-progress tickets
- Commit all changes — docs, handoffs, and code together; no uncommitted work left behind

### Documentation Scope

All project artifacts (commits, handoffs, ADRs, specs) must be portable.
Never reference machine-local configuration, personal dotfiles, or
single-developer environment setup.
