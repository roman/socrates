## PM sweep — archive depends-on-smell spec

`tk ready -a ralph` returned `soc-z4r9 [open]` epic. All three children
(soc-a41r, soc-9vi9, soc-cirx) were already closed. Ran the Spec
Lifecycle Sweep on `docs/specs/2026-04-08-depends-on-smell/`:

- Closed epic `soc-z4r9`
- Stamped `_overview.md` frontmatter `archived: 2026-04-08`
- Moved spec dir to `docs/specs/archive/2026-04-08-depends-on-smell/`

The spec dir was untracked (poured but never committed under
`docs/specs/`), so `git mv` failed on empty source. Used plain `mv`
plus `git add` to land it directly under the archive path.

### Next

`tk ready -a ralph` should now be empty. Next ralph cycle is PM with
nothing actionable → `.ralph-stop`.
