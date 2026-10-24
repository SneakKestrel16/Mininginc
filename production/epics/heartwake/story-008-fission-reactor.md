# Story 008: Mid layer uranium + fission reactor

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 2 items 8–9` (Build order 8–9)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 2 items 8–9), scoped to this story:*

- [ ] Below Breath's thaw (depth 100 and down) the shaft holds uranium blocks found by digging, alongside coal and ice; ore bands come from `data/ores.json`.
- [ ] Copper is spent to build the fission reactor; the cost is a tuning value.
- [ ] Uranium is fed into the reactor by hand, up to a fuel capacity, like coal into the furnace.
- [ ] While it has uranium the reactor produces far more power than the turbine, and it stops when the uranium runs out (the brief's stall).
- [ ] Reactor power joins furnace and turbine power in the same Drills/Heart split, and Pulse's +25% applies to it.
- [ ] While running the reactor builds heat, shown on screen as a bar (cooling is story 009).
- [ ] Uranium count, reactor built flag, fuel and heat are saved and restored; a save from v0.1.x (format 1) still loads, with no reactor.
- [ ] Build cost, fuel capacity, burn time, power and heat rate are read from `data/economy.json`, not hardcoded.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Reuse the generator model from stories 003 and 006 (`Furnace` holds fuel and burn); the reactor adds heat.
- Save format goes to 2; `SaveGame.validate` accepts 1 and fills the new fields with defaults.

---

## Out of Scope

- Cooling and scram, waste: story 009.
- Deep tier and waste as fuel: brief Out of scope.

---

## Files

- src/economy/fission_reactor.gd
- src/economy/economy.gd
- src/save/save_game.gd
- src/ui/reactor_panel.gd
- src/ui/reactor_panel.tscn
- src/mining/dig_shaft_view.gd
- src/main.tscn
- data/ores.json
- data/economy.json
- tests/unit/heartwake/fission_reactor_check.gd
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/fission_reactor_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-006-steam-turbine.md`, `production/epics/heartwake/story-007-save-offline.md`
- Unlocks: `production/epics/heartwake/story-009-reactor-cooling-waste.md`, `production/epics/heartwake/story-012-milestone-2-pacing.md`

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 8/8 passing (probe set Heart stage 3 and gave 18 copper, 7 uranium; real clicks built and fed the reactor: 125/s with Pulse, heat rising)
**Deviations**: Heat is capped at `reactor_heat_limit` with no scram yet; story 009 adds cooling and scram. Fixed in passing: the ore counts now stack one per line, since a fourth ore pushed the layout past the window. Copper and ice also appear below depth 100, so the reactor's 15 copper and story 009's cooling ice can be found there.
**Known gap**: with the reactor running, 5 s offline steps ended one block shallower than 0.1 s live ticks over 5 minutes, because the reactor's power crosses a Heart stage inside a step. `save_offline_check.gd` compares offline and live play without the reactor; story 012 should look at the offline step size.
**Test Evidence**: waived at qa.level minimal; self-check `tests/unit/heartwake/fission_reactor_check.gd` passes, `save_offline_check.gd` covers the format 2 round trip and format 1 load; screenshots in `production/qa/evidence/story-008-fission-reactor/`
**Reviewed by**: self, no independent review
