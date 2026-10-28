# Story 044: The console and the away report say what the drills do

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 11 item 48, 49` (Build order 48, 49)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 11 item 48, 49), scoped to this story:*

- [ ] The power console's drill line has three cases. Drills working: "Drill power: 12.00 hits/s, shared by 6 auto-drills (they bore 2x per hit) and your hand tool while you cut". No drills placed: the hand tool takes it all, as today. Every placed drill at bedrock: "Every auto-drill is at bedrock: move the slider to the Heart". The multiplier is read from `mine.drill_efficiency`, never written as a literal.
- [ ] The auto-drill prompt states the multiplier from `mine.drill_efficiency`.
- [ ] The away report says "Drills dug on from %d m to %d m" when the deepest drill went deeper, and no drill line otherwise. `save_offline_check`: a save with a drill digging while away gives the line; one with no drills, or no growth, does not. Readers of the old `dug` field are found and moved first.
- [ ] Retained screenshots in `production/qa/evidence/story-044-*`: the console with no drills, with drills working, and with every drill at bedrock, plus the away report after time away with drills.
- [ ] All checks pass.

---

## Implementation Notes

- Last on purpose, so the screenshots show the shipped multiplier.
- Keep the label inside the power panel's width at the shipped font size; check it in the screenshot.

---

## Out of Scope

- Any change to the numbers (story 043).

---

## Files

- src/ui/power_panel.gd
- src/machines/auto_drill.gd
- src/save/save_game.gd
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: screenshots of each case in `production/qa/evidence/story-044-*`; save_offline_check passes.

**Status**: [ ] not yet

---

## Dependencies

- Depends on: `production/epics/heartwake/story-043-drill-efficiency.md`
- Unlocks: none
