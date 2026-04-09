## soc-a41r — Surface owner marker for Shared Surfaces

Added an explicit `(surface owner)` annotation to the Shared Surfaces
format across the three places it is documented:

- `plugins/socrates/templates/_overview.md` placeholder
- `plugins/socrates/commands/spec.md` Design phase guidance + example
- `docs/spec-format.md` Shared Surfaces subsection + example

Semantics: marker sits on the linked task that creates/owns the surface;
other links are readers and follow it. No marker = mutual read, no
ordering edge. Marker is on the link itself, not positional, so link
reordering during refinement is safe.

### Naming note

Spec task originally said `(producer)`. Human pushed back during the
session: too jargony, and the label should make clear *what* is being
owned. Settled on `(surface owner)` — explicit and unambiguous.
Downstream tasks (soc-9vi9 ordering derivation, soc-cirx depends_on
retirement) should read this marker, not `(producer)`.

### Next

soc-a41r → close. Unblocks soc-9vi9 (derive pour ordering from Shared
Surfaces).
