# Delimit Phase (STRICT GATE)

**Goal**: Produce a crisp, 1-2 sentence problem statement that the user explicitly
approves. This is the only hard gate — do NOT proceed without approval.

**Technique**: Precise Language — every word must earn its place. Vague terms
like "improve", "better", "optimize" must be replaced with observable specifics.

## Drafting the Problem Statement

Using the root causes from Diagnose, draft a problem statement that:

- States the **unmet user objective** (what users can't do or struggle with)
- States the **cause** (why the objective is unmet)
- Is **1-2 sentences** — if it takes more, you haven't delimited enough
- Uses **observable terms** — someone should be able to tell if this is solved
- Does NOT contain a solution — "we need to build X" is a solution, not a problem

## Inversion Test: What Would Make This the Wrong Scope?

Before presenting the problem statement for approval, apply Munger's inversion:
**"What would guarantee this problem statement is scoped incorrectly?"**

Actively search for:

1. **Too narrow** — Does the statement exclude a root cause that will resurface?
   Check: would solving this statement leave a diagnosed RC unaddressed?

2. **Too broad** — Does the statement include problems we didn't diagnose?
   Check: does every word trace back to evidence in Diagnose?

3. **Wrong boundary** — Does the statement cut across a natural seam?
   Check: would solving this require solving an adjacent problem first?

4. **Solution leak** — Does the statement smuggle in an assumption about *how*
   to solve it? Check: could this be solved multiple different ways?

If any inversion test fails, revise the statement before presenting it.
Document what the inversion caught (briefly) so the user sees the refinement.

**Bad examples**:
- "We need a better auth system" (solution disguised as problem)
- "The codebase is messy" (vague, no user impact stated)
- "Performance needs to be improved" (no specifics)

**Good examples**:
- "Users abandon checkout when page load exceeds 3s on mobile because the
  product image pipeline blocks rendering"
- "New team members take 2+ weeks to ship their first PR because the test
  suite requires undocumented local dependencies"

## Approval Gate

1. Present the draft problem statement to the user
2. Use AskUserQuestion with options:
   - **"Approved"** — problem statement is crisp and correct
   - **"Needs refinement"** — close but wording needs adjustment
   - **"Wrong problem"** — go back to Diagnose
3. If "Needs refinement": ask what to change, redraft, present again
4. If "Wrong problem": set Diagnose back to `[DRAFT]`, return to Diagnose phase
5. If "Approved": proceed to *Writing the Delimit Section* below

## Writing the Delimit Section

On approval:

1. Write the problem statement to the `## Delimit` section
2. Remove `[DRAFT]` from the heading
3. Update frontmatter: set `delimit_approved: true`
4. Confirm and preview Direction phase

The bare heading means the phase is complete. The `delimit_approved: true`
frontmatter field is the authoritative record that the user approved it.

**Important**: Use Edit tool for targeted updates. The frontmatter change and
section change are two separate edits.
