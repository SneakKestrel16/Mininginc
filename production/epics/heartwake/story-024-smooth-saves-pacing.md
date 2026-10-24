# Story 024: Saves and pacing for smooth ground

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 27` (Build order 27)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 27), scoped to this story:*

- [ ] Saves keep every carved change to the ground, and loading rebuilds the same holes.
- [ ] A save from v0.2.x loads its economy and inventory onto a fresh smooth world.
- [ ] The pacing simulator digs by scooping, and the shipped tuning keeps a drills-heavy split ahead of 100% to the Heart, with no strategy stuck.
- [ ] Every self-check passes.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Save the changed samples only, as for blocks.

---

## Out of Scope

- Multiple save slots.

---

## Files

- src/save/save_game.gd
- tools/pacing_sim.gd
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `save_offline_check.gd` and simulator output — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-023-buried-heart.md`
- Unlocks: none
