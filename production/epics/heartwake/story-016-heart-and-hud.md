# Story 016: The Heart in the world + HUD

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 3D items 18–19` (Build order items 18–19)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 3D items 18–19), scoped to this story:*

- [ ] The Heart is a large machine buried near the base, visible from the surface through an opening.
- [ ] It glows and pulses, brighter and faster at each stage.
- [ ] Reaching a stage shows its story line as on-screen text that fades after a few seconds.
- [ ] The HUD shows a crosshair, the inventory (one count per ore), total power per second, and the Heart's stage with progress to the next.
- [ ] With the HUD in place the Tab overlay keeps only the power slider, until story 017 moves it to the console.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- An `OmniLight3D` and an emissive material driven from the stage index; the pulse is a sine on energy.

---

## Out of Scope

- Sight's ore highlighting: story 010, after this milestone.

---

## Files

- src/heart/heart_machine.gd
- src/heart/heart_machine.tscn
- src/ui/hud.gd
- src/ui/hud.tscn
- src/main.tscn

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/heart_hud_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-015-world-machines.md`
- Unlocks: `production/epics/heartwake/story-017-console-auto-drills.md`
