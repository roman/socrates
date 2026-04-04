# ADR-001: tk over Beads as Task Backend

**Date**: 2026-04-04
**Status**: Accepted

## Context

choo-choo-ralph used Beads (a git-backed task tracker with SQLite + JSONL layer) for
task management. Beads' SQLite-to-JSONL migration introduced silent write bugs: `bd close`
exits 0 but the file on disk does not change. This silently breaks the entire git-native
sync promise and caused real data loss during autonomous sessions in sandboxed VMs.

## Decision

Replace Beads with `tk` — a ~1,400-line bash script that stores markdown files with YAML
frontmatter directly in `.tickets/`. No SQLite, no daemon, no JSONL sync layer.

## Consequences

**Gained:**
- No silent write bugs. Files are the source of truth. Git diff shows exactly what changed.
- No daemon to manage or sandbox-expose.
- Simple to Nix-package (single script + jq).
- Dependency graph support via `tk dep`, `tk ready`, `tk blocked`.

**Lost:**
- No dependency graph visualization beyond `tk dep tree`.
- No molecule templates or formula expansion.
- No multi-format export.
- Unproven under machine-speed concurrent access (spike required).

**Accepted tradeoff:** We need create, query, and close. tk does all three reliably.
Visualization and templating are out of scope for v1.
