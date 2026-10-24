# Story 013: Voxel moon terrain

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D item 15` (Build order item 15)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D item 15), scoped to this story:*

- [ ] The moon is block terrain split into chunks, generated from the game's seed: the same seed always gives the same blocks.
- [ ] The top layer is an ice crust; below it each block is rock or an ore, picked by depth from the bands in `data/ores.json` (coal near the top, ice and copper below 50 m, uranium from 100 m).
- [ ] A block's hardness follows depth the same way the shaft's did, and rock below the frozen floor is harder until Breath thaws it.
- [ ] Only faces next to air are drawn, each block type has its own colour, and the terrain has collision a body can stand on.
- [ ] Breaking a block turns it to air, redraws only the chunks it touches, and reports what it held.
- [ ] The world has hard edges and a floor of unbreakable bedrock, so nothing falls out of it.
- [ ] Chunks are built around a point (the player, from story 014) out to a radius in `data/world.json`, and never all at once.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Godot has no built-in voxel terrain; mesh chunks in GDScript with `SurfaceTool`, vertex colours, and a trimesh collision shape.
- Reuse the ore bands and hardness rules from `DigShaft`; the economy's drills keep digging the old shaft until story 017.

---

## Out of Scope

- Ore veins or cave shapes: plain per-block chances for now; the pacing story retunes density.
- Textures and lighting polish.

---

## Files

- src/world/voxel_world.gd
- src/world/voxel_chunk.gd
- src/world/blocks.gd
- data/world.json
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

- Depends on: `production/epics/heartwake/story-009-reactor-cooling-waste.md`
- Unlocks: `production/epics/heartwake/story-014-first-person-miner.md`
