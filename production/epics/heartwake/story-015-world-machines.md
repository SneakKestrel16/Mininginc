# Story 015: Machines in the world

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D item 17` (Build order item 17)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D item 17), scoped to this story:*

- [ ] The furnace, steam turbine and fission reactor stand at the base as 3D machines, in place of their 2D panels.
- [ ] Looking at a machine within reach shows a prompt naming it, its state, and what E does.
- [ ] E feeds coal to the furnace or turbine and uranium to the reactor; a second key (Q) melts ice into the turbine or cools the reactor.
- [ ] An unbuilt turbine or reactor shows as a frame; E builds it when the copper is there, and the prompt says how much it needs.
- [ ] Each machine shows its state on the model: lit while running, dark when out of fuel, red when the reactor has scrammed, plus a gauge for fuel, water or heat.
- [ ] Power output is unchanged from the 2D game: the same economy code drives the machines.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Simple primitive meshes (boxes, cylinders) with emissive materials are enough.

---

## Out of Scope

- Moving or rebuilding machines elsewhere.
- Machine art beyond primitives.

---

## Files

- src/machines/machine.gd
- src/player/player.gd
- src/player/player.tscn
- src/main.tscn
- src/ui/furnace_panel.gd (deleted)
- src/ui/turbine_panel.gd (deleted)
- src/ui/reactor_panel.gd (deleted)

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/machines_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-014-first-person-miner.md`
- Unlocks: `production/epics/heartwake/story-016-heart-and-hud.md`

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 6/6 passing (windowed probe on the second monitor, no mouse capture: looked at each machine, E fed the furnace, E built then fed the turbine, Q melted ice, E built and fed the reactor, a forced overheat showed the red scram lamp and Q cooled it back below restart; total power matched the economy)
**Deviations**: One `WorldMachine` script builds all three machines from primitives, picked by `kind`, instead of a scene per machine. The 2D furnace, turbine and reactor panels are deleted. Mouse-look now turns the view only while the game holds the mouse, so a free cursor over the window never moves it.
**Known gap**: machines stand on the surface blocks; digging out the block under one leaves it floating.
**Test Evidence**: waived at qa.level minimal; no new self-check (input-driven); screenshots in `production/qa/evidence/story-015-world-machines/`
**Reviewed by**: self, no independent review
