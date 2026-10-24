# Story 017: Power console + auto-drills

> **Epic**: Heartwake
> **Status**: Complete
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
- src/machines/console.gd
- src/ui/overlay.gd
- src/mining/mine.gd
- src/player/player.gd
- src/player/player.tscn
- src/main.tscn
- data/world.json
- tests/unit/heartwake/auto_drill_check.gd

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

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 6/6 passing (self-check `auto_drill_check.gd`; windowed probe on the second monitor: F placed a drill for 3 copper on the aimed ground block, it dug down on furnace power with the split at Drills, its prompt offered pick-up, and the console's prompt opened the slider)
**Deviations**: Placing uses F on an upward face; picking up is E on the drill and refunds its copper. Drills are solid to the aim ray only (collision layer 2), so the player can drop into a drilled column. The console opens the same slider panel the Tab overlay showed; Tab no longer opens it. `Economy` is unchanged: `Mine.dig` now shares drill hits between placed drills, so `DigShaft` only carries the seed and saved fields until story 018.
**Known gap**: `tools/pacing_sim.gd` still digs through `Mine.dig` with no drills placed, so it no longer models digging; story 012 has to rebuild it for the 3D game. Drill speed is the MVP's 0.1 hits per power-second, about one block per 3 s on furnace power.
**Test Evidence**: waived at qa.level minimal; self-check `tests/unit/heartwake/auto_drill_check.gd` passes; screenshots in `production/qa/evidence/story-017-console-auto-drills/`
**Reviewed by**: self, no independent review
