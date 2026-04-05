# Spike 0.5 — Protocol Test Harness Findings

**Date**: 2026-04-04
**Result**: All three components work. Full pipeline validated against
real Claude Code hook data.

## Component 1: Hook-based Sequence Logging

Works as designed. Key details:

- **Hook input**: JSON on stdin with `session_id`, `hook_event_name`,
  `tool_name`, `tool_input`, and (for PostToolUse) `tool_response`
- **Configuration**: `.claude/settings.local.json` with `hooks.PreToolUse`
  and `hooks.PostToolUse` arrays
- **Non-blocking**: exit 0 = proceed, exit 2 = block. Logging hooks
  always exit 0.
- **Output**: JSONL file per session at `.claude/protocol-logs/{session_id}.jsonl`
- **Enrichment**: jq adds `ts` (ISO timestamp) to each entry
- **Other useful hooks**: `SessionStart`, `Stop`, `UserPromptSubmit`,
  `PostToolUseFailure` — can add these later for richer traces

## Real Hook Data Validation

Configured hooks on this repo, ran a real Claude session, captured 10
events (Bash, Read, Write tool calls). Confirmed:

| Field | Assumed | Actual | Match? |
|-------|---------|--------|--------|
| `.tool_name` | `"Read"`, `"Edit"`, `"Bash"`, etc. | `"Bash"`, `"Read"`, `"Write"` | Yes |
| `.tool_input.file_path` | present on Read/Edit/Write | present, absolute paths | Yes |
| `.tool_input.command` | present on Bash | present | Yes |
| `.hook_event_name` | `"PreToolUse"` / `"PostToolUse"` | exact match | Yes |
| `.session_id` | UUID string | `"43ecc4c8-..."` | Yes |
| `.tool_response` | only on PostToolUse | confirmed | Yes |
| `.tool_input.pattern` | present on Grep/Glob | not tested (no Grep in session) | TBD |

Key detail: **file paths are absolute** (`/home/user/project/docs/handoffs/...`),
not relative. Our grep-based assertions match substrings so this works, but
worth noting for any future exact-match logic.

## Component 2: Artifact Assertion Script

Works. Caught real issues in the repo:

- 3 ADRs missing `## Status` section (format not enforced before now)
- Genesis handoff missing HHmm in filename (`2026-04-04-project-genesis.md`)
- 3 early commits missing `Refs:` line (before convention was established)

These are expected — the harness validates going forward, not retroactively.

Commit message parsing: must iterate by SHA and check full message body,
not split `%B` output by blank lines (multi-paragraph messages break that).

## Component 3: Sequence Assertion Script

Works. Five invariants implemented:

1. Read RALPH.md before any Edit
2. Read handoffs before Edit src/
3. tk ready before tk start
4. Handoff file written during session
5. ADR file written when docs/adrs/ was modified

Tested three ways:
- Synthetic "good" log → all pass
- Synthetic "bad" log → correctly fails on ordering violations
- **Real Claude hook data** → correctly passes 4, correctly fails 1
  (no handoff in a trivial test session)

## Integration Notes

- Hook script and settings go in `.claude/` (project-scoped)
- Use `settings.local.json` to keep hooks out of git
- Assertion scripts run post-session, outside Claude
- No LLM in the assertion loop — pure grep/jq/git
- Sequence assertions depend on hook log; artifact assertions are standalone
