---
title: Core Socrates portability
created: 2026-06-06
tags: []
archived:
delimit_approved: true
review_mode: false # gates post-merge review loop; see RALPH.md § Review Mode
---

<!-- Voice and structure follow plugins/socrates/voice.md. -->

## Describe [COMPLETE]

### Situation

Today Socrates ships as a single Claude Code plugin combining two
concerns: the Socrates design surface (the `/spec` family, voice rules,
task and overview templates) and the Ralph autonomous-loop surface (the
`RALPH.md` protocol, the loop scripts, the sandbox VM). The plugin is
installed into target projects via two mechanisms:

- a Nix/devenv install that hard-links plugin contents from the Nix
  store into the project, so plugin changes propagate the next time the
  operator updates the flake input;
- a `/socrates-init` command that copies templates into the project
  tree, after which the project owns its own snapshot and the plugin's
  changes do not reach it.

🟨 In practice only the Nix path has been exercised by the project's
sole operator. The `/socrates-init` drift surface exists in code but
has not produced concrete confusion on a real project.

### What's driving the work

The operator wants to split today's combined plugin into core Socrates
(a Claude Code plugin that ships via the Anthropic plugin marketplace
and via Nix) and Ralph (Nix-only, living outside the Claude Code plugin
layout because it isn't a marketplace plugin). The constraint shaping
that split:

- core Socrates (spec/design) must stay infrastructure-free so it can
  ship via the Anthropic plugin marketplace as well as via Nix;
- Ralph (loop + sandbox + protocol) needs devenv shells and a sandbox
  VM, so it remains Nix-only and lives outside the plugin layout to
  avoid signalling that it's marketplace-installable.

The upgrade-flow gap is the entry point into that split. Designing how
an upgrade works forces a clear answer to what each plugin actually
puts inside a target project, which determines whether an upgrade
story is even necessary, and for which surface.

### What's known

- ✅ Two install mechanisms exist today; the Nix one propagates and the
  `/socrates-init` one copies and drifts.
- The split target is two plugins from one monorepo, independently
  installable and versioned.
- Core Socrates is meant to be infrastructure-free. The operator's
  current intuition is that it should put nothing project-local at
  install time, with the possible exception of the interactive
  instructions injected into a session, and even those are a candidate
  for delivery via hooks rather than a copied file.
- Ralph cannot meet the Anthropic plugin contract; its install path
  stays Nix-only.

### What's not known

- Whether core Socrates can truly land at zero project-local footprint,
  or whether some artifact (interactive instructions, scaffolding,
  voice rules) has to live in the project tree for the experience to
  work.
- What "upgrade" should mean for the Anthropic-plugin path that the
  operator has never exercised, including how operators discover that
  a new version is available and what state the plugin manages on
  their behalf.
- Whether projects that bootstrapped under the current combined
  `/socrates-init` need a one-time migration path when the split lands,
  or whether the split itself is the migration.
- Where Ralph's own project-local surface (if any beyond what devenv
  provides) sits on the drift question.

### Stakeholders

The primary stakeholder is the project's sole operator, running
Socrates across personal projects exclusively via Nix. The secondary,
currently hypothetical stakeholder is a future operator who discovers
core Socrates through the Anthropic plugin marketplace and never
touches Nix; preserving that path is the load-bearing reason to keep
core Socrates portable.

## Diagnose [COMPLETE]

### The shape of the real problem

The framing question from the gap was "how do we ship plugin updates to
projects that drift?" The interview reframed it. The operator has never
used `/socrates-init`; every install they run is Nix, which hard-links
from the store and propagates updates by construction. No project
anywhere carries stale `/init` copies. The lived drift surface is zero.

What's actually load-bearing is the upcoming split of the combined
plugin into core Socrates (the spec/design surface, portable enough to
ship via the Anthropic plugin marketplace) and Ralph (the autonomous
loop, locked to Nix because it needs `limactl` and a sandbox VM). The
"upgrade flow" gap is the entry point into that split: deciding how
upgrades work forces a clear answer to what each plugin actually puts
inside a target project.

Once we look at the current `/socrates-init` footprint with the split in
mind, every project-local artifact falls into one of three buckets:

- Ralph-owned, stays Nix-only (drift solved by hard-link propagation).
- Core-Socrates-owned, candidate for non-project delivery (hooks, plugin
  context, skill content).
- Core-Socrates-owned, intrinsically project-local but explicitly
  dropped from core (the commit-msg hook, the `spec` CLI), with the
  marketplace path losing those capabilities by design.

The dominant hypothesis is that core Socrates can be designed to leave
nothing in the project tree at install time, which makes "upgrade =
the plugin manager refreshing skill files" true by construction. We
have not yet confirmed the delivery vectors that replace `INTERACTIVE.md`
and the CLAUDE.md discipline gates, but no artifact has been identified
that intrinsically forces a project-local footprint on core Socrates.

### Hypotheses tested

#### H1 — Core Socrates can land at zero project-local footprint

The operator's claim: with the right delivery vectors, core Socrates
puts nothing in the project tree at install time, so upgrade collapses
to the plugin manager refreshing skill files.

Tested by enumerating today's `/socrates-init` footprint and asking,
for each artifact, whether it has to be project-local:

- Ralph artifacts (`ralph.sh`, `RALPH.md`, `.msgs/`) → not core
  Socrates's concern; Ralph stays Nix-only and propagates via hard-links.
- `INTERACTIVE.md` → 🟨 plausibly deliverable via hooks or plugin-context
  injection. Operator floated hooks during the interview.
- CLAUDE.md gates appended at install → 🟨 same vector candidates.
- `docs/specs/`, `docs/specs/archive/`, `docs/handoffs/` → can be
  created on demand by `/spec`. No install-time action needed.
- `commit-msg` hook → ✅ dropped from core entirely. Marketplace
  operators do not get the warning.
- `spec` CLI → ✅ marketplace operators do not get it. Nix-side
  convenience only.

H1 holds *if* the hook/skill-content delivery vector for `INTERACTIVE.md`
and the CLAUDE.md gates is engineerable. That's a validation question
for Direction/Design, not a refutation here.

#### H2 — At least one core Socrates artifact is intrinsically project-local

The natural disprover. Tested against the same enumeration:

- The two strongest candidates (commit-msg hook and `spec` CLI) are
  intrinsically project-local on the project's filesystem, but the
  operator chose to drop both from core rather than keep them. They no
  longer function as disprovers for H1.
- `INTERACTIVE.md` and CLAUDE.md gates are content, not state; they
  describe behaviour Claude follows. Content delivery has multiple
  vectors; no inherent reason it must be a file in the project tree.

H2 has no surviving instance. The hypothesis is not supported by the
current artifact set.

#### H3 — A `/socrates-upgrade` command is the right shape

The gap's suggested resolution was a version-aware upgrade command that
diffs and applies template changes. Tested against H1: if core Socrates
has no project-local artifacts, there is nothing for the upgrade
command to diff or apply. Ralph propagates via Nix hard-links, so the
upgrade command has nothing to do there either. The command has no
inputs to operate on; the shape is wrong.

### Diagnosed items

#### Legend

| Prefix | Name | Meaning |
| --- | --- | --- |
| **RC** | Root Cause | A real reason the problem exists. |
| **NC** | Non-Cause | Looked like a cause; turned out not to be. Limit to 2-3. |
| **AC** | Adjacent Constraint | A rule from outside this spec that we must respect. |
| **ID** | Implementation Detail | Effort, risk, reversibility — not tied to a diagnosed item. |

#### RC1 — Pre-split install assumption

The current `/socrates-init` was designed when Socrates and Ralph were
one plugin sharing one install footprint. The footprint mixes
core-design artifacts (`INTERACTIVE.md`, CLAUDE.md gates,
`docs/specs/`, `docs/handoffs/`) with Ralph artifacts (`ralph.sh`,
`RALPH.md`, `.msgs/`), and that mix was acceptable because everything
shipped together.

Splitting the plugins requires decomposing the footprint by ownership
and revealing, for each artifact, whether it has to land in the target
project at all.

#### RC2 — Project-local files were the default delivery vector

Files in the project tree were the default mechanism for Claude to
read protocol and gate content, because the project's `CLAUDE.md` is
auto-loaded and operators naturally point at files by path. But Claude
Code's plugin mechanisms (hooks, plugin-side skill descriptions, plugin
context) provide non-project-local delivery vectors that were not the
shape `/socrates-init` was authored against.

The "drift problem" the gap described exists because the original
delivery choice was project-tree-by-default. Switching to a
plugin-managed vector dissolves the drift surface.

#### NC1 — Operator pain from `/init` drift

The gap framed this as an upgrade problem in a setting where projects
carry stale `/init` copies. The operator has never used `/init`. No
project has stale copies. The diagnostic anchor for the gap's framing
does not exist in practice.

#### NC2 — Need for a versioned upgrade command

The gap proposed a `/socrates-upgrade` command (or `/socrates-init`
re-runnable as upgrade) as the resolution shape. With core Socrates
producing no project-local artifacts and Ralph propagating via Nix
hard-links, the command has nothing to diff or apply.

#### AC1 — Ralph requires system dependencies the marketplace can't manage

Ralph needs `limactl`, `qemu`, and the sandbox VM. The Anthropic plugin
contract does not manage system dependencies. This is the structural
reason the split exists: Ralph stays Nix-only.

#### AC2 — Anthropic plugin contract excludes filesystem state outside Claude's sandbox

Git hooks (`.git/hooks/`), system CLIs (`spec` on PATH), and similar
state-bearing installs are outside what a marketplace plugin can do.
Core Socrates must respect this: any feature that requires such state
is either Nix-only or marketplace-loses-it.

#### AC3 — Claude Code plugin mechanisms can deliver content via hooks and skill descriptions

The vector that makes H1 possible. Plugin authors can inject content
into the session via hooks (SessionStart, etc.) or via the skill
description the plugin ships. This is the constraint that lets core
Socrates avoid a project-local footprint without losing the behaviour
`INTERACTIVE.md` and the CLAUDE.md gates currently encode.

🟨 The exact mechanism (which hook, which skill metadata) is a
Direction question. The constraint at Diagnose level is only that the
vector exists.

### Boundary checkpoint

The root causes explain the problem here and now:

- **Why here**: this project is the one being split. The decomposition
  of the install footprint is a problem only for projects that bundle
  multiple concerns into one plugin and want to unbundle them.
- **Why now**: the operator's goal of attracting non-Nix users via the
  Anthropic plugin marketplace creates the portability constraint that
  forces the split. Without that goal, the combined plugin works fine.

The upstream cause is the design choice (combined plugin, project-tree
delivery), not external causation or protocol-level forcing functions.
That places the work squarely inside this spec's mandate.

## Delimit [APPROVED]

Core Socrates cannot ship to non-Nix operators through the Anthropic
plugin marketplace, because today's install footprint mixes Ralph
artifacts and project-local content delivery into a single
`/socrates-init` flow that the marketplace contract cannot reproduce.

## Direction [COMPLETE]

### Ackoff checkpoint

Delimit says core Socrates can't ship to non-Nix operators via the
marketplace because the install footprint mixes Ralph artifacts with
project-local content delivery. Each approach below addresses that, in
different ways. The right-problem framing still holds.

### Approaches

#### A1 — Status quo

**Center of gravity**: Don't split. Accept that the marketplace path
is unreachable and keep dogfooding the combined plugin on Nix.

`/socrates-init` continues to write `INTERACTIVE.md`, CLAUDE.md gates,
the commit-msg hook, the Ralph scripts, and `RALPH.md` into the
project tree. Operators outside Nix have no install path.

#### A2 — Split, skill-based delivery

**Center of gravity**: Move core Socrates onto Claude Code's skills
mechanism for content delivery.

Mechanically:

1. Ralph moves out of the plugin layout into a Nix-only home (e.g.,
   `nix/ralph/`). The Nix devenv module continues to manage it.
2. Core Socrates stays under `plugins/socrates/`. The marketplace
   manifest stays valid.
3. `INTERACTIVE.md` content and the CLAUDE.md discipline kernel become
   skills (text under `plugins/socrates/skills/`) with descriptions
   that activate them when relevant: editing spec files, starting a
   session in a project with `docs/specs/`, running `/spec`.
4. `/socrates-init` shrinks to a thin command that only creates
   on-demand directories (`docs/specs/`, `docs/handoffs/`) the first
   time the operator runs `/spec`. No protocol files copied.
5. This project's own install migrates: existing `INTERACTIVE.md`,
   gates in `CLAUDE.md`, commit-msg hook, and ralph scripts get
   removed or moved to their Nix-managed homes.

Skills are content Claude chooses to read when their description
matches. Reliability depends on the skill description triggering at
the right moments.

#### A3 — Split, hook-based delivery

**Center of gravity**: Move core Socrates onto Claude Code's hooks
mechanism so content is injected by the platform, not chosen by Claude.

Mechanically the same split as A2, but instead of skills:

1. A `SessionStart` (or equivalent) hook in the plugin injects the
   spec discipline kernel and the interactive protocol into the
   session context at the start of every interactive session.
2. The hook may also detect whether the session is interactive or
   Ralph-driven (by presence of a known env var or process ancestor)
   and choose what to inject accordingly.
3. Same on-demand directory creation as A2.
4. Same self-migration step for this project.

Hooks guarantee delivery in a way skill triggers do not, at the cost
of being heavier infrastructure to maintain.

#### A4 — Split, hybrid (skills for kernel, hooks for protocol selection)

**Center of gravity**: Use the lightest mechanism for each piece of
content.

1. The spec discipline kernel (directive hierarchy rules) ships as a
   skill, activated by spec-file editing or `/spec` invocation. Stable,
   project-wide context that Claude reads when working on specs.
2. The interactive session protocol ships via a `SessionStart` hook
   that fires once per session and injects the appropriate protocol
   text (interactive vs Ralph, if mode detection is desired).
3. Same split and self-migration as A2/A3.

Combines A2's lightness for stable content with A3's guarantee for
session-start protocol. More moving parts to keep coherent.

#### A5 — Split, explicit protocol invocation via slash commands

**Center of gravity**: No skills, no hooks. Protocol contexts load via
explicit slash-command invocation. Delivery is deterministic because
the operator types it.

1. The spec discipline kernel lives inline in the `/spec` command
   body as preamble. The task-entry command inlines a copy. Both
   command bodies carry a short comment naming the duplication so
   future edits update both. Editing a spec without invoking a
   command is accepted as an edge case.
2. The interactive session protocol ships as a new entry command (e.g.,
   `/socrates-task <id>`) that loads the protocol plus the named task's
   context. Operators explicitly enter the protocol when they pick up
   a task.
3. Ralph is unchanged: `ralph.sh` already loads `RALPH.md` explicitly
   as part of the autonomous bootstrap.
4. Same split and self-migration as A2/A3/A4.

The lightest mechanism in the set. No skill descriptions to tune, no
hook contract to maintain, no platform-side activation heuristics to
depend on. Operator agency is explicit.

### Decision Matrix

Criteria trace to diagnosed items:

- **C1 — Resolves RC1 (mixed footprint)?** Does it cleanly separate
  core Socrates and Ralph artifacts?
- **C2 — Resolves RC2 (project-local default vector)?** Does it
  provide a non-project-local delivery vector for core Socrates
  content?
- **C3 — Respects AC2 (marketplace contract)?** Does it work within
  what the Anthropic plugin contract allows?
- **C4 — Uses AC3 (hooks/skills available)?** Does it leverage Claude
  Code's plugin mechanisms?
- **C5 — Implementation effort [ID]**: How much work to land?
- **C6 — Reliability of delivery [ID]**: How sure are we Claude will
  see the content at the right time?
- **C7 — Reversibility [ID]**: If the chosen vector doesn't work in
  practice, how hard to swap?

| | A1 Status quo | A2 Skills | A3 Hooks | A4 Hybrid | A5 Explicit |
|---|---|---|---|---|---|
| **C1** RC1 footprint | 🔴 unresolved | 🟢 split clean | 🟢 split clean | 🟢 split clean | 🟢 split clean |
| **C2** RC2 vector | 🔴 still project-local | 🟢 skills replace files | 🟢 hooks replace files | 🟢 skills + hooks | 🟢 commands replace files |
| **C3** AC2 contract | ⚪ n/a (no marketplace) | 🟢 in-contract | 🟢 in-contract | 🟢 in-contract | 🟢 in-contract |
| **C4** AC3 leverage | ⚪ n/a | 🟡 skills only | 🟡 hooks only | 🟢 both | 🟡 commands (different mechanism, still in Claude Code) |
| **C5** Effort | 🟢 none | 🟡 medium (skill descriptions + migration) | 🔴 highest (hook author, mode detection) | 🔴 highest (two mechanisms) | 🟢 lowest split (no skills/hooks to author) |
| **C6** Reliability | ⚪ n/a | 🟡 depends on triggers firing | 🟢 platform-guaranteed | 🟢 protocol guaranteed, kernel relies on skill trigger | 🟢 deterministic (operator types it) |
| **C7** Reversibility | 🟢 already there | 🟢 skills are easy to swap | 🟡 hook contract is stickier | 🟡 swap surface is larger | 🟢 trivially layer skills/hooks later |

### Chosen Approach

> **Chosen: A5 — Split, explicit protocol invocation via slash
> commands.** It resolves RC1 and RC2 with the simplest mechanism in
> the set. Slash commands already exist; no skill descriptions to tune,
> no hook contract to maintain, no platform-side activation heuristic
> to depend on. Delivery is deterministic because the operator types
> the entry command. It respects AC2 by working entirely inside the
> marketplace contract. The accepted edge case (an operator editing a
> spec file without first invoking `/spec`) is observable; if it
> happens often in practice, layering a skill or hook is a low-cost
> follow-up that A5's reversibility leaves wide open.

### Inversion test on A5

What would guarantee A5 fails?

- **Operators forget to invoke the entry command.** They open a
  session, start editing a spec or task file directly, and the
  discipline kernel never loads. Mitigation: the existing `/spec` and
  the new task-entry command cover the actual workflows; ad-hoc edits
  without invocation are an accepted edge case. If observed often,
  layering a skill is a low-cost follow-up.
- **Command discoverability is poor.** Operators don't know the
  task-entry command exists. Mitigation: the plugin's marketplace
  description and the slash-command list surface it. Naming should be
  clear and consistent with `/spec`.
- **DRY drift between commands.** Both `/spec` and `/socrates-task`
  inline the same discipline kernel. If a future edit updates one
  and forgets the other, the two commands silently behave
  differently. Mitigation: each command's body carries a short
  comment naming the sister command and the duplication contract;
  if a third referencer emerges, that's the cue to extract into a
  shared `lib/` file (a follow-up, not now).

### Residue check

If A5 is executed perfectly, what's still broken?

- The commit-msg hook warning is gone for marketplace operators. They
  commit without the `Refs:` validation. Acceptable per the operator's
  decision to drop the hook from core.
- The `spec` CLI is unavailable to marketplace operators. They use the
  slash command equivalents in `/spec`. Acceptable per the operator's
  decision to keep the CLI Nix-side.
- Ralph remains Nix-only. Anyone wanting the autonomous loop must
  install via Nix. The structural constraint, not a residue.
- Ad-hoc spec edits without first invoking the entry command bypass
  the discipline kernel. Accepted edge case; follow-up surface if
  observed in practice.
- The marketplace install path is designed but unverified at spec
  completion. The operator only runs the Nix install path; spinning
  up a fresh non-Nix environment to smoke-test the marketplace flow
  is disproportionate effort at this stage. The first non-Nix
  operator's experience is the natural test, and the residue is
  recoverable (any breakage surfaces as a follow-up spec).

No diagnosed item is left unaddressed.

### Use Cases

| Actor | Intent | Outcome |
| --- | --- | --- |
| Non-Nix operator | Install core Socrates from the Anthropic plugin marketplace | Slash commands appear without any project-local files written. Operator runs `/spec` or the task-entry command to load the protocol context. |
| Nix operator (this project) | Run Socrates in their devenv shell | Same slash commands as marketplace path, plus Ralph and the `spec` CLI from Nix. |
| Plugin author (operator) | Update the spec discipline rule | Edits a single shared plugin file referenced by both `/spec` and the task-entry command; change propagates on next plugin refresh, no project files to migrate. |
| Marketplace operator | Update to a new core Socrates release | Marketplace refreshes plugin files; no project state to migrate. |

## Design [COMPLETE]

### Context

The current plugin layout already separates core Socrates content
from Ralph content at the file level, but ships everything under
`plugins/socrates/` and installs both via the same `/socrates-init`
flow. The relocation work is mechanical: Ralph and the other Nix-only
artifacts move to a Nix-side home, and the marketplace plugin keeps
the slash commands, templates, and voice rules that the design
journey reads. (See [Addendum A.1](#a1) for the file-by-file split
boundary.)

Claude Code skills live at `<plugin>/skills/<name>/SKILL.md` and
activate when their `description` matches conversation context. That
matching is heuristic, not deterministic, which is why A5 sidesteps
skills entirely: explicit slash-command invocation is the delivery
vector. (See [Addendum A.2](#a2) for the skills mechanism research.)

Adjacent constraints land in specific places:

- **AC1** (Ralph needs system dependencies) forces Ralph artifacts
  out of `plugins/socrates/` to a Nix-only path. T1 carries this.
- **AC2** (marketplace contract excludes project filesystem state)
  forces `/socrates-init` to trim to no project writes and forces
  removal of the commit-msg hook and `spec` CLI from the marketplace
  plugin. T1 and T5 carry this together.
- **AC3** (Claude Code mechanisms can deliver content via
  hooks/skills) is used by reference: A5 deliberately picks slash
  commands instead, so AC3 stays as a documented fallback if skills
  or hooks prove necessary in future.

The Nix devenv module and the spec-cli Nix package are integration
points multiple tasks touch. T1 updates them when Ralph and the spec
CLI move; T4 verifies nothing else still references removed files;
T6 confirms this project's install continues to work after the
moves.

### Tasks

| ID | Title | Priority | Category |
| --- | --- | --- | --- |
| `1-46c0-extract-nix-only-artifacts` | Extract Nix-only artifacts from the plugin | 1 | infrastructure |
| `2-85ae-spec-discipline-via-spec-preamble` | Spec discipline kernel delivered via /spec preamble | 1 | functional |
| `3-91eb-task-entry-command` | Task-entry command for interactive task work | 1 | functional |
| `4-e82d-trim-socrates-init` | Trim /socrates-init for the marketplace path | 2 | functional |
| `5-23fa-migrate-this-project` | Migrate this project to the new plugin shape | 1 | infrastructure |

T2 absorbs the deletion of `claude-gates.md`; T3 absorbs the
deletion of `INTERACTIVE.md`. Both deletions are sub-steps of the
tasks that replace their content, not a separate task.

### Execution Order

- [1-46c0](1-46c0-extract-nix-only-artifacts.md) and
  [2-85ae](2-85ae-spec-discipline-via-spec-preamble.md) are
  independent and can run in either order. T1 moves Ralph, the
  commit-msg hook, and the spec CLI out of the plugin and updates
  the plugin manifest so the marketplace layout is reachable. T2
  inlines the discipline kernel into `/spec` and removes
  `claude-gates.md`.
- [3-91eb](3-91eb-task-entry-command.md) follows T2: the
  task-entry command inlines the same kernel content T2 established,
  adds the interactive protocol inline, and removes
  `INTERACTIVE.md`.
- [4-e82d](4-e82d-trim-socrates-init.md) follows T2 and T3 because
  trimming the install flow only makes sense once the new entry
  commands carry the protocol context.
- [5-23fa](5-23fa-migrate-this-project.md) runs last and depends on
  every other task. Migrating this project closes the spec by
  verifying the redesigned plugin works end-to-end on the
  dogfooding install.

### Glossary

- **Core Socrates**: the spec/design surface of the plugin —
  `/spec`, the design phases, voice rules, the discipline kernel,
  and the task-entry command. Ships via the Anthropic plugin
  marketplace and via Nix.
- **Ralph**: the autonomous loop surface — `RALPH.md`, the loop
  scripts, the sandbox VM. Nix-only because of system-dependency
  requirements (AC1).
- **Discipline kernel**: the mode-agnostic content currently in
  `claude-gates.md`'s "Spec discipline" section — directive
  hierarchy and code-critic gate. After this spec, the kernel
  lives inline in the body of `/spec` and is duplicated inline in
  `/socrates-task`.
- **`/socrates-task`**: the task-entry slash command T3 introduces.
  Takes a task identity as argument and loads the discipline
  kernel, the interactive session protocol, and the named task's
  context.
- **Marketplace path**: the install path where an operator gets the
  plugin from the Anthropic plugin marketplace, without Nix.
  Constrained by AC2.
- **Nix path**: the install path where an operator gets the plugin
  via the devenv module in this repo's flake. No marketplace
  constraints; can install Ralph and the spec CLI on top.

## Technical Addendum

<a id="a1"></a>
### A.1 — File-by-file split boundary

Current plugin layout under `plugins/socrates/`:

- **Core Socrates (stays under `plugins/socrates/`)**:
  - `commands/spec.md` (kernel inlined as preamble by T2)
  - `commands/harvest.md`
  - `commands/spec-support/{phases,patterns}/*.md`
  - `templates/_overview.md`, `templates/task.md`
  - `voice.md`
  - `.claude-plugin/plugin.json` (description and keywords updated)
  - new: `commands/socrates-task.md` (T3 — task-entry command,
    inlines kernel and interactive protocol)

- **Nix-only artifacts (move out of `plugins/socrates/`)**:
  - `templates/RALPH.md`
  - `templates/ralph.sh`, `templates/ralph-once.sh`,
    `templates/ralph-format.sh`
  - `templates/handoff.md`
  - `templates/commit-msg.sh`
  - `templates/spec` (the CLI script)
  - `templates/spec.test.sh`

- **Commands and templates removed entirely**:
  - `commands/init.md` → T4 removes the `/socrates-init` command;
    `/spec` creates `docs/specs/` on first use.
  - `templates/INTERACTIVE.md` → T3 inlines its content into the
    task-entry command.
  - `templates/claude-gates.md` → T2 inlines the kernel content
    into `/spec`'s body; the mode-fork content is obsolete because
    each entry point loads its own protocol directly.

Nix integration points the moves touch:

- `nix/modules/devenv/socrates.nix` — devenv module that declares
  `claude.code.plugins.socrates.enable` and conditionally installs
  templates.
- `nix/packages/skills/socrates/default.nix` — package that exposes
  plugin contents at `/share/claude/skills/socrates`.
- `nix/packages/spec-cli.nix` — wraps `templates/spec` as a standalone
  Nix-only CLI.

<a id="a2"></a>
### A.2 — Skills mechanism research (basis for the A5 choice)

Findings cited from Claude Code documentation
(`code.claude.com/docs/en/skills.md`,
`code.claude.com/docs/en/plugins.md`,
`code.claude.com/docs/en/hooks-guide.md`):

- Skills in plugins live at `<plugin>/skills/<skill-name>/SKILL.md`
  with YAML frontmatter (`description`, `disable-model-invocation`).
- ✅ Skill activation is heuristic: Claude matches the `description`
  field against current conversation context. Activation is not
  deterministic.
- ✅ For "ensure Claude reads protocol at every session start," skills
  alone are insufficient; the platform's deterministic mechanism is a
  `SessionStart` hook (`hooks.json` at plugin root).
- ✅ Marketplace plugins ship: skills, hooks, slash commands, MCP
  servers, agents. They cannot ship git hooks, CLIs on PATH, or any
  state that writes to the operator's project tree.

A5's decision to use slash commands as the explicit entry mechanism
sidesteps the skill-activation heuristic and the hook-authoring
overhead. AC3 remains a documented fallback if observation shows
explicit invocation is too easy to forget.
