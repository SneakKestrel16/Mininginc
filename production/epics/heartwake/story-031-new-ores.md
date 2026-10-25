# Story 031: New ores: iron, quartz, gold

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 8 item 36` (Build order 36)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 8 item 36), scoped to this story:*

- [ ] Iron lies from the crust to 80 m, quartz from 40 to 140 m, gold from 100 m down and rarer than uranium.
- [ ] Each comes in deposits, has its own colour, and glows under Sight.
- [ ] Digging them adds them to the inventory; the HUD lists only what the player holds.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Ores are data in data/ores.json; materials and colours in src/world/blocks.gd.

---

## Out of Scope

- Using the new ores (story 032).

---

## Files

- data/ores.json
- src/world/blocks.gd
- src/ui/hud.gd
- tests/unit/heartwake/voxel_world_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-030-wake-pacing.md`
- Unlocks: `production/epics/heartwake/story-032-crafting.md`
