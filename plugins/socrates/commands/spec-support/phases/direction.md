# Direction Phase

**Goal**: Generate multiple approaches to solving the delimited problem, help the
user compare them, and choose one. Also capture use cases.

**Technique**: Contrast Over Linearity — seeing differences between approaches
triggers thinking that a single proposal never would.

## Ackoff Checkpoint (Recurring)

Before generating approaches, revisit the Ackoff question from Describe:
**"Are we still solving the right problem?"**

The journey from Describe through Diagnose and Delimit may have surfaced
information that reframes the original situation. Quick check:

1. Re-read the approved Delimit statement
2. Compare it to what you now know from the K-T audit and diagnosis
3. If the problem statement still feels like the real problem, proceed
4. If it now feels like a symptom or wrong framing, surface this to the user
   before generating approaches — it's cheaper to revisit Delimit now than
   to design solutions to the wrong problem

This is a lightweight checkpoint, not a full gate. If nothing feels off,
proceed without asking the user.

## Generating Approaches

1. **Always include Status Quo as A1** — what happens if we do nothing?
   This is the baseline all other approaches are measured against.

2. Generate 2-3 additional approaches that address the problem statement from
   different angles. Number them sequentially: A2, A3, A4. Don't number
   by phase, status, or scope; don't leave gaps. If an approach is
   later dropped, renumber. Each approach gets a short tag describing
   its center of gravity (e.g., "A2 — VAP as safety surface", not
   "A2 — Add a VAP").

3. Vary approaches meaningfully:
   - Different technical strategies (not just variations of the same idea)
   - Different scope/ambition levels where applicable
   - Different tradeoff profiles (speed vs correctness, simplicity vs flexibility)

4. For each approach, describe:
   - What it does (1-2 sentences)
   - Key tradeoffs (what you gain, what you give up)
   - Rough scope signal (small/medium/large — not time estimates)

5. **Inversion test per approach** — Before presenting, ask of each approach:
   "What would guarantee this approach fails?" Identify:
   - **Assumptions that must hold** — what does this approach take for granted?
   - **Failure modes** — how could this go wrong even if executed well?
   - **Dependencies** — what external factors could break this?

   If the inversion reveals a fatal flaw (an assumption that's unlikely to hold,
   a failure mode with no mitigation), either revise the approach to address it
   or note it prominently in the tradeoffs. Don't hide failure modes in optimism.

6. Present approaches to the user and ask for initial reactions before building
   the decision matrix.

## Decision Matrix

If the choice is non-trivial (more than 2 viable approaches), build a decision
matrix:

- **Header**: The problem statement from Delimit
- **Columns**: Each approach (including status quo as A1)
- **Rows**: Evaluation criteria. Each row's "Criterion" cell is
  prefixed with a typed link back to the Diagnose section, e.g.
  `[[RC1](#rc1)] Reduces opaque sync failures` for criteria that
  trace to a diagnosed item. Implementation concerns (effort,
  risk, reversibility, time-to-value) use `[ID]` as the prefix
  instead of an item ID. The legend that defines the prefixes
  lives in Diagnose's `### Diagnosed items` subsection.
- **Cells**: 🟢 (strong), 🟡 (adequate), 🔴 (weak), ⚪ (not applicable),
  with a brief explanation alongside the indicator.

**Anti-patterns to avoid**:
- All-green columns → rationalization, not analysis. Find distinguishing criteria.
- Criteria that don't differentiate → remove them, they add noise.
- Solution-biased criteria → criteria should matter regardless of which approach wins.
- Criteria with no `[XX]` prefix → either it traces to a Diagnose
  item (give it the right RC/NC/AC tag) or it's an implementation
  concern (`[ID]`). Untagged criteria signal the matrix is
  drifting away from the diagnosis.

**Render the matrix in the chat session BEFORE writing it to the spec file.**
Markdown table notation is illegible in raw form — the user needs to see it
rendered to evaluate it. Decision matrices commonly trigger technical
discussion, criterion reassessment, or new approach ideas; capturing those
before persisting avoids file churn. Only write to the overview file once
the user has reviewed the rendered draft and confirmed direction. Discuss
any surprising results before asking for a choice.

## Choosing an Approach

Use AskUserQuestion to ask which approach the user wants to pursue.
Record: which approach and the user's rationale for choosing it.

The chosen approach gets a blockquote in the `### Chosen Approach`
subsection so it stands out visually:

```markdown
> **Chosen: A2 — <approach name>.** <Short rationale that ties the
> choice back to the diagnosed items it solves and the ones it
> deliberately leaves out.>
```

The blockquote may extend across multiple lines if the rationale
needs more than one sentence.

## Use Cases

After the approach is chosen, draft use cases as a three-column table:
Actor / Intent / Outcome.

- Focus on **user intentions**, not implementation: "I wish I could..." not
  "the system will..."
- 3-7 use cases is typical

Present use cases to user for confirmation.

## Writing the Direction Section

1. Write all subsections to `## Direction`:
   - `### Approaches` — all approaches with descriptions
   - `### Decision Matrix` — if applicable
   - `### Chosen Approach` — selection and rationale
   - `### Use Cases` — confirmed use cases
2. Update marker to `## Direction [COMPLETE]`
3. Confirm and preview Design phase

**Important**: Use Edit tool. Replace only the Direction section content.
