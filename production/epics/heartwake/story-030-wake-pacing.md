# Story 030: Pacing through Wake

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 7 item 35` (Build order 35)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 7 item 35), scoped to this story:*

- [x] The pacing simulator plays until Wake and reports when it was reached.
- [x] A second pass with one point of Resonance reaches Wake clearly faster than the first.
- [x] No strategy gets stuck; every self-check passes.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Results table goes in this story file.

---

## Out of Scope

- Tuning the Voice-and-earlier thresholds.

---

## Files

- tools/pacing_sim.gd
- data/heart_stages.json
- data/economy.json

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-029-resonance.md`
- Unlocks: none

## Results (shipped tuning, seed 1234, tools/pacing_sim.gd)

The simulated player moves the slider to 100% Heart once every upgrade is maxed.

| Strategy | Voice | Wake | Wake, Resonance 1 |
|---|---|---|---|
| hand only, 50% Heart | 47:07 | 64:25 | 54:35 |
| 6 drills, 50% Heart | 44:23 | 55:22 | 44:40 |
| 6 drills, 100% Heart | 47:43 | 65:01 | 55:09 |
| 6 drills, 25% Heart | 41:09 | 52:07 | 42:17 |

Resonance was first added to the other output bonuses, which gave only +23% power late in a
run (Wake 64:26 to 56:28). It now multiplies them: +50% power per point. The second moon is
about 18% faster. One seed, one player model.
