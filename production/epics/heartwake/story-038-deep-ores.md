# Story 038: Deep ores and the second shop

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 10 item 43` (Build order 43)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: MEDIUM
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 10 item 43), scoped to this story:*

- [ ] Cobalt occurs only in the Deep (150–249 m), amethyst only in the Abyss (250–339 m), heartstone only in the Core (340–399 m). Adding them moves no existing deposit: with the new rows removed, the world differs only where the new ores now stand.
- [ ] Each new ore colour stands at least 0.40 (RGB distance) from every other block colour.
- [ ] Recipes: alloy (2 cobalt + 10 coal), lens (4 amethyst + 1 glass), core cell (6 heartstone + 1 lens + 1 alloy).
- [ ] Deep rock is harder: Deep x1.5, Abyss x2, Core x3.
- [ ] Four upgrades bought with the new parts: Deep tuning (+5% generator output per level), Carbide bit (+30% drill speed per level), Thermal lance (once Breath is reached, rock thaws 100 m deeper per level) and Core tap (+10 power/s per level, no fuel, takes the generator bonus).
- [ ] Every upgrade's panel text shows the right whole number at every level (no 89% for 90%).
- [ ] Simulator, three seeds: hand only and 100% Heart within a minute of story 036's baseline; drill routes reach Wake earlier; none STUCK; edits at Wake at most 100,000.
- [ ] Old saves load with the new items and upgrades at zero.
- [ ] Retained screenshot of the console with every upgrade and recipe row readable.

---

## Implementation Notes

- New ores are APPENDED to `data/ores.json` and `Blocks.NAMES`: each band's noise seed is `world_seed + 7919 * (index + 1)` and the first matching row wins, so inserting moves every deposit below it.
- An optional per-ore `frequency` in `data/ores.json` (default: the world's) makes deep lodes fewer and bigger. Panel numbers: cobalt chance 0.06 frequency 0.06; amethyst 0.05 / 0.06; heartstone 0.04 / 0.05. Colours: cobalt (0.20, 0.30, 1.00), amethyst (0.62, 0.25, 0.95), heartstone (1.00, 0.25, 0.60).
- Upgrades (effect per level x levels, base cost, growth): deep_tuning power_bonus 0.05 x 6, {alloy 3, uranium 20, circuit 1}, 1.5; carbide_bit drill_speed 0.3 x 4, {alloy 4, wire 6}, 1.6; thermal_lance thaw 100 x 3, {alloy 6, lens 2}, 2.0; core_tap flat_power 10 x 3, {core_cell 1, lens 2}, 2.0.
- Only two new effect names need code: `flat_power` (Economy adds it to power) and `thaw` (added to Breath's thaw depth, only once Breath is reached).
- Nothing refuses to dig at any depth.

---

## Out of Scope

- Per-drill geothermal taps with cable loss; reactor waste as fuel; Resonance from heartstone.

---

## Files

- data/ores.json
- data/strata.json
- data/recipes.json
- data/upgrades.json
- src/world/blocks.gd
- src/world/voxel_world.gd
- src/economy/economy.gd
- src/ui/upgrade_panel.gd
- src/ui/dev_menu.gd
- tests/unit/heartwake/*_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: headless checks pass; console screenshot in `production/qa/evidence/story-038-*`.

**Status**: [ ] Not yet created

---

## Results

*Filled in when the story is built.*

---

## Dependencies

- Depends on: `production/epics/heartwake/story-037-strata.md`
- Unlocks: `production/epics/heartwake/story-039-recall.md`
