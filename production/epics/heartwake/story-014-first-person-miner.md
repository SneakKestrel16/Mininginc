# Story 014: First-person miner + hand drill

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D item 16` (Build order item 16)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D item 16), scoped to this story:*

- [ ] The game starts in first person on the surface: move with WASD, jump with Space, look with the mouse; Esc frees the mouse.
- [ ] The player collides with the terrain and cannot walk through blocks or off the world.
- [ ] Holding left click with the hand drill breaks the block under the crosshair within reach; harder blocks take proportionally longer, and letting go keeps the damage on that block.
- [ ] The block being drilled shows its damage, so the player can see it is working.
- [ ] Broken ore goes into the inventory, the same counts the economy already uses; rock and crust give nothing.
- [ ] The old 2D panels stay reachable as an overlay (Tab) until stories 015, 016 and 019 replace them, so the game stays playable.
- [ ] Move speed, jump, reach and drill speed are read from `data/world.json`.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- `CharacterBody3D` with a capsule; raycast from the camera to find the target block.

---

## Out of Scope

- Placing blocks.
- Tool upgrades.

---

## Files

- src/player/player.gd
- src/player/player.tscn
- src/main.tscn
- src/mining/mine.gd
- data/world.json

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/first_person_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-013-voxel-moon.md`
- Unlocks: `production/epics/heartwake/story-015-world-machines.md`
