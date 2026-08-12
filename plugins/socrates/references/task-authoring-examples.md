# Task Authoring: Worked Examples

Bad-versus-good pairs for the checks in
[task-authoring.md](task-authoring.md). Each example is drawn from a real
socrates task and rewritten to pass the check it illustrates.

## Outcome-first title (check 2)

A title should make the task list readable as a set of results. Avoid both code
mechanisms and dramatic restatements of the diagnosis.

| Avoid | Prefer |
| --- | --- |
| Stop auto-triggering the airproject pipeline on push | Bootstrap clusters from current CD Configs |
| Shipping the controller image auto-activates fanout on every production principal | Let projects opt into setup ApplicationSet fanout |
| Guard setup Application pruning against live namespaces | Preserve live namespaces when removing a cluster |
| Maintain a setup ApplicationSet from discovered and explicit destinations | Bootstrap discovered and declared destinations |
| Add the AirProjectPlacement resource as the static-placement input | Let projects declare static cluster placement |

The title names the capability or end state. Scope and Outcome carry the chosen
mechanism and its rationale.

## Done is distinct from tested (check 8)

A task whose Outcome and Verification say the same thing has written one
section twice. The Outcome describes behavior; the Verification describes an
observable artifact.

**Bad** — the done-statement and the test are the same sentence:

> Outcome: A go/no-go record exists: if the agent does not deliver the
> Application, the approach stops here.
>
> Verification: A written finding states whether agent delivery works.

**Good** — behavior versus observation:

> Outcome: The opt-out path tears down the setup ApplicationSet on the next
> reconcile, so a disabled project generates no setup Applications.
>
> Verification: After removing the flag, the ApplicationSet is absent and the
> AirProject no longer advertises `ApplicationSetReconciled`.

## Explicit dependencies (check 5)

A task that assumes another's output without declaring the edge is the hardest
kind to schedule. The edge belongs in `deps:`; the body says why it matters.

**Bad** — the setup ApplicationSet appears with no origin, and `deps:` is empty:

> deps: []
>
> The setup ApplicationSet carries `preserveResourcesOnDeletion: true`...

The reader can't tell which task creates the ApplicationSet this one guards, and
no parser can schedule the two in order.

**Good** — the edge is in frontmatter, and the body explains it:

> deps: [aa66-maintain-applicationset]
>
> The setup ApplicationSet this guards is created by `aa66`. This task adds
> `preserveResourcesOnDeletion: true` to it so removing a cluster never deletes
> a namespace that still holds workloads.

## One deliverable per task (check 4)

When a task bundles separable work, no one can estimate it and its Verification
reads as several tickets at once.

**Bad** — one task carrying four deliverables:

> A handoff strategy is chosen. The two open assumptions are resolved by
> observe-only spikes. One pilot project is migrated. The migration is captured
> as a repeatable runbook.

**Good** — split on the seams (the second task carries the first in `deps:`):

- *Task A:* Choose the ownership-handoff strategy and validate its two
  assumptions with observe-only spikes.
- *Task B (`deps: [<A>]`):* Migrate the pilot project and capture the migration
  as a runbook.

A related case is the unresolved load-bearing question. Rather than leave it
inline —

> ...must emit a pipeline trigger referencing the CD Configs pipeline. The
> reference the trigger needs — whether that pipeline is per-tenant or shared —
> is the open implementation question the task must resolve.

— pull it into Open decisions or a spike task, so the implementer isn't blocked
mid-task by a question the ticket never answers.

## Verification that checks facts, not vibes (check 3)

**Bad:**

> The controller reconciles the ApplicationSet correctly.

**Good:**

> Two projects on one principal, one opted in and one not: the setup
> ApplicationSet is present for the first and absent for the second. The
> generated Applications target exactly those clusters by name, with no
> `ignore-sync` label.

## Surfacing the rejected alternative (check 9)

A design choice stated without its alternative reads as an assumption. Both
belong in `## Scope`, next to each other.

**Bad** — the choice is asserted:

> A namespaced AirProjectPlacement resource exists, matched 1:1 to an AirProject
> by name.

**Good** — the alternative and its reason are visible:

> Placement is a namespaced AirProjectPlacement CR, not a field on the
> AirProject spec, because it is authored externally (by the CLI or an operator)
> rather than owned by the controller, and a separate object keeps that
> ownership boundary clean.
