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

## Source-doc claims

Source documents make factual claims about how systems work today.
Those claims may be stale, wrong, or aspirational.

Trust but flag: pre-fill phases with content as-is, but add a note
at the top of pre-filled sections:

> *Pre-filled from [source]. Claims not verified this session.*

The Diagnose interview will naturally challenge assumptions — stale
claims surface there. Explicit verification happens only if needed.

## Gap Detection

After pre-filling, identify what the source document does NOT cover:
- Missing stakeholder context → ask in Describe
- No root cause analysis → full Diagnose interview needed
- Vague problem statement → full Delimit process needed
- Single solution proposed without alternatives → full Direction needed

Resume the journey at the first phase with gaps.
