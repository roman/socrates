---
id: 46c0-extract-nix-only-artifacts
status: approved
priority: 1
category: infrastructure
assignee:
deps: []
---

# Extract Nix-only artifacts from the plugin

## Outcomes

- Ralph protocol and loop scripts (RALPH.md, ralph.sh, ralph-once.sh,
  ralph-format.sh, handoff.md), the commit-msg.sh git hook, and the
  spec CLI script (with its test) are removed from
  `plugins/socrates/` and live under a Nix-only home in this repo.
- The three Nix consumers point at the new home: the devenv module
  at `nix/modules/devenv/socrates.nix`, the skills package at
  `nix/packages/skills/socrates/default.nix`, and the spec-cli
  package at `nix/packages/spec-cli.nix`. The Nix install path is
  unchanged from an operator's perspective.
- The plugin manifest at `plugins/socrates/.claude-plugin/plugin.json`
  is updated to drop the `ralph` keyword and any description content
  that no longer reflects the marketplace-shippable scope.
- The plugin's spec overview template at
  `plugins/socrates/templates/_overview.md` no longer prose-references
  RALPH.md (the line that points marketplace users at a file the
  marketplace plugin doesn't ship).
- After the move, `plugins/socrates/` contains only artifacts that
  ship in the Anthropic plugin marketplace: command definitions,
  templates the commands read, voice rules, and the plugin manifest.

## Verification

- `plugins/socrates/templates/` no longer contains RALPH.md,
  ralph*.sh, handoff.md, commit-msg.sh, spec, or spec.test.sh.
- The `ralph.sh` invoked from this project's devenv shell loads
  RALPH.md by a path under the new Nix-only home (verifiable by
  inspecting the resolved path in the script's bootstrap).
- The commit-msg hook still warns on missing or draft `Refs:` for
  this project's commits.
- Running `spec status` in this project's devenv shell returns the
  expected listing of non-archived specs.
- `plugin.json` keywords do not include "ralph".
- `nix flake check` passes after the move.
