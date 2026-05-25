---
title: PR Review Loop
created: 2026-04-29
epic: soc-ooy8
archived:
delimit_approved: true
---

## Describe [COMPLETE]

### Situation

A spec author runs the Socrates flow today: design the spec, approve
tasks, pour tickets, and hand off to RALPH. RALPH executes the tickets,
opens a PR, and closes the ticket as done. The PR then enters a review
phase — the author reviews on GitHub as a discipline, and human
teammates review as well. Review comments
land on the PR.

To address the comments, the author starts a *fresh* Claude session
(RALPH is gone, its ticket is closed) and asks it to fetch the PR via
`gh`. That session applies fixes. Eventually the PR merges.

### Known facts and constraints

- ✅ Tickets are marked closed by RALPH at "work done" (the moment the
  implementation lands on a branch), not at "merged". Verified via
  RALPH.md End-of-Session Gate (see Addendum A.1).
- ✅ The PR is the unit of review, but RALPH has no awareness of PR
  state. Once RALPH closes a ticket, it has no relationship to the PR
  that follows. Verified by reading RALPH.md: no mention of PR state.
- 🟨 Review comments fall into three within-scope shapes: small
  targeted fixes, behavioural corrections, and design pushback. They
  are continuations of the original ticket's work, not new tickets.
  Based on observed workflow patterns; not formally validated.
- ✅ The bridge from PR comments to a Claude session is manual: the
  author tells a fresh session to fetch the PR. There is no
  protocol-level handle. Verified: no protocol artifact references
  external review comments.
- ✅ Reviewers include the author (via GitHub) and human teammates
  with no spec/RALPH context. Verified: current workflow.
- 🟨 Specs are designed under the assumption that third-party review
  is part of the work, not optional. Based on spec template design;
  not enforced mechanically.

### Open questions

- Where should the "in review" / "merged" state live — on the ticket,
  the PR, or both? Today it lives nowhere.
- Should review feedback re-enter as new tickets, as amendments to the
  original, or as something else?
- How does a fresh session pick up the original ticket's context
  cleanly, given RALPH won't be around?
- Does this interact with `tk` (ticket store) primitives, or is it
  strictly a protocol-layer concern?

### Stakeholders and impact

- **Spec author / driver**: manually orchestrates the bridge between PR
  review and Claude work; loses spec context every cycle; cannot tell
  from the ticket store whether work is *truly* done.
- **RALPH**: blind to PR state, so it cannot know whether its tickets
  actually shipped or whether more work is pending.
- **Human teammates reviewing PRs**: their comments hit a workflow seam
  and require manual translation back into actionable work.
- **Future Socrates users** (downstream of this dogfooded design):
  inherit whatever pattern we settle on.

## Diagnose [COMPLETE]

### Hypotheses

#### H1 — Ticket lifecycle ends at "work done", not "merged"

**Status: ✅ Confirmed.**
RALPH.md End-of-Session Gate step 3 says "Close tickets that are
done," where `done` is defined by Verification passing on the local
branch (see Addendum A.1). `tk` only supports `open`/`in_progress`/`closed`.
Once RALPH closes a ticket, the protocol has no further hook on it;
the entire review-to-merge window happens outside any protocol structure.

#### H2 — The Reviewer role is internal-only (pre-commit), not external (post-merge-request)

**Status: ✅ Confirmed.**
RALPH.md Reviewer section spawns the `code-critic` agent before commit.
The phrase "Pending review comments on tk tickets" refers to tk-internal
notes added by that code-critic pass, not to external review comments
from a code-hosting service (see Addendum A.2). The protocol has no
role for the post-merge-request window: no phase, no triage rule, no
role assignment.

#### H3 — No protocol-level bridge between external review and tk tickets

**Status: ✅ Confirmed.**
`tk` supports `--external-ref` as passive metadata; nothing reads or
acts on it (see Addendum A.3). There is no convention for pulling
external review comments into a ticket's notes. The author bridges
manually each cycle ("look at PR #N").

#### H4 — The work units (ticket vs merge request) are mismatched

**Status: ❌ Rejected.**
Review comments are within-scope for the original ticket: small fixes,
behavioural corrections, design pushback. They are continuations of
the same work, not new work. The unit is not mismatched; the time
dimension is wrong (the ticket dies too early).

*Implication for Direction:* No need to create separate tickets for
review feedback; extend the lifecycle of the existing ticket instead.

#### H5 — Session ephemerality is the cause

**Status: 🟡 Symptom, not root cause.**
A fresh session has to pick up the work, but that is a consequence of
H1/H2. `tk` tickets are durable, git-tracked, and machine-readable;
fresh sessions already pick up `open`/`in_progress` tickets via
`tk ready` and reconstitute context from `tk show`. Sessions dying is
a feature of the design, not a bug. The fragmentation only appears
because the ticket dies before the work is done. Fix RC1 and session
ephemerality stops being painful.

*Implication for Direction:* Do not add session persistence; fix the
ticket lifecycle.

#### H6 — Specs do not expect review

**Status: ❌ Rejected.**
Specs are designed with third-party review in mind. The protocol
downstream of pour is what loses that assumption, not the spec model.

*Implication for Direction:* The spec model is sound; only the
protocol execution layer needs change.

### Diagnosed items

#### RC1 — The ticket lifecycle has no "in review" state

Tickets transition straight from `in_progress` to `closed` at
branch-landed, so the protocol loses grip on the work during the most
failure-prone window: review and merge.

#### RC2 — The protocol has no role/phase for external review

RALPH.md treats review as the internal `code-critic` pass before
commit. The external review cycle has no role, no phase, no triage
entry, and no merge gate.

### Symptoms (downstream of RC1+RC2)

- Fresh Claude sessions must rebuild context manually each time review
  feedback lands.
- External review comments require manual narration to enter the work
  loop.
- The ticket store reports "done" before the work is actually shipped,
  polluting `tk ready` reasoning and spec-lifecycle archival.

#### AC1 — Per-spec opt-in

Review mode is set per spec, not per ticket. When opt-out is in
effect, today's behaviour is preserved exactly: RALPH closes tickets
at "work done" with no review/merge phase. The new behaviour is
purely additive for review-mode specs. The home is the spec's own
`_overview.md` frontmatter, which RALPH already reads during the PM
Spec Lifecycle Sweep and whenever a ticket carries a `Spec overview:`
link. Tickets without a `Spec overview:` link default to off.

#### AC2 — Service-agnostic

The protocol names the abstraction (an external reference) without
binding to a service. The shape is already established by
`tk --external-ref`. The RALPH agent has the tools and judgment to
resolve the reference (run `gh`, `curl` an API, query a CLI). The
protocol layer stays declarative; the imperative resolution stays in
the agent.

### Boundary Checkpoint

Does the diagnosed root cause explain why the problem occurs *here*
and *now* but not in similar situations?

Yes. The problem is specific to Socrates/RALPH because:
- Other agentic frameworks either don't track tickets (no lifecycle
  to cut short) or use external issue trackers that already have
  "in review" states.
- Human-only workflows bridge manually by default; the fragmentation
  is invisible because humans maintain context across sessions.

The root cause is not "code review exists" (universal) but "the
protocol's ticket lifecycle ends at branch-landed" (specific to
RALPH.md's current design).

### Scope note

RC1 and RC2 are tightly coupled: adding an "in review" state (RC1)
creates the home for external review work, but the protocol also needs
a role and phase (RC2) to operate during that state. They are two
facets of one missing concept ("review-and-merge as a protocol-level
phase"). One spec covers both.

## Delimit [APPROVED]

On specs that opt into external code review, RALPH cannot carry a
ticket end-to-end through merge — the ticket closes at branch-landed
and no protocol role or state covers the review-to-merge window —
forcing the human to manually bridge each round of review feedback
into a fresh Claude session.

## Direction [COMPLETE]

### Approaches

#### A1 — Status Quo

No changes. Human bridges PR comments into a fresh Claude session each
round. The pain stays.

#### A2 — Lightweight protocol: open ticket + external-ref + tag

RALPH does not close the ticket at work-done. Instead it sets
`--external-ref` (the upstream PR URL), tags the ticket
`awaiting-review`, and leaves it as `in_progress`. The PM cycle gains
a small extension: for any ticket tagged `awaiting-review`, the agent
resolves the external-ref via whatever tool fits the host (`gh`,
`glab`, `curl`, etc.), appends new comments as notes, and ensures the
ticket reappears in `tk ready`. The ticket closes only when the agent
observes the merge via the same resolver. Service-agnostic by design;
per-spec opt-in via the spec's `_overview.md` frontmatter.

#### A3 — Heavyweight: new `tk` status + dedicated External-Reviewer role

Extend `tk` itself to add an `in_review` status; add a distinct
"External Reviewer" role to RALPH.md alongside the existing internal
`code-critic` Reviewer. More explicit, more invasive: touches `tk` source.

#### A4 — Tool-not-protocol: dedicated `/review <pr>` skill

Don't change the protocol or ticket lifecycle. Add a dedicated skill
the human invokes when ready to address comments. The skill bridges
PR → tk-notes → fresh session. Better tooling for the existing bridge,
but the ticket still dies at work-done.

### Decision Matrix

*Problem: On projects that opt into external code review, RALPH
cannot carry a ticket end-to-end through merge — the ticket closes at
branch-landed and no protocol role or state covers the
review-to-merge window.*

| Criterion | A1 Status Quo | A2 Lightweight | A3 Heavyweight | A4 Tool-only |
|---|---|---|---|---|
| Solves RC1 + RC2 | 🔴 | 🟢 | 🟢 | 🟡 |
| [ID] Implementation complexity | 🟢 (none) | 🟢 (small) | 🔴 (large) | 🟡 (medium) |
| Respects AC2 (service-agnostic) | ⚪ | 🟢 | 🟢 | 🟢 |
| Respects AC1 (opt-in) | 🟢 | 🟢 | 🟢 | 🟢 |
| [ID] `tk` schema changes | 🟢 (none) | 🟢 (none) | 🔴 (new status) | 🟢 (none) |
| Fresh-session pickup (from RC1) | 🔴 | 🟢 (tag query) | 🟢 (status query) | 🟡 (human invokes) |
| [ID] Failure modes | ⚪ | 🟡 (poll, creds, races) | 🟡 (state coherence) | 🟢 (no protocol coupling) |

**Notes on the matrix**

- A2 vs A3: a tag plus existing `in_progress` is a sufficient signal.
  No need to expand `tk`'s state machine. The signal is "has
  external-ref AND is tagged `awaiting-review`".
- A4 is honest about its limit: better tooling for the manual bridge,
  but RALPH still does not know its work is in review, and the ticket
  store still reports premature `closed`.

### Chosen Approach

> **Chosen: A2 — Lightweight protocol.** Smallest change that actually
> fixes RC1 and RC2. Uses `tk`'s existing primitives (`--external-ref`,
> tags, notes) without schema changes, respecting AC2 (service-agnostic:
> the agent resolves the reference; the protocol does not name the host)
> and AC1 (opt-in: when off, RALPH's behaviour is unchanged).

### Inversion Test

What would guarantee this approach fails?

**Assumptions that must hold:**

1. The agent can resolve external-ref URLs to fetch review comments.
   If auth is missing, rate limits hit, or the API changes, the sweep
   stalls. Mitigation: escalation rule ensures the human is notified
   rather than silent failure.

2. Append-only ticket mutation avoids races. If a future change to
   `tk` or the protocol introduces concurrent writes, notes could
   collide. Mitigation: the protocol pins append-only as a rule.

3. The `awaiting-review` tag is unambiguous. If another feature reuses
   the tag for a different purpose, the PM sweep could process wrong
   tickets. Mitigation: the tag is namespaced to the review-mode
   feature; document it as reserved.

**Failure modes:**

- **Polling delays**: The PM sweep is not instant. Comments may sit
  for hours before the agent notices. Acceptable for current use case
  (async review), but would break real-time expectations.
- **Credential rot**: If `gh` or `glab` tokens expire, the sweep fails
  to fetch comments. Escalation surfaces this, but the human must
  manually refresh credentials.
- **Close-without-merge**: If a PR is closed without merging, the
  ticket is orphaned in `awaiting-review`. Escalation handles this,
  but the human must decide what to do with the work.

### Residue Check

If we execute this approach perfectly, what would still be broken?

- **Upgrade path for `/init`-installed projects**: Existing projects
  won't get the new RALPH.md template automatically. The flag itself
  lives in each spec's `_overview.md`, but the new PM behaviours
  (External Review Sweep, End-of-Session Gate branching) are protocol
  changes inside RALPH.md. Documented as deferred work in
  `docs/gaps/socrates-upgrade-flow.md`.
- **No proactive notification**: The protocol surfaces comments via
  ticket notes, but doesn't ping the human externally. Acceptable for
  now; external notification is a separate feature.
- **No branch protection enforcement**: The protocol assumes the PR
  is created and the branch is pushed. If the human forgets to push,
  the external-ref discovery fails. The escalation rule catches this,
  but the human must complete the push manually.

### Use Cases

| Actor | Intent | Outcome | How |
|---|---|---|---|
| Spec author | Hand off a ticket and have RALPH carry it through review and merge | Only intervene on real decisions; the loop runs unattended through the whole lifecycle | (Design) |
| RALPH (PM role) | Discover that an in-flight ticket has new review feedback during normal triage | Pulls feedback as notes, ticket re-enters `tk ready`, addresses fixes without being told | (Design) |
| Spec author | See an honest view of which work is shipped vs only branch-landed | `tk` listings reflect merged state, not premature `closed`; spec-lifecycle archival is accurate | (Design) |
| Fresh Claude session | Pick up review work from a single ticket without external bridging | `tk show <id>` is enough to get full context (original outcome, work done, review comments, current state) | (Design) |
| Project on non-GitHub host (GitLab, codeberg, internal) | Use the same protocol with the service of choice | Agent resolves the external-ref via whatever tool fits (`glab`, `curl` to internal API) — no protocol changes per service | (Design) |
| Hobby-mode spec | Preserve today's behaviour with no review cycle | Spec's `_overview.md` leaves `review_mode` at its default of `false`; RALPH closes tickets at work-done as today; no new ceremony | (Design) |
| Spec author | Have a merged PR automatically close its ticket | Merge state polled via the same resolver as comments; ticket closes when the agent observes the merge | (Design) |

### Resolved scope decisions

- **Per-spec opt-in.** Review mode is set per spec, not per ticket.
  Lives in the spec's `_overview.md` frontmatter (`review_mode:
  false` by default). Tickets without a `Spec overview:` link default
  to off, preserving today's behaviour exactly.
- **Service-agnostic.** Protocol names the abstraction (external
  reference); agent resolves the host (`gh`, `glab`, `curl`, etc.).
- **No `tk` schema changes.** Tag + existing `--external-ref` is the
  signal for "in review"; no new status added.
- **Read points.** RALPH already reads `_overview.md` during the PM
  Spec Lifecycle Sweep and whenever a ticket carries a
  `Spec overview:` link, so no new file is loaded at session start.

## Design [COMPLETE]

### Context

The chosen approach (A2) lives almost entirely in RALPH.md, the
prose protocol the agent reads at the start of every session. All
`tk` state transitions are agent-issued, not script-issued — there
is no shell wrapper around `tk close` to retrofit. The protocol
layer is the integration point.

Key findings from codebase research:

- **`tk` is a constraint, not a target of refactor.** `tk` accepts
  `--external-ref` and `--tags` only at create time; `tk edit <id>`
  opens `$EDITOR`, which is unsuitable for autonomous agents. The
  protocol therefore directs the agent to edit ticket markdown
  directly under `.tickets/`. Status is a fixed three-state machine
  (`open`/`in_progress`/`closed`); we deliberately use a tag rather
  than a new status, leaving `tk` source untouched.

- **Tag conventions today.** Category tags on tasks (`functional`,
  `documentation`); spec-name tags on epics. `awaiting-review` is a
  new lifecycle tag — first of its kind, introduced by this spec.

- **The spec's `_overview.md` is the natural home.** RALPH already
  reads `_overview.md` during the PM Spec Lifecycle Sweep and
  whenever a ticket body carries a `Spec overview:` link. No new
  per-project config surface is needed. Tickets without a
  `Spec overview:` link default to `review_mode: false`, preserving
  today's behaviour for one-off `tk` tickets created outside the
  spec flow.

- **Greenfield host integration.** No existing code in the repo
  calls `gh`, `glab`, or any code-hosting tool. `gh` is checked at
  init time as a warn-if-missing prerequisite but never invoked.
  The protocol must therefore *describe* the operations and let the
  agent's common knowledge perform them — there are no helpers to
  lean on.

- **Append-only mutation rules out races.** The PM role's sweep and
  the implementer role can both touch an `awaiting-review` ticket.
  By restricting the sweep to appending notes and never mutating
  prior notes, the protocol avoids lost-write races against a
  concurrent implementer who is reading the ticket.

### Tasks

| ID | Title | Priority | Category |
|---|---|---|---|
| [1-13a3](1-13a3-implement-review-mode.md) | Implement review-mode behaviour in RALPH.md and pair docs | 0 | functional |
| [2-e75b](2-e75b-init-stamp-review-mode.md) | Stamp review_mode default in spec _overview.md template | 1 | functional |

### Execution Order

- [1-13a3](1-13a3-implement-review-mode.md) is the protocol-change
  task: a coherent edit to `RALPH.md` plus its pair docs that
  introduces the `review_mode` flag, the URL-based external-ref
  convention, the End-of-Session Gate branch, the PM External Review
  Sweep, and the pinned mechanism for mutating existing tickets.
  Validation against real upstream artifacts happens during this
  task; caveats are folded into the protocol prose itself.

- [2-e75b](2-e75b-init-stamp-review-mode.md) follows by stamping
  `review_mode: false` into the spec `_overview.md` template at
  `plugins/socrates/templates/_overview.md` so newly created specs
  carry the field by default. It depends on the field's semantics
  being established by task 1 but is otherwise a thin one-line
  template change.

### Glossary

- **`review_mode`** — per-spec boolean field in `_overview.md`
  frontmatter that gates every conditional behaviour introduced by
  this spec. Default: `false`. A missing field is treated as
  `false`. Tickets without a `Spec overview:` link also default to
  off.
- **External-ref** — the URL of the upstream review artifact
  (PR, MR, or equivalent) attached to a ticket via `tk`'s
  `--external-ref` slot. Empty external-ref on an `awaiting-review`
  ticket means "no upstream artifact yet".
- **`awaiting-review`** — lifecycle tag set on a ticket at the
  moment of handoff to review. Removed when the upstream is observed
  merged.
- **External Review Sweep** — new PM role responsibility introduced
  by task 1; parallel in shape to the existing Spec Lifecycle Sweep.
  Iterates `awaiting-review` tickets and handles each by
  external-ref state, append-only.

#### Shared Surfaces

- **`review_mode` field in `_overview.md` frontmatter** — touched by
  [1-13a3](1-13a3-implement-review-mode.md) (surface owner) and
  [2-e75b](2-e75b-init-stamp-review-mode.md); task 1 defines the
  field and the read protocol in RALPH.md, task 2 stamps the default
  value into the spec template.

## Technical Addendum

### A.1 — Ticket closure definition

`plugins/socrates/templates/RALPH.md`, End-of-Session Gate, step 3:
"Close tickets that are done." The definition of `done` is Verification
passing on the local branch.

### A.2 — Reviewer role location

`plugins/socrates/templates/RALPH.md`, §Reviewer (approx. line 86).
The phrase "Pending review comments on tk tickets" appears in the PM
role triage (approx. line 23) and refers to tk-internal notes, not
external code-hosting comments.

### A.3 — `tk` external-ref pattern

`tk` accepts `--external-ref` at ticket creation time. Examples:
`gh-123`, `gitlab-456`, `linear-XYZ`. The field is passive metadata
today; nothing reads or acts on it.
