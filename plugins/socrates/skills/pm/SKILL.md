---
name: pm
description: Wear the project-manager hat — triage review comments, reconcile task states, sweep specs through their lifecycle, and keep working-notes folders consistent. Use when spec tasks need triage, task states have drifted, specs may have completed, or a notes folder (learnings/gaps/specs) needs an audit for consistency.
---

# pm — project-manager hat

The PM role keeps a project's tracked work honest: it does not implement
features, it reconciles state and surfaces what needs a human decision. Wear it
for one cycle at a time, and finish the cycle before switching to another role.

Pick this role when:

- Pending review comments on spec tasks need triage.
- Task states have drifted (stale `in_progress`, missing deps).
- New work needs scoping but no spec exists yet.
- Specs may have completed since the last PM cycle.
- There is no obvious implementation work — default to PM and verify everything
  is consistent before concluding there is nothing to do.

## PM actions

1. **Triage review comments** on spec tasks; route each to the task it concerns.
2. **Reconcile task states** — close what's done, correct stale `in_progress`,
   flag missing or broken dependencies.
3. **Run the Spec Lifecycle sweep** (below).
4. **Audit working-notes folders** for consistency against the format contract
   (the `spec-format` skill): flat gaps, conforming learning frontmatter, an
   index in sync with its files.
5. **Surface, don't guess** — when scoping or a tradeoff needs a human, say so
   rather than best-effort past it.

## Spec Lifecycle sweep

Cheap and idempotent; run it every PM cycle.

1. **Detect completed specs.** For each spec directory (excluding the archive):
   read `_overview.md`; if it has task files and every task's `status` is
   `closed` or `cancelled`, the spec is complete.
2. **Archive completed specs.** Stamp `_overview.md` frontmatter with
   `archived: YYYY-MM-DD` and `git mv` the directory into the archive. Git
   history preserves everything; note the archival in the session handoff.

## Autonomous vs interactive

Standalone (interactive, a human in the chat), the PM actions above are the
whole job: triage, reconcile, sweep, audit, and ask when a decision is needed.

Inside the autonomous RALPH loop, the PM role additionally runs the External
Review sweep and uses the `.msgs/` inbox and `.ralph-stop` exit. The full
autonomous protocol — role triage, the review sweep, escalation, and the
end-of-session gate — is in
[`../../references/ralph-protocol.md`](../../references/ralph-protocol.md). Read
it when operating the loop; ignore it for interactive PM work.
