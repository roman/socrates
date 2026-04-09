---
id: soc-a41r
status: closed
deps: []
links: []
created: 2026-04-09T03:36:35Z
type: task
priority: 1
assignee: ralph
parent: soc-z4r9
tags: [documentation]
---
# Add producer marker to Shared Surfaces format

Spec: docs/specs/2026-04-08-depends-on-smell/1-58c1-producer-marker-format.md

## Steps
1. Update `plugins/socrates/templates/_overview.md`'s `#### Shared Surfaces` placeholder text to describe the explicit `(producer)` marker convention: one linked task per entry may be annotated `(producer)`; absence means the surface is a mutual read and contributes no ordering; multiple producers are allowed but rare.
2. Update `plugins/socrates/commands/spec.md` Design phase guidance (the Shared Surfaces example around lines 473–485) to show a surface entry with the producer marker, and to instruct the authoring agent to mark the producing task whenever the surface has a natural producer.
3. Update `docs/spec-format.md`'s `#### Shared Surfaces` subsection to document the producer marker, including: what it looks like, what "no marker" means (mutual read, no edges), and the rule that the marker must be explicit rather than positional so it survives link reordering during refinement.
4. Leave the existing rot-avoidance rule (no shapes, no literals, no concrete config keys) untouched — it still applies.

## Verification
- Read the updated template, `spec.md`, and `spec-format.md` and confirm the producer marker is documented consistently across all three with the same syntax.
- Confirm an example Shared Surfaces entry with a producer marker appears in at least one of the three files and is unambiguous.
- Confirm the "no marker = no edges" semantics is stated.

