## PM sweep — archive spec-sizing-rule spec

`tk ready -a ralph` returned `soc-w9x2 [open]` epic. Both children
(soc-a3hd, soc-r1m5) were already closed. Ran the Spec Lifecycle Sweep
on `docs/specs/2026-04-08-spec-sizing-rule/`:

- Closed epic `soc-w9x2`
- Stamped `_overview.md` frontmatter `archived: 2026-04-09`
- Moved spec dir to `docs/specs/archive/2026-04-08-spec-sizing-rule/`

Same untracked-dir issue as the previous archival (depends-on-smell):
`git mv` fails on untracked source, used `mv` + `git add` instead.

### Next

`tk ready -a ralph` is empty. No actionable work remains. Next session
should create `.ralph-stop` if still empty, or pick up any new tickets.
