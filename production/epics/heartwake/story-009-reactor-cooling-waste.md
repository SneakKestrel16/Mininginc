# Story 009: Reactor cooling, scram + waste

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 2 items 10–11` (Build order 10–11)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 2 items 10–11), scoped to this story:*

- [ ] Melting ice into the reactor removes heat; heat removed per ice is a tuning value.
- [ ] Heat at the limit scrams the reactor: it stops producing power at once, even with uranium left.
- [ ] A scrammed reactor stays off until heat falls to a restart level, then runs again on its own if it has uranium.
- [ ] The reactor panel shows heat against the limit and says when it has scrammed and why.
- [ ] Every uranium burned leaves waste, which piles up in a store shown on screen; waste has no use yet.
- [ ] Heat, scram state and waste are saved and restored, and offline progress can scram the reactor the same as live play.
- [ ] Heat limit, restart level, cooling per ice, passive cooling and waste per uranium are read from `data/economy.json`, not hardcoded.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Offline progress runs `Economy.advance` in bigger steps; check a scram is not skipped over at the offline step size.

---

## Out of Scope

- Waste as fuel or any other waste use: brief Out of scope.
- Automatic cooling (drones feeding ice): not in the brief.

---

## Files

- src/economy/fission_reactor.gd
- src/economy/economy.gd
- src/save/save_game.gd
- src/ui/reactor_panel.gd
- src/ui/reactor_panel.tscn
- data/economy.json
- tests/unit/heartwake/fission_reactor_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/fission_reactor_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-008-fission-reactor.md`
- Unlocks: `production/epics/heartwake/story-012-milestone-2-pacing.md`
