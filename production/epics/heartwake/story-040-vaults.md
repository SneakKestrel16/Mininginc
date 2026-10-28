# Story 040: Vaults

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 10 item 45` (Build order 45)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 10 item 45), scoped to this story:*

- [ ] Each seed places sealed vaults in the Deep, Abyss and Core (counts per stratum in `data/strata.json`): squashed, lumpy hollows of air walled with the stratum's own ore, made from the seed alone, so nothing new is saved.
- [ ] The same seed gives the same vaults; every vault lies inside its stratum, clear of the walls and of each other, and is sealed (no air path to the surface, the Heart or another vault).
- [ ] Outside the vaults the world is unchanged.
- [ ] A vault's chunks are drawn, so its inside is visible and walkable.
- [ ] Near a vault a light in its ore's colour glows inside it, lighting the rock the player tunnels toward.
- [ ] The first scoop to break in shows a banner; once the Heart has Sight, the HUD says how far the nearest vault is (distance only).
- [ ] Auto-drills crossing a vault spend no hits on its air.
- [ ] Simulator: no strategy STUCK, no drill row moves more than 1:30 on any seed.
- [ ] Retained screenshots: the glow seen from a tunnel, the moment of breaking in, and the inside.

---

## Implementation Notes

- The vault rides the density field the way the Heart's cavern does: `min(ground, cavity)`, its chunks added to the open set.
- Panel numbers: counts deep 12, abyss 10, core 8; radius 3.5–6.0 m (core 3.5–5.5); shell 1.6 m; ore cover 0.45 / 0.50 / 0.60; light range 18 m, energy 1.8; Sight range 45 m.
- Keep the density hot path cheap: look vaults up by a coarse cell index only below 140 m.
- Riskiest item: built last; the milestone stands without it.

---

## Out of Scope

- Remembering which vaults were opened; vault sounds; caves in general.

---

## Files

- data/strata.json
- data/world.json
- src/world/voxel_world.gd
- src/machines/auto_drill.gd
- src/ui/hud.gd
- src/ui/dev_menu.gd
- tools/pacing_sim.gd
- tests/unit/heartwake/vault_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: headless check passes; screenshots in `production/qa/evidence/story-040-*`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-039-recall.md`
- Unlocks: none
