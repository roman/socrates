# Resume Detection and Navigation

Read the existing `_overview.md` and detect the current phase by scanning section
headers for phase markers:

- `[DRAFT]` — phase not yet completed
- `[COMPLETE]` — phase done
- `[APPROVED]` — Delimit phase approved by user

Also check frontmatter `delimit_approved:` field.

**Resume logic**: Find the first section with `[DRAFT]` marker. That is the
current phase. Skip all `[COMPLETE]`/`[APPROVED]` phases.

Tell the user which phase you're resuming at and give a brief recap of what's
been completed so far (summarize completed sections in 1-2 sentences each).

## Going Back

The user can request to revisit a completed phase (e.g., "revisit Delimit",
"go back to Describe"). When this happens:

1. Set the target phase's header marker to `[DRAFT]`
2. Set ALL subsequent phase markers to `[DRAFT]`
3. If going back to or before Delimit: set `delimit_approved: false` in frontmatter
4. Resume the journey from the target phase

Edit sections directly — git tracks history.

This ensures that downstream phases that depended on the now-changed upstream
content are re-evaluated rather than silently stale.

## Automatic walk-back on detected conflict

The user can also reach a point where their input contradicts a
decision recorded in an earlier `[COMPLETE]` phase, without
explicitly asking to revisit it. Examples:

- The user reframes the problem during Direction, contradicting
  the Delimit problem statement.
- The user introduces a new constraint during Design that would
  change the Direction comparison.
- The user discovers a verified fact during Design that
  contradicts a Diagnose hypothesis.

When this happens, **do not silently roll forward**. Stop, name
the conflict, and ask the user before unwinding any markers:

1. Identify which `[COMPLETE]` (or `[APPROVED]`) section the new
   input contradicts.
2. Use AskUserQuestion to surface the conflict explicitly:
   "This contradicts the Delimit problem statement. Should I
   walk Direction back to `[DRAFT]` and revisit Delimit, or are
   you adjusting the problem statement deliberately?"
3. If the user confirms a walk-back, follow the "Going Back"
   procedure above for the target phase.
4. If the user says the conflict is intentional and shouldn't
   reopen earlier phases, log a brief note in the section being
   currently worked on (e.g., as an "Open assumption" line) so
   the conflict is visible to readers, and continue.

The point is to never let a `[COMPLETE]` marker become a lie. If
the spec contradicts itself, the contradiction is acknowledged in
writing — either by walking back the marker, or by recording the
deliberate divergence.
