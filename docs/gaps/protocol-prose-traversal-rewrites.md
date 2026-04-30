---
title: Tooling adoption of the spec-status CLI
created: 2026-04-30
discovered_in: docs/specs/2026-04-29-spec-status-view/
---

# Tooling adoption of the spec-status CLI

## Gap

Four Socrates tooling surfaces describe spec/task traversal
in prose-and-bash that the implementing agent must follow,
each re-implementing the parser the new `socrates-status`
CLI is meant to centralize:

- `plugins/socrates/templates/RALPH.md` — the PM "Spec
  Lifecycle Sweep" iterates `docs/specs/*/`, reads each
  `_overview.md` frontmatter, and calls `tk show <epic-id>`.
- `plugins/socrates/commands/spec.md` (resume detection) —
  scans phase markers in section headers
  (`[DRAFT]`/`[COMPLETE]`/`[APPROVED]`) plus the
  `delimit_approved:` frontmatter to find the current phase
  of a single spec.
- `plugins/socrates/commands/spec.md` (`--status` summary
  form) — separately enumerates all specs and reports their
  phase as a status table; today this is implemented in
  prose by the slash-command agent, not by shelling out.
- `plugins/socrates/commands/pour.md` — the approved-task
  partition reads every `.md` in the spec directory and
  partitions by `status:` frontmatter.

Each runs the same parser logic ad-hoc, drifts when the
Markdown shape changes, and pays a re-derivation cost on
every invocation.

## Why it matters

The `socrates-status` CLI introduced by the
`spec-status-view` spec gives these prose surfaces a single
backing tool to invoke instead of re-implementing the
parser. Until they are rewritten to call the CLI, the agent
keeps paying the re-derivation cost on every PM cycle, every
`/socrates-spec` resume, and every `/pour` invocation — and
each protocol surface drifts independently when the Markdown
file shape changes (frontmatter field added, phase marker
renamed, etc.).

## Triggering context

Surfaced by the design review council on the
`spec-status-view` spec. Both `code-critic` and
`grug-architect` flagged that rewriting the protocol prose in
the same spec as the CLI itself was speculative — the right
shape of the agent-facing contract is not yet known, because
the CLI has never been used in anger. Cutting the rewrite to a
follow-up lets the CLI ship, accumulate a week of real use,
and informs the eventual contract (subcommand shape,
`--json` output, error-mode conventions).

## Suggested resolution

Open a follow-up spec once the CLI has been used by the human
author for long enough to surface the natural agent-facing
contract. The follow-up spec should design:

- The agent-readable output format (most likely `--json` per
  subcommand, but defer the choice).
- The exact prose changes in each of the four tooling
  surfaces, preserving behaviour while replacing the parser.
- The composition with `tk show` in the PM Spec Lifecycle
  Sweep — the CLI returns "specs that have an epic set",
  `tk` confirms closure; the prose specifies the join.
- Whether `/socrates-spec --status` should shell out to the
  CLI as its primary backing or render in-agent over CLI
  output.
