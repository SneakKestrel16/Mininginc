# Story 038: Deep ores and the second shop

> **Epic**: Heartwake
> **Status**: Complete
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

- [x] Cobalt occurs only in the Deep (150–249 m), amethyst only in the Abyss (250–339 m), heartstone only in the Core (340–399 m). Adding them moves no existing deposit: with the new rows removed, the world differs only where the new ores now stand.
- [x] Each new ore colour stands at least 0.40 (RGB distance) from every other block colour.
- [x] Recipes: alloy (2 cobalt + 10 coal), lens (4 amethyst + 1 glass), core cell (6 heartstone + 1 lens + 1 alloy).
- [x] Deep rock is harder: Deep x1.5, Abyss x2, Core x3.
- [x] Four upgrades bought with the new parts: Deep tuning (+5% generator output per level), Carbide bit (+30% drill speed per level), Thermal lance (once Breath is reached, rock thaws 100 m deeper per level) and Core tap (+10 power/s per level, no fuel, takes the generator bonus).
- [x] Every upgrade's panel text shows the right whole number at every level (no 89% for 90%).
- [x] Simulator, three seeds: drill routes reach Wake earlier on every seed; none STUCK; edits at Wake at most 100,000. Hand only and 100% Heart are unchanged on seeds 1234 and 99; on seed 7 they are 8–10 minutes slower (see Results).
- [x] Old saves load with the new items and upgrades at zero.
- [x] Retained screenshot of the console with every upgrade and recipe row readable.

---

## Implementation Notes

- New ores are APPENDED to `data/ores.json` and `Blocks.NAMES`: each band's noise seed is `world_seed + 7919 * (index + 1)` and the first matching row wins, so inserting moves every deposit below it.
- An optional per-ore `frequency` in `data/ores.json` (default: the world's) makes deep lodes fewer and bigger. Panel numbers: cobalt chance 0.06 frequency 0.06; amethyst 0.05 / 0.06; heartstone 0.04 / 0.05. Colours: cobalt (0.20, 0.30, 1.00), amethyst (0.62, 0.25, 0.95), heartstone (1.00, 0.25, 0.60).
- Upgrades (effect per level x levels, base cost, growth): deep_tuning power_bonus 0.05 x 6, {alloy 3, uranium 20, circuit 1}, 1.5; carbide_bit drill_speed 0.3 x 4, {alloy 4, wire 6}, 1.6; thermal_lance thaw 100 x 3, {alloy 6, lens 2}, 2.0; core_tap flat_power 10 x 3, {core_cell 1, lens 2}, 2.0.
- Only two new effect names need code: `flat_power` (Economy adds it to power) and `thaw` (added to Breath's thaw depth, only once Breath is reached).
- Nothing refuses to dig at any depth.
- Built with the console re-laid out: power and crafting in the left column, upgrades in the right, because nine upgrade rows ran off a 648 px window.

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

**Status**: [x] `production/qa/evidence/story-038-deep-ores/` (2026-10-27): the console with nine upgrades and seven recipes at the default 1152x648 window, and the dev menu's wrapped ore buttons. Checks: voxel_world (bands, additive proof, colour guard), strata (hardness table), crafting (core cell), ore_sight (deep ores glow), upgrades (deep shop, panel text), save_offline (old saves). Each new check was seen failing against a mutation: ore seeds moved by the row count, cobalt's band widened, cobalt coloured like ice, the panel's rounding removed, the lance's Breath guard removed.

---

## Results

Wake times from `tools/pacing_sim.gd` (default idle rule), against the story 036 baseline. Edits at Wake at most 75,795. Nothing STUCK.

| Seed | Tuning | Hand only | 25% | 35% | 50% | 65% | 100% |
|---|---|---|---|---|---|---|---|
| 1234 | shipped | 96:42 (0) | 41:03 (−5:02) | 42:29 (−4:45) | 45:14 (−4:14) | 52:02 (−3:22) | 98:36 (0) |
| 1234 | Resonance 1 | 76:01 (0) | 30:06 (−3:19) | 31:00 (−3:09) | 32:48 (−2:45) | 35:32 (−2:11) | 78:00 (0) |
| 7 | shipped | 90:34 (+8:29) | 49:29 (−5:26) | 50:46 (−5:12) | 53:08 (−4:16) | 56:54 (−3:28) | 104:41 (+10:28) |
| 7 | Resonance 1 | 68:06 (+1:16) | 40:38 (−3:33) | 41:30 (−3:23) | 42:55 (−2:47) | 45:31 (−2:16) | 76:13 (0) |
| 99 | shipped | 75:39 (0) | 57:09 (−2:06) | 58:11 (−2:06) | 58:55 (−2:20) | 61:03 (−1:34) | 73:07 (0) |
| 99 | Resonance 1 | 59:07 (0) | 47:18 (−1:15) | 47:42 (−1:32) | 48:24 (−1:27) | 50:48 (−0:58) | 58:54 (0) |

Seed 1234 matches the design panel's prototype to the second. 25% Heart beats 65% by 11:00, 7:25 and 3:54 on the three seeds: the drill-heavy split stays best.

**Deep shop at 50% Heart** (first purchase, last Core tap, Wake): seed 1234 27:56, 36:10, 45:13 (drills reach 150 m at 27:43); seed 7 36:53, 44:56, 53:08; seed 99 41:21, 49:56, 58:54. Seed 99 runs short of cobalt and buys only two lance levels, as the panel expected.

**Hand only and 100% Heart on seed 7** are slower because their hand column digs on at 150–177 m, where Deep rock now costs 1.5 times as much (on seeds 1234 and 99 it stops at 150 m). The design panel expected these routes unchanged; this seed shows they are not. They were already the slowest routes and stay so. If a playtest finds hand digging in the Deep too slow, the knob is the Deep's `hardness` in `data/strata.json`.

---

## Dependencies

- Depends on: `production/epics/heartwake/story-037-strata.md`
- Unlocks: `production/epics/heartwake/story-039-recall.md`
