# ADR 005 — Review Mode as Protocol Extension

## Context

RALPH closes tickets at "work done" (branch-landed). On projects that
use external code review (PRs/MRs), the review-to-merge window has no
protocol coverage. Humans manually bridge each round of review feedback
into a fresh Claude session.

The pr-review-loop spec diagnosed two root causes: the ticket lifecycle
has no "in review" state (RC1) and the protocol has no role for external
review (RC2).

## Decision

Extend RALPH.md with an opt-in review mode rather than modifying `tk`'s
status model or adding a dedicated skill.

Key design choices:

- **Per-spec opt-in via `review_mode` in `_overview.md` frontmatter.**
  Not per-ticket, not per-project. Missing field treated as `false`.
- **Tag-based signaling** (`awaiting-review`, `needs-human`) instead of
  new `tk` statuses. Avoids `tk` schema changes.
- **URL-based external-ref** with no custom prefix scheme. The agent
  maps host to tool using common knowledge.
- **Append-only ticket mutation** to avoid races between PM sweep and
  concurrent implementer sessions.
- **Direct `.tickets/<id>.md` editing** since `tk edit` opens `$EDITOR`.

## Consequences

- Specs that opt in get end-to-end ticket lifecycle through merge.
- Specs that don't opt in (and one-off tickets) behave identically to
  today.
- PM cycle gains a sweep (External Review Sweep) that is a no-op when
  no tickets carry the tag.
- Auth is required for most useful operations on both GitHub and GitLab.
  The escalation rule surfaces auth failures rather than silently
  dropping them.
- `/init`-installed projects must re-run `/init` to pick up the new
  RALPH.md. Deferred to `docs/gaps/socrates-upgrade-flow.md`.

## Alternatives Considered

- **A3 — New `tk` status `in_review`**: More explicit but touches `tk`
  source and adds schema complexity. Tag + existing `in_progress` is
  sufficient signaling.
- **A4 — Dedicated `/review` skill**: Better tooling for the manual
  bridge but doesn't fix the ticket lifecycle — tickets still die at
  work-done.
