# Story 021: Smooth terrain

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 24` (Build order 24)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 24), scoped to this story:*

- [ ] The moon's ground is a smooth surface built per chunk from a density field generated from the seed, not blocks.
- [ ] Ore lies in deposits shaped by 3D noise, by depth band from `data/ores.json`; the surface is coloured by what lies under it.
- [ ] The ground has collision the player walks on, with hard edges and an unbreakable floor.
- [ ] Chunks are built around the player within a radius and only where the ground surface passes, never all at once.
- [ ] A new world builds fast enough to start in a few seconds.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Surface nets over a 1 m sample grid: one vertex per cell the surface crosses, quads across sign changes. No big lookup tables.

---

## Out of Scope

- Caves and overhangs in generation: flat ground plus what the player carves.

---

## Files

- src/world/voxel_world.gd
- src/world/blocks.gd
- data/world.json
- data/ores.json
- tests/unit/heartwake/voxel_world_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/voxel_world_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-020-hand-tool-power.md`
- Unlocks: `production/epics/heartwake/story-022-carving-tool.md`
