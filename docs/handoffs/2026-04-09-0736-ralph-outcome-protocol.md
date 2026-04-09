## soc-a3hd — Update RALPH protocol for outcome-shaped tickets

Updated RALPH.md Phase Sequence so the implementer knows tickets carry
Outcome + Verification sections (not procedural steps) and owns the
decomposition into commits.

### Changes to RALPH.md

- **Bearings**: new bullet teaching the agent to read Outcome as target
  state and Verification as contract. New bullet explaining that the
  implementer owns decomposition and multi-commit work means multiple
  phase-sequence passes.
- **Implement**: first bullet now says "work toward the Outcome, use
  Verification to confirm you are on track."
- **Verify**: reworded to "satisfies the Verification contract" and
  added bullet to walk each Verification item explicitly.
- Exit criteria updated in all three phases to reference outcome
  language.

### Code-critic findings

Spawned code-critic (opus). One actionable finding:
- Tension between "decompose into multiple commits" (Bearings) and
  "one commit per task cycle" (Phase 4). Fixed by clarifying that each
  commit is a separate pass through the full phase sequence.

Trimmed redundant "not to dictate the implementation path" in Implement
(already said in Bearings).

### Next

soc-a3hd closed. soc-w9x2 (epic) has no other open children visible
from `tk ready`. PM cycle should check whether the epic's remaining
children are all closed and run Spec Lifecycle sweep if so.
