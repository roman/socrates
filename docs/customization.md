# Customization Guide

Socrates installs templates that you own after initialization. Everything is
customizable.

## Shell Scripts

### ralph.sh

**Max iterations**: Change the default by editing the `MAX_ITERATIONS` variable
or passing it as the first argument: `./ralph.sh 50`.

**Task selection**: The prompt inside ralph.sh guides which task Ralph picks.
Edit the prompt to change prioritization logic (e.g., prefer certain categories,
avoid specific tags).

**Output formatting**: ralph-format.sh controls how stream-json output is
displayed. Add `--verbose` for detailed tool output including thinking blocks.

### ralph-once.sh

Same as ralph.sh but exits after one iteration. Useful for testing changes to
the task selection prompt before running the full loop.

## RALPH.md Protocol

The protocol file is yours to edit. Common customizations:

### Role Triage

Add project-specific roles or modify when each role applies. For example, add a
"Deployer" role for projects with deployment tasks.

### Phase Sequence

Adjust what each phase does. Examples:
- Add a "Lint" step to Bearings for projects with strict linting
- Add database migration checks to Verify for backend tasks
- Skip UI verification for headless/CLI projects

### Task-Type Adaptations

Add new task types or modify existing ones. The four defaults (feature, docs,
infrastructure, bug fix) cover most cases, but your project might have others
(e.g., "migration", "security", "performance").

### Decision Protocol

Customize when Ralph should escalate. Add project-specific thresholds, like
"always escalate if touching auth code" or "escalate if change affects more
than 5 files".

## Handoff Format

Edit `templates/handoff.md` to add project-specific sections. Examples:
- **Metrics** — performance numbers before/after
- **Migration notes** — for projects with database migrations
- **Deploy checklist** — for projects with manual deploy steps

## CLAUDE.md Discipline Gates

Edit the gates in your project's CLAUDE.md. Common changes:
- Adjust code-critic configuration (model, rounds)
- Add project-specific pre-commit checks
- Add required reading beyond RALPH.md (e.g., architecture docs)

## Spec Format

### Overview Template

Edit `templates/_overview.md` to add project-specific sections. The five
phases (Describe through Design) are structural — don't remove them. But you
can add subsections, change prompts, or add project-specific guidance within
each phase.

### Task Template

Edit `templates/task.md` to add fields or sections. The frontmatter fields
(`id`, `status`, `priority`, `category`, `ticket`) are used by
`/pour` — keep those. Body sections (`outcome`, `verification`, `review`) are
also expected by the tooling.

You can add additional frontmatter fields (e.g., `estimated_effort`, `area`)
or body sections (e.g., `<notes>`, `<references>`).

## Nix/devenv Integration

If you use the devenv module, templates are installed from the Nix store and
are read-only. To customize:

1. Override in your devenv configuration
2. Or: let `/init` detect the Nix-managed files and skip them, then manually
   create your customized versions (they won't be overwritten on rebuild)
