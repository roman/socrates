---
id: 3-1ea5-extend-cli-frontier-queries
status: draft
priority: 1
category: functional
ticket: null
---

# Extend the spec CLI with frontier and dependent queries

## Outcomes

- The in-repo `spec` CLI gains a `ready` subcommand that computes the
  unblocked frontier from the spec directory: it reads task `status`,
  frontmatter dependency edges, and `assignee`, topologically orders the
  tasks, and emits those that are `approved`, unblocked by any
  incomplete dependency, and assigned to the requested assignee.
- The CLI gains a `dependents` query that, given a task id, reports the
  tasks whose edges point at it. This is the read-only query the reopen
  path consults to flag work affected by a contract change.
- A dependency cycle is reported as an error naming the tasks in the
  cycle, rather than producing an arbitrary order.
- The CLI stays read-only and re-derives state from the filesystem on
  every invocation, consistent with its existing charter. It does not
  mutate task files.
- The CLI's test suite covers frontier computation (status filter,
  assignee filter, dependency blocking, topological order), the
  dependents query, and cycle detection.

## Verification

- `spec ready -a <assignee>` against a fixture spec emits exactly the
  tasks that are approved, unblocked, and assigned to that assignee, in
  dependency order.
- A task whose dependency is not yet closed does not appear in the
  `ready` output; once the dependency closes, it does.
- `spec dependents <task-id>` lists every task whose frontmatter edges
  reference the given task, and nothing else.
- A fixture containing a dependency cycle causes the frontier query to
  exit non-zero with a message naming the cycle members.
- The test suite exercises all of the above and passes.

<review></review>
