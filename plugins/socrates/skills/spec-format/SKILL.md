---
name: spec-format
description: The format contract for socrates working-notes folders — specs, gaps, learnings, and handoffs. Use when creating or editing any of those artifacts, or when another repo asks you to follow the socrates conventions, so structure and frontmatter stay consistent without hardcoding a filesystem path.
---

# spec-format — working-notes format contract

Socrates organizes durable working notes into four folders, each with a
distinct altitude. This skill is the discoverable handle for their format: a
repo that adopts socrates references `socrates:spec-format` by name rather than
pointing at a file path.

The authoritative, detailed format for specs lives in
[`../../references/spec-format.md`](../../references/spec-format.md). Read it
before authoring a spec. This skill summarizes the folder contracts and the
routing rule between them.

## Where each note belongs

- **`specs/`** — a designed unit of work. One directory per spec
  (`specs/<YYYY-MM-DD-slug>/`) with an `_overview.md` carrying the
  Describe → Diagnose → Delimit → Direction → Design journey, plus per-task
  files. Full format in the reference above.
- **`gaps/`** — a known deficiency surfaced by other work but out of scope to
  fix now. One flat `.md` per gap (never a subdirectory; supporting scripts go
  under the originating spec). Frontmatter: `title`, `created`, `discovered_in`;
  optional `upstream`, `component`. Body: `## Gap` and `## Why it matters`, plus
  `## Stopgap` / `## Suggested resolution` when known.
- **`learnings/`** — a durable, reusable fact about how a system behaves. One
  file per topic, filename = the claim (kebab-case, subject-first, no dates or
  ticket numbers). Frontmatter: `name` (one-sentence claim), `description`
  (one-sentence recall hook, under 200 chars), `type` (`technical` | `project` |
  `workflow`). The body's H1 restates the claim. Each `learnings/` directory
  carries a `MEMORY.md` index generated from frontmatter:
  `- [name](file.md) — description`, one line each, grouped by `type`.
- **`handoffs/`** — chronological session narrative so the next session resumes
  without re-reading the transcript. Named `YYYY-MM-DD-HHmm-<topic>.md`.

## Routing rule

When a note doesn't obviously fit, route by altitude:

- A durable fact that stays true across sessions → `learnings/`.
- An open action or unresolved deficiency → `gaps/`.
- Point-in-time status or "what I did this session" → `handoffs/` (or a spec's
  status, never `learnings/`).

## Corrections and de-duplication

- Correct a learning in place only when its headline claim survives. When a
  correction inverts the claim, rewrite the file to the new truth (filename,
  H1, `name`, index entry) and leave one trailing pointer to git history — never
  keep the disproven narrative inline.
- Don't duplicate content across files. Link the durable mechanism from a gap
  with `[[learning-name]]` rather than restating it.

The `/harvest` flow (the `harvest` skill) is what promotes learnings and gaps
out of handoffs into these folders.
