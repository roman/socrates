## PM sweep — archive spec-status-view spec

`tk ready -a ralph` returned `soc-qzop [open]` epic. Its sole child
(soc-dw00) was already closed. Ran the Spec Lifecycle Sweep:

- Closed epic `soc-qzop`
- Stamped `_overview.md` frontmatter `archived: 2026-05-01`
- Moved `docs/specs/2026-04-29-spec-status-view/` to
  `docs/specs/archive/2026-04-29-spec-status-view/`
- `git mv` succeeded cleanly (no untracked-dir issue this time)

Also checked `docs/specs/2026-04-29-pr-review-loop/` — `epic:` is empty
(never poured), so skipped per sweep rules.

### Next

`tk ready -a ralph` is empty after the sweep. Created `.ralph-stop`.
