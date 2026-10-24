# Story 020: Drill power drives the hand tool

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 23` (Build order 23)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 23), scoped to this story:*

- [ ] The hand tool digs at a base rate plus a bonus that grows with the power on the Drills side of the slider.
- [ ] With no auto-drills placed, all drill power goes to the hand tool; with drills placed it is shared between them and the tool.
- [ ] The power panel and HUD say where drill power is going.
- [ ] The bonus per unit of power is read from data.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- The hand tool counts as one more drill in `Mine.dig`'s share, so the split stays in one place.

---

## Out of Scope

- Tool upgrades.

---

## Files

- src/mining/mine.gd
- src/player/player.gd
- src/ui/power_panel.gd
- src/ui/hud.gd
- src/main.tscn
- data/world.json
- tests/unit/heartwake/auto_drill_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/auto_drill_check.gd` extended — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-019-dev-menu.md`
- Unlocks: `production/epics/heartwake/story-021-smooth-terrain.md`

## Completion Notes
**Completed**: 2026-10-24
**Criteria**: 4/4 passing (`auto_drill_check.gd` covers the share; windowed probe: hand tool 4.0 hits/s with no power, 14.0 with the furnace's 10/s all on Drills, 4.0 again with all on the Heart; the HUD and power panel say where drill power goes)
**Deviations**: The hand tool always takes one share of drill power, even while the player is not drilling; that share is then unused. `hand_power_bonus` in `data/world.json` scales it (1.0 now). Pacing is retuned in story 024.
**Test Evidence**: waived at qa.level minimal; self-check `tests/unit/heartwake/auto_drill_check.gd` passes; screenshot in `production/qa/evidence/story-020-hand-tool-power/`
**Reviewed by**: self, no independent review
