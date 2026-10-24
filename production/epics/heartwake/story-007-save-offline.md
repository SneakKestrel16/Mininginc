# Story 007: Save/load + offline progress

> **Epic**: Heartwake
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 7` (Build order 6)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP feature 7, Player goal & fail state), scoped to this story:*

- [ ] The game saves automatically at an interval and on quit, to `user://` (the launcher's updates never touch it; see `INSTALL.md`).
- [ ] Loading restores ore counts, depth, shaft seed, generators and their fuel/water, slider position, Heart progress and stage.
- [ ] On load, time since the last save is simulated as offline progress, up to a tunable cap.
- [ ] Offline, generators keep running only while they have fuel: a hand-fed furnace burns out; with Flicker's drones it keeps being fed while coal lasts.
- [ ] After offline progress the player sees a summary of what was earned while away.
- [ ] A missing or unreadable save starts a new game instead of crashing, and the unreadable file is kept, not overwritten, so it can be inspected.
- [ ] The save holds a format version so a later build can migrate it.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Offline progress should run the same simulation as live play in large steps, not a separate formula, so the two cannot drift apart.

---

## Out of Scope

- Cloud saves and multiple save slots: not in the brief.

---

## Files

- src/save/save_game.gd
- src/economy/economy.gd
- src/main.tscn
- data/save.json
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/heartwake/save_offline_test.gd` or a playtest doc — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-005-heart-stages.md`, `production/epics/heartwake/story-006-steam-turbine.md`
- Unlocks: None
