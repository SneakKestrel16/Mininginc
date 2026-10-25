# Story 034: Ore flecks on the ground

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 9 item 39` (Build order 39)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 9 item 39), scoped to this story:*

- [ ] Rock and crust show a fine grain instead of flat colour.
- [ ] Every ore surface is flecked with specks in its own colour that catch the light; coal's specks glint against its black.
- [ ] A deposit stands out from plain rock in a probe screenshot, lit by the headlamp only.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- One terrain shader; the mesher marks ore vertices so the shader knows where to fleck.

---

## Out of Scope

- Textures or normal maps from files.

---

## Files

- src/world/voxel_world.gd
- src/world/terrain.gdshader

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: a probe screenshot — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-033-parts-as-costs.md`
- Unlocks: `production/epics/heartwake/story-035-solid-panels.md`
