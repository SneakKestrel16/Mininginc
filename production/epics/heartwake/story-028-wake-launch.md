# Story 028: Wake and launch

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 7 item 32–33` (Build order 32–33)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 7 item 32–33), scoped to this story:*

- [x] Heart stage 6, Wake, follows Voice with a much larger threshold; the HUD counts six stages.
- [x] When Wake is reached the Heart rises in its cavern, glows at full strength, and says its last lines.
- [x] Looking at the awake Heart offers [E] Launch; before Wake it only shows its stage.
- [x] Launching plays a short ending: fade out, the moon falling away below, the Heart's closing words, and the Resonance the run earned.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Data-driven: Wake is a stage in data/heart_stages.json with effect "wake".

---

## Out of Scope

- A cutscene with camera moves or models; the ending is an overlay.

---

## Files

- data/heart_stages.json
- src/heart/heart_machine.gd
- src/ui/ending.gd
- src/main.tscn
- tests/integration/heartwake/heart_stages_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-027-dig-feedback.md`
- Unlocks: `production/epics/heartwake/story-029-resonance.md`
