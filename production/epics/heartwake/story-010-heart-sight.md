# Story 010: Heart stage 4: Sight

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 2 item 12` (Build order 12)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 2 item 12, rewritten for Milestone 3D: Sight becomes ore veins glowing through the rock), scoped to this story:*

- [ ] Sight is the fourth stage, after Breath, with its threshold, effect, reach and story line read from `data/heart_stages.json`.
- [ ] After Sight, every ore block within the reach of the player glows through the rock in its ore's colour, so the player can see where to dig.
- [ ] Before Sight nothing glows: hidden ore cannot be told from rock.
- [ ] The glow matches what digging finds: a glowing block yields that ore, and broken blocks stop glowing.
- [ ] The glow follows the player as they move and dig, without stalling the game.
- [ ] Sight's reach is derived from the stage index alone, so a loaded save shows the glow with no extra saved field.

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- `VoxelWorld.block_at` is deterministic from the seed and edits, so a scan around the player shows exactly what digging will find.
- Draw the glow as one `MultiMeshInstance3D` with depth testing off, rebuilt when the player moves a block or the world changes.

---

## Out of Scope

- A moon-wide scan map: the shaft view is the only map.
- Stage 6 Wake: brief Out of scope.

---

## Files

- src/heart/ore_sight.gd
- data/heart_stages.json
- src/main.tscn
- tests/unit/heartwake/ore_sight_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/heart_stages_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-005-heart-stages.md`
- Unlocks: `production/epics/heartwake/story-011-heart-voice.md`

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 6/6 passing (self-check `ore_sight_check.gd`; windowed probe on the second monitor: in a room 60 m down nothing glowed before Sight, and at Sight 412 hidden ore blocks glowed through the walls in their colours; one scan takes about 4 ms)
**Deviations**: Criteria rewritten for the 3D game before work began (brief Milestone 3D: Sight becomes ore glowing through the rock). Ore already showing on an open face does not glow, which cuts clutter. Sight's threshold is 2500, reach 6 blocks: placeholders for story 012.
**Known gap**: ore is so dense below 50 m (about 65% of blocks) that Sight looks busy there; story 012's density retune fixes the cause.
**Test Evidence**: waived at qa.level minimal; self-check `tests/unit/heartwake/ore_sight_check.gd` passes; screenshots in `production/qa/evidence/story-010-heart-sight/`
**Reviewed by**: self, no independent review
