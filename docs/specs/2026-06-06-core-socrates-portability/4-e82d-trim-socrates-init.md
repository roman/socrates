---
id: e82d-trim-socrates-init
status: closed
priority: 2
category: functional
assignee: ralph
deps: [85ae-spec-discipline-via-spec-preamble, 91eb-task-entry-command]
---

# Trim /socrates-init for the marketplace path

## Outcomes

- The `/socrates-init` command is removed from the plugin. The
  source file `plugins/socrates/commands/init.md` no longer ships;
  the plugin no longer advertises a slash command for project
  bootstrapping.
- `/spec`, on first invocation in a project that lacks
  `docs/specs/`, creates the directory itself before continuing
  with phase work. No separate install-time step is required to
  prepare the project tree.
- Marketplace operators installing core Socrates from the plugin
  layout see no files appear in their project tree at install;
  the only writes ever made by core Socrates are spec content the
  operator creates by running `/spec`.

## Verification

- `plugins/socrates/commands/init.md` is absent from the plugin
  tree.
- The slash-command list no longer surfaces `/socrates-init` when
  the plugin is loaded.
- Running `/spec` in a fresh project that has no `docs/specs/`
  causes that directory to be created during phase work; the
  operator did not run any pre-step.
- A clean project that installs core Socrates from the plugin
  layout and never runs Ralph has no Socrates-authored files in
  its working tree after install.

<review></review>
