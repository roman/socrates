# Source Doc Mode

When invoked with `--source <path-or-url>`:

## Reading the Source

1. If the source is a file path: use Read tool
2. If the source is a URL: use WebFetch tool
3. If the source is a ticket URL (Asana, Linear, GitHub issue): use appropriate
   tool (gh for GitHub issues, WebFetch for others)

## Pre-filling Phases

Analyze the document and extract what maps to each Design in Practice phase:

- **Describe**: Context, background, current situation → pre-fill Describe section
- **Diagnose**: Problem analysis, root causes if stated → pre-fill Diagnose section
- **Delimit**: Problem statement if crisp enough → propose for Delimit (still
  requires explicit approval)
- **Direction**: Proposed solutions, alternatives considered → pre-fill Approaches

For each phase that can be pre-filled:
1. Present the extracted content to the user
2. Ask if it's accurate or needs adjustment
3. If accurate: write to overview with `[COMPLETE]` marker (except Delimit which
   needs explicit approval)
4. If needs adjustment: enter that phase's interview flow with the extracted
   content as a starting point

## Verifying source-doc claims

Source documents make factual claims about how systems work today
(file paths, behaviors, configurations, counts). Those claims may
be stale, wrong, or aspirational. Pre-filling phases without
checking them inherits the source's errors into the spec.

Before pre-filling Describe and Diagnose, prompt the user:

> "I extracted N factual claims from the source doc. Want me to
> verify them against the codebase before pre-filling, or accept
> them as-is and flag uncertainty later?"

If the user says verify:

1. List the verifiable claims as a numbered list (e.g., "the chart
   ships with `crds.keep: false`", "the pipeline emits a
   `MeshAirProjectExtension` per project").
2. Spawn a foreground sub-agent (Explore or general-purpose) with
   the explicit task of confirming each claim against the
   codebase.
3. Report findings back inline using the confidence labels from
   `voice.md`: ✅ Verified, 🟨 High confidence, 🟧 Medium confidence,
   🟥 Low confidence. Refuted claims get 🟥 with the contradicting
   evidence.
4. Pre-fill Describe / Diagnose using only ✅ and 🟨 claims as
   asserted facts. Anything 🟧 medium / 🟥 low becomes a noted
   uncertainty in the relevant phase, not a fact.

If the user says accept:

- Pre-fill phases as-is, but each non-trivial factual claim
  inherited from the source carries a 🟨 label by default
  (high-confidence-but-not-this-session-verified). Surfacing the
  label in the spec is honest about the inheritance and creates
  a hook to verify later.

## Gap Detection

After pre-filling, identify what the source document does NOT cover:
- Missing stakeholder context → ask in Describe
- No root cause analysis → full Diagnose interview needed
- Vague problem statement → full Delimit process needed
- Single solution proposed without alternatives → full Direction needed

Resume the journey at the first phase with gaps.
