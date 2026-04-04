# Handoff: Socrates Project Genesis

**Date**: 2026-04-04

## What Was Done

Designed and documented Socrates — a Claude Code plugin for structured design and
autonomous development. This was a full design session starting from pain points with
choo-choo-ralph and project-status-sync, converging on a hybrid approach.

### Artifacts Created

- **WORKPLAN.md** — 9-phase implementation plan with ~45 chunks, appendices for
  `_overview.md` and task file templates, provenance table
- **RATIONALE.md** — project rationale, goals, tradeoffs (simplicity vs flexibility,
  convention vs automation, guided process vs speed), explicit non-goals
- **docs/architecture.md** — workflow overview, component descriptions, file layout
- **docs/adrs/** — 3 architectural decision records:
  - 001: tk over beads (silent write bugs, simplicity)
  - 002: RALPH.md protocol over per-ticket formulas (protocol as reference)
  - 003: /spec + /design merged into one command (Design in Practice journey)
- **Obsidian vault docs** at `01 Projects/Personal/socrates/` — mirrors of the above

### Key Decisions

1. **tk as task backend** replacing beads — bash+jq, no database, no daemon
2. **4 commands** not 6: `/init`, `/spec`, `/pour`, `/harvest`
3. **`/spec` covers full D1-D5** (Describe→Design) with phase markers and resume
4. **Strict Delimit gate** — `delimit_approved: true` in frontmatter, AI won't proceed
5. **File-per-task** with overview — incremental review, `draft→approved→poured` lifecycle
6. **Spec files frozen after pour** — write-once artifacts, mutable state in `.tickets/`
7. **Task-type-adaptive protocol** — feature/docs/infra/bug get different ceremony
8. **PR comments go on tk tickets** — no separate review file pipeline
9. **Warning commit hook** for `Refs:` — noisy degradation, not silent
10. **No progress.log** — handoffs are the durable artifact (tradeoff: no real-time monitoring)
11. **`docs/` not `notes/`** for handoffs, specs, and reviews

### Code-Critic Review

Ran an opus-level code-critic review that surfaced 17 findings. Major ones addressed:
- Merged `/design` into `/spec` (artificial seam, cargo-culting Hickey's Design phase)
- Added `depends_on: []` to task file schema
- Defined `_overview.md` schema with phase markers
- Specified resume state machine (going back preserves content under "Previous")
- Added concurrent access stress test to spike 0.1
- Made convention degradation explicit in RATIONALE (silent vs noisy)

## What's Next

- **Phase 0 spikes** — validate tk reliability, dependency support, gh API metadata,
  Nix packaging. These gate all subsequent work.
- After spikes: Phase 1 (scaffold) and Phase 2 (shell scripts) can proceed in parallel
  with Phase 4 (the `/spec` command, which is the core differentiator)
- The spec-journey skill (Phase 9.1) should be drafted early — it operationalizes the
  Design in Practice techniques into concrete AI behavior, which informs how `/spec`
  is implemented

## Learnings

- Beads' silent write bug (`bd close` exits 0, file unchanged) was the catalyst for
  this entire redesign. Silent failures in task infrastructure undermine everything.
- The single-file spec becomes cognitively overwhelming past ~6 tasks. File-per-task
  with an overview solves this but adds filesystem overhead.
- Formula-in-every-ticket conflates "what to do" with "how to do it." Separating
  protocol from task data is a fundamental improvement.
- Rich Hickey's Design in Practice maps cleanly to an AI-guided interview. The techniques
  (Reflective Inquiry, Scientific Method, Decision Matrix) can be operationalized into
  prompt patterns.

## Gaps

- The `/spec` resume state machine needs a concrete implementation spike — the markers
  approach is specified but untested with a real LLM.
- The spec-journey skill needs to operationalize Hickey's techniques into concrete
  prompt patterns, not just name them. This is the difference between "inspired by" and
  "implements."
- No automated way to detect a missing handoff (session that started but agent didn't
  write one due to context exhaustion). PM role is expected to reconcile but has no
  signal to trigger on.
