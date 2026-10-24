# Story 019: Dev menu

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: UI
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 4 item 22` (Build order 22)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 4 item 22), scoped to this story:*

- [ ] F1 opens and closes a dev menu over the game; while it is open the mouse is free and the player does not move.
- [ ] It adds any amount of each ore to the inventory.
- [ ] It sets the Heart's stage and fills its meter, and the stage's bonuses apply at once.
- [ ] It skips time by a chosen amount, running the same simulation offline progress uses.
- [ ] It toggles fly mode: no gravity, move through the ground, Space up and Ctrl down.
- [ ] It teleports the player to the base or to the Heart.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Dev-only, but it ships in friends' builds too; that is fine for a friends-only game.

---

## Out of Scope

- Hiding it behind a cheat code.

---

## Files

- src/ui/dev_menu.gd
- src/ui/dev_menu.tscn
- src/player/player.gd
- src/main.tscn

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: a probe screenshot of each control — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-018-world-saves.md`
- Unlocks: `production/epics/heartwake/story-020-hand-tool-power.md`
