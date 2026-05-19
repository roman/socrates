# Diagnose Phase

**Goal**: Identify the real problem beneath the situation. Challenge surface-level
assertions and test hypotheses.

**Technique**: Scientific Method — form hypotheses about what's wrong, test them
against evidence, reject the ones that don't hold up.

## Core Principle

"We don't have feature X" is NEVER a valid problem statement. Always dig deeper:
- Why is feature X needed? What user objective is unmet?
- What is the actual impact of the current situation?
- Is the assumed cause actually the cause?

## Interview Process

Start from the Describe section. Identify assertions and assumptions that need
testing. Use AskUserQuestion to probe:

1. **Challenge surface assertions** — For each "we need X" statement, ask: "What
   happens to users because X doesn't exist? What are they trying to accomplish?"

2. **Form hypotheses** — Based on the situation, propose 2-3 possible root causes.
   Present them to the user and ask which resonates, or if there's another angle.

3. **Test with evidence (Platt's Strong Inference)** — For each hypothesis,
   design the question that would *exclude* it, not confirm it. Ask: "What
   evidence would *disprove* this hypothesis?" Then actively search for that
   evidence in the codebase.

   The goal is elimination, not confirmation. A hypothesis survives by failing
   to be disproven, not by accumulating supporting evidence. If you cannot
   conceive of evidence that would disprove a hypothesis, it's not testable —
   flag it as an assumption, not a root cause.

   When multiple hypotheses remain after testing, design a distinguishing
   question: "What observable difference would we expect if hypothesis A is
   true vs hypothesis B?" Search for that difference.

4. **Identify root causes** — Converge on the actual problems. There may be more
   than one. Distinguish between root causes and symptoms.

**Guidelines**:
- Be respectfully skeptical — the first explanation is rarely the deepest one
- If the user says "we just need to build X", redirect: "Let's make sure X
  solves the right problem before we design it"
- Look for problems behind problems — technical debt, missing abstractions,
  process gaps, unclear ownership
- Note any constraints discovered (timeline, compatibility, team capacity)
- 3-5 questions is typical for this phase

## Writing the Diagnose Section

When root causes are identified:

1. Draft the `## Diagnose` section content — structured as:
   - Hypotheses considered (what was tested)
   - Evidence for/against each, with explicit **status** per hypothesis:
     **Confirmed** (tested with evidence), **Rejected** (disproved),
     or **Unconfirmed** (plausible but not yet testable). Never present
     an unconfirmed hypothesis as a root cause — label it clearly and
     note what evidence would confirm or reject it.
   - A `### Diagnosed items` subsection containing the typed-prefix
     items the rest of the spec will reference. See "Diagnosed items
     structure" below.
   - Symptoms vs causes (what looked like the problem vs what actually is)
2. Present draft to user for review
3. Write to overview: replace `## Diagnose [DRAFT]` content, update marker to
   `## Diagnose [COMPLETE]`
4. Confirm completion and preview Delimit phase

**Important**: Use Edit tool on just the Diagnose section. Preserve all other sections.

## K-T Completeness Audit

Before proceeding to Delimit, run a Kepner-Tregoe IS/IS-NOT audit on the
diagnosed problem. This technique bounds the problem by what it IS *and*
deliberately by what it could be but ISN'T — surfacing distinguishing
features that confirm root cause identification.

Launch a general-purpose agent (foreground, opus) with this prompt:

> Review the Diagnose section and build an IS/IS-NOT specification for
> the identified root causes. For each dimension below, state what the
> problem IS and what it IS-NOT (but plausibly could be):
>
> | Dimension | IS | IS-NOT |
> |-----------|-----|--------|
> | **What** | What objects/systems are affected? | What similar objects/systems are NOT affected? |
> | **Where** | Where does the problem occur? | Where does it NOT occur (but could)? |
> | **When** | When does it happen? | When does it NOT happen (but could)? |
> | **Extent** | How much/many are affected? | How much/many are NOT affected? |
>
> For each IS-NOT cell, explain why that distinction matters — what does
> it tell us about the root cause? Flag any row where you cannot identify
> a meaningful IS-NOT; that's a gap in problem characterization.
>
> Return: the completed table, any gaps found, and whether the diagnosed
> root causes are consistent with the IS/IS-NOT boundaries.

If the audit reveals gaps or inconsistencies:
- Present findings to the user
- Either return to Diagnose interview to fill gaps, or
- Note the gaps explicitly in the Diagnose section before proceeding

The K-T audit is optional for simple, well-bounded problems. Use judgment:
if the problem is already crisp and the root cause obvious, skip to Delimit.
If there's any ambiguity about scope or boundaries, run the audit.

## Diagnosed items structure

Each item in the `### Diagnosed items` subsection carries a typed
prefixed identifier so the decision matrix and downstream phases
can reference it precisely:

- **RC** — Root Cause. A real reason the problem exists.
- **NC** — Non-Cause. Looked like a cause; turned out not to be.
  Always include an "Implication for Direction" line (e.g.,
  "approaches should not be scored favorably for solving this").
- **AC** — Adjacent Constraint. A rule from outside this spec
  that any approach must respect.

Number each prefix sequentially (RC1, RC2, NC1, AC1, ...). Each
item gets a stable HTML anchor immediately above its heading so
the matrix's links don't break when headings are reworded:

```markdown
<a id="rc1"></a>
#### RC1 — Mesh safety enforced at the wrong altitude

<Explanation paragraph.>
```

The `### Diagnosed items` subsection starts with the legend table
from `_overview.md` (the four prefixes: RC, NC, AC, ID). Keep it
as a table; it's where readers learn what the prefixes mean before
they hit the matrix in Direction.

**Do not** present unconfirmed hypotheses as RCs. An unconfirmed
hypothesis stays in the Hypotheses subsection above with its
status; promote to RC only after evidence confirms it.
