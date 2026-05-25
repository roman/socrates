# soc-rc5m — Review-mode protocol in RALPH.md

Implemented the review-mode protocol extension as a single coherent edit
to RALPH.md, plus pair docs and the `/spec` discoverability hook.

## Changes

### plugins/socrates/templates/RALPH.md
- Added **External Review Sweep** under PM role (parallel to Spec
  Lifecycle Sweep). Tag-driven, iterates `awaiting-review` tickets,
  handles all states (empty/set external-ref, merge, close-without-merge,
  inaccessible upstream).
- Added **Review Mode** top-level section: review-mode resolution,
  external-ref URL convention, upstream discovery, reading review
  comments, ticket mutation mechanism, escalation rule, reserved tags,
  self-evident ticket view walkthrough.
- Modified **End-of-Session Gate** step 3 (tk Updates) to branch on
  `review_mode`. Off-branch preserves today's behavior. On-branch:
  tag awaiting-review, attempt upstream discovery, set external-ref,
  leave ticket in_progress.

### plugins/socrates/commands/spec.md
- Added review-mode prompt during new-spec creation. Stamps
  `review_mode: true/false` into `_overview.md` frontmatter. Skipped
  on resume.

### docs/workflow.md, docs/customization.md, README.md
- Review-mode sections linking to RALPH.md without restating protocol.
- Install-path divergence noted, pointing to
  `docs/gaps/socrates-upgrade-flow.md`.

## Validation evidence

Tested upstream operations against github.com and gitlab.com via `curl`:
- GitHub: PR listing, branch-to-PR discovery, merge detection all work
  unauthenticated for public repos (60 req/hr limit). `gh` requires
  auth.
- GitLab: MR listing works unauthenticated. MR notes return 401
  without auth. `glab` not in default dev shell.
- Caveats folded into RALPH.md § Upstream Discovery.

## Next

- soc-6k6x (task 2): stamp `review_mode: false` into `_overview.md`
  template. Depends on this task's semantics being established.
