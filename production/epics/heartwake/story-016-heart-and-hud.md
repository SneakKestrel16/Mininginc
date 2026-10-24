# Story 016: The Heart in the world + HUD

> **Epic**: Heartwake
> **Status**: Complete
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
- src/ui/hud.gd
- src/ui/hud.tscn
- src/world/voxel_world.gd
- data/world.json
- src/main.tscn
- src/ui/heart_panel.gd (deleted)
- src/mining/dig_shaft_view.gd (deleted)

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

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 5/5 passing (windowed probe on the second monitor: the Heart seen from the pit's edge asleep, then at Flicker with its line on screen, then awake at Breath, brighter, lighting the pit walls; the line faded to 0 after 8 s; HUD showed inventory, power and the stage meter)
**Deviations**: The Heart's pit is part of world generation (`heart_chamber_min`/`max` in `data/world.json`), so it costs no saved edits. The Heart is built in code (sphere, three cage rings, light), not a scene. The overlay's dig-shaft view is deleted along with the Heart panel; the economy's drills still dig the old shaft unseen until story 017.
**Test Evidence**: waived at qa.level minimal; no new self-check (visual); screenshots in `production/qa/evidence/story-016-heart-and-hud/`
**Reviewed by**: self, no independent review
