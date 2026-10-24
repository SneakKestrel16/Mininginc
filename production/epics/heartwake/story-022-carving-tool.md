# Story 022: Carving tool on smooth ground

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 25` (Build order 25)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 25), scoped to this story:*

- [ ] Holding the tool scoops a round chunk out of the ground at the point aimed at; harder and deeper rock takes longer per scoop.
- [ ] Ore inside each scoop goes into the inventory, by how much of the scoop it filled.
- [ ] A marker shows where the next scoop lands and how close it is.
- [ ] Auto-drills bore down by scooping a column under them.
- [ ] Sight shows ore deposits through the ground near the player.
- [ ] Machines no longer float: digging is blocked under machines and the console.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Carving takes the minimum of the old density and the sphere's signed distance, so the hole is smooth and only ever grows.

---

## Out of Scope

- Building up ground (placing).

---

## Files

- src/world/voxel_world.gd
- src/player/player.gd
- src/machines/auto_drill.gd
- src/heart/ore_sight.gd
- src/mining/mine.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: probe screenshots plus `voxel_world_check.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-021-smooth-terrain.md`
- Unlocks: `production/epics/heartwake/story-023-buried-heart.md`
