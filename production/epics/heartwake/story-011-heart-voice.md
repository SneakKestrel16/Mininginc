# Story 011: Heart stage 5: Voice

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 2 item 13` (Build order 13)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 2 item 13), scoped to this story:*

- [ ] Voice is the fifth stage, after Sight, with its threshold and lines read from `data/heart_stages.json`.
- [ ] Reaching Voice shows a short run of lines, one at a time, that hint the Heart is a seed ship or a beacon.
- [ ] The player can read the lines again after reaching Voice.
- [ ] Voice grants a gameplay bonus read from the data file, so reaching it changes the best slider setting (brief Core loop).
- [ ] After Voice the meter shows that this build has no further stage, as it did after Breath.
- [ ] Voice's lines and bonus follow from the stage index alone, so a loaded save keeps them.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Pick the bonus from effects that already exist (`output_bonus`, drill speed) unless story 012's tuning needs a new one.

---

## Out of Scope

- Stage 6 Wake, launch and the star map: brief Out of scope.
- Story logs beyond these lines: brief Out of scope.

---

## Files

- src/heart/heart.gd
- src/economy/economy.gd
- src/ui/heart_panel.gd
- src/ui/heart_panel.tscn
- data/heart_stages.json
- tests/integration/heartwake/heart_stages_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/heart_stages_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-010-heart-sight.md`
- Unlocks: `production/epics/heartwake/story-012-milestone-2-pacing.md`
