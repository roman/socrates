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

**Behavior**: Always render the Direction draft (approaches, decision matrix,
use cases) directly in the chat session BEFORE writing it to the spec file.
Markdown table notation is illegible in raw form — the user needs to see the
rendered matrix to evaluate it. Decision matrices commonly surface technical
discussion, questions, or reassessment of criteria; capturing those before
the file is written avoids churn. After rendering, ask "does anything surprise
you?" before asking for a choice. Only persist to the spec file once the user
has reviewed the rendered draft.

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

### Design — Open Questions

Open questions during Design must be **resolved with the human driver via
the AskUserQuestion tool**, not silently written into the spec file as an
"Open questions" section.

- When you notice an unresolved scope/design question while drafting Design,
  pause and ask the user via AskUserQuestion.
- After the user answers, fold the resolution into the relevant Design
  subsection (or into a "Resolved scope decisions" list). Do **not** leave
  the question itself in the document.
- Only write an "Open questions" section if the human driver explicitly
  says they want to defer the question and keep it visible in the spec.
  Default behavior is: resolve, then delete.

### Decompose — Task Files

Design ends with a Changes section describing what needs to happen.
That is not the executable form. After Design is marked `[COMPLETE]`,
decompose the Changes into one file per discrete task, written into
the same spec directory alongside `_overview.md`. The spec is not
ready for `/socrates-pour` until every Design change maps to at
least one task file.

**Naming**: `<ordinal>-<4-hex>-<2-3-word-kebab-title>.md`. The
ordinal is a 1-based integer reflecting the task's execution order
(lowest depends on nothing; highest depends on everything before
it). The 4-hex segment is the first four characters of `sha256sum`
of the task title and disambiguates titles that might collide. The
ordinal prefix exists so humans can refer to tasks by number
("task 2", "task 3") without having to remember hex, which matters
a lot during review and implementation.

```bash
echo -n "Setup auth middleware" | sha256sum | cut -c1-4
```

**Frontmatter** (required):

```yaml
---
id: <ordinal>-<hex>-<kebab-title>
status: draft
priority: <0 (highest) to 4>
category: <functional | style | infrastructure | documentation>
depends_on: [<other task ids, full form>]
ticket: null
---
```

The `id` in frontmatter must match the filename (minus `.md`) and
must include the ordinal prefix. `depends_on` entries are full
task ids, including their ordinal prefixes, so the dependency
graph stays resolvable when ordinals change.

**Body** (required sections, in order):

1. `# <Title>` — a single imperative sentence describing the task.
2. `<steps>` — numbered, mechanical instructions an implementer can
   follow without re-deriving intent. Each step names concrete files,
   functions, or commands. No ambiguity, no "figure out".
3. `<test_steps>` — how to verify the change works. Concrete
   commands, observable outcomes, specific files to inspect.
4. `<review></review>` — empty on creation; filled during
   implementation review.

**Sizing**: one task ≈ one focused commit. If a task's `<steps>`
describe work that would naturally split into two commits, split the
task. If multiple tasks have the same implementer reading the same
files for the same reason, merge them.

**Dependency graph**: `depends_on` carries task ids, not free text.
A task with no dependencies can start immediately; a task with
dependencies blocks until all named tasks are `done`. The graph
must be acyclic.

**Behavior**: When Design is marked `[COMPLETE]`, do not stop. Walk
the Changes section, identify the discrete units of work, and
create the task files in the same turn (or the next one). Announce
the decomposition to the user and let them object before treating
the spec as ready for `/socrates-pour`.

## File Format Reminders

- Spec directory layout: `_overview.md` holds the journey (Describe
  through Design); sibling task files hold the executable
  decomposition. Both are required for a complete spec.
- Phase markers: `[DRAFT]`, `[COMPLETE]`, `[APPROVED]` in section headers
- Frontmatter: `delimit_approved: true/false` is the authoritative signal
- Task file frontmatter keys: `id`, `status`, `priority`, `category`,
  `depends_on`, `ticket`. `status` lifecycle: `draft` → `approved`
  → `poured` (once `/socrates-pour` creates the tk ticket) → `done`.
  `ticket` is `null` until `/socrates-pour` populates it.
- Going back: reset target + all downstream markers to `[DRAFT]`, preserve
  previous content under `### Previous (superseded)`
- Edit tool: update only the active section, never rewrite the entire file
