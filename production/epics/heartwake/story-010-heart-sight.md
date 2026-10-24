# Story 010: Heart stage 4: Sight

> **Epic**: Heartwake
> **Status**: Ready
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

*From `design/game-brief.md` (Milestone 2 item 12), scoped to this story:*

- [ ] Sight is the fourth stage, after Breath, with its threshold, effect and story line read from `data/heart_stages.json`.
- [ ] After Sight, blocks with ore are marked on the shaft view before they are dug, for a tuning number of blocks below the current depth.
- [ ] Before Sight, unknown blocks look the same whether they hold ore or rock.
- [ ] The marks match what digging finds: a marked block yields that ore, an unmarked one does not.
- [ ] Reaching Sight shows its story line, and the Heart panel shows Sight as the current stage.
- [ ] Sight's reach is derived from the stage index alone, so a loaded save shows the marks with no extra saved field.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- `DigShaft.block_at(d)` is deterministic from the seed, so the view can ask it ahead of the depth.
- The Heart panel's "Every stage reached" text moves to after Voice (story 011).

---

## Out of Scope

- A moon-wide scan map: the shaft view is the only map.
- Stage 6 Wake: brief Out of scope.

---

## Files

- src/heart/heart.gd
- src/mining/dig_shaft_view.gd
- src/economy/economy.gd
- src/ui/heart_panel.gd
- data/heart_stages.json
- tests/integration/heartwake/heart_stages_check.gd

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
