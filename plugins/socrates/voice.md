# Spec voice and structure

This file describes the voice and structure conventions specs in this
plugin should follow. The `/spec` command and any related skills
should keep generated prose aligned with what's written here.

The goal is documents that read like they were written by a human
who edits their own prose: prose-first, scannable, and free of the
pattern-recognizable tics of LLM-generated text.

## Prose-first structure

### Move technical detail to a Technical Addendum

The body of a spec uses *concept names* (the names of types, APIs,
modules, and components a technical reader benefits from
recognizing). The body does *not* inline file paths, line numbers,
commit SHAs, or long identifier strings.

Specs include a `## Technical Addendum` section at the end of
`_overview.md`. That section is organized by topic (A.1, A.2, ...)
and holds:

- file paths and line numbers
- commit SHAs and PR references
- exact identifier strings (env var names, full type paths,
  protocol-specific keys)
- quantitative basis for claims (counts, sizes, ratios)
- raw evidence cited during Diagnose

When the body needs to point at evidence, use an inline
parenthetical: `(See Addendum A.3 for the catalog.)` Do not bury
file paths in running prose.

### Keep concept-level names in the body prose

Concept-level names belong in the body. Do not over-genericize them.
Names that a technical reader recognizes at a glance — module names,
type names, public API surface, framework primitives — are
vocabulary, not noise. Replacing `OrderViewModel` with "the order
view's coordinator class" hurts clarity rather than helping it.

The rule is: if a technical reader would scan past the name and
immediately know what it refers to, keep the name. If the name is
a path, a hash, or an instance identifier, move it to the Addendum.

### Use real headings for structural breaks

Promote bold inline lead-ins to real `###` (or `####`) headings.
A bolded fragment at the start of a 5-line paragraph does not
anchor scanning; a heading does.

Avoid this shape:

```
**Caching strategy.** Reads go through the in-memory cache before
hitting the database. The cache is invalidated on write...
```

Use this instead:

```
### Caching strategy

Reads go through the in-memory cache before hitting the database.
The cache is invalidated on write...
```

### Break long paragraphs at logical seams

A paragraph longer than ~5 lines almost always contains 2-3 distinct
ideas crammed together. Split them. The eye needs landing points.

### Render implicit lists as real lists

When prose describes a chain of steps or a set of related rules,
use a numbered or bulleted list. Comma-stitched prose disguised as
a list ("the request handler validates input, then enriches it,
then dispatches, while also logging") is harder to read than the
four-bullet version.

### Mark deliverables with a blockquote

Phase descriptions, task outcomes, and similar wrap-up statements
that name a deliverable use a blockquote, set off from surrounding
prose:

```
> Deliverable: one shared component library across all surfaces.
```

A blockquote scales cleanly to multiple sentences when needed and
stays distinctly different from heading-weight elements that
compete with the surrounding paragraph flow.

### Wrap-up paragraphs get their own subheading

When an approach description ends with a summary paragraph that
ties the phases together, give it a `##### Summary` subheading.
Don't let it run on after the last phase as though it were part
of that phase.

## What not to write

### Do not audit prior literature in the spec body

Earlier docs may have framed something differently. That doesn't
belong in *our* spec. State today's reality directly.

Don't dedicate sub-headings to other source documents.
Reference their conclusions inline as rationale ("a separate
proposal settled X, so we must respect Y") without giving them
their own titled section.

### Use team-level granularity, not individual names

Stakeholders, contract owners, and ongoing-responsibility
references use team names ("the platform team," "the design
systems team"), not individuals.

Origin events that mention specific people in passing — a meeting,
a thread, a doc — are honest historical fact and may stay named,
but the body of the spec describes responsibility at the team
level.

## AI-ism reduction

Generated prose tends to develop pattern-recognizable tics. Sweep
them out before persisting.

### Em-dashes used as default separators

Em-dashes serve a real parenthetical function (an aside, an
appositive). Used as default separators they degrade readability
and signal LLM authorship. Replace with commas, periods, or
parentheses where they aren't doing real parenthetical work.

A practical heuristic: if a paragraph has more than two em-dashes,
at least one is filler.

### Filler words and phrases

Sweep these out unless they earn their place:

- "by design," "structurally," "deliberately," "in practice,"
  "in essence," "fundamentally"
- "crucially," "importantly," "notably"
- "leverage," "robust," "comprehensive," "seamless"
- "in other words"

### "Load-bearing" used as a metaphor

The metaphor is useful sparingly. Capped at 2-3 uses per document.
More than that signals the writer reaching for a phrase rather
than describing what's happening.

### Rhetorical "X, not Y" patterns

"Rather than," "not just," and "X is the Y that exists because Z"
are LLM-shaped rhetorical patterns. Prefer direct active voice:
"Y left X as the workaround" reads more naturally than "X is the
workaround that exists because Y."

### Bold lead-in paragraphs

A `**Bold lead-in.**` followed by a long paragraph is the most
common AI-prose tic in technical writing. It substitutes for a
heading. Use a real heading.

## Diagnose ID convention

Diagnose items carry typed prefixed identifiers so subsequent
phases can reference them precisely:

- **RC** — Root Cause. A real reason the problem exists. Each one
  needs to be solved (or deliberately left out) by the chosen
  approach.
- **NC** — Non-Cause. Looked like a cause; turned out not to be.
  Listed so approaches don't get credit for "solving" it.
- **AC** — Adjacent Constraint. A rule from outside this spec
  that we have to respect. Approaches are judged on whether they
  preserve it.

When references appear in subsequent phases (such as decision
matrix rows), the format is: `[RC1] Description text` with the
`RC1` hyperlinked back to a stable anchor in the Diagnose section.

## Confidence labels for factual claims

During investigation phases (Describe, Diagnose), assert facts
with explicit confidence labels. Verified claims use a checkmark
because they carry a stronger semantic signal than the rest;
unverified claims use squares so they're visually distinct from
the decision matrix's circles:

- ✅ **Verified** — directly confirmed by reading source code,
  docs, or running it this session
- 🟨 **High confidence** — well-established knowledge from
  training; unlikely wrong but not verified live
- 🟧 **Medium confidence** — general understanding; details may
  be off; worth double-checking
- 🟥 **Low confidence** — educated guess or extrapolation; treat
  as a starting hypothesis only

A claim that can't be verified gets a label, not silent acceptance.

## Verification bullets describe observable facts

Task verifications describe what someone could observe to confirm
the outcome, not the procedure to produce it.

Avoid: "Run the test suite against every supported configuration."

Prefer: "A test report covers every supported configuration and
is committed alongside the change."

The artifact is the verification, not the act of producing it.

## Tasks introducing gates include a negative test

When a task introduces a gate, policy, validation, or any other
mechanism that's supposed to *reject* something, its verification
includes a deliberate denial test that confirms the gate actually
rejects what it should. The test change is reverted before the
task is closed if it temporarily disables a working production
path.
