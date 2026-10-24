# Story 025: Upgrade shop

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 5 item 28–29` (Build order 28–29)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 5 item 28–29), scoped to this story:*

- [ ] The power console's panel lists each upgrade with its level, cap, effect and the ore the next level costs.
- [ ] Buying takes the ore and raises the level; it is refused when ore is short or the cap is reached.
- [ ] Each level costs more than the last.
- [ ] Tool motor speeds hand digging; wider scoop carves bigger chunks; longer arm adds reach; drill gearing speeds drill power.
- [ ] Upgrade levels are saved and loaded, and take effect at once; older saves load with none bought.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Costs, caps and effects live in data/upgrades.json.
- Upgrade levels stay within the save format 4 as an optional key, so no format bump.

---

## Out of Scope

- Refunds or selling levels back.

---

## Files

- data/upgrades.json
- src/economy/upgrades.gd
- src/economy/economy.gd
- src/player/player.gd
- src/world/voxel_world.gd
- src/ui/upgrade_panel.gd
- src/main.tscn
- src/save/save_game.gd
- tests/unit/heartwake/upgrades_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-024-smooth-saves-pacing.md`
- Unlocks: `production/epics/heartwake/story-026-upgrade-pacing.md`
