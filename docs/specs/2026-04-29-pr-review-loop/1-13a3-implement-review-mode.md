---
id: 1-13a3-implement-review-mode
status: draft
priority: 0
category: functional
ticket: null
revisions: 1
---

# Implement review-mode behaviour in RALPH.md and pair docs

<outcome>
Target projects that set `review_mode: true` in RALPH.md frontmatter
run RALPH end-to-end through external review and merge without
manual session orchestration; projects that leave it `false` (or
absent) behave exactly as today. The protocol change lands as a
single coherent edit to `plugins/socrates/templates/RALPH.md`, the
matching user-facing notes in `docs/workflow.md` and
`docs/customization.md`, and a small discoverability hook in
`plugins/socrates/commands/spec.md`.

Concretely the protocol gains:

- **Frontmatter flag.** A `review_mode: false` field in RALPH.md
  frontmatter, default `false`, missing-field treated as `false`.
  The Startup Checklist names how the agent reads it and what
  conditional behaviours it gates. Existing target projects whose
  RALPH.md predates this change are unaffected.

- **URL-based external-reference convention.** A ticket's
  external-ref is the URL of the upstream review artifact (e.g.,
  `https://github.com/user/repo/pull/123`). No custom prefix scheme.
  No project-level backend hint. The agent uses common knowledge to
  map host → tool and reads the host either from the URL or from
  `git remote -v`. The protocol assumes git as the VCS, notes the
  assumption, and explicitly states that RALPH does *not* open the
  upstream artifact — humans do.

- **Conditional End-of-Session Gate.** When `review_mode` is on,
  work done on a ticket results in: tag `awaiting-review` added,
  upstream-artifact discovery attempted for the current branch, and
  external-ref set to the discovered URL when found. The ticket is
  left `in_progress`. If no upstream is discoverable at
  end-of-session, the agent escalates per the escalation rule
  below. When `review_mode` is off, the gate behaves identically to
  today.

- **External Review Sweep** added to the PM role, gated on
  `review_mode`. The sweep iterates `awaiting-review`-tagged
  tickets and handles each by external-ref state:
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

  When `review_mode` is flipped from on to off mid-stream, any
  tickets still tagged `awaiting-review` are escalated on the next
  PM cycle so they are never silently stranded.

- **Escalation rule (existing primitives only).** When the agent
  escalates, it: (a) appends a structured note to the ticket
  describing what failed and what the agent expects from the human;
  (b) tags the ticket `needs-human`; (c) creates `.ralph-stop` so
  the loop halts at the end of the current cycle. At the session's
  close, the agent's final output names how the human can review
  the escalations (e.g., "Escalations occurred — run
  `tk ls --tags needs-human` to triage"). No new protocol surface:
  `.msgs/` is unchanged, and the existing `.ralph-stop` mechanism
  is reused. The escalation rule is described once in RALPH.md and
  referenced from every escalation site.

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

- **`/spec` discoverability hook.** When `/spec` is invoked, the
  skill checks three conditions: `review_mode` is `false` or absent
  in RALPH.md frontmatter; the user has not been informed during
  this session (a session sentinel records the "asked already"
  state); and there are no tickets in `.tickets/` (no work in
  flight). When all three hold, the skill prompts the user once
  with three options — *enable now* (which flips RALPH.md
  frontmatter to `true`), *not now*, or *don't ask again this
  session* — before proceeding with the Design in Practice journey.
  When any condition is false, the prompt is skipped silently. This
  makes review-mode discoverable at the moment the operator is
  thinking about lifecycle, without burdening `/init` or
  interrupting in-flight work. The exact session-sentinel mechanism
  (env var, `/tmp` file, etc.) is pinned during implementation.

- **Pair documentation.** `docs/workflow.md` and
  `docs/customization.md` describe review-mode for end users, link
  to RALPH.md as the authoritative protocol description, and do not
  duplicate its content. README is reviewed; if its high-level
  pitch references ticket lifecycle, it accommodates review-mode
  honestly.

- **Install-path divergence acknowledged.** Nix-installed target
  projects propagate this protocol change automatically;
  `/init`-installed projects do not. The spec defers the
  upgrade-flow design to the gap recorded at
  `docs/gaps/socrates-upgrade-flow.md`. Until that follow-up lands,
  operators on the `/init` path must re-run `/init` or manually
  patch RALPH.md frontmatter; the user-facing docs name this
  explicitly so the divergence is not silent.

Validation evidence: as part of landing this task, the implementer
runs candidate commands against real upstream artifacts on at least
two distinct hosting services. Caveats discovered (auth
requirements, rate limits, missing operations, unusual host quirks)
are folded directly into the protocol prose where relevant — no
separate spike artifact is produced.
</outcome>

<verification>
- `RALPH.md` template starts with a frontmatter block defining
  `review_mode: false`. The Startup Checklist instructs the agent
  to read this flag and explains the missing-field-as-false
  default.
- The protocol contains a section that defines the URL convention
  and enumerates the agent operations (list new comments, detect
  merge, discover for branch, handle missing upstream) without
  naming any host. The "RALPH does not open upstream artifacts"
  rule is explicit.
- The End-of-Session Gate text branches on `review_mode`. The
  off-branch is byte-equivalent in observable behaviour to today's
  protocol. The on-branch instructs: tag `awaiting-review`, attempt
  discovery, set external-ref or escalate, leave the ticket
  `in_progress`. The branch never opens the upstream artifact.
- The escalation rule is described once in RALPH.md and referenced
  from every escalation site. It uses existing primitives only:
  structured note + `needs-human` tag + `.ralph-stop` + a
  session-end reminder line in the agent's output. The `.msgs/`
  mechanism is unchanged.
- The PM role's External Review Sweep is fully described. Every
  state (empty external-ref, set external-ref, inaccessible
  upstream, close-without-merge, mid-stream toggle) has a defined
  agent action that uses the escalation rule where applicable.
  The sweep is documented as append-only on ticket notes and the
  no-op case (no new comments, not merged) produces no churn.
- The `tk` mutation mechanism is pinned: the protocol says agents
  edit ticket markdown directly under `.tickets/`, lists the
  permitted frontmatter fields, and points to existing tickets as
  the schema source.
- A walkthrough section in the protocol or its docs demonstrates
  `tk show` on a hypothetical `awaiting-review` ticket and shows
  it is self-evident.
- The `/spec` discoverability hook is implemented in
  `plugins/socrates/commands/spec.md`. The check covers all three
  conditions (review_mode false/absent, session-sentinel absent,
  no tickets in flight). The session-sentinel mechanism is pinned.
  The prompt offers three options. The "enable now" path writes
  RALPH.md frontmatter idempotently. When any condition is false
  the prompt is skipped silently.
- `docs/workflow.md` and `docs/customization.md` cover review-mode
  in user-facing terms, link to RALPH.md, and do not restate it.
  The user-facing docs name the install-path divergence and point
  to `docs/gaps/socrates-upgrade-flow.md`.
- `docs/gaps/socrates-upgrade-flow.md` exists and describes the
  install-path divergence as a deferred concern. T1's outcome and
  the user-facing docs reference it.
- The protocol prose embeds the validation evidence captured
  during implementation (commands, sample output excerpts,
  caveats) so a future reader can reproduce the operations.
</verification>

<review></review>
