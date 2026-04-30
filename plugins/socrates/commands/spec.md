---
description: Design a feature through the Design in Practice journey (Describe → Diagnose → Delimit → Direction → Design)
---

# /spec — Design in Practice Journey

Walk the user through a structured design process that produces a spec overview
and individual task files. Each phase builds on the previous one, with a strict
gate at Delimit requiring explicit user approval.

## Arguments

The user may provide:
- **A spec name**: `/spec auth-redesign` — creates `docs/specs/YYYY-MM-DD-auth-redesign/`
  (today's date), or resumes any existing `docs/specs/*-auth-redesign/` directory
- **A task file path**: `/spec docs/specs/2026-04-06-auth-redesign/a1b2-setup-middleware.md` — enters
  task review mode (see Task Review section)
- **A source document**: `/spec --source PRD.md` or `/spec --source https://...` — reads
  the document first, pre-fills what it can, then interviews for gaps (see Source Doc Mode)
- **No arguments**: lists existing specs and asks which to resume, or prompts for a new name

## Step 1 — Spec Discovery and Setup

### If no arguments provided

1. Check `docs/specs/` for existing spec directories
2. If specs exist, use AskUserQuestion to ask: resume an existing spec, or create new?
3. If creating new, ask for a short kebab-case name

### If spec name provided

1. Check if any `docs/specs/*-<name>/_overview.md` exists (date-prefixed directories)
2. If yes: resume mode (go to Step 2)
3. If no: create the spec directory and overview from template

### Creating a new spec

Spec directories are created with a date prefix for chronological ordering and
disambiguation. The date is the spec creation date.

```bash
TODAY=$(date +%Y-%m-%d)
mkdir -p "docs/specs/${TODAY}-<name>"
```

Copy the overview template and fill in frontmatter:
- Read the template from `${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}/_overview.md`
- Set `title:` to the spec name (human-readable, derived from kebab-case)
- Set `created:` to today's date (YYYY-MM-DD)
- Leave `epic:` and `archived:` blank (populated later by `/pour` and PM archival)
- Set `delimit_approved: false`
- Write to `docs/specs/${TODAY}-<name>/_overview.md`

## Step 2 — Resume Detection and Navigation

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

### Going Back

The user can request to revisit a completed phase (e.g., "revisit Delimit",
"go back to Describe"). When this happens:

1. Set the target phase's header marker to `[DRAFT]`
2. Set ALL subsequent phase markers to `[DRAFT]`
3. If going back to or before Delimit: set `delimit_approved: false` in frontmatter
4. Preserve the previous content of each reset phase under a
   `### Previous (superseded)` sub-heading within that section
5. Resume the journey from the target phase

This ensures that downstream phases that depended on the now-changed upstream
content are re-evaluated rather than silently stale.

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

### Scope Triage (multi-issue sessions)

When the user surfaces multiple distinct issues during the Describe interview,
investigate whether they share a root cause before writing the section:

1. **Name the candidate issues** — list them explicitly for the user.
2. **Hypothesize a link** — could one cause or amplify the other? State the
   hypothesis concretely (e.g., "duplicate events inflate the synthesis input,
   causing verbose output").
3. **Test the link** — examine actual data (event logs, output files, code
   paths). Look for shared code, shared data flow, or causal chains.
4. **Recommend** — if the issues have independent root causes and independent
   fixes, recommend separate specs and explain why. If they share a root cause,
   keep them in one spec. Present your evidence and let the user confirm.

**Do not ask the user whether to split** — investigate first, then recommend
with evidence. The user validates your conclusion, not does the analysis.

If splitting: create multiple spec directories, write separate Describe sections
for each, and ask the user which to continue with in this session.

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
   - Evidence for/against each, with explicit **status** per hypothesis:
     **Confirmed** (tested with evidence), **Rejected** (disproved),
     or **Unconfirmed** (plausible but not yet testable). Never present
     an unconfirmed hypothesis as a root cause — label it clearly and
     note what evidence would confirm or reject it.
   - Root causes identified (only confirmed findings)
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

**Goal**: Generate multiple approaches to solving the delimited problem, help the
user compare them, and choose one. Also capture use cases.

**Technique**: Contrast Over Linearity — seeing differences between approaches
triggers thinking that a single proposal never would.

### Generating Approaches

1. **Always include Status Quo** as approach #1 — what happens if we do nothing?
   This is the baseline all other approaches are measured against.

2. Generate 2-3 additional approaches that address the problem statement from
   different angles. Vary them meaningfully:
   - Different technical strategies (not just variations of the same idea)
   - Different scope/ambition levels where applicable
   - Different tradeoff profiles (speed vs correctness, simplicity vs flexibility)

3. For each approach, describe:
   - What it does (1-2 sentences)
   - Key tradeoffs (what you gain, what you give up)
   - Rough scope signal (small/medium/large — not time estimates)

4. Present approaches to the user and ask for initial reactions before building
   the decision matrix.

### Decision Matrix

If the choice is non-trivial (more than 2 viable approaches), build a decision
matrix:

- **Header**: The problem statement from Delimit
- **Columns**: Each approach (including status quo)
- **Rows**: Evaluation criteria discovered during the conversation. Include both
  technical and non-technical criteria. Common ones:
  - Complexity / implementation effort
  - Addresses root cause vs symptom
  - Risk / reversibility
  - Team familiarity
  - Maintenance burden
- **Cells**: 🟢 (strong), 🟡 (adequate), 🔴 (weak), ⬜ (not applicable)

**Anti-patterns to avoid**:
- All-green columns → rationalization, not analysis. Find distinguishing criteria.
- Criteria that don't differentiate → remove them, they add noise.
- Solution-biased criteria → criteria should matter regardless of which approach wins.

**Render the matrix in the chat session BEFORE writing it to the spec file.**
Markdown table notation is illegible in raw form — the user needs to see it
rendered to evaluate it. Decision matrices commonly trigger technical
discussion, criterion reassessment, or new approach ideas; capturing those
before persisting avoids file churn. Only write to the overview file once
the user has reviewed the rendered draft and confirmed direction. Discuss
any surprising results before asking for a choice.

### Choosing an Approach

Use AskUserQuestion to ask which approach the user wants to pursue.
Record: which approach and the user's rationale for choosing it.

### Use Cases

After the approach is chosen, draft use cases:

- Focus on **user intentions**, not implementation: "I wish I could..." not
  "the system will..."
- Each use case: Actor + Intent + Outcome
- Leave the "How" column blank — it gets filled during Design phase
- 3-7 use cases is typical

Present use cases to user for confirmation.

### Writing the Direction Section

1. Write all subsections to `## Direction`:
   - `### Approaches` — all approaches with descriptions
   - `### Decision Matrix` — if applicable
   - `### Chosen Approach` — selection and rationale
   - `### Use Cases` — confirmed use cases
2. Update marker to `## Direction [COMPLETE]`
3. Confirm and preview Design phase

**Important**: Use Edit tool. Replace only the Direction section content.

## Step 7 — Design Phase

**Goal**: Break the chosen approach into concrete, implementable task files.
Research the codebase to ground tasks in reality.

### Codebase Research (parallel sub-agents)

Before decomposing, gather context. Launch parallel Agent sub-agents to:

1. **Codebase exploration** — Use an Explore agent to find:
   - Existing patterns relevant to the chosen approach
   - Integration points the tasks will touch
   - Conventions to follow (naming, file organization, testing patterns)
   - Potential conflicts with in-progress work

2. **Technology research** (if needed) — Use a general-purpose agent to:
   - Look up API docs or library capabilities
   - Verify assumptions about tools/frameworks
   - Check for known issues or limitations

3. **Shared surfaces identification** — While exploring, explicitly identify
   cross-task touchpoints: files, type names, config keys, or sentinel values
   that more than one task will read or write. Name them by surface only.
   **Name the surface, do not pin the shape.** Do not record type definitions,
   literal values, or concrete config keys at the overview level — those are
   discovered by the implementer of the task that owns the surface. If you
   catch yourself wanting to write a shape, that content belongs in a task
   file, not the overview.

Synthesize findings into the `### Context` subsection of the Design section.
This context informs the task decomposition.

### Task Decomposition

Break the approach into **5-10 implementation tasks** (configurable — the user
can request more or fewer granularity).

**Sizing rule**: one task ≈ one outcome slice — a discrete, verifiable change
in system behaviour or project state. Size by what the implementer must
*achieve*, not by how many files or commits the work touches. If a task
describes two independently verifiable outcomes, split it. If several tasks
target the same outcome and cannot be verified separately, merge them.

For each task:

1. **Generate an ID**: ordinal prefix (1-based execution order) +
   short hash (first 4 chars of sha256 of title) + human suffix
   (2-3 word kebab-case). Example: `1-a1b2-setup-middleware`.
   The ordinal is assigned from the surface-derived topo order:
   parse the `#### Shared Surfaces` section, derive edges from
   `(surface owner)` markers (consumers depend on owners), and
   topo-sort. Tasks with no incoming edges get the lowest ordinals.
   The ordinal is a readability hint only — `/pour` re-derives the
   same order independently from Shared Surfaces at pour time.
   ```bash
   echo -n "Setup auth middleware" | sha256sum | cut -c1-4
   ```

2. **Create the task file** at `docs/specs/<name>/<id>.md` using the task
   template from `${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}/task.md`.
   The filename is the full id including the ordinal prefix, so
   `ls` on the spec directory shows tasks in execution order.

3. **Fill in**:
   - `id:` — generated ID
   - `status: draft`
   - `priority:` — 0 (highest) to 4, based on surface-derived order and criticality
   - `category:` — functional, style, infrastructure, or documentation
   - `revisions: 0` — review iterations start at zero; Task Review Mode
     bumps this each time it processes `<review>` feedback
   - Title — clear, action-oriented (starts with a verb)
   - `<outcome>` — what the implementer must achieve and what changes for
     the system or project when done. State the target, not the procedure.
     Concrete file-path grounding belongs in the overview's Context section,
     not here — the implementer discovers the how.
   - `<verification>` — observable criteria for confirming the outcome is met
   - `<review>` — leave empty

Coupling between tasks is expressed entirely through the `#### Shared Surfaces`
section of the overview, not through per-task frontmatter. `/pour` derives the
ordering edges from there at pour time.

### Open Questions During Design

If unresolved scope or design questions surface while drafting Design,
**resolve them with the human driver via AskUserQuestion before writing
to the file**. Do not silently persist an "Open questions" section.

After the user answers, fold the resolution into the relevant Design
subsection (or into a "Resolved scope decisions" list). Only write an
"Open questions" section if the user explicitly says they want to defer
the question and keep it visible in the spec.

### Writing the Design Section

1. Write `### Context` with codebase research findings
2. Write `### Tasks` with a summary table:
   | ID | Title | Priority | Category |
3. Write `### Execution Order` as a topo-sorted bulleted narrative, produced
   **after** the dependency graph is known. Each line links to the task file
   (by id) and gives one sentence of purpose. Tasks with no dependencies come
   first; downstream tasks follow. This is the rendered reading order a human
   would use to walk the spec.
4. Write `### Glossary` with terms used consistently in the tasks, and
   populate a `#### Shared Surfaces` subsection listing the surfaces
   identified during research. Each entry is a narrative line: the surface
   name, the linked task ids that touch it, and one sentence explaining why
   the coupling matters. Example:
   > **`config.yaml` `retry` block** — touched by
   > [1-a1b2](1-a1b2-setup.md) (surface owner) and
   > [3-c4d5](3-c4d5-worker.md); the worker reads retry policy the setup
   > task writes, so the setup task must land first.

   When a surface has a natural owner — the task that creates or first
   writes it — annotate that task's link with `(surface owner)`. Other
   linked tasks are readers and will be ordered after the owner. If the
   surface is a mutual read with no clear creator, omit the marker on
   every link; the surface then contributes no ordering edge. The marker
   sits on the link itself (not on a positional "first task in the list")
   so it survives later reordering.

   **Shared Surfaces must NOT contain type shapes, literal sentinel values,
   concrete config keys beyond the surface name, or any detail the implementer
   would be the first to know.** If you are tempted to write a shape, that is
   a sign the content belongs in a task file, not the overview.
5. Update marker to `## Design [COMPLETE]`

### Design Review

After writing all task files and the Design section, run a review council
before presenting the spec to the user:

1. Launch two Agent sub-agents **in parallel, both foreground, both opus**:
   - **code-critic** — review the full spec (overview + all task files) for
     gaps, missing shared surfaces, incorrect dependency edges, risks the
     spec doesn't acknowledge, and whether the tasks eat their own dogfood
     (i.e., are they outcome-shaped if the spec calls for outcome-shaped
     tasks?).
   - **grug-architect** — review for unnecessary complexity, over-decomposition,
     tasks that could be merged, ceremony that doesn't earn its keep, and
     whether the simplest approach was chosen. Challenge anything that smells
     like over-engineering.

2. Synthesize findings into:
   - **Consensus items** — both agents agree
   - **Concerns by severity** — blocker / major / minor
   - **Actionable changes** — specific edits to make

3. Apply non-controversial fixes (missing surfaces, stale conventions,
   clear over-decomposition). For judgment calls, present the findings to
   the user and ask how to proceed.

4. If changes were made, briefly confirm what changed and why.

### Post-Design Summary

After the design review is resolved and all task files are finalized:
1. Show the user a summary: how many tasks, dependency structure, categories
2. Explain next steps:
   - Review each task file, add notes to `<review>` if changes needed
   - Run `/spec <task-file>` to process review feedback
   - Change `status: draft` to `status: approved` when satisfied
   - Run `/pour` to create tk tickets from approved tasks

## Task Review Mode

When invoked with a task file path (`/spec docs/specs/<name>/<id>.md`):

1. Read the task file
2. Check the `<review>` section for feedback
3. If `<review>` is empty: ask the user what changes they want
4. If `<review>` has content: process the feedback

### Processing Review Feedback

1. Read the review comments in `<review>`
2. Regenerate the `<outcome>` and/or `<verification>` sections based on feedback
3. Clear the `<review>` section (set back to empty)
4. Increment `revisions` in frontmatter (e.g., 0 → 1, 1 → 2). If the
   field is missing on a pre-existing task file, add it with the
   incremented value (treat absence as 0).
5. Present the changes to the user for confirmation
6. Write the updated task file

The task stays at `status: draft` throughout review iterations. The user
manually changes status to `approved` when satisfied. The `revisions`
counter is informational — it shows how much a task has been iterated
on without losing that signal when `<review>` is cleared.

### Batch Review

If invoked with a spec directory (`/spec docs/specs/<name>/`), check all task
files for non-empty `<review>` sections and process them sequentially.

## Status Summary

When invoked with `--status` or when the user asks for an overview:

1. Scan `docs/specs/` for all spec directories
2. For each spec, read `_overview.md` and report:
   - Current phase (first `[DRAFT]` section)
   - Whether Delimit is approved
3. For each spec, scan task files and report counts:
   - `draft` — still iterating
   - `approved` — ready to pour
   - `poured` — tk ticket exists
4. Present as a summary table:

```
Spec: auth-redesign
  Phase: Direction [COMPLETE] → Design [DRAFT]
  Delimit: approved
  Tasks: 3 draft, 2 approved, 0 poured
```

## Source Doc Mode

When invoked with `--source <path-or-url>`:

### Reading the Source

1. If the source is a file path: use Read tool
2. If the source is a URL: use WebFetch tool
3. If the source is a ticket URL (Asana, Linear, GitHub issue): use appropriate
   tool (gh for GitHub issues, WebFetch for others)

### Pre-filling Phases

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

### Gap Detection

After pre-filling, identify what the source document does NOT cover:
- Missing stakeholder context → ask in Describe
- No root cause analysis → full Diagnose interview needed
- Vague problem statement → full Delimit process needed
- Single solution proposed without alternatives → full Direction needed

Resume the journey at the first phase with gaps.
