---
title: Spec Sizing Rule
created: 2026-04-08
epic: soc-w9x2
archived: 2026-04-09
delimit_approved: true
---

## Describe [COMPLETE]

Socrates' `/spec` command tells authors to size each task so it maps to
roughly one focused commit, and to ground steps in concrete file paths
and function names discovered during research. Tasks are written as
numbered implementation steps plus verification steps, with a review
channel for human feedback.

In practice, across the specs written so far, task bodies have drifted
toward prescriptive recipes: specific sub-steps, exact parameter
positions, literal identifiers, line-pinned references. The earlier
specs in the corpus read as outcome statements; the later ones read as
scripts. The sizing rule and the "ground in concrete paths" guidance
pull authors toward this shape.

The anti-pattern being observed is over-specification. When the spec
author writes the task as a procedure, the implementer loses the
freedom to diverge when reality disagrees with the spec — discoveries
made during implementation collide with instructions that were never
meant to be load-bearing. What the implementer actually needs is a
clear vision of the outcome and enough latitude to choose the path to
it. The current schema does not make that distinction; `<steps>` is a
single blob that equally accommodates "do X, Y, Z" and "end state
should satisfy P."

The review loop adds a second-order effect. Reviewers correct whatever
shape is in the file, so procedural tasks attract procedural
corrections, reinforcing the drift.

The unknowns sit on the implementer side of the handoff. If tasks
describe outcomes instead of procedures, the autonomous implementer
needs to decompose the outcome into concrete work itself, and the
review loop needs to act on a shape it was not designed for. Neither
of these has been validated.

Affected: the spec author (feels brittleness during review), the
autonomous implementer (collides with over-specified steps during
execution), and later readers (wade through prescriptive prose to
recover the original intent).

## Diagnose [COMPLETE]

### Hypotheses considered

**H1 — The sizing rule itself pulls authors toward procedures.**
Anchoring tasks to "roughly one commit" makes outcome statements
feel too vague to act on, so authors reach for steps instead.
*Status: Confirmed.* Drift is monotone across the corpus; the
tasks that stayed outcome-shaped were simply small enough that
the outcome and the step converged.

**H2 — "Ground in concrete paths" guidance compounds H1.**
Authoring guidance tells authors to reference real file paths and
identifiers discovered in research. Combined with commit-sized
sizing, this pins implementation detail that the implementer
should be the one to find. *Status: Confirmed.* Line-pinned
references and parameter positions in task bodies only exist
because the guidance invited them.

**H3 — The single `<steps>` block conflates two kinds of content.**
There is no structural separation between "the outcome the
implementer must reach" and "the path the author imagined taking
to get there." Both share one list, and the reviewer cannot tell
which bullets are load-bearing. *Status: Confirmed.* This is what
lets a task contain an instruction and its negation in the same
block without the schema flagging it.

**H4 — The review loop reinforces whichever shape it finds.**
Reviewers correct what is in the file. Procedural content attracts
procedural corrections, and the loop has no pressure to raise the
level of abstraction. *Status: Confirmed as amplifier.* Not a root
cause on its own — it only amplifies content H1–H3 put there.

**H5 — A capable implementer can work from outcome-shaped content
given appropriate guardrails.** *Status: Assumed true for now.*
Anecdotal experience with a capable model plus pre-commit
guardrails suggests the implementer can decompose outcomes into
correct commits when the verification contract is clear. This
assumption is load-bearing for any direction that raises sizing,
and will be assessed against future specs written under the new
rule rather than via an up-front spike.

### Root causes

1. The sizing rule collapses planning and implementation into one
   layer, forcing every task to be commit-shaped regardless of
   whether the work is better expressed as an outcome.
2. The task schema offers no structural separation between
   intended outcome and imagined path; both land in `<steps>`.
3. Authoring guidance actively pulls authors toward implementation
   detail at a layer where that detail rots quickly.

### Symptoms vs causes

- **Brittleness under discovery** is a symptom of causes 1 and 3.
- **Self-contradiction inside a task** is a symptom of cause 2.
- **Navigation pain** is a layout concern, already handled by
  earlier work on `_overview.md`, and is out of scope here.

## Delimit [APPROVED]

The `/spec` sizing rule ("one task ≈ one focused commit") combined with
guidance to ground steps in concrete code references collapses planning
and implementation into a single layer. This produces task bodies that
over-specify the path and under-specify the outcome, removing the
implementer's freedom to adapt when reality diverges from the spec.

## Direction [COMPLETE]

### Approaches

**A0 — Status quo.** Keep "one task ≈ one focused commit" sizing and
concrete-path grounding guidance. Root cause stays in place.

**A1 — Raise sizing to outcome slice.** Rewrite the sizing rule so one
task describes an outcome the implementer must reach, which may span
multiple commits. Rewrite authoring guidance to steer toward outcome
and verification content rather than step-by-step procedures. Keep
multi-file layout, `<review>`, ADR-004 constraints intact.

**A2 — Rename tags only.** Rename `<steps>` to `<outcome>` and
`<test_steps>` to `<verification>`. Keep sizing rule. Cosmetic rename
is unlikely to shift author behavior given the sizing rule still pulls
toward procedures.

**A3 — Full two-layer model (choo-choo-ralph).** Spec tasks become
~10 high-level slices; `/pour` explodes each into implementation tasks
at pour time. Requires reworking the hook, pour, and namespace
separation. Right long-term direction but disproportionate scope today.

### Decision Matrix

| | A0: Status quo | A1: Outcome slice | A2: Tag rename | A3: Two-layer |
|---|---|---|---|---|
| Reduces over-specification | 🔴 | 🟢 | 🟡 | 🟢 |
| Implementer freedom | 🔴 | 🟢 | 🟡 | 🟢 |
| Review loop preserved | 🟢 | 🟢 | 🟢 | 🟡 |
| ADR-004 constraints | 🟢 | 🟢 | 🟢 | 🔴 |
| Scope of change | ⬜ | 🟡 | 🟢 | 🔴 |
| Validated by experience | 🟢 | 🟡 | 🔴 | 🟡 |

### Chosen Approach

**A1 — Raise sizing to outcome slice.** Addresses root causes 1–3 from
Diagnose while preserving all mechanical constraints. Scope is
proportional to the problem. H5 (implementer can work from outcomes)
is assumed true and will be assessed against future specs.

### Use Cases

1. **Spec author writing a new spec** — describe what the implementer
   should achieve, not dictate the steps, so the task stays valid as
   surrounding code evolves.
2. **Spec reviewer reading a task** — tell whether the outcome is
   correct without mentally executing a procedure to see where it
   leads.
3. **Autonomous implementer consuming a poured ticket** — receive a
   clear target and verification contract, choose the path to get
   there.
4. **Spec author using `<review>`** — give feedback on whether the
   outcome is right, not whether step 3b's parameter order is
   correct.

## Design [COMPLETE]

### Context

The sizing rule lives in `plugins/socrates/commands/spec.md`. The
"ground in concrete paths" guidance is in the same file. The task
template at `plugins/socrates/templates/task.md` defines the
`<steps>`, `<test_steps>`, and `<review>` tags. Pour does verbatim
extraction of `<steps>` and `<test_steps>` content into tk ticket
descriptions under `## Steps` and `## Verification` headings.
RALPH.md tells the implementer how to read and execute poured
tickets. `docs/spec-format.md` and `docs/customization.md` document
the format for users.

Tag names are parsed by pour — renaming `<steps>` → `<outcome>` and
`<test_steps>` → `<verification>` requires a corresponding pour
update. The `<review>` tag and its semantics stay unchanged. The
multi-file layout, ADR-004 constraints, hooks, and namespace
separation are not touched.

### Tasks

| ID | Title | Priority | Category |
|----|-------|----------|----------|
| 1-15a1 | Rewrite sizing guidance and rename task body tags | 0 | functional |
| 2-91d9 | Update RALPH protocol for outcome-shaped tickets | 1 | functional |

### Execution Order

1. [1-15a1-rewrite-sizing-and-rename-tags](1-15a1-rewrite-sizing-and-rename-tags.md)
   — the core change: rewrites the sizing rule and authoring guidance,
   renames `<steps>` → `<outcome>` and `<test_steps>` →
   `<verification>` across template/spec/pour, and updates
   documentation to match.
2. [2-91d9-update-ralph-protocol](2-91d9-update-ralph-protocol.md)
   — adapts the implementer protocol so it explicitly accounts for
   outcome-shaped ticket bodies instead of assuming procedural steps.

### Glossary

- **outcome slice** — a task sized to describe a single observable
  result the implementer must reach, which may span multiple commits.
  Replaces "one focused commit" as the sizing unit.
- **verification contract** — the `<verification>` section of a task
  describing how to confirm the outcome was reached. Replaces
  procedural test steps.

#### Shared Surfaces

- **tk ticket body format** — touched by
  [1-15a1](1-15a1-rewrite-sizing-and-rename-tags.md) (surface owner)
  and [2-91d9](2-91d9-update-ralph-protocol.md); pour writes
  `## Outcome` / `## Verification` headings into the ticket, ralph
  reads them. Both must agree on the heading names.
