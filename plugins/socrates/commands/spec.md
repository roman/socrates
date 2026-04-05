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

> **Not yet implemented.** Tell the user this phase is coming soon and stop here.
> Do NOT proceed past the Describe phase.

## Step 5 — Delimit Phase (strict gate)

> **Not yet implemented.**

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
