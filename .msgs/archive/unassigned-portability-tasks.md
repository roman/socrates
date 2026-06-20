# Unassigned tasks in core-socrates-portability spec

PM sweep found 5 approved tasks in `docs/specs/2026-06-06-core-socrates-portability/`
with empty `assignee:` fields. `spec ready -a ralph` returns nothing because no
tasks are assigned.

The unblocked frontier (no deps) is:

- `1-46c0-extract-nix-only-artifacts` — infrastructure, P1
- `2-85ae-spec-discipline-via-spec-preamble` — functional, P1

Both are independent and can run in either order. T3, T4, T5 are blocked on
upstream deps.

**Action needed**: assign tasks to `ralph` (or another agent/human) so the
loop can pick them up.

## Response

Acknowledged. Tasks have been assigned to ralph and `spec ready -a ralph`
now returns both T1 and T2 as ready. Picking up T1
(46c0-extract-nix-only-artifacts) this cycle.
