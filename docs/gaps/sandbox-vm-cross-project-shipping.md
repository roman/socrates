---
title: Cross-project shipping of the sandbox-vm capability
created: 2026-04-30
discovered_in: implementation of sandbox-vm in this flake
---

# Cross-project shipping of the sandbox-vm capability

## Gap

Socrates currently ships the bare-metal Ralph loop (`ralph.sh`,
`ralph-once.sh`, `ralph-format.sh`) into target projects via the
devenv module's `claude.code.plugins.socrates.templates.install`
option — a file-copy mechanism that writes scripts into the target
project's root.

The new sandbox-vm capability does not fit that mechanism. It
expresses itself as flake **packages** (`sandbox-vm-image`,
`sandbox-ralph`, `sandbox-ralph-once`) and a NixOS **module**
(`nixosModules.sandbox-vm`), not as portable shell scripts. A target
project that wants the sandboxed flavour cannot enable a single
devenv option to get it; they have to wire the packages into their
own flake by hand.

## Why it matters

The sandbox is the load-bearing safety mechanism for autonomous
Ralph runs (it is what protects the host from
`--dangerously-skip-permissions`). If using it requires every
target project to know flake-output plumbing, adoption stays low
and the unsafe bare-metal path remains the default — defeating the
purpose of building the sandbox in the first place.

It also bakes a per-project tailoring problem: the sandbox image
includes a guest toolchain (`claude-code`, `git`, `jq`, `tk`, `gh`,
`ripgrep`). Other projects may need additional tooling (a language
toolchain, a project-specific CLI). A one-size-fits-all shipping
artefact wouldn't serve them; whatever we ship has to be
parameterizable.

## Triggering context

Surfaced during initial implementation of `sandbox-vm` in this
flake. The author asked whether the existing devenv `templates.install`
option should grow a sandbox flag. The answer for *this* iteration
is "no, dogfood here first" — but the cross-project shipping
question is real and will resurface as soon as another project
wants the sandbox. Recording the gap now keeps the implementation
focused on the local-flake case without losing the design question.

## Suggested resolution

Open a spec once `sandbox-vm` has been used in this project for
long enough to know what the natural target-project contract looks
like. The spec should design:

- A flake-output helper (e.g. `lib.mkSandboxRalph { extraPackages =
  [...]; ... }`) that target projects call from their own flake to
  construct a sandbox-ralph configured for their toolchain.
- Whether `nixosModules.sandbox-vm` is the right re-export surface,
  or whether we expose a higher-level "compose-the-whole-thing"
  module that target projects import in one line.
- How the devenv module integrates: most likely a
  `claude.code.plugins.socrates.sandbox.enable` option that adds
  `lima` + `qemu` to the devShell and surfaces convenience aliases
  (`nix run` is already discoverable, but operators may want
  `socrates-sandbox-ralph` style entry points).
- Whether we ship a prebuilt qcow2 image (release artefact) for
  projects that don't want to rebuild on first use, vs. requiring
  every consumer to build their own from their own modules.

The right shape depends on how the second-and-third target project
end up using the sandbox in practice; deferring lets the contract
be informed by real use rather than guesswork.
