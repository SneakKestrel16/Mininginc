# Story 017: Power console + auto-drills

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D item 20` (Build order item 20)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D item 20), scoped to this story:*

- [ ] A console at the base opens the Drills/Heart slider with E; the Tab overlay is gone.
- [ ] The player can place an auto-drill on the ground (costs copper, read from data), and pick one up again.
- [ ] Each placed drill bores straight down from where it stands, breaking blocks in the voxel world with drill power, and puts what it breaks into the inventory.
- [ ] Drill power is shared between all placed drills; with no drills placed, drill power does nothing.
- [ ] A drill stops at bedrock, and its column stays open for the player to climb down.
- [ ] The old single-shaft `DigShaft` is no longer used by the economy.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Drills land hits on their current block exactly as the hand drill does, so hardness and Breath apply the same.

---

## Out of Scope

- Drills that tunnel sideways.
- Power cables or transmission loss.

---

## Files

- src/machines/auto_drill.gd
- src/machines/auto_drill.tscn
- src/machines/console.gd
- src/economy/economy.gd
- src/mining/mine.gd
- src/main.tscn

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/auto_drill_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-016-heart-and-hud.md`
- Unlocks: `production/epics/heartwake/story-018-world-saves.md`
