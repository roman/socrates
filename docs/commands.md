# Command Reference

## /init

Initialize Socrates in the current project.

```
/init
```

**What it does:**
- Checks prerequisites: `tk`, `claude`, `jq`, `gh`
- Runs `tk init` to create `.tickets/`
- Copies shell scripts (ralph.sh, ralph-once.sh, ralph-format.sh)
- Creates directory structure: `docs/specs/`, `docs/handoffs/`, `.msgs/`
- Copies RALPH.md protocol file from template
- Appends discipline gates to CLAUDE.md
- Installs commit-msg hook (warning mode — warns if `Refs:` is missing)

**Nix/devenv detection:** Files managed by Nix (symlinks into `/nix/store/`) are
skipped. The devenv module handles those.

**Conflict handling:** If files already exist, you're asked to skip or overwrite
each one.

---

## /spec

Design a feature through the Design in Practice journey.

```
/spec                          # list specs or create new
/spec <name>                   # create or resume a spec
/spec --source <file-or-url>   # pre-fill from a document
/spec <task-file-path>         # review a specific task
/spec --status                 # show progress summary
```

**Arguments:**

| Argument | Effect |
|----------|--------|
| (none) | Lists existing specs, asks to resume or create new |
| `<name>` | Creates `docs/specs/<name>/` or resumes existing |
| `--source <path>` | Reads PRD/ticket/URL, pre-fills phases, interviews for gaps |
| `<task-file>` | Enters task review mode for that file |
| `--status` | Shows phase progress and task counts across all specs |

**Phases:** Describe → Diagnose → Delimit (strict gate) → Direction → Design

**Resume:** Re-running `/spec <name>` detects completed phases via `[COMPLETE]`
markers and resumes at the first `[DRAFT]` phase. You can request to go back to
any earlier phase.

**Output:**
- `docs/specs/<name>/_overview.md` — design journey document
- `docs/specs/<name>/<id>.md` — individual task files (5-10 per spec)

---

## /pour

Transform approved spec task files into tk tickets.

```
/pour                   # list specs with approved tasks
/pour <name>            # pour approved tasks from a specific spec
```

**Arguments:**

| Argument | Effect |
|----------|--------|
| (none) | Lists specs with approved tasks, asks which to pour |
| `<name>` | Pours approved tasks from `docs/specs/<name>/` |

**Behavior:**
- Only `status: approved` tasks are poured (draft skipped, poured skipped)
- Creates parent epic when 2+ tasks exist
- Wires dependencies via `tk dep` in topological order
- Freezes task files: sets `status: poured` and `ticket: <tk-id>`
- Idempotent: safe to re-run

---

## /harvest

Extract learnings and gaps from session handoffs.

```
/harvest
```

**No arguments.** Scans all unharvested handoffs since `.last-harvest` marker.

**For each learning**, you choose:
- Create/update a skill in `.claude/skills/`
- Add to CLAUDE.md or folder CLAUDE.md
- Add to `docs/`
- Skip

**For each gap**, you choose:
- Create a tk ticket
- Add to an existing spec
- Skip

**Tracking:** Writes the most recent handoff filename to `.last-harvest` so
future runs skip already-processed handoffs.

---

## Shell Scripts

These are installed by `/init` and used for the Ralph autonomous loop.

### ralph.sh

```bash
./ralph.sh [max_iterations] [--verbose|-v]
```

Main autonomous loop. Picks tasks from `tk ready -a ralph`, invokes Claude,
formats output. Default: 100 iterations. Exits on `.ralph-stop` file or when
no tasks remain.

### ralph-once.sh

```bash
./ralph-once.sh
```

Single iteration of the Ralph loop. Useful for testing and interactive
development.

### ralph-format.sh

```bash
./ralph-format.sh [--verbose|-v]
```

Formats Claude's stream-json output with color-coded tool calls, token
accounting, and progress display. Piped from ralph.sh automatically.
