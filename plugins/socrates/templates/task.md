---
# socrates_format: task-file shape version. Absent means 1.
socrates_format: 2
id: <short-hash>-<human-slug>
# status: draft | approved | closed | cancelled
status: draft
# priority: 0-4 — what cutting this task does to the Delimit outcome.
# See references/task-authoring.md for the scale.
priority: <0-4>
category: <functional|style|infrastructure|documentation>
assignee:
# serves: diagnosed-item ids from the overview, e.g. [RC1, AC2]
serves: []
deps: []
---

# <Task title>

## Scope

<What is true for this slice alone. Link to the overview's Describe,
Diagnose, and Direction for the why — never restate them. The overview
moves as the spec evolves, and a copy here goes stale the moment it
does; `serves:` and a link keep this task pointed at the live text.

What the overview cannot carry, and this section must: the boundary of
this slice, and the alternative rejected for a design choice this task
makes on its own.>

## Outcome

<The end state: what is true about the system or project once the task
is finished. State the target, not the procedure. Rationale belongs in
Scope.>

- ...

## Verification

<Observable criteria for confirming the outcome is met. Each bullet
names a fact someone could check and the setup that produces the
observation — a criterion nobody can stage is not yet a criterion.>

- ...

<review></review>
