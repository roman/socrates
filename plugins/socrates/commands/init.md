---
description: Initialize Socrates in the current project
---

# Initialize Socrates

Set up the Socrates structured design and autonomous development workflow.

## Pre-requisites Check

1. **Check tk CLI**: Run `tk --version`
   - If not installed: "Please install tk first. See: https://github.com/wedow/ticket"

2. **Check Claude CLI**: Run `claude --version`
   - If not installed: Warn user they'll need it to run Ralph

3. **Check jq**: Run `jq --version`
   - If not installed: "Please install jq for JSON parsing. See: https://jqlang.github.io/jq/"

4. **Check gh**: Run `gh --version`
   - If not installed: Warn user they'll need it for PR workflows

5. **Initialize tk**: If `.tickets/` doesn't exist, run `tk init`

## Nix/devenv Detection

Before copying or creating any file, check whether it is already managed by
Nix (devenv module). A file is Nix-managed if it is a symlink pointing into
`/nix/store/`. For each file that would be installed:

```bash
# Returns true if the file is a nix store symlink
is_nix_managed() {
  [ -L "$1" ] && readlink "$1" | grep -q '^/nix/store/'
}
```

**If Nix-managed**: Skip silently — devenv owns that file.
**If exists but NOT Nix-managed**: Ask user to skip or overwrite (same as below).
**If missing**: Install it.

This means in a devenv-enabled project, `/init` only handles what the devenv
module doesn't provide (e.g., `tk init`, content generation for project-specific
files like RALPH.md).

## Check for Existing Files

Before installing, check which non-Nix-managed files already exist:
- `./ralph.sh`
- `./ralph-once.sh`
- `./ralph-format.sh`
- `docs/specs/`
- `docs/handoffs/`
- `.msgs/`
- `RALPH.md`

**If ANY exist** (and are not Nix-managed): Use AskUserQuestion to ask user
for each existing file whether to:
- Skip (keep existing)
- Overwrite (replace with new version)

**If NO conflicts**: Proceed directly to installation.

## Installation Steps

Use Bash `cp` commands for fast file copying (NOT Read/Write tools).
Skip any file that is Nix-managed.

Determine the template source directory:
```bash
# Prefer SOCRATES_TEMPLATES env var (set by devenv module), fall back to plugin root
TEMPLATE_DIR="${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}"
```

1. **Copy shell scripts** to project root (if not skipped/Nix-managed):
   ```bash
   cp "${TEMPLATE_DIR}/ralph.sh" ./ralph.sh
   cp "${TEMPLATE_DIR}/ralph-once.sh" ./ralph-once.sh
   cp "${TEMPLATE_DIR}/ralph-format.sh" ./ralph-format.sh
   chmod +x ralph.sh ralph-once.sh ralph-format.sh
   ```

2. **Create directory structure** (if not already present):
   ```bash
   mkdir -p docs/specs docs/handoffs .msgs
   ```

3. **Copy RALPH.md** (if not Nix-managed): Copy from the template:
   ```bash
   cp "${TEMPLATE_DIR}/RALPH.md" ./RALPH.md
   ```

4. **Append CLAUDE.md discipline gates**: Read the gates template and append
   to CLAUDE.md (or create if it doesn't exist). Skip if CLAUDE.md is
   Nix-managed — in that case, print a message telling the user to add
   these to their Nix source instead:
   ```bash
   cat "${TEMPLATE_DIR}/claude-gates.md" >> CLAUDE.md
   ```

5. **Install commit-msg hook** (warning only, does not block):
   Skip if `.git/hooks/commit-msg` is Nix-managed.
   ```bash
   # Create .git/hooks/commit-msg that warns if Refs: is missing
   # Does NOT block the commit — just prints a warning
   ```

6. **Create .msgs/ inbox**: Already done in step 2.

## Verify Installation

Confirm all files/directories exist (whether Nix-managed or locally installed):
- Scripts: ralph.sh, ralph-once.sh, ralph-format.sh
- Directories: docs/specs/, docs/handoffs/, .msgs/, .tickets/
- Protocol: RALPH.md
- Hook: .git/hooks/commit-msg (warning mode)

Report which files are Nix-managed vs locally installed.

## Output

Report what was installed, what was skipped (user choice), and what was
deferred to Nix/devenv.

Explain next steps:
1. Use `/socrates:spec` to design a feature through the Design in Practice journey
2. Review and approve task files in the spec
3. Use `/socrates:pour` to create tk tickets from approved tasks
4. Run `./ralph.sh` to start the autonomous loop
5. Use `/socrates:harvest` to extract learnings from session handoffs
