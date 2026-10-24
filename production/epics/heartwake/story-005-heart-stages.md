# Story 005: Heart stages 1–3 (Flicker, Pulse, Breath)

> **Epic**: Heartwake
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 5` (Build order 4)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop step 4, MVP feature 5, Player goal), scoped to this story:*

- [ ] When the Heart meter reaches a stage threshold, that stage is reached once, its bonus applies permanently, and the meter starts toward the next threshold.
- [ ] Each stage shows a one-line story beat when reached.
- [ ] **Flicker**: drones appear and feed the furnace automatically, so it no longer runs dry while there is coal.
- [ ] **Pulse**: all generator output is +25%.
- [ ] **Breath**: the next layer thaws, so the shaft can be dug past the surface layer (story 006 adds its contents).
- [ ] After Breath (stage 3) the meter shows that the MVP has no further stage, rather than a threshold that can never be met.
- [ ] Stage thresholds, bonus values and story lines are read from a data file, not hardcoded.
- [ ] Reaching a stage is a session-complete moment (brief: Player goal): the player can see which stage they are on at all times.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Bonuses touch three systems (furnace, all generators, the shaft); apply them through the simulation, not by editing each system's numbers in place, so story 007 can save the stage index alone.

---

## Out of Scope

- Stages 4–6 (Sight, Voice, Wake), launch and prestige: brief Out of scope.
- Story 006: the Shallow layer's ores and turbine.

---

## Files

- src/heart/heart.gd
- src/economy/economy.gd
- src/economy/power_split.gd
- src/mining/dig_shaft.gd
- src/mining/mine.gd
- src/mining/dig_shaft_view.gd
- src/ui/heart_panel.gd
- src/ui/heart_panel.tscn
- src/ui/power_panel.gd
- src/ui/power_panel.tscn
- src/main.tscn
- data/heart_stages.json
- data/economy.json
- data/ores.json
- tests/integration/heartwake/heart_stages_check.gd
- tests/unit/heartwake/power_split_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/heart_stages_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-001-power-split.md`, `production/epics/heartwake/story-003-furnace.md`, `production/epics/heartwake/story-004-drills.md`
- Unlocks: `production/epics/heartwake/story-006-steam-turbine.md`, `production/epics/heartwake/story-007-save-offline.md`
