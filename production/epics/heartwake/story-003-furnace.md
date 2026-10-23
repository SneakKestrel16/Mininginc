# Story 003: Hand-fed furnace

> **Epic**: Heartwake
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 2` (Build order 2)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop step 2, MVP feature 2, Player goal & fail state), scoped to this story:*

- [ ] The player feeds coal from the ore counter into the furnace by hand; feeding with no coal does nothing.
- [ ] The furnace burns its loaded coal over time and produces power while it burns.
- [ ] When its fuel runs out it stops producing power: this is the brief's stall, and it is visible to the player (fuel gauge empty, output 0).
- [ ] Furnace power replaces the fake source from story 001 and goes through the same Drills/Heart split.
- [ ] Fuel capacity, burn time per coal and power per second are read from a data file, not hardcoded.
- [ ] Fuel use and output are deterministic for a given tick count, so they can be unit tested.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Model the furnace as a generator in the story 001 simulation; story 006's steam turbine is the second generator.

---

## Out of Scope

- Story 005: drones that feed the furnace automatically (Flicker stage).
- Story 006: the steam turbine.

---

## Files

- src/economy/furnace.gd
- src/economy/economy.gd
- src/mining/mine.gd
- src/mining/dig_shaft_view.gd
- src/ui/furnace_panel.gd
- src/ui/furnace_panel.tscn
- src/main.tscn
- data/economy.json
- tests/unit/heartwake/furnace_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/furnace_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-001-power-split.md`, `production/epics/heartwake/story-002-dig-shaft.md`
- Unlocks: `production/epics/heartwake/story-005-heart-stages.md`, `production/epics/heartwake/story-006-steam-turbine.md`
