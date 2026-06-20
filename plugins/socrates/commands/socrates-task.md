---
description: Entry point for interactive task work — loads the discipline kernel, interactive protocol, and named task context
---

# /socrates-task — Interactive Task Entry

Pick up a spec task for interactive work. Takes a task identity as argument (the
`<hash>-<suffix>` value from a task file's `id:` frontmatter, or the full filename).

## Spec discipline kernel

<!-- DUPLICATION NOTE: the /spec command (commands/spec.md) inlines the same
     kernel content below. If you edit this section, update the corresponding
     section in commands/spec.md as well. -->

Specs in this project carry a directive hierarchy:

- The overview's **Describe** section names the user-facing pain (the durable why).
- The overview's **Diagnose** section names the mechanism (RC/NC/AC).
- A task file's **Outcome** describes a slice of work, not the why. Task-ordering language
  ("prerequisite for X", "must land before Y") is sequencing, not why — do not anchor
  planning, code comments, or PR descriptions on it.

Before planning or implementing on a task, reconstruct the why from the overview's
Describe + Diagnose. If the why isn't reconstructible from those sections, ask before
proceeding.

Before commits on non-trivial changes: spawn the `code-critic` agent (foreground, opus
model) and address findings in at most 2 rounds.

## Interactive session protocol

You are working in an interactive session. The human is in the chat and steering.

### Defaults

| Behavior | Default |
| --- | --- |
| Ambiguity in the why | **Pause and ask.** The human is in the chat; clarification is cheap. Do not best-effort and flag. |
| Pacing | User-paced. Present and stop. The user reviews on their own clock. |
| Approval gates | In-conversation: `AskUserQuestion` for clarifications, `ExitPlanMode` for plan approval. No `.msgs/` inbox needed. |
| Failure handling | Surface in chat, name the category (data / impl / config / prompt / criteria / approach), wait for steer. Do not retry the same failed action with tweaks. |
| Context transfer | Conversation memory carries the session. No mandatory handoff doc unless the user asks. |
| Work source | The user names the task — by spec task file path or ad-hoc ask. The user is the gate. The `spec ready -a ralph` work-source rule does not apply. |

### Phase sequence (interactive deltas)

The RALPH phase sequence (Bearings -> Implement -> Verify -> Commit) still applies. The
deltas:

- **Bearings**: same as RALPH, but the user may shortcut some exploration by pointing you
  at files directly. Trust the pointer; still confirm the directive hierarchy before
  planning.
- **Implement**: do not commit until the user asks. Show diffs or the changed file's path
  so the user can review at their pace.
- **Verify**: same checks; report results in chat.
- **Commit**: only on explicit user request. Follow the project's commit conventions
  (50/72 line lengths, conventional-commits prefix, why-not-what message body,
  `Refs: <task-id>` with the identity token from the task's `id` frontmatter field).

### Plan mode

Before non-trivial implementation, enter plan mode. When in plan mode, apply the
design-in-practice rule (produce a Decision Matrix when comparing non-trivial approaches).
Exit plan mode with `ExitPlanMode` once the user is aligned.

### What never changes between modes

- The spec discipline kernel above (directive hierarchy).
- Voice and structure conventions when authoring spec content (see `voice.md`).
- The rule that the spec overview is the source of why; task files are slices.

## Task resolution

Resolve the argument to a task file:

1. Search `docs/specs/` (excluding `docs/specs/archive/`) for a file whose `id:`
   frontmatter matches the argument, or whose filename contains the argument.
2. If exactly one match: use it.
3. If multiple matches: list them and ask the user to pick.
4. If no match: surface the resolution failure — "No task file found matching `<arg>`
   under `docs/specs/`. Check the id or filename and try again." Do not silently proceed.

## On invocation

Once the task file is resolved:

1. Read the task file's **Outcomes** and **Verification**.
2. Find the task's parent spec directory and read its `_overview.md` — specifically
   **Describe** (user-facing pain), **Diagnose** (RC/NC/AC), and the section that
   justifies the chosen **Direction**. This is the durable why.
3. Reconstruct the directive hierarchy:
   - Main directive (the user-facing why, from Describe + Diagnose).
   - Secondary directive (how this task serves the main directive).
   - Task-ordering claims (sequencing language; do not treat as why).
4. If the why isn't reconstructible from those sections, ask before proceeding.

### Draft task warning

If the task's `status:` is `draft`, warn the user:

> This task's contract (Outcomes, Verification) is not frozen — it may change before
> approval. Want to proceed anyway, or refine the task first?

The warning is advisory. The user can direct you to proceed.

### Approved task contract

An `approved` task's contract (Outcomes, Verification, deps) is frozen. To change it,
reopen the task to `draft` first, then re-approve after editing. Reopening flags affected
dependents — run `spec dependents <id>` to see which tasks depend on the reopened one and
may need re-checking.

To refine a task iteratively, write feedback in the task's `<review>` block, then run
`/spec <task-file>` to regenerate Outcomes and Verification. Repeat until satisfied, then
set `status: approved`.

5. Confirm with the user what they want next: refine the task spec, plan the
   implementation, or implement.
