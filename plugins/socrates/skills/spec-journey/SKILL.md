---
name: spec-journey
description: Guidance for the /spec Design in Practice flow. Operationalizes Reflective Inquiry, Socratic Method, Scientific Method, Precise Language, Decision Matrix, and Use Cases into concrete AI behavior during spec creation.
---

# Spec Journey Skill

AI guidance for driving the `/spec` Design in Practice journey. This skill
handles Socrates-specific mechanics (file formats, command flow, resume, phase
markers). The global `design-in-practice` skill handles general methodology —
within `/spec` context, this skill takes precedence on format and flow.

## When Active

This skill applies when running `/spec` or working with files in `docs/specs/`.

## Techniques by Phase

### Describe — Reflective Inquiry

Surface the situation through four orienting questions:

- **"Where are you at?"** — Current state, what triggered this work
- **"Where are you going?"** — Desired outcome, what success looks like
- **"What do you know?"** — Established facts, constraints, prior decisions
- **"What do you need to know?"** — Open questions, uncertainties, unknowns

Ask these at the start and at phase transitions. Don't ask all four robotically
— adapt based on what's already clear. The goal is a complete picture of the
landscape before any interpretation.

**Behavior**: Capture, don't interpret. If you catch yourself proposing a
solution, stop and rephrase as a question.

### Diagnose — Scientific Method

Form hypotheses about root causes and test them:

1. **Observe** — What does the Describe section tell us?
2. **Hypothesize** — What could be causing the problem? Generate 2-3 candidates.
3. **Test** — What evidence supports or refutes each? Ask the user. Explore the
   codebase if needed.
4. **Conclude** — Which hypothesis survives? What's the root cause?

**Behavior**: Be respectfully skeptical. The first explanation is rarely the
deepest. "We need feature X" always gets challenged — push through to the unmet
user objective. Don't accept "it's obvious" without evidence.

### Delimit — Precise Language

Every word in the problem statement must earn its place:

- **Vague terms are banned**: "improve", "better", "optimize", "enhance" —
  replace with observable specifics
- **Observable test**: Could someone tell if this problem is solved by looking
  at concrete outcomes?
- **Solution contamination**: If the statement contains a solution ("we need to
  build X"), extract the problem underneath it
- **Length constraint**: 1-2 sentences. If it takes more, you haven't delimited
  enough — split into sub-problems or find the common thread

**Behavior**: This is the strict gate. Do not proceed without explicit user
approval. Push back on vague statements — precision here saves enormous effort
downstream.

### Direction — Contrast Over Linearity

Seeing differences between approaches triggers thinking:

- **Always include Status Quo** — what happens if we do nothing? This is the
  baseline, not a strawman.
- **Vary meaningfully** — different strategies, not cosmetic variations. If two
  approaches only differ in naming, they're the same approach.
- **Decision Matrix discipline**:
  - Problem statement in the header (from Delimit)
  - Approaches as columns, criteria as rows
  - 🟢 (strong), 🟡 (adequate), 🔴 (weak), ⬜ (not applicable)
  - **No all-green columns** — that's rationalization, not analysis. Find the
    criterion where this approach is weakest.
  - **Remove non-differentiating criteria** — if every approach gets the same
    color, the criterion doesn't help decide.

**Behavior**: Present the matrix, then ask "does anything surprise you?" before
asking for a choice. Surprises indicate either a wrong assessment or a
criterion the user hadn't considered.

### Direction — Use Cases

Focus on user intentions, not implementation:

- **"I wish I could..."** not "the user will click a button"
- **Actor + Intent + Outcome** structure
- **"How" column stays blank** until after the approach is chosen — it gets
  filled during Design
- 3-7 use cases is typical; more suggests the scope needs splitting

**Behavior**: If a use case describes implementation ("the system will..."),
rewrite it from the user's perspective.

### Design — Glossary

Maintain consistent terminology:

- When a term is first used with a specific meaning, add it to the Glossary
- When a term becomes ambiguous or overloaded, stop and resolve it
- When a term's meaning evolves during the journey, update the Glossary and
  fix prior references
- Prefer concrete terms over abstract ones

## File Format Reminders

- Phase markers: `[DRAFT]`, `[COMPLETE]`, `[APPROVED]` in section headers
- Frontmatter: `delimit_approved: true/false` is the authoritative signal
- Going back: reset target + all downstream markers to `[DRAFT]`, preserve
  previous content under `### Previous (superseded)`
- Edit tool: update only the active section, never rewrite the entire file
