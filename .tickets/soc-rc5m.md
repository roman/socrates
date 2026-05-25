---
id: soc-rc5m
status: open
deps: []
links: []
created: 2026-05-25T00:42:29Z
type: task
priority: 0
assignee: ralph
parent: soc-ooy8
tags: [functional]
---
# Implement review-mode behaviour in RALPH.md and pair docs

Spec overview: docs/specs/2026-04-29-pr-review-loop/_overview.md
Spec task:     docs/specs/2026-04-29-pr-review-loop/1-13a3-implement-review-mode.md

## Outcomes

Specs that set `review_mode: true` in their own `_overview.md`
frontmatter run RALPH end-to-end through external review and merge
without manual session orchestration; specs that leave it `false`
(or absent), and one-off `tk` tickets with no `Spec overview:`
link, behave exactly as today. The protocol change lands as a
single coherent edit to `plugins/socrates/templates/RALPH.md`, the
matching user-facing notes in the Socrates project's
`docs/workflow.md` and `docs/customization.md`, and a small
discoverability hook in `plugins/socrates/commands/socrates-spec.md`.

Concretely the protocol gains:

- **Per-spec frontmatter field.** A `review_mode: false` field in
  the spec's `_overview.md` frontmatter, default `false`,
  missing-field treated as `false`. RALPH.md describes how the
  agent resolves the value for a given ticket: when the ticket body
  carries a `Spec overview:` link, read that spec's `_overview.md`
  and use its `review_mode`; otherwise default to `false`,
  preserving today's behaviour for one-off `tk` tickets. RALPH.md
  itself stays protocol-only and carries no per-project flag, so it
  remains safe to treat as effectively immutable.

- **URL-based external-reference convention.** A ticket's
  external-ref is the URL of the upstream review artifact (e.g.,
  `https://github.com/user/repo/pull/123`). No custom prefix scheme.
  No project-level backend hint. The agent uses common knowledge to
  map host → tool and reads the host either from the URL or from
  `git remote -v`. The protocol assumes git as the VCS, notes the
  assumption, and explicitly states that RALPH does *not* open the
  upstream artifact — humans do.

- **Conditional End-of-Session Gate.** When the ticket's linked
  spec resolves to `review_mode: true`, work done on the ticket
  results in: tag `awaiting-review` added, upstream-artifact
  discovery attempted for the current branch, and external-ref set
  to the discovered URL when found. The ticket is left
  `in_progress`. If no upstream is discoverable at end-of-session,
  the agent escalates per the escalation rule below. When the
  ticket has no spec link or the linked spec resolves to
  `review_mode: false`, the gate behaves identically to today.

- **External Review Sweep** added to the PM role. The sweep is
  tag-driven, not flag-driven: it iterates every ticket carrying
  the `awaiting-review` tag, regardless of any spec's current
  `review_mode` value. A project with no opted-in specs has nothing
  to sweep, so the sweep is a silent no-op. For each tagged ticket,
  the agent handles it by external-ref state:
  - **Empty external-ref**: re-attempt upstream discovery for the
    ticket's branch (recoverable from the branch note recorded by
    the gate). If still not found after a reasonable retry window,
    escalate.
  - **Set external-ref**: append every review comment newer than
    the timestamp of the latest existing note as a new ticket note
    (append-only, never mutates prior notes — this rules out races
    with a concurrent implementer role). On observed merge: remove
    `awaiting-review` and close the ticket. On observed
    close-without-merge: escalate.
  - **Inaccessible upstream**: escalate. Never silently close.

- **Escalation rule (existing primitives only).** When the agent
  escalates, it: (a) appends a structured note to the ticket
  describing what failed and what the agent expects from the human;
  (b) tags the ticket `needs-human`; (c) creates `.ralph-stop` so
  the loop halts at the end of the current cycle. At the session's
  close, the agent's final output names how the human can review
  the escalations (e.g., "Escalations occurred — run
  `tk ls --tags needs-human` to triage"). The escalation rule is
  described once in RALPH.md and referenced from every escalation
  site. The tags `awaiting-review` and `needs-human` are documented
  in RALPH.md as reserved by review-mode so other features know
  not to reuse them.

- **Pinned `tk` mutation mechanism.** `tk` exposes `--external-ref`
  and `--tags` only at create time, and `tk edit` opens `$EDITOR`
  (unsuited to autonomous agents). The protocol therefore directs
  the agent to edit ticket markdown directly under
  `.tickets/<id>.md`, naming the frontmatter fields the agent is
  allowed to set (`external-ref`, `tags`) and pointing to existing
  tickets in the repo as the schema reference.

- **Self-evident `tk show <id>` view.** A fresh Claude session
  reading `tk show` on an `awaiting-review` ticket can name the
  ticket's state, the upstream URL (if any), and the next step from
  the artifact alone, without consulting RALPH.md or any external
  service. The protocol prose calls this requirement out so a
  reviewer can verify it against a sample ticket walkthrough.

- **`/spec` discoverability hook.** During the Describe phase of
  `/spec` (after the spec directory exists), the skill prompts the
  operator once: "Will this spec's work go through external code
  review (PRs/MRs)?" The answer stamps `review_mode: true` or
  `review_mode: false` into the new `_overview.md` frontmatter. The
  prompt is unconditional during new-spec creation: no session
  sentinel, no global config to check, no in-flight-work
  consideration, because the decision is local to the spec being
  authored. On resume of an existing spec, the prompt is skipped;
  the operator edits `_overview.md` directly if they change their
  mind.

- **Pair documentation in the Socrates source repo.** The Socrates
  project's own `docs/workflow.md` and `docs/customization.md`
  describe review-mode for Socrates users reading the project's
  documentation. They link to RALPH.md as the authoritative
  protocol description and do not duplicate its content. No
  documentation is generated into target projects. The Socrates
  project's README is reviewed; if its high-level pitch references
  ticket lifecycle, it accommodates review-mode honestly.

- **Install-path divergence acknowledged.** Nix-installed target
  projects propagate the new RALPH.md protocol behaviours
  automatically; `/init`-installed projects do not. The spec defers
  the upgrade-flow design to the gap recorded at
  `docs/gaps/socrates-upgrade-flow.md`. Until that follow-up lands,
  operators on the `/init` path must re-run `/init` to pick up the
  updated RALPH.md; existing specs are unaffected because the
  `review_mode` field is opt-in (a missing field reads as `false`).
  The user-facing docs name the divergence explicitly so it is not
  silent.

Validation evidence: as part of landing this task, the implementer
runs candidate commands against real upstream artifacts on at least
two distinct hosting services. Caveats discovered (auth
requirements, rate limits, missing operations, unusual host quirks)
are folded directly into the protocol prose where relevant — no
separate spike artifact is produced.

## Verification

- The spec `_overview.md` template at
  `plugins/socrates/templates/_overview.md` carries `review_mode:
  false` in its frontmatter. RALPH.md describes how the agent
  resolves a ticket's effective `review_mode`: read the linked
  spec's `_overview.md` if a `Spec overview:` line exists in the
  ticket body, otherwise treat as `false`. Missing fields are
  treated as `false`.
- RALPH.md contains a section that defines the URL convention and
  enumerates the agent operations (list new comments, detect merge,
  discover for branch, handle missing upstream) without naming any
  host. The "RALPH does not open upstream artifacts" rule is
  explicit.
- The End-of-Session Gate text branches on the linked spec's
  `review_mode`. The off-branch is byte-equivalent in observable
  behaviour to today's protocol. The on-branch instructs: tag
  `awaiting-review`, attempt discovery, set external-ref or
  escalate, leave the ticket `in_progress`. The branch never opens
  the upstream artifact.
- The escalation rule is described once in RALPH.md and referenced
  from every escalation site. It uses existing primitives only:
  structured note + `needs-human` tag + `.ralph-stop` + a
  session-end reminder line in the agent's output.
- The PM role's External Review Sweep is fully described. It is
  tag-driven (iterates `awaiting-review`-tagged tickets) and runs
  unconditionally — a no-op when no tickets carry the tag. Every
  state (empty external-ref, set external-ref, inaccessible
  upstream, close-without-merge) has a defined agent action that
  uses the escalation rule where applicable. The sweep is
  documented as append-only on ticket notes and the no-op case
  (no new comments, not merged) produces no churn.
- RALPH.md documents `awaiting-review` and `needs-human` as
  review-mode-reserved tags so other features know not to reuse
  them.
- The `tk` mutation mechanism is pinned: the protocol says agents
  edit ticket markdown directly under `.tickets/`, lists the
  permitted frontmatter fields, and points to existing tickets as
  the schema source.
- A walkthrough section in the protocol or its docs demonstrates
  `tk show` on a hypothetical `awaiting-review` ticket and shows
  it is self-evident.
- The `/spec` discoverability hook is implemented in
  `plugins/socrates/commands/socrates-spec.md`. During new-spec
  creation, the skill asks the operator once whether the spec opts
  into review mode and stamps the answer into `_overview.md`. On
  resume of an existing spec, the prompt is skipped.
- The Socrates project's own `docs/workflow.md` and
  `docs/customization.md` cover review-mode in user-facing terms,
  link to RALPH.md, and do not restate it. No documentation is
  generated into target projects. The user-facing docs name the
  install-path divergence and point to
  `docs/gaps/socrates-upgrade-flow.md`.
- `docs/gaps/socrates-upgrade-flow.md` exists and describes the
  install-path divergence as a deferred concern. T1's outcome and
  the user-facing docs reference it.
- The protocol prose embeds the validation evidence captured
  during implementation (commands, sample output excerpts,
  caveats) so a future reader can reproduce the operations.

**Negative tests (gate rejection verification):**

- A ticket whose linked spec has `review_mode: false` is closed at
  work-done exactly as today; no `awaiting-review` tag is set, no
  external-ref is queried, no PM sweep action is taken.
- A ticket with no `Spec overview:` link in its body defaults to
  off and behaves identically to today.
- A ticket tagged `awaiting-review` with an inaccessible upstream
  (e.g., 404 URL, missing credentials) triggers escalation rather
  than silent closure. Confirm the `needs-human` tag is set and
  `.ralph-stop` is created.
- A ticket tagged `awaiting-review` whose upstream is closed
  without merge triggers escalation. Confirm the agent does not
  close the ticket as "done".

