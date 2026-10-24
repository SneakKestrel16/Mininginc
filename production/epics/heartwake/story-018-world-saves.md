# Story 018: Saves for the 3D world

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D item 21` (Build order item 21)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D item 21), scoped to this story:*

- [ ] The save keeps every block changed from the generated world, the player's position and facing, and each placed drill with its depth.
- [ ] Loading rebuilds the same world: dug tunnels stay dug.
- [ ] Offline progress still runs; placed drills keep boring down while away.
- [ ] A save from before the 3D milestone still loads: the economy and inventory carry over, and the player starts at the base on a fresh world.
- [ ] Save size stays small: only changed blocks are stored, not whole chunks.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Bump the save format; keep the format 1 and 2 loaders.

---

## Out of Scope

- Multiple save slots.

---

## Files

- src/save/save_game.gd
- src/world/voxel_world.gd
- src/mining/mine.gd
- src/machines/auto_drill.gd
- src/main.tscn
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/save_offline_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-017-console-auto-drills.md`
- Unlocks: `production/epics/heartwake/story-010-heart-sight.md`

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 5/5 passing (self-check round trip of world edits, drills and player; windowed probe: dug a pit and placed a drill, saved, aged the save by 10 minutes and restarted: 36 edits came back, the drill dug 20 more blocks while away, and the summary said so; save was 1.6 KB)
**Deviations**: Save format 3 drops the MVP shaft's depth, damage and revealed fields; damage on half-dug blocks is not saved. Formats 1 and 2 load their economy and ores onto a fresh world from their seed, with the player where the scene puts them.
**Fixed in passing**: `SaveGame` loaded before `VoxelWorld` was set up, so a restored drill saw only air and dug forever. `World` now comes first in `main.tscn`, and a drill past the world's floor stops.
**Test Evidence**: waived at qa.level minimal; self-check `tests/integration/heartwake/save_offline_check.gd` passes; screenshot in `production/qa/evidence/story-018-world-saves/`
**Reviewed by**: self, no independent review
