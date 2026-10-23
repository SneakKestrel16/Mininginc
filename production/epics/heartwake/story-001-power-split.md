# Story 001: Power split slider + Heart meter

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 3` (Build order 1)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop step 3, MVP feature 3, Build order 1), scoped to this story:*

- [ ] A power source produces a steady amount of power per second; until story 003 lands it is a fake source with a tunable rate.
- [ ] One slider splits that power between **Drills** and **Heart**, from 0% to 100% Heart; the two shares always add up to the total produced.
- [ ] Power sent to the Heart fills a Heart meter toward its next stage threshold; the meter shows current progress and the threshold.
- [ ] Power sent to the Drills is reported as available drill power (story 004 consumes it); with no drills yet it is shown, not lost silently.
- [ ] Moving the slider changes both rates on the next tick, with no reset of progress already made.
- [ ] At 100% Heart the drill share is 0, and at 0% Heart the meter does not move.
- [ ] The power rate, tick length and first stage threshold are read from a data file, not hardcoded.
- [ ] The split arithmetic lives in a plain script with no scene dependency, so it can be unit tested.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Keep the economy simulation (rates, ticks) separate from the UI nodes that display it; later stories add producers and consumers to the same simulation.

---

## Out of Scope

- Story 003: real power from the furnace.
- Story 004: drills spending the drill share.
- Story 005: what happens when a Heart stage is reached.

---

## Files

- src/economy/power_split.gd
- src/economy/economy.gd
- src/ui/power_panel.gd
- src/ui/power_panel.tscn
- src/main.tscn
- data/economy.json
- export_presets.cfg
- tests/unit/heartwake/power_split_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/power_split_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/heartwake/story-003-furnace.md`, `production/epics/heartwake/story-004-drills.md`, `production/epics/heartwake/story-005-heart-stages.md`

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 8/8 passing (AC-5 by a headless probe: slider to 100% moved Heart progress 2.00 → 6.00 with drill share 0, no reset)
**Deviations**: None
**Test Evidence**: waived at qa.level minimal; self-check `tests/unit/heartwake/power_split_check.gd` passes; screenshot `production/qa/evidence/story-001-power-split/heart-meter-3s.png`
**Reviewed by**: self, no independent review
