---
id: 1-15a1-rewrite-sizing-and-rename-tags
status: poured
priority: 0
category: functional
ticket: soc-r1m5
---

# Rewrite sizing guidance and rename task body tags

<outcome>
The `/spec` Design phase sizes tasks as outcome slices rather than
commit-shaped procedures. Authoring guidance steers toward stating
what the implementer must achieve and how to verify it — concrete
file-path grounding stays in the overview's Context section, not in
task bodies.

The task template uses `<outcome>` and `<verification>` tags instead
of `<steps>` and `<test_steps>`. Pour extracts content from the new
tags and writes `## Outcome` and `## Verification` headings into tk
ticket descriptions. The `/spec` Task Review Mode references the new
tag names when regenerating content from review feedback.

`docs/spec-format.md` and `docs/customization.md` reflect the new
sizing rule and tag names.
</outcome>

<verification>
- The sizing rule in spec.md no longer references "one focused commit"
- Task authoring guidance no longer tells authors to put file paths
  or function names inside task body tags
- task.md template contains `<outcome>`, `<verification>`, `<review>`
- pour.md extracts from `<outcome>` and `<verification>`, writes
  `## Outcome` and `## Verification` into tk tickets
- spec.md Task Review Mode references the new tag names
- spec-format.md and customization.md document the new tags and
  sizing rule
- No references to `<steps>` or `<test_steps>` remain in command,
  template, or documentation files
</verification>

<review></review>
