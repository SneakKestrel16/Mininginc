# Story 023: The Heart buried in the planet

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 26` (Build order 26)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 26), scoped to this story:*

- [ ] The Heart lies in a sealed cavern deep below the base; nothing of it shows from the surface.
- [ ] The player reaches it by digging down; the cavern is open air once broken into.
- [ ] Its light and a low hum grow as the player gets closer, so they can dig toward it.
- [ ] The HUD shows roughly how far below the Heart is.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- The cavern is part of world generation, so it costs no saved edits.

---

## Out of Scope

- A story event on first reaching it.

---

## Files

- src/heart/heart_machine.gd
- src/world/voxel_world.gd
- data/world.json
- src/main.tscn

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: probe screenshots — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-022-carving-tool.md`
- Unlocks: `production/epics/heartwake/story-024-smooth-saves-pacing.md`
