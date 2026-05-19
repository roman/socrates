# Design Phase

**Goal**: Break the chosen approach into concrete, implementable task files.
Research the codebase to ground tasks in reality.

## Codebase Research (parallel sub-agents)

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

When any Adjacent Constraint (AC) from Diagnose dictates a specific
encoding (where the constraint must live in the design — a chart
conditional, a config-file structure, an interface boundary), call
that out explicitly in the Context. The Direction phase committed
to *honoring* the constraint; the Context translates that into
*where it lands*.

If the codebase research surfaced concrete file paths, line
numbers, or quantitative findings (e.g., "this file is ~400 lines,
60% of which is incidental drift"), put the prose claim in Context
and the supporting detail in the `## Technical Addendum` section
at the end of `_overview.md`. Reference the Addendum from the
Context with an anchored link: `(See [Addendum A.3](#a3) for the
catalog.)`

## Task Decomposition

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
   - `## Outcomes` — a bulleted list of what the implementer must achieve and
     what changes for the system or project when done. State the target, not
     the procedure. Concrete file-path grounding belongs in the overview's
     Context section, not here — the implementer discovers the how.
   - `## Verification` — a bulleted list of observable criteria for confirming
     the outcome is met
   - `<review>` — leave empty (XML tag stays invisible in rendered markdown)

Coupling between tasks is expressed entirely through the `#### Shared Surfaces`
section of the overview, not through per-task frontmatter. `/pour` derives the
ordering edges from there at pour time.

## Open Questions During Design

If unresolved scope or design questions surface while drafting Design,
**resolve them with the human driver via AskUserQuestion before writing
to the file**. Do not silently persist an "Open questions" section.

After the user answers, fold the resolution into the relevant Design
subsection (or into a "Resolved scope decisions" list). Only write an
"Open questions" section if the user explicitly says they want to defer
the question and keep it visible in the spec.

## Writing the Design Section

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

## Design Review

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

3. Before asking the user any judgment-call question, render a
   **per-task TL;DR with council feedback attached**, so the user
   can absorb what each task is and what each reviewer flagged
   *about that task* without having to re-link findings to tasks
   themselves. Format roughly:

   ```
   ## <task id> — <one-line task purpose>

   - code-critic: <crisp bullet of what they flagged on this task>
   - grug-architect: <crisp bullet of what they flagged on this task>
   ```

   Plus a separate short section for spec-wide concerns (those
   that don't attach to a single task — e.g., scope shape, missing
   surfaces, deferred work). Keep each bullet to one sentence;
   omit the reviewer entirely if they had nothing to say about
   that task. The goal is that the user can decide on scope or
   contract changes after reading this synthesis alone.

4. Sort findings into two groups before applying anything:

   **Non-controversial fixes** — concrete, mechanical, no design
   tradeoff. Apply these directly:
   - missing shared surface entries
   - stale references after a renumber
   - verification bullets that are procedure-shaped instead of
     observable
   - tasks that are byte-identical in shape to a sibling and
     should clearly be merged

   **Judgment calls** — anything that involves a tradeoff the
   user should weigh. Surface these to the user as a single
   AskUserQuestion (or a short numbered list if there are several),
   each with the reviewer's argument and the alternative. Do not
   apply these without explicit user input. Examples:
   - over-decomposition that *might* be intentional
   - phase ordering that has a legitimate alternative
   - a task that one reviewer wants merged and another wants
     split
   - missing scope (something the council thinks should be in
     the spec but isn't)

5. After applying any non-controversial fixes and resolving
   judgment calls, briefly confirm what changed and why.

## Post-Design Summary

After the design review is resolved and all task files are finalized:
1. Show the user a summary: how many tasks, dependency structure, categories
2. List the options the user has, neutrally:
   - Review each task file at their own pace, adding notes to
     `<review>` if changes are needed
   - Run `/spec <task-file>` to process any review feedback
   - Flip `status: draft` → `status: approved` when satisfied
   - Run `/pour` to create tk tickets from approved tasks
3. Stop. Do not ask whether the user is ready to approve, do
   not mark any of the above options as recommended, and do not
   imply readiness for the next step. The user moves on their
   own clock; your role here is done.
