---
description: Design a feature through the Design in Practice journey (Describe → Diagnose → Delimit → Direction → Design)
---

# /spec — Design in Practice Journey

Walk the user through a structured design process that produces a spec overview
and individual task files. Each phase builds on the previous one, with a strict
gate at Delimit requiring explicit user approval.

## Arguments

The user may provide:
- **A spec name**: `/spec auth-redesign` — creates or resumes `docs/specs/auth-redesign/`
- **A task file path**: `/spec docs/specs/auth-redesign/a1b2-setup-middleware.md` — enters
  task review mode (see Task Review section)
- **A source document**: `/spec --source PRD.md` or `/spec --source https://...` — reads
  the document first, pre-fills what it can, then interviews for gaps
- **No arguments**: lists existing specs and asks which to resume, or prompts for a new name

## Step 1 — Spec Discovery and Setup

### If no arguments provided

1. Check `docs/specs/` for existing spec directories
2. If specs exist, use AskUserQuestion to ask: resume an existing spec, or create new?
3. If creating new, ask for a short kebab-case name

### If spec name provided

1. Check if `docs/specs/<name>/_overview.md` exists
2. If yes: resume mode (go to Step 2)
3. If no: create the spec directory and overview from template

### Creating a new spec

```bash
mkdir -p "docs/specs/<name>"
```

Copy the overview template and fill in frontmatter:
- Read the template from `${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}/_overview.md`
- Set `title:` to the spec name (human-readable, derived from kebab-case)
- Set `created:` to today's date (YYYY-MM-DD)
- Set `delimit_approved: false`
- Write to `docs/specs/<name>/_overview.md`

## Step 2 — Resume Detection

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

## Step 3 — Describe Phase

**Goal**: Capture the situation as-is, without interpretation or proposed solutions.

**Technique**: Reflective Inquiry — surface what the user knows, what they don't
know, and what context matters.

### Interview Process

Use AskUserQuestion iteratively to understand the situation. Start with these
orienting questions (adapt based on answers, don't ask robotically):

1. **"What's the situation?"** — What is happening right now? What triggered this
   work? Get the context and circumstances.

2. **"What do you know?"** — What facts, constraints, or prior decisions are
   established? What has been tried before?

3. **"What don't you know?"** — What are the open questions? What would you need
   to find out? Where is the uncertainty?

4. **"Who is affected?"** — Who are the users/stakeholders? How does the current
   situation impact them?

**Guidelines**:
- Ask ONE question at a time via AskUserQuestion
- Listen for implicit assumptions — note them but don't challenge yet (that's Diagnose)
- If the user provides a wall of text, reflect back a structured summary and ask
  if it captures things correctly
- Do NOT propose solutions or interpret problems — just capture the landscape
- 3-6 questions is typical; stop when you have a clear picture of the situation

### If source document provided

Instead of interviewing from scratch:
1. Read the source document (use Read tool for files, WebFetch for URLs)
2. Extract and structure the situation description from the document
3. Present the extracted description to the user for confirmation
4. Ask clarifying questions for any gaps (missing context, unclear stakeholders, etc.)

### Writing the Describe Section

When the interview is complete:

1. Draft the `## Describe` section content — a structured narrative covering:
   - The current situation and context
   - Known facts and constraints
   - Open questions and uncertainties
   - Stakeholders and impact
2. Present the draft to the user via a text response (not AskUserQuestion)
3. Ask if they want to adjust anything
4. Write the final version to the overview file:
   - Replace the `## Describe [DRAFT]` section content with the narrative
   - Update the marker to `## Describe [COMPLETE]`
5. Confirm completion and preview what comes next (Diagnose phase)

**Important**: Use the Edit tool to update only the Describe section. Do NOT
rewrite the entire file — other sections must remain as-is with their `[DRAFT]`
markers.

## Step 4 — Diagnose Phase

**Goal**: Identify the real problem beneath the situation. Challenge surface-level
assertions and test hypotheses.

**Technique**: Scientific Method — form hypotheses about what's wrong, test them
against evidence, reject the ones that don't hold up.

### Core Principle

"We don't have feature X" is NEVER a valid problem statement. Always dig deeper:
- Why is feature X needed? What user objective is unmet?
- What is the actual impact of the current situation?
- Is the assumed cause actually the cause?

### Interview Process

Start from the Describe section. Identify assertions and assumptions that need
testing. Use AskUserQuestion to probe:

1. **Challenge surface assertions** — For each "we need X" statement, ask: "What
   happens to users because X doesn't exist? What are they trying to accomplish?"

2. **Form hypotheses** — Based on the situation, propose 2-3 possible root causes.
   Present them to the user and ask which resonates, or if there's another angle.

3. **Test with evidence** — For each hypothesis, ask: "What evidence supports this?
   What would disprove it?" If the user can't distinguish between hypotheses,
   explore the codebase or docs to find evidence (use Grep/Read tools).

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

### Writing the Diagnose Section

When root causes are identified:

1. Draft the `## Diagnose` section content — structured as:
   - Hypotheses considered (what was tested)
   - Evidence for/against each
   - Root causes identified (the real problems)
   - Symptoms vs causes (what looked like the problem vs what actually is)
2. Present draft to user for review
3. Write to overview: replace `## Diagnose [DRAFT]` content, update marker to
   `## Diagnose [COMPLETE]`
4. Confirm completion and preview Delimit phase

**Important**: Use Edit tool on just the Diagnose section. Preserve all other sections.

## Step 5 — Delimit Phase (STRICT GATE)

**Goal**: Produce a crisp, 1-2 sentence problem statement that the user explicitly
approves. This is the only hard gate — do NOT proceed without approval.

**Technique**: Precise Language — every word must earn its place. Vague terms
like "improve", "better", "optimize" must be replaced with observable specifics.

### Drafting the Problem Statement

Using the root causes from Diagnose, draft a problem statement that:

- States the **unmet user objective** (what users can't do or struggle with)
- States the **cause** (why the objective is unmet)
- Is **1-2 sentences** — if it takes more, you haven't delimited enough
- Uses **observable terms** — someone should be able to tell if this is solved
- Does NOT contain a solution — "we need to build X" is a solution, not a problem

**Bad examples**:
- "We need a better auth system" (solution disguised as problem)
- "The codebase is messy" (vague, no user impact stated)
- "Performance needs to be improved" (no specifics)

**Good examples**:
- "Users abandon checkout when page load exceeds 3s on mobile because the
  product image pipeline blocks rendering"
- "New team members take 2+ weeks to ship their first PR because the test
  suite requires undocumented local dependencies"

### Approval Gate

1. Present the draft problem statement to the user
2. Use AskUserQuestion with options:
   - **"Approved"** — problem statement is crisp and correct
   - **"Needs refinement"** — close but wording needs adjustment
   - **"Wrong problem"** — go back to Diagnose
3. If "Needs refinement": ask what to change, redraft, present again
4. If "Wrong problem": set Diagnose back to `[DRAFT]`, return to Step 4
5. If "Approved": write to overview and proceed

### Writing the Delimit Section

On approval:

1. Write the problem statement to the `## Delimit` section
2. Update marker to `## Delimit [APPROVED]`
3. Update frontmatter: set `delimit_approved: true`
4. Confirm and preview Direction phase

**Both the marker AND the frontmatter must be set.** Resume detection checks
`delimit_approved:` in frontmatter as the authoritative signal.

**Important**: Use Edit tool for targeted updates. The frontmatter change and
section change are two separate edits.

## Step 6 — Direction Phase

> **Not yet implemented.**

## Step 7 — Design Phase

> **Not yet implemented.**

## Task Review Mode

> **Not yet implemented.** When a task file path is provided as argument,
> this mode processes `<review>` feedback and regenerates the task.

## Status Summary Mode

> **Not yet implemented.** When run with `--status` flag, shows a summary
> of all specs and their phase/task statuses.
