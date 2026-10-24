# Story 027: Dig feedback

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 6 item 31` (Build order 31)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 6 item 31), scoped to this story:*

- [x] Each scoop the player digs throws a short puff of dust at the scoop, coloured by what it cut most of.
- [x] Each scoop plays a short crunch from the scoop's position, varied in pitch so repeats do not drone.
- [x] Ore gained from a scoop shows by the crosshair for a moment ("+2 coal"); rock and crust do not.
- [x] Auto-drill scoops underground make no dust, sound or popup.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- The crunch is generated in code (filtered noise), so no audio asset is needed.

---

## Out of Scope

- A looping drill sound while the button is held.

---

## Files

- src/player/player.gd
- src/player/dig_effects.gd
- src/ui/hud.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: a probe screenshot of the dust and popup — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-026-upgrade-pacing.md`
- Unlocks: none
