---
description: Design a feature through the Design in Practice journey (Describe → Diagnose → Delimit → Direction → Design)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, AskUserQuestion, Task
model: opus
effort: high
---

# /spec — Design in Practice Journey

Walk the user through a structured design process that produces a spec overview
and individual task files. Each phase builds on the previous one, with a strict
gate at Delimit requiring explicit user approval.

## Quick Reference

**Phases**: Describe → Diagnose → Delimit (gate) → Direction → Design

**Markers**: `[DRAFT]` (incomplete), `[COMPLETE]` (done), `[APPROVED]` (Delimit only)

**Templates**:
- Overview: `${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}/_overview.md`
- Task: `${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/templates}/task.md`

**Phase details**: See `spec-support/phases/*.md`
**Patterns**: See `spec-support/patterns/*.md`

## Voice and structure

All prose this command generates follows the conventions in
`${SOCRATES_TEMPLATES:-${CLAUDE_PLUGIN_ROOT}/..}/voice.md`. Read that file once
at the start of any spec session. Key rules: prose-first structure, Technical
Addendum for file paths/hashes, RC/NC/AC typed IDs, confidence labels on claims.

## Pacing principle

This command exists to slow thinking down before doing. The user will sit with
drafts, re-read them, change their mind, and approve on their own clock.

- Do NOT add "Approved" or "Ready" framing to phase boundary options
- Do NOT mark approval options as "(Recommended)"
- Do NOT write closing summaries implying urgency
- After Design completes, the user reviews at their own pace

When in doubt, present and stop.

## Entry Points

When invoked, determine the mode from arguments:

| Argument | Mode | Action |
|----------|------|--------|
| None | Discovery | List existing specs, ask resume or create new |
| `<spec-name>` | Resume/Create | Resume existing or create new spec |
| `<task-file-path>` | Task Review | Process review feedback on task file |
| `--source <path-or-url>` | Source Doc | Pre-fill from external document |
| `--status` | Status | Show overview of all specs |

### Discovery Mode (no arguments)

1. Check `docs/specs/` for existing spec directories
2. If specs exist, use AskUserQuestion: resume existing or create new?
3. If creating new: run "Check open gaps", then ask for name or defer naming

### Resume/Create Mode (spec name provided)

1. Check if `docs/specs/*-<name>/_overview.md` exists
2. If yes: enter Resume flow (see `spec-support/patterns/resume-detection.md`)
3. If no: run "Check open gaps", create spec directory from template

### Task Review Mode (task file path)

See `spec-support/patterns/task-review-mode.md`

### Source Doc Mode (--source flag)

See `spec-support/patterns/source-doc-mode.md`

## Creating a New Spec

Spec directories use date prefix for ordering: `docs/specs/YYYY-MM-DD-<name>/`

```bash
TODAY=$(date +%Y-%m-%d)
mkdir -p "docs/specs/${TODAY}-<name>"
```

Copy overview template and fill frontmatter:
- `title:` — human-readable name
- `created:` — today's date (YYYY-MM-DD)
- `epic:` — leave blank (populated by `/pour`)
- `archived:` — leave blank
- `delimit_approved: false`

### Check open gaps (new spec only)

Before creating any new spec, scan `docs/gaps/` for `*.md` files. Skip silently
if empty or absent.

When gaps present:
1. Present each gap as one-line summary (title + first sentence)
2. Ask if new spec addresses a gap or is independent work
3. If addressing gap: fold body into Describe as context, then `git rm` the gap file
4. If independent: continue normal flow

### Deferred naming

When user defers naming until after Describe:
1. Hold spec state in conversation only (no files yet)
2. Run Describe interview in chat
3. After Describe complete, suggest 2-4 kebab-case names from discussion
4. Create spec directory with chosen name, Describe already `[COMPLETE]`
5. Continue with Diagnose

## Phase Journey

Each phase has detailed instructions in `spec-support/phases/<phase>.md`.

### Describe

**Goal**: Capture situation as-is without interpretation or solutions.
**Technique**: Reflective Inquiry — surface what user knows, doesn't know, context.
**Details**: See `spec-support/phases/describe.md`

Key elements:
- Interview with 3-6 questions (one at a time via AskUserQuestion)
- Scope triage if multiple issues surface
- Ackoff Gate: test if this is real problem or symptom (recurrence, upstream, residue tests)
- Write structured narrative covering situation, known facts, uncertainties, stakeholders

### Diagnose

**Goal**: Identify real problem beneath situation. Challenge assertions, test hypotheses.
**Technique**: Scientific Method with Platt's Strong Inference (eliminative testing).
**Details**: See `spec-support/phases/diagnose.md`

Key elements:
- Challenge surface assertions ("we need X" → why?)
- Form 2-3 hypotheses, test by trying to disprove them
- Typed diagnosed items: RC (root cause), NC (non-cause), AC (adjacent constraint)
- K-T Completeness Audit: IS/IS-NOT table for problem boundaries
- Write hypotheses, evidence, diagnosed items with HTML anchors

### Delimit (STRICT GATE)

**Goal**: Crisp 1-2 sentence problem statement, explicitly approved.
**Technique**: Precise Language — every word earns its place.
**Details**: See `spec-support/phases/delimit.md`

Key elements:
- State unmet user objective + cause
- Observable terms (not vague "improve", "better")
- Inversion test: too narrow? too broad? wrong boundary? solution leak?
- Explicit approval gate with AskUserQuestion (Approved / Needs refinement / Wrong problem)
- Both marker `[APPROVED]` AND frontmatter `delimit_approved: true` required

### Direction

**Goal**: Generate approaches, compare via matrix, choose one.
**Technique**: Contrast Over Linearity — differences trigger thinking.
**Details**: See `spec-support/phases/direction.md`

Key elements:
- Ackoff checkpoint: still solving right problem?
- Always include Status Quo as A1
- 2-3 additional approaches with varied strategies/tradeoffs
- Inversion test per approach: what guarantees failure?
- Decision matrix with typed criteria ([RC1], [AC2], [ID])
- Chosen approach in blockquote with rationale
- Use cases table: Actor / Intent / Outcome

### Design

**Goal**: Break chosen approach into 5-10 implementable tasks.
**Technique**: Codebase research grounding + outcome-based decomposition.
**Details**: See `spec-support/phases/design.md`

Key elements:
- Parallel sub-agents for codebase exploration and tech research
- Shared surfaces identification (name surfaces, don't pin shapes)
- Task IDs: ordinal + hash + suffix (e.g., `1-a1b2-setup-middleware`)
- Task files with `## Outcomes`, `## Verification`, `<review>` sections
- Design Review council: code-critic + grug-architect (both opus)
- Separate mechanical fixes from judgment calls
- Post-design summary: neutral options, no urgency

## Resume Detection

See `spec-support/patterns/resume-detection.md` for:
- Phase marker scanning
- Going Back procedure
- Automatic walk-back on detected conflict

## Tools Reference

**File operations**: Read, Edit, Write (targeted section updates)
**Search**: Grep, Glob for codebase exploration
**Sub-agents**: Task tool with Explore, general-purpose, code-critic, grug-architect
**User interaction**: AskUserQuestion (one question at a time)

**Critical**: Use Edit for section updates, never rewrite entire overview file.
