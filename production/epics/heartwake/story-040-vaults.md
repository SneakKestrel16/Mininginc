# Story 040: Vaults

> **Epic**: Heartwake
> **Status**: Complete
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

- [x] Each seed places sealed vaults in the Deep, Abyss and Core (counts per stratum in `data/strata.json`): squashed, lumpy hollows of air walled with the stratum's own ore, made from the seed alone, so nothing new is saved.
- [x] The same seed gives the same vaults; every vault lies inside its stratum, clear of the walls and of each other, and is sealed (no air path to the surface, the Heart or another vault).
- [x] Outside the vaults the world is unchanged.
- [x] A vault's chunks are drawn, so its inside is visible and walkable.
- [x] Near a vault a light in its ore's colour glows inside it, lighting the rock the player tunnels toward.
- [x] The first scoop to break in shows a banner; once the Heart has Sight, the HUD says how far the nearest vault is (distance only).
- [x] Auto-drills crossing a vault spend no hits on its air.
- [x] Simulator: no strategy STUCK, no drill row moves more than 1:30 on any seed.
- [x] Retained screenshots: the glow seen from a tunnel, the moment of breaking in, and the inside.

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

**Status**: [x] `production/qa/evidence/story-040-vaults/` (2026-10-27): a tunnel's far end tinted by a vault's light with the HUD's vault hint, breaking in with the banner, and standing inside on cobalt walls. `tests/unit/heartwake/vault_check.gd` passes: placement and counts on seeds 7, 8 and 1234, sealed air, unchanged ground outside, ore walls of 100–500 samples near their cover, open chunks and a reseed, lights near and gone, the breach signal once, drills paying only for rock, the HUD hint. It was seen failing with the drill's air skip, the chunk opening, the once-only guard and the vault spacing removed.

---

## Results

`tools/pacing_sim.gd`, three seeds, against story 038's table:

- **No vaults** (tuning `no_vaults`): every row on every seed equals story 038's, to the second.
- **With vaults**: seeds 1234 and 7 are unchanged (no drill column crosses a vault). On seed 99 one vault is crossed by a drill and the drill rows move by 0:16 to 0:50. Nothing STUCK; edits at Wake at most 75,538.
- The simulator never tunnels sideways, so a player hunting vaults by hand is covered only by the checks and screenshots.

Built with two changes found while checking: a vault changes density only out to 1 m past its shell (first draft lowered the density of solid rock in its whole 16 m lookup cell), and the HUD hint says "level with you" instead of "0 m up".

---

## Dependencies

- Depends on: `production/epics/heartwake/story-039-recall.md`
- Unlocks: none
