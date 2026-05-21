# Spec Command Simplification

Analyzed `/spec` protocol for accidental complexity with grug-architect agent.
Identified and removed ceremony that didn't earn its keep.

## Changes Made

### Deleted entirely
- **K-T Completeness Audit** — Spawned opus agent to build IS/IS-NOT table. Replaced with one checkpoint question at end of Diagnose.
- **"Previous (superseded)" history preservation** — Git tracks history; no need to embed it in the spec file.
- **`revisions` frontmatter field** — No downstream consumer. Git log shows iteration history.
- **Medium confidence tier** — Collapsed to 3 tiers: Verified / High / Low.

### Relocated
- **Inversion test** — Moved from per-approach (4x ceremony) to post-selection only. One test on the chosen approach.
- **Residue test** — Moved from Describe to Direction (post-selection). More appropriate timing.

### Simplified
- **Ackoff Gate** — Triple-test (Recurrence/Upstream/Residue) → single upstream question.
- **RC/NC/AC prefix system** — Kept prefixes as vocabulary, dropped HTML anchors. NC capped at 2-3 items.
- **Design Review council** — Mandatory → opt-in via prompt.
- **Source-doc verification** — Agent spawn + per-claim labeling → "trust but flag" with Diagnose catching errors.
- **Shared Surfaces** — Renamed to "Files touched by multiple tasks". Dropped ownership markers. Added explicit "Dependencies" section with arrow notation (`Task 1 -> Task 3`).

### Added
- Optional `tags:` field in overview frontmatter for recurrence pattern detection.

## Deferred

**Task ID generation** (hash in `1-a1b2-setup-middleware`) — Deferred pending larger conversation about pour/tk architecture. The hash exists because tk tickets share a namespace; if Socrates owned spec-namespaced tickets, hash wouldn't be needed.

## Files touched

- `plugins/socrates/commands/spec.md`
- `plugins/socrates/commands/spec-support/phases/describe.md`
- `plugins/socrates/commands/spec-support/phases/diagnose.md`
- `plugins/socrates/commands/spec-support/phases/direction.md`
- `plugins/socrates/commands/spec-support/phases/design.md`
- `plugins/socrates/commands/spec-support/patterns/resume-detection.md`
- `plugins/socrates/commands/spec-support/patterns/source-doc-mode.md`
- `plugins/socrates/commands/spec-support/patterns/task-review-mode.md`
- `plugins/socrates/templates/_overview.md`
- `plugins/socrates/templates/task.md`
- `plugins/socrates/voice.md`

## Open threads

1. **Pour/tk architecture** — Is tk integration the right approach, or should Socrates own spec-namespaced tickets directly? This affects task ID format.
