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

## Boundary Checkpoint

Before proceeding to Delimit, verify the diagnosis is complete:

> "Does the diagnosed root cause explain why the problem occurs *here* and
> *now* but not in similar situations? If not, the boundary isn't crisp yet."

If the answer is unclear, ask one follow-up question to sharpen the boundary.

## Diagnosed items structure

Each item in the `### Diagnosed items` subsection carries a typed prefix
so it can be referenced as vocabulary in discussion and the decision matrix:

- **RC** — Root Cause. A real reason the problem exists.
- **NC** — Non-Cause. Looked like a cause; turned out not to be. Limit to
  2-3 items worth documenting. Include an "Implication for Direction" line.
- **AC** — Adjacent Constraint. A rule from outside this spec that any
  approach must respect.

Number each prefix sequentially (RC1, RC2, NC1, AC1, ...):

```markdown
#### RC1 — Mesh safety enforced at the wrong altitude

<Explanation paragraph.>
```

If an item is deleted, note "RC2 removed" rather than renumbering — this
preserves references in discussion history.

**Do not** present unconfirmed hypotheses as RCs. An unconfirmed hypothesis
stays in the Hypotheses subsection with its status; promote to RC only
after evidence confirms it.
