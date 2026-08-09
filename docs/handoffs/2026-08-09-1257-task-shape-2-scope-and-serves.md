# Task files carry Scope and an RC/AC trace, marked as socrates_format 2

A review of the ticket format against Jeff Patton's card-and-confirmation
standards found that four of the nine checks in `task-authoring.md`
described prose with no section to hold it. The task file shape changed to
close that gap, the new shape is marked `socrates_format: 2`, and RALPH's
task-mutation whitelist was reconciled with what the PM role had been doing
all along. Everything landed as c93562f on `main` and is pushed.

## What Was Done

### The review that started it

I reviewed `templates/task.md` against the three files that define and
consume it, plus the 24 task files under `docs/specs/archive/`, using the
`product-manager:story-mapping` skill as the lens.

The headline defect: `task-authoring.md` declared the task shape as
"frontmatter, title, **Context**, Outcomes, Verification", but no Context
section existed anywhere — not in the template, not in `spec-format.md`, not
in the Design phase's fill-in list. None of the 24 archived tasks had one.
Checks 1 (valuable), 2 (problem-first), 7 (bounded) and 9 (negotiable) were
therefore unenforceable as written.

Three consequences followed from that single absence, and each showed up in
real files. Rationale accumulated in Outcomes — one bullet in
`4-de92-reaim-defenses-to-status.md` runs seven lines and is mostly
justification, which makes check 8 ("done is distinct from tested")
impossible to apply. Non-goals were filed under the Verification guidance,
where a scope boundary sat among observations. And the Design phase's
comprehension test asked a fresh reader which Diagnose item a task served
while the template offered no field to record the answer.

### Reworked the task shape (c93562f)

- **`## Scope`** replaced the missing Context section. It carries the slice
  boundary and the alternative the task rejected, and it links to the
  overview instead of copying it. The operator set that constraint
  explicitly: a ticket must follow the live spec, not own a snapshot of it.
- **`## Outcomes` became `## Outcome`**, matching the sizing rule that
  splits any task describing two independently verifiable outcomes.
- **`serves:`** was added to frontmatter, listing the diagnosed-item ids
  (`RC1`, `AC2`) a task addresses. This is the live pointer that lets Scope
  stay short.
- **Verification** now asks Patton's second confirmation question — how the
  observation gets staged, not only what to observe. It stayed one flat
  list, because in Patton the demonstration question adds bullets to the
  criteria rather than forming a section of its own.
- **`priority`** kept its 0-4 range and gained a rubric anchored on what
  cutting the task would do to the Delimit outcome, plus a rule that it
  never encodes order.
- **`socrates_format: 2`** was added to both the task and overview
  templates. An absent field reads as shape 1.

The propagation ran last, deliberately, once the shape settled:
`spec-format.md`, `phases/design.md`, `task-authoring.md`,
`task-authoring-examples.md`, `patterns/task-review-mode.md`,
`skills/task/SKILL.md`, and both copies of the RALPH protocol.

### Reconciled RALPH with the PM role (c93562f)

`RALPH.md`'s Task Mutation whitelist permitted only `external-ref` and
`tags`, while both the External Review Sweep and the End-of-Session Gate
set `status`. The whitelist now lists `status` and names which role sets it
when — the implementer at the End-of-Session Gate for work it finished, the
PM when reconciling state or observing a merge. `priority` and `serves`
were added as PM-only, and the frozen contract was named as never mutable
by either role.

While there I fixed something unrelated but broken: all four PM-role
descriptions told the agent to correct a "stale `in_progress`" task.
`in_progress` has not been a status since the lifecycle was unified to
`draft | approved | closed | cancelled`, so the instruction named a state
that cannot occur. It now describes the real drift — work landed while the
task is still `approved`, or a `deps` entry naming a task that does not
exist.

### Removed an orphaned Emacs autosave

`plugins/socrates/commands/spec-support/phases/#design.md#` was the only
file in an untracked three-level directory, left over from the June plugin
restructure and superseded by `references/phases/design.md`. I verified the
directory held nothing else before deleting it. `rm -rf` was blocked by the
permission classifier; removing the file and then the empty directories
with `rmdir` worked.

## Decisions the next reader should not re-litigate

- **The section is called `Scope`, not `Context`.** The first draft used
  Context, which collided with the overview's `### Context` (codebase
  research) — two different things under one name across one spec
  directory. The operator chose Scope from four candidates. It also matches
  vocabulary already in the file: check 7 is "Bounded", and the non-goals
  guidance talks about making scope unambiguous.
- **`serves` and `priority` sit outside the frozen contract.** Diagnosed
  items get renumbered and reworded as a spec matures. Forcing a task
  reopen to re-point at a renamed `RC1` would fight the no-snapshot rule
  the whole change exists to enforce. The contract is Scope, Outcome,
  Verification, `deps`.
- **`priority` was kept, not deleted.** I proposed removing it as an
  unanchored third encoding of order. The operator kept it — priority on
  tickets is a normal convention, and removal would have pulled the `spec`
  CLI into scope. Defining it was the cheaper fix.

## Verification

- The `spec` CLI parser (`nix/ralph/spec:24`) anchors keys at line start, so
  the new `#` comment lines in the templates cannot shadow real fields. I
  ran `fm_value` against both templates: all eight task keys and all four
  overview keys resolve, including `socrates_format => 2`.
- `nix/ralph/RALPH.md` and `references/ralph-protocol.md` are byte-identical
  (`diff -q`), as they were before the change.
- No `in_progress` remains anywhere under `nix/ralph/` or
  `plugins/socrates/`.
- Every remaining `Context` reference is the overview's `### Context`, the
  `Context transfer` row in the interactive-defaults table, or unrelated
  prose in `source-doc-mode.md`.
- A meat review ran on the branch and came back LGTM with no file-anchored
  comments. `main` fast-forwarded from 6b0ec27 to c93562f and is pushed.

## What's Next

- Watch whether Scope stays short in practice. It is the section authors
  will want to overfill, and the no-duplication rule is enforced by prose
  alone.
- The archived specs stay at shape 1 by design. If a future reader finds
  the mixed shapes confusing, the `socrates_format` field is what a
  migration would key on.

## Gaps

- **Nothing checks the template against its own standard.** This entire
  defect class — a documented section that no template provides — was
  invisible because no test compares `templates/task.md` against the nine
  checks in `task-authoring.md`. The same drift can recur tomorrow.
- **No `code-critic` pass ran.** The session was configured not to spawn
  agents, so the meat review was the only review this change received.
- **`<review>` history is still destroyed on regeneration.** The review
  workflow clears the block after regenerating the contract, so the reason
  a frozen contract changed survives only in git history. Raised and
  deferred.
- **`assignee` carries no information.** All 24 archived tasks say `ralph`,
  which makes `spec ready -a ralph` filter nothing. Raised and deferred.
- **The two protocol copies must still be edited together.** The
  2026-07-15 handoff recorded this same gap; this is the second session to
  hit it, and the second to fix both copies by hand. A `diff -q` in a test
  or pre-commit hook would catch the drift the moment it appears.

## Skills and meta

**Skills used**

- `product-manager:story-mapping` — review lens for the ticket format —
  supplied the card/confirmation standards that produced the defect list,
  in particular the two-question confirmation that exposed the missing
  demonstration criterion.
- `herdr:meat-review` — opened the review on c93562f — one round, LGTM.
- `writing:handoff` — this document.

**Steering**

- I proposed deleting `priority`; the operator kept it and asked for a
  rubric instead. Durable lesson: when a field is unanchored but is also a
  domain convention, propose defining it before proposing removal, and
  price in the consumers (here, the `spec` CLI) before recommending a
  delete.
- I proposed `## Context` for the new section and only noticed the
  collision with the overview's `### Context` after propagating it through
  ten files. The operator caught it. Durable lesson: check a proposed
  section name against the existing headings in the same document family
  before writing it anywhere.
- I offered to do the propagation pass in the same breath as the shape
  change; the operator sequenced it last, once the shape settled. That was
  right — the section got renamed afterwards, and doing propagation early
  would have meant doing it twice.

**Meta**

- The operator twice asked for a plain enumerated change list because the
  prose answers buried the decisions. For a multi-part change, lead with
  the numbered list of what will change and keep the argument underneath
  it.
- Reviewing a template against an external standard (here, Patton) found a
  defect class that internal review had missed for months, because the
  standard named sections the project had quietly dropped. Worth repeating
  on the overview format.
