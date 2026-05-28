# INTERACTIVE — Protocol

You are working in an interactive session. The human is in the chat and
steering. This file is your operating protocol when not running under
RALPH (autonomous loop). Read it at the start of every interactive session
before doing anything else.

The spec discipline kernel in CLAUDE.md applies (directive hierarchy:
the overview's Describe + Diagnose are the source of the durable why; the
task file's Outcome is a slice; task-ordering language is sequencing, not
why). This file covers what differs from the autonomous loop.

## Defaults that differ from RALPH

| Behavior | Default |
| --- | --- |
| Ambiguity in the why | **Pause and ask.** The human is in the chat; clarification is cheap. Do not best-effort and flag. |
| Pacing | User-paced. Present and stop. The user reviews on their own clock. |
| Approval gates | In-conversation: `AskUserQuestion` for clarifications, `ExitPlanMode` for plan approval. No `.msgs/` inbox needed. |
| Failure handling | Surface in chat, name the category (data / impl / config / prompt / criteria / approach), wait for steer. Do not retry the same failed action with tweaks. |
| Context transfer | Conversation memory carries the session. No mandatory handoff doc unless the user asks. |
| Work source | The user names the task — by spec task file path, ticket URL, or ad-hoc ask. The user is the gate. The `tk ready -a ralph` work-source rule does not apply. |

## When picking up a spec task

The user has named a task file under `docs/specs/<dir>/<n>-*.md`.

1. Read the task file's Outcome and Verification.
2. Read the spec's `_overview.md` — specifically Describe (user-facing
   pain), Diagnose (RC/NC/AC), and the section that justifies the chosen
   Direction. This is the durable why.
3. Reconstruct the directive hierarchy in your head:
   - Main directive (the user-facing why, from Describe + Diagnose).
   - Secondary directive (how this task serves the main directive).
   - Task-ordering claims (sequencing language; do not treat as why).
4. If the why isn't reconstructible from those sections, ask before
   proceeding.
5. Confirm with the user what they want next: refine the task spec, plan
   the implementation, or implement.

The `spec-read-guard.sh` `PreToolUse` hook is RALPH-only (gated on
`RALPH_SESSION=1`). In an interactive session, reading task files is
allowed — the human authorized it by naming the task.

## Phase sequence (interactive deltas)

The RALPH phase sequence (Bearings → Implement → Verify → Commit) still
applies. See `RALPH.md` for the full description. The deltas:

- **Bearings**: same as RALPH, but the user may shortcut some exploration
  by pointing you at files directly. Trust the pointer; still confirm the
  directive hierarchy before planning.
- **Implement**: do not commit until the user asks. Show diffs or the
  changed file's path so the user can review at their pace.
- **Verify**: same checks; report results in chat.
- **Commit**: only on explicit user request. Follow the project's commit
  conventions (50/72 line lengths, conventional-commits prefix, why-not-
  what message body, ticket reference if applicable).

## Plan mode

Before non-trivial implementation, enter plan mode. When in plan mode,
apply the design-in-practice rule from the user's CLAUDE.md (produce a
Decision Matrix when comparing non-trivial approaches). Exit plan mode
with `ExitPlanMode` once the user is aligned.

## What never changes between modes

- The spec discipline kernel in CLAUDE.md (directive hierarchy).
- Voice and structure conventions when authoring spec content (see
  `voice.md`).
- The rule that the spec overview is the source of why; task files are
  slices.
