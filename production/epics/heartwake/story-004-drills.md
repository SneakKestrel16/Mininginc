# Story 004: Power-driven drills with depth cost

> **Epic**: Heartwake
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 4` (Build order 3)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop steps 1 and 3, MVP feature 4), scoped to this story:*

- [ ] Drills dig the same shaft as the player's clicks (story 002), with no clicking.
- [ ] Drills run only on the drill share of the power split; with 0 drill power they stop.
- [ ] Dig speed rises with drill power and falls as block hardness rises with depth.
- [ ] Ore in blocks the drills break is added to the same ore counters as hand digging.
- [ ] Clicking still works while drills run, and both act on the current block without double-counting it.
- [ ] Drill power-to-speed and any drill upgrade costs are read from a data file, not hardcoded.
- [ ] With all power sent to the Heart, income stops; with all power sent to the drills, the Heart stalls: the brief's core tension holds.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- The dig rate formula is a tuning knob; keep it in one function the data file feeds.

---

## Out of Scope

- Story 005: drones (automation of feeding, not digging).
- Story 006: layer changes below the surface layer.

---

## Files

- src/mining/dig_shaft.gd
- src/mining/mine.gd
- src/mining/dig_shaft_view.gd
- src/economy/economy.gd
- src/ui/power_panel.gd
- src/ui/power_panel.tscn
- data/economy.json
- tests/unit/heartwake/drills_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/drills_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-001-power-split.md`, `production/epics/heartwake/story-002-dig-shaft.md`
- Unlocks: `production/epics/heartwake/story-005-heart-stages.md`
