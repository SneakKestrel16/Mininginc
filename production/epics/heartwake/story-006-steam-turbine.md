# Story 006: Shallow layer + steam turbine

> **Epic**: Heartwake
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 6` (Build order 5)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP feature 6, Player goal & fail state), scoped to this story:*

- [ ] Below the surface layer, once Breath has thawed it, the shaft holds ice and copper blocks found by digging, the same way coal is.
- [ ] Ice melts into water; the conversion rate is a tuning value.
- [ ] Copper is spent to build the steam turbine.
- [ ] The turbine produces power only while it has both fuel and water, and stops when either runs out (the brief's stall).
- [ ] Turbine power joins furnace power in the same Drills/Heart split, and Pulse's +25% applies to it.
- [ ] Ore bands, melt rate, build cost and turbine output are read from a data file, not hardcoded.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Reuse the generator model from story 003; the turbine adds a second input (water).

---

## Out of Scope

- Fission and every deeper tier: brief Out of scope.
- Transmission loss and wiring upgrades: brief Out of scope.

---

## Files

- src/economy/steam_turbine.gd
- src/economy/economy.gd
- src/ui/turbine_panel.gd
- src/ui/turbine_panel.tscn
- src/ui/furnace_panel.gd
- src/ui/furnace_panel.tscn
- src/ui/power_panel.tscn
- src/ui/heart_panel.tscn
- src/main.tscn
- data/ores.json
- data/economy.json
- tests/unit/heartwake/steam_turbine_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/steam_turbine_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-003-furnace.md`, `production/epics/heartwake/story-005-heart-stages.md`
- Unlocks: `production/epics/heartwake/story-007-save-offline.md`
