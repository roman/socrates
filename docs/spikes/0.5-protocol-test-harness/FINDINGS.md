# Spike 0.5 — Protocol Test Harness Findings

**Date**: 2026-04-04
**Result**: All three components work. Harness caught real pre-existing issues.

## Component 1: Hook-based Sequence Logging

Works as designed. Key details:

- **Hook input**: JSON on stdin with `session_id`, `hook_event_name`,
  `tool_name`, `tool_input`, and (for PostToolUse) `tool_response`
- **Configuration**: `.claude/settings.json` with `hooks.PreToolUse` and
  `hooks.PostToolUse` arrays
- **Non-blocking**: exit 0 = proceed, exit 2 = block. Logging hooks
  always exit 0.
- **Output**: JSONL file per session at `.claude/protocol-logs/{session_id}.jsonl`
- **Enrichment**: jq adds `ts` (ISO timestamp) to each entry
- **Other useful hooks**: `SessionStart`, `Stop`, `UserPromptSubmit`,
  `PostToolUseFailure` — can add these later for richer traces

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

Correctly passes on good ordering, correctly fails on bad ordering.
Pattern matching uses grep on `tool_name` + `file_path` from JSONL entries.

## Integration Notes

- Hook script and settings go in `.claude/` (project-scoped)
- Assertion scripts run post-session, outside Claude
- No LLM in the assertion loop — pure grep/jq/git
- Sequence assertions depend on hook log; artifact assertions are standalone
