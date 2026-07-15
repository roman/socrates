# Source Doc Mode

When invoked with `--source <path-or-url>`:

## Reading the Source

Pick the reader by source type, checking in this order (the branches are
mutually exclusive):

1. GitHub issue URL → `gh issue view`
2. Any other URL (web page, Asana, Linear ticket) → WebFetch
3. Local file path → Read tool

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
(file paths, behaviors, configurations, counts). Those claims may be
stale, wrong, or aspirational. Pre-filling phases without checking them
inherits the source's errors into the spec.

Before pre-filling Describe and Diagnose, prompt the user:

> "I extracted <count> factual claims from the source doc. Want me to verify
> them against the codebase before pre-filling, or accept them as-is and
> flag uncertainty later?"

If the user says verify:

1. List the verifiable claims as a numbered list (e.g., "the chart ships
   with `crds.keep: false`", "the pipeline emits a
   `MeshAirProjectExtension` per project").
2. Spawn a foreground sub-agent (Explore or general-purpose) with the
   explicit task of confirming each claim against the codebase.
3. Report findings back inline, stating for each claim whether the
   codebase confirmed it, contradicted it, or left it unresolved.
   Refuted claims are reported with the contradicting evidence.
4. Pre-fill Describe / Diagnose using only confirmed claims as asserted
   facts. Anything contradicted or unresolved becomes a noted uncertainty
   in the relevant phase, not a fact.

If the user says accept:

- Pre-fill phases as-is, but add a note at the top of each pre-filled
  section so the inherited, unverified claims stay visible:
  > *Pre-filled from [source]. Claims not verified this session.*
- The Diagnose interview will naturally challenge assumptions, so stale
  claims tend to surface there. Naming the inheritance is honest and
  creates a hook to verify later.

## Gap Detection

After pre-filling, identify what the source document does NOT cover:
- Missing stakeholder context → ask in Describe
- No root cause analysis → full Diagnose interview needed
- Vague problem statement → full Delimit process needed
- Single solution proposed without alternatives → full Direction needed

Resume the journey at the first phase with gaps.
