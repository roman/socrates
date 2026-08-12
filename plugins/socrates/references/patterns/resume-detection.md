# Resume Detection and Navigation

Read the existing `_overview.md` and scan the phase headings:

- `[DRAFT]` — phase not yet completed
- no marker — phase complete

Legacy specs may use `[COMPLETE]` or `[APPROVED]`; treat either as complete.
The frontmatter `delimit_approved:` field is the authoritative signal for
Delimit approval.

**Resume logic**: Find the first section with `[DRAFT]` marker. That is the current
phase. Skip completed phases.

Tell the user which phase you're resuming at and give a brief recap of what's been completed
so far (summarize completed sections in 1-2 sentences each).

## Going Back

The user can request to revisit a completed phase (e.g., "revisit Delimit", "go back to
Describe"). When this happens:

1. Add `[DRAFT]` to the target phase heading
2. Add `[DRAFT]` to ALL subsequent phase headings
3. If going back to or before Delimit: set `delimit_approved: false` in frontmatter
4. Resume the journey from the target phase

Edit sections directly — git tracks history.

This ensures that downstream phases that depended on the now-changed upstream content are
re-evaluated rather than silently stale.

## Automatic walk-back on detected conflict

Sometimes the user's input contradicts a decision recorded in an earlier completed phase,
even though they did not ask to revisit that phase. Detect this yourself. Examples:

- The user reframes the problem during Direction, contradicting the Delimit problem
  statement.
- The user introduces a new constraint during Design that would change the Direction
  comparison.
- The user discovers a verified fact during Design that contradicts a Diagnose hypothesis.

When this happens, **do not silently roll forward**. Stop, name the conflict, and ask the user
before reopening any phases:

1. Identify which completed section the new input contradicts.
2. Use AskUserQuestion to surface the conflict explicitly: "This contradicts the Delimit
   problem statement. Should I walk Direction back to `[DRAFT]` and revisit Delimit, or are
   you adjusting the problem statement deliberately?"
3. If the user confirms a walk-back, follow the "Going Back" procedure above for the target
   phase.
4. If the user says the conflict is intentional and shouldn't reopen earlier phases, log a
   brief note in the current phase's section (e.g., an "Open assumption" line) so readers
   can see the conflict, then continue.

The point is to keep a bare, completed heading from becoming a lie. If the spec
contradicts itself, acknowledge the contradiction by reopening the affected
phases or recording the deliberate divergence.
