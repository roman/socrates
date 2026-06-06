---
id: 7-4919-remove-pour-reconcile-authoring
status: draft
priority: 3
category: functional
ticket: null
---

# Remove pour and reconcile spec and init authoring

## Outcomes

- The `/pour` command is removed: its command file is deleted and every
  reference to it across the plugin (command docs, the commands index,
  `/init` output, spec-format documentation) is removed or rewritten.
- The `/spec` Design phase stops writing the prose `Shared Surfaces`
  edge representation as the dependency source of truth and instead has
  tasks declare edges in frontmatter per the new schema. Any guidance
  describing `/pour` as the promotion step is removed.
- The completion anchor changes: nothing writes an `epic:` field, and
  the surfaces that read it (covered in the protocols task) no longer
  expect it. The `epic:` field is removed from the overview template.
- `/init` no longer creates the `.tickets/` directory or installs tk as
  part of a working setup, and its verification report reflects the
  unified lifecycle. (The actual tk package removal is a separate task;
  this task stops `/init` from depending on it.)
- The `spec` CLI `status` output drops the `poured` count and reflects
  the `draft / approved / closed` lifecycle.

## Verification

- No file in the plugin references the `/pour` command as an operative
  step.
- A spec authored through `/spec` expresses task dependencies in
  frontmatter, and the Design phase guidance no longer presents
  `Shared Surfaces` prose as the machine-read edge source.
- The overview template carries no `epic:` field, and `/init` output
  describes the unified lifecycle without `.tickets/` or `/pour`.
- `spec status` reports task counts using the `draft / approved /
  closed` vocabulary with no `poured` bucket.

<review></review>
