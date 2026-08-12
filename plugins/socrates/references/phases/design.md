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

Use the findings to choose the task boundaries and the smallest useful Design
summary. `### Context` keeps only research that changes how an implementer
understands the design. Do not turn the research log into overview prose.

Some Adjacent Constraints (AC) from Diagnose dictate a specific *encoding* —
where the constraint must live in the design (a chart conditional, a
config-file structure, an interface boundary). When one does, call out that
encoding explicitly in the Context. Direction committed to *honoring* the
constraint; the Context translates that into *where it lands*.

If codebase research surfaced concrete file paths, line numbers, or
quantitative findings (e.g., "this file is ~400 lines, 60% of which is
incidental drift"):

1. Put the prose claim in Context.
2. Put the supporting detail in the `## Technical Addendum` section at the
   end of `_overview.md`.
3. Link them with an anchored reference: `(See [Addendum A.3](#a3) for the
   catalog.)`

## Choose a solution map

After research, decide whether a small solution diagram would explain the
chosen approach faster than prose. Add one when a reader otherwise has to
track any of these:

- three or more interacting components or ownership boundaries
- an ordered exchange whose timing, retries, or failure path matters
- three or more lifecycle states or guarded transitions
- several inputs that converge on one decision or fan out to several outputs

Choose the diagram by the question it answers:

- **Data flow** — What inputs produce the result, and where does it go?
- **Component** — Who owns, reads, writes, or depends on what?
- **Sequence** — What crosses boundaries, in what order, and what happens on
  failure?
- **State** — Which transitions are allowed, and what triggers them?

A task dependency graph explains the implementation plan, not the solution.
Use one only when the task graph itself is difficult to read from `deps:`.

When the best diagram is clear, add it without asking. Ask the human driver
only when different diagram types would emphasize meaningfully different
concerns, the diagram would settle an unresolved design choice, or producing
it would substantially expand the document.

State the question in one sentence above the diagram. If the question is not
specific, the diagram has no job and should be omitted.

Default to one diagram. Add a second only when it answers a separate question
that readers need and combining the two would make both harder to read. Aim
for 5-8 nodes or participants and do not exceed about 10. Use MermaidJS so
the source stays reviewable in Markdown. Omit file paths, task ids, test
cases, and details already covered by nearby prose. If no diagram earns its
space, omit `### Solution Map` silently.

## Task Decomposition

Break the approach into **5-10 implementation tasks** (configurable — the user
can request more or fewer granularity).

Every task follows the standard in `../task-authoring.md`
(worked bad-versus-good pairs in `task-authoring-examples.md` alongside it).
Read it before decomposing and run its nine checks before marking any task
ready.

**Sizing rule**: one task ≈ one outcome slice — a discrete, verifiable change
in system behaviour or project state. Size by what the implementer must
*achieve*, not by how many files or commits the work touches.

- **Split** a task if it describes two outcomes that can be verified
  independently.
- **Merge** tasks if they target the same outcome and cannot be verified
  separately.

For each task:

1. **Generate the identity**: short hash (first 4 chars of sha256 of
   title) + human suffix (2-3 word kebab-case). Example:
   `a1b2-setup-middleware`. This is what goes in the task's `id:`
   frontmatter field.
   ```bash
   echo -n "Setup auth middleware" | sha256sum | cut -c1-4
   ```

2. **Assign an ordinal** (1-based execution order) based on logical
   dependency order. The ordinal does not go in the frontmatter; it
   only appears in the filename so `ls` on the spec directory shows
   tasks in execution order. Tasks with no dependencies get the
   lowest ordinals.

3. **Create the task file** at
   `docs/specs/<name>/<ordinal>-<id>.md` using the task template
   from `../../templates/task.md`.
   Example filename: `1-a1b2-setup-middleware.md`. Example
   frontmatter `id:` value: `a1b2-setup-middleware`.

4. **Fill in**:
   - `socrates_format: 2`
   - `id:` — the `<hash>-<suffix>` identity (without the ordinal)
   - `status: draft`
   - `priority:` — 0 (highest) to 4, scored on what cutting the task would
     do to the Delimit outcome. Never derive it from dependency order; that
     is what `deps:` is for. The scale is in `../task-authoring.md`.
   - `category:` — functional, style, infrastructure, or documentation
   - `serves:` — the diagnosed-item ids from Diagnose (`RC1`, `AC2`, ...)
     this task addresses. A task that serves none has to justify why it is
     in the spec.
   - `deps:` — list of upstream task identities (the `<hash>-<suffix>`
     form) this task depends on; empty list when none. If two tasks
     touch the same surface and one must land before the other, that
     ordering is a `dep` — capture it here.
   - Title — names the outcome or deliverable, not the mechanism or a dramatic
     restatement of the problem. See check 2 in
     `../task-authoring.md`.
   - `## Scope` — the boundary of this slice, and the alternative rejected
     for a design choice this task makes on its own. Link to the overview
     for the why; do not copy it. The overview keeps moving, and a task
     holding a snapshot of it goes stale silently.
   - `## Outcome` — a bulleted list of what the implementer must achieve and
     what changes for the system or project when done. State the target, not
     the procedure. Concrete file-path grounding belongs in the overview's
     Technical Addendum, not here — the implementer discovers the how.
   - `## Verification` — a bulleted list of observable criteria for confirming
     the outcome is met. Each bullet names the fact to check and the setup
     that produces the observation.
   - `<review>` — leave empty (XML tag stays invisible in rendered markdown)

Task dependencies live in each task file's `deps:` frontmatter and are the
single source of truth. The overview's task table renders those edges for
humans but does not define a second dependency graph.

## Open Questions During Design

If unresolved scope or design questions surface while drafting Design,
**resolve them with the human driver via AskUserQuestion before writing
to the file**. Do not silently persist an "Open questions" section.

After the user answers, fold the resolution into the relevant Design
subsection (or into a "Resolved scope decisions" list). Only write an
"Open questions" section if the user explicitly says they want to defer
the question and keep it visible in the spec.

## Writing the Design Section

1. Write `### Solution Map` when the diagram test above passes. Introduce it
   with the question it answers, then render the diagram.
2. Write `### Context` with only the constraints, ownership decisions, and
   codebase conventions that are not already clear from Direction or the map.
3. Write `### Tasks` as one topo-sorted table after the dependency graph is
   known:
   | Task | Outcome | Depends on | Priority |
   Use the task identity as the link label. The Outcome cell uses the task's
   outcome-first title when that is sufficient; add no second paraphrase. Each
   row renders `deps:` from frontmatter. The table is a view of the task files,
   not another source of truth.
4. Add `### Glossary` only for terms whose meaning is specific or ambiguous in
   this spec.
5. Remove `[DRAFT]` from the Design heading.

## Design Review (optional)

After writing all task files and the Design section, ask the user:

> "Design phase complete. Want a review council (code-critic + grug-architect)
> before finalizing?"

If the user declines, proceed directly to Post-Design Summary.

If the user accepts, run the council:

1. Launch two Agent sub-agents **in parallel, both foreground, both opus**:
   - **code-critic** — review the full spec (overview + all task files) for
     gaps, incorrect or missing task dependencies, risks the spec
     doesn't acknowledge, and whether the tasks are outcome-shaped.
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
   dependencies, deferred work). Keep each bullet to one sentence;
   omit the reviewer entirely if they had nothing to say about
   that task. The goal is that the user can decide on scope or
   contract changes after reading this synthesis alone.

4. Sort findings into two groups before applying anything:

   **Non-controversial fixes** — concrete, mechanical, no design
   tradeoff. Apply these directly:
   - missing `deps:` entries between tasks that clearly must be ordered
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

## Comprehension Test (optional)

After the design review (or directly after writing the Design
section if the review was skipped), ask the user:

> "Want a comprehension test before finalizing? A fresh sub-agent
> reads only what an implementer would see and answers whether the
> spec communicates each task's purpose, scope, and what done
> looks like."

If the user declines, proceed directly to Post-Design Summary.

The premise: an implementer picks up a task and reads only what's
reachable from that task — the task file, the spec overview, and
the "Spec discipline kernel" section of `/spec`. If a fresh
reader with that material cannot answer questions about the task's
*purpose*, *scope*, or *what done looks like*, the spec failed to
communicate those things, even if the answers exist in your head
as the spec's author.

### Sample selection

Test two tasks per spec:

- The **highest-priority task** (lowest ordinal that isn't pure
  pre-work or already merged). This is the entry point an
  implementer is most likely to pick up first.
- The **task with the most complex why** — the task whose purpose
  is hardest to reconstruct from the task file alone, typically
  one that closes an Adjacent Constraint, lands a prerequisite for
  later work, or whose Outcome reads as a slice rather than as the
  full motivation. Use your judgment; if two tasks tie, pick the
  one whose Outcome reframes the why in task-ordering language.

If the spec has fewer than two tasks, test all of them.

### Test execution

For each selected task, launch a fresh sub-agent (general-purpose,
foreground, sonnet model is enough — this is comprehension, not
code work). The agent's prompt:

1. **Materials**: paths to the task file, the spec's `_overview.md`,
   and the `/spec` command file (the "Spec discipline kernel"
   section is the relevant part). The agent reads only these.
2. **Questions** — the agent must answer all three:
   - **Purpose**: in one sentence, what user-facing pain does this
     task ultimately address? Which Diagnose item (RC/AC) does it
     serve? Why does this task exist *now* rather than later?
   - **Scope**: name one thing that is *not* in this task that a
     reader might mistakenly think is. If nothing comes to mind,
     say so explicitly.
   - **Done**: without re-reading the Verification section,
     describe what an observer would see when this task is done.
     Then re-read Verification and note any mismatch.
3. **Output shape**: terse answers, plus a single coverage label
   per question:
   - **covered** — the answer is directly findable in the materials
   - **inferred** — the agent had to reason across sections but got
     there confidently
   - **gap** — partial or couldn't answer

   This scale is about whether the spec *communicated* the answer,
   not how sure the agent is the answer is true.

### Failure handling

A task fails the comprehension test when any answer comes back as
**gap**. Treat the failure the same way the design review treats
non-controversial fixes — revise the spec without re-prompting the
user — with a 2-round cap symmetric with the code-critic rule:

1. **Round 1**: read the agent's answers and identify which spec
   surface should carry the missing information. The fix is almost
   always one of:
   - Tighten the overview's Describe (user-facing pain) or Diagnose
     (mechanism) so the why is reconstructible.
   - Correct the task's `serves:` so it points at the diagnosed items
     it actually addresses. A purpose answer scored **gap** is often a
     missing or wrong trace rather than missing prose.
   - Name the excluded work in the task's `## Scope` when the scope
     answer is the one that failed.
   - Reword the task's Outcome to describe the slice without
     reframing the why in task-ordering language.
   - Sharpen a Verification bullet so it names an observable
     artifact, not a procedure.

   Apply the fix and re-run the test on the same task.

2. **Round 2**: if the test still fails, surface the residual gap
   to the user as a judgment call (not a non-controversial fix),
   with the agent's transcript and your candidate fix. The user
   decides whether to apply, defer, or revise differently. Do not
   loop further.

A task passes the comprehension test when all three answers come
back as **covered** or **inferred**. Note the result inline
(one line per tested task) so the user can see what was checked.

### Why this step exists

The spec command authored the spec; of course it knows the why. A
fresh reader who can only see what an implementer sees is the
honest test of whether the spec *communicated* the why. This step
catches the failure mode where the durable why lives only in the
author's head while the spec body talks about task ordering.

## Post-Design Summary

After the design review is resolved and all task files are finalized:
1. Show the user a summary: how many tasks, dependency structure, categories
2. List the options the user has, neutrally:
   - Review each task file at their own pace, adding notes to
     `<review>` if changes are needed
   - Run `/spec <task-file>` to process any review feedback
   - Flip `status: draft` → `status: approved` when satisfied
3. Stop. Do not ask whether the user is ready to approve, do
   not mark any of the above options as recommended, and do not
   imply readiness for the next step. The user moves on their
   own clock; your role here is done.
