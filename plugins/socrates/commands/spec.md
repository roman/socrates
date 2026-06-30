---
description: Design a feature through the Design in Practice journey (Describe → Diagnose → Delimit → Direction → Design)
---

# /spec — Design in Practice Journey

Walk the user through a structured design process that produces a spec overview and
individual task files. Each phase builds on the previous one, with a strict gate at Delimit
requiring explicit user approval.

## Spec discipline kernel

<!-- DUPLICATION NOTE: the task-entry command (/socrates-task, T3) inlines
     the same kernel content below. If you edit this section, update the
     corresponding section in commands/socrates-task.md as well. -->

Specs in this project carry a directive hierarchy:

- The overview's **Describe** section names the user-facing pain (the durable why).
- The overview's **Diagnose** section names the mechanism (RC/NC/AC).
- A task file's **Outcome** describes a slice of work, not the why. Task-ordering language
  ("prerequisite for X", "must land before Y") is sequencing, not why — do not anchor
  planning, code comments, or PR descriptions on it.

Before planning or implementing on a task, reconstruct the why from the overview's
Describe + Diagnose. If the why isn't reconstructible from those sections, ask before
proceeding.

Before commits on non-trivial changes: spawn the `code-critic` agent (foreground, opus
model) and address findings in at most 2 rounds.

## Support files

This command is an orchestrator. Each phase and each reusable mode lives in its own file
under `${SOCRATES_SUPPORT:-${CLAUDE_PLUGIN_ROOT}/commands/spec-support}` (referred to below as
`<support>`). When a step points to one of these files, read it and follow it as the
authoritative instructions for that phase or mode. The files are the source of truth; this
command only sequences them.

## Voice and structure

All prose this command generates (descriptions, hypotheses, approach write-ups, task
outcomes, etc.) follows the voice and structure conventions in
`${SOCRATES_VOICE:-${CLAUDE_PLUGIN_ROOT}/voice.md}`.  Read that file once at the start of any
spec session and apply its guidance throughout. The conventions cover:

- prose-first structure
- the Technical Addendum pattern
- the RC/NC/AC ID convention
- AI-ism reduction
- how to mark deliverables and chosen approaches

Task files additionally follow the authoring standard in
`<support>/references/task-authoring.md` (the nine checks, problem-first titles,
done-vs-tested), with worked examples in `task-authoring-examples.md` beside it.

## Pacing principle: do not rush acceptance

This command exists to slow thinking down before doing. The user will sit with drafts,
re-read them in their own editor, change their mind, and approve work on their own clock —
sometimes hours or days after it was written. Your job is to present state and options
neutrally; never push toward approval.

Concretely:

- Do **not** add "Approved" or "Ready" framing to options presented at phase boundaries (the
  Delimit gate is the only place explicit approval is solicited, and even there the options
  are neutral: Approved / Needs refinement / Wrong problem).
- Do **not** mark approval choices as **(Recommended)** in `AskUserQuestion`. Acceptance is
  the user's call.
- Do **not** write closing summaries that imply urgency ("spec is approved-shape", "ready to
  implement", etc.). Confirm what was written, list options the user has, and stop.
- After Design completes and task files exist, the user may review on their own time before
  flipping `status: draft` → `status: approved`. Do not nudge that flip.

When in doubt, present and stop.

## Arguments

The user may provide:
- **A spec name**: `/spec auth-redesign` — creates `docs/specs/YYYY-MM-DD-auth-redesign/`
  (today's date), or resumes any existing `docs/specs/*-auth-redesign/` directory
- **A task file path**: `/spec docs/specs/2026-04-06-auth-redesign/a1b2-setup-middleware.md` — enters
  task review mode (see Task Review Mode)
- **A source document**: `/spec --source PRD.md` or `/spec --source https://...` — reads the
  document first, pre-fills what it can, then interviews for gaps (see Source Doc Mode)
- **No arguments**: lists existing specs and asks which to resume, or prompts for a new name

## Step 1 — Spec Discovery and Setup

### Auto-create spec directory

Before any discovery or creation, ensure the spec root exists:

```bash
mkdir -p docs/specs
```

This is the only project-tree write core Socrates ever makes, and only on first use of `/spec`.

### If no arguments provided

1. Check `docs/specs/` for existing spec directories
2. If specs exist, use AskUserQuestion to ask: resume an existing spec, or create new?
3. If creating new: run the "Check open gaps" subsection below, then
   use AskUserQuestion to either:
   - Collect a short kebab-case name now, **OR**
   - Defer naming until after the Describe phase (see "Deferred naming" below).

   Note: defer when the user cannot yet phrase the concern crisply — naming a
   problem before articulating it is hard.

### If spec name provided

1. Check if any `docs/specs/*-<name>/_overview.md` exists (date-prefixed directories)
2. If yes: resume mode (go to Step 2)
3. If no: run the "Check open gaps" subsection below, then create the spec directory and
   overview from template

### Creating a new spec

Spec directories are created with a date prefix for chronological ordering and
disambiguation. The date is the spec creation date.

```bash
TODAY=$(date +%Y-%m-%d)
mkdir -p "docs/specs/${TODAY}-<name>"
```

Copy overview template and fill frontmatter:
- `title:` — human-readable name
- `created:` — today's date (YYYY-MM-DD)
- `archived:` — leave blank
- `delimit_approved: false`
- `review_mode:` — set by the review-mode prompt below

### Review-mode prompt (new spec only)

After creating the spec directory and copying the template, ask the operator once via
AskUserQuestion:

> "Will this spec's work go through external code review (PRs/MRs)?"

Stamp the answer into the new `_overview.md` frontmatter:
- Yes → `review_mode: true`
- No → `review_mode: false`

On **resume of an existing spec**, skip this prompt. The operator edits `_overview.md`
directly if they change their mind. See RALPH.md § Review Mode for the full semantics.

### Check open gaps (new spec only)

Before any new spec is created (named or deferred path), scan `docs/gaps/` for `*.md`
files. Skip this subsection silently when the directory is empty or absent.

When gaps are present:

1. Present each gap to the user as a one-line summary (title + first sentence of the body).
2. Use AskUserQuestion to ask whether the new spec is addressing one of these gaps, or is
   independent work. Offer the gap titles as options plus an "independent work" option.
3. **If a gap is being addressed**:
   - Fold the gap's body — situation, why-it-matters, suggested resolution — into the
     Describe phase as pre-existing context.  The user can confirm or expand on it during
     the interview; this avoids re-discovering ground the gap already covered.
   - Once the spec directory exists (immediately in the named path, after Describe in the
     deferred path), delete the gap file with `git rm docs/gaps/<filename>.md`. Git history
     preserves the gap as the audit trail; the spec is now its forward-looking home.
4. **If independent work**: continue with the normal Step 1 flow.

A gap file's existence is its lifecycle: present means open, absent means addressed. No
status field, no archive directory, no close-side sweep responsibility.
<review>This pattern: "No status field, no archive directory, no close-side sweep responsibility." is a very strong ai-ism, please rephrase it in a way that sounds more natural, also update the writing extension in minerva to account for this</review>

### Deferred naming

When the user opts to defer naming until after Describe, do **not** create the spec
directory or overview file yet. Instead:

1. Hold the spec state in conversation memory only. Run Step 3 (Describe phase)
   interview-driven — drafts, edits, and approvals happen in the chat without persisting to
   disk.
2. Once Describe is complete (user-approved), prompt the user for a short kebab-case name
   informed by what was discussed. Suggesting 2–4 candidate names derived from the situation
   is helpful; offer them via AskUserQuestion alongside an "I'll type my own" option.
3. With the name set, follow the "Creating a new spec" steps above: create the directory,
   copy the template, fill the frontmatter, and write the overview file. The Describe
   section lands with the user-approved content already in place and its marker set to
   `[COMPLETE]`; all other sections remain `[DRAFT]` per the template.
4. Continue with Step 4 (Diagnose) as usual.

This avoids forcing the user to name a problem they have not yet articulated, while still
producing a normal spec directory once the shape of the work is clear.

## Step 2 — Resume Detection and Navigation

When resuming an existing spec, detect the current phase from its section markers and recap
progress. The support file also covers two cases: the user going back to a completed phase,
and automatic walk-back when new input contradicts an earlier phase. Read and follow
`<support>/patterns/resume-detection.md`.

## Step 3 — Describe Phase

Capture the situation as-is, without interpretation or proposed solutions.  Read and follow
`<support>/phases/describe.md`.

## Step 4 — Diagnose Phase

Identify the real problem beneath the situation; challenge assertions and test
hypotheses. Read and follow `<support>/phases/diagnose.md`.

## Step 5 — Delimit Phase (STRICT GATE)

Produce a crisp problem statement that the user explicitly approves — the only hard gate in
the journey. Read and follow `<support>/phases/delimit.md`.

## Step 6 — Direction Phase

Generate multiple approaches, compare them in a decision matrix, and choose one; capture use
cases. Read and follow `<support>/phases/direction.md`.

## Step 7 — Design Phase

Break the chosen approach into concrete, implementable task files grounded in codebase
research. Read and follow `<support>/phases/design.md`.

## Task Review Mode

When invoked with a task file path or a spec directory, process `<review>` feedback on task
files. Read and follow `<support>/patterns/task-review-mode.md`.

## Status Summary

When invoked with `--status` (or when the user asks for an overview), report each spec's
current phase and task counts. Read and follow the Status Summary section of
`<support>/patterns/task-review-mode.md`.

## Source Doc Mode

When invoked with `--source <path-or-url>`, read the document, optionally verify its claims,
pre-fill the phases it covers, and resume the journey at the first gap. Read and follow
`<support>/patterns/source-doc-mode.md`.
