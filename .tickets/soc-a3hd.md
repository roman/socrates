---
id: soc-a3hd
status: closed
deps: [soc-r1m5]
links: []
created: 2026-04-09T07:28:00Z
type: task
priority: 1
assignee: ralph
parent: soc-w9x2
tags: [functional]
---
# Update RALPH protocol for outcome-shaped tickets

Spec: docs/specs/2026-04-08-spec-sizing-rule/2-91d9-update-ralph-protocol.md

## Outcome
RALPH.md's task execution guidance accounts for outcome-shaped
ticket bodies. The protocol tells the implementer to read the
outcome as a target to reach and the verification as a contract to
satisfy, then decompose the work into commits as it sees fit.
The implementer is not expected to receive step-by-step procedures
from the ticket — it owns the decomposition.

## Verification
- RALPH.md Phase Sequence or Task-Type Adaptations section
  references outcome-shaped tickets and describes how the
  implementer decomposes an outcome into commits
- The protocol does not assume ticket bodies contain procedural
  steps

