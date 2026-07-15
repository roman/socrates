# Socrates ships as an installed @skills-dir plugin, consumed by minerva/olympia

Restructured socrates from a commands-plus-loose-docs plugin into a
cohesive multi-skill `@skills-dir` plugin, packaged it in minerva via
`fetchFromGitHub`, and enabled it on the olympia host. socrates
conventions are now discoverable by skill name instead of by filesystem
path, which is what let a consuming repo (the work `specs` repo) drop its
hardcoded `~/Projects/self/socrates/...` references.

## What Was Done

### Restructured the plugin (socrates 66c2b39)

The former slash commands and loose reference files became five skills
under a shared `references/` tree:

- `spec` — the Design in Practice journey (was `commands/spec.md`)
- `task` — interactive task work (was `commands/socrates-task.md`)
- `harvest` — promote handoff learnings/gaps (was `commands/harvest.md`)
- `pm` — triage, task-state reconciliation, the Spec Lifecycle sweep
  (extracted from the PM role in `RALPH.md`)
- `spec-format` — the format contract for specs/gaps/learnings/handoffs
  (new; this is the skill other repos reference by name)

Shared `references/` holds `voice.md`, `spec-format.md`,
`ralph-protocol.md`, `task-authoring*.md`, and the `phases/` and
`patterns/` dirs. The skills reach them by relative path
(`../../references/...`). All the old path indirection
(`${SOCRATES_SUPPORT}`, `${SOCRATES_VOICE}`, `${SOCRATES_TEMPLATES}`,
`<support>`) collapsed into those relative links, because a cohesive
`@skills-dir` plugin installs as one intact tree.

The skill package installs to `share/agents/skills/socrates`. A new
home-manager module exposes `programs.claude-code.plugins.socrates.enable`.
We dropped the project-scoped devenv module in favor of the global
home-manager path (socrates no longer self-installs into its own dev
shell).

### Packaged socrates in minerva (f16d0c7)

minerva's socrates skill package fetches the pushed socrates commit via
`fetchFromGitHub` (rev `66c2b39`, hash pinned) and installs the tree so
`agent-skills`' `mkPluginDir` wraps it as an `@skills-dir` plugin
(`socrates:spec`, `socrates:task`, `socrates:harvest`, `socrates:pm`,
`socrates:spec-format`). It sits alongside the other remote skills
(ast-grep, obsidian-skills). We reached this end-state through an
interim `flake = false` input (overridable via `nix/inputs` for local,
pre-push iteration), then switched to `fetchFromGitHub` once socrates was
pushed. zoonix (4cc0060) bumped its minerva lock to this commit.

### Enabled it on olympia

olympia set `programs.claude-code.plugins.socrates.enable = true`; the
option flows in through `zoonix -> minerva.homeManagerModules.default`.
The clean state carries no socrates flake input in olympia — minerva owns
it, olympia just enables it. We verified a plain `smart-rebuild build`
(no `--impure`, no local override) builds `claude-plugin-socrates` from
the fetchFromGitHub source, and a `switch` installed all five skills into
`~/.claude/skills/socrates`.

### Repointed the consuming repo

The work `specs` repo's `CLAUDE.md` (ec9990e, pushed) now delegates to
`socrates:spec-format`, `socrates:harvest`, `socrates:pm`, and the
`tutor:*` skills by name. The absolute `~/Projects/self/socrates/...` and
`docs/spec-format.md` paths are gone; the file keeps only the
honor-when-writing-by-hand folder contracts.

## Verification

- socrates skill package builds; installed tree has all five skills, the
  bundled manifest, and `references/`, with `../../references/` links
  resolving in the store output.
- `smart-rebuild build` on olympia succeeds purely (exit 0), building
  `claude-plugin-socrates` with no socrates override anywhere.
- olympia `switch` placed the plugin at `~/.claude/skills/socrates`.
- socrates (66c2b39), minerva (f16d0c7), zoonix (4cc0060), and the specs
  CLAUDE.md (ec9990e) are all pushed; olympia is pushed too.

## What's Next

- Revert the graphite-cli stable pin in olympia
  (`nix/configurations/darwin/olympia/default.nix`, `pkgs.graphite-cli`
  back to `upkgs.graphite-cli`) once nixpkgs-unstable fixes the broken
  `graphite-cli-unwrapped-1.8.6` build. It was pinned only to unblock the
  full darwin-system build; it is unrelated to socrates.
- The five SKILL.md `description` fields were written for discoverability
  but not yet exercised in a real session. Watch whether they trigger the
  right skill in practice and tune if a skill fails to activate on intent.

## Gaps

- socrates's autonomous RALPH loop (`ralph.sh` + root `RALPH.md`) still
  reads the root `RALPH.md`; the `pm`/`task` skills link a copy at
  `references/ralph-protocol.md`. Two copies of the PM/protocol content
  now exist (root + reference). This is deliberate for the two runtimes,
  but a future edit to the protocol must touch both.

## Addendum: recurring nix friction hit this session

- **nix-unit pre-commit hook is slow.** minerva commits ran the
  `nix-unit` test suite in the pre-commit hook and exceeded a 2-minute
  foreground timeout twice; committing in the background succeeded.
- **git fsmonitor breaks pure eval.** `builtins.getFlake` on a dirty tree
  failed with `.git/fsmonitor--daemon.ipc has an unsupported type`; fix
  was `git fsmonitor--daemon stop` + `git config core.fsmonitor false` in
  the affected checkouts.
- **smart-rebuild relock chases the nixpkgs-unstable branch tip.**
  Because zoonix pins `nixpkgs-unstable` to a branch, smart-rebuild's
  auto-relock pulled the broken graphite 1.8.6; building against the
  existing lock (or with unpushed inputs, which it refuses to relock)
  avoids it.
