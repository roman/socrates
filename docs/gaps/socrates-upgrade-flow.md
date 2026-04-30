---
title: Socrates Upgrade Flow
created: 2026-04-29
discovered_in: docs/specs/2026-04-29-pr-review-loop/
---

# Socrates Upgrade Flow

## Gap

Socrates installs into target projects via two mechanisms today:

- **Nix / devenv install.** Hard-links templates from the plugin
  source. Plugin changes propagate automatically to every project
  that uses the Nix install.
- **`/socrates-init` install.** Copies templates into the target
  project. Plugin changes do not propagate; the project carries its
  own snapshot.

When the plugin's protocol changes (new section in RALPH.md, new
template field, etc.), Nix-installed projects pick up the change
with no operator action; `/init`-installed projects do not.

## Why it matters

Every future protocol change inherits this divergence. Projects on
the `/init` install path drift from the plugin's current protocol
silently. There is no operator-facing signal that a protocol update
is available, and no command to apply one.

This is not specific to any one feature — it is a systemic concern
that grows with every plugin release.

## Triggering context

Surfaced during review of the `pr-review-loop` spec (T1), where a
significant protocol change to RALPH.md is introduced. The spec
itself has no upgrade story; the gap was deferred here so the
spec could land without scope creep.

## Suggested resolution

Open a spec for the Socrates upgrade flow. Candidate shapes:

- A new `/socrates-upgrade` command that detects an existing install,
  diffs against current templates, and applies the changes
  idempotently.
- Folding the upgrade behaviour into `/socrates-init` by making it
  re-runnable as an upgrade entry-point.
- A versioned-template pattern where each install records the
  template version and the upgrade command targets the diff.

The right choice depends on what protocol changes look like over
time and how operators are expected to discover them.