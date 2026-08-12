# Describe Phase

**Goal**: Capture the situation as-is, without interpretation or proposed solutions.

**Technique**: Reflective Inquiry — surface what the user knows, what they don't
know, and what context matters.

## Interview Process

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

## If source document provided

Instead of interviewing from scratch:
1. Read the source document (use Read tool for files, WebFetch for URLs)
2. Extract and structure the situation description from the document
3. Present the extracted description to the user for confirmation
4. Ask clarifying questions for any gaps (missing context, unclear stakeholders, etc.)

## Scope Triage (multi-issue sessions)

When the user surfaces multiple distinct issues during the Describe interview,
investigate whether they share a root cause before writing the section. This is
a lightweight split-vs-keep check, not a full diagnosis — you are only testing
whether the issues are linked, not solving them:

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
with evidence. The user validates your conclusion; the user does not do the
analysis.

If splitting: create multiple spec directories, write separate Describe sections
for each, and ask the user which to continue with in this session.

## Upstream Check

Before writing the Describe section, ask one question:

> "Could this situation be caused by something upstream we should address
> instead?"

If yes, surface it to the user before proceeding. Solving the cause may
dissolve the problem entirely.

## Recurrence Check

If the problem seems familiar, check the overview frontmatter `tags:` of
existing specs to see if this is a recurring pattern. Recurring problems
in the same category may indicate deeper architectural debt.

## Writing the Describe Section

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
   - Remove `[DRAFT]` from the heading
5. Confirm completion and preview what comes next (Diagnose phase)

**Important**: Use the Edit tool to update only the Describe section. Do NOT
rewrite the entire file. Other incomplete sections must keep their `[DRAFT]`
markers.
