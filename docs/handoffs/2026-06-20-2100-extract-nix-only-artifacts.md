# 46c0 — Extract Nix-only artifacts from the plugin

Moved Nix-only files out of `plugins/socrates/templates/` into
`nix/ralph/`, separating the marketplace-shippable plugin from the
Nix-only Ralph surface.

## What Was Done

### Moved (plugins/socrates/templates/ -> nix/ralph/)
- RALPH.md, ralph.sh, ralph-once.sh, ralph-format.sh
- handoff.md, commit-msg.sh
- spec (CLI script), spec.test.sh

### Updated Nix consumers
- `nix/packages/spec-cli.nix` — source path now `../ralph/spec`
- `nix/modules/devenv/socrates.nix` — ralph script reads use new
  `ralphDir` pointing at `${inputs.self}/nix/ralph`
- `nix/packages/skills/socrates/default.nix` — no code change needed;
  the `cp -r templates` now copies only marketplace templates

### Updated references
- `nix/packages/sandbox-ralph/sandbox-vm-lib.sh` — VM inner script
  path changed from `plugins/socrates/templates/` to `nix/ralph/`
- `plugins/socrates/.claude-plugin/plugin.json` — dropped `ralph`
  keyword, updated description to remove "autonomous development"
- `CLAUDE.md` — updated RALPH.md path reference

## Verification
- All spec CLI tests pass
- `spec status` works correctly
- Both `skills.socrates` and `spec-cli` Nix packages build
- `nix flake check` has a pre-existing devenv assertion failure
  (not related to this change — same on clean tree)

## Known Interim Breakage
- `/socrates-init` (`plugins/socrates/commands/init.md`) references
  ralph files via `SOCRATES_TEMPLATES` that no longer exist there.
  T4 (trim-socrates-init) removes `/init` entirely, so this is
  expected interim state. The operator only uses Nix, never `/init`.

## What's Next
- T2 (85ae-spec-discipline-via-spec-preamble) is independent and ready
- T3 depends on T2; T4 depends on T2+T3; T5 depends on all

Refs: 46c0-extract-nix-only-artifacts
