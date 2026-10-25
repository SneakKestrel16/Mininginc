# Story 029: Resonance reset

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 7 item 34` (Build order 34)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 7 item 34), scoped to this story:*

- [x] Each launch earns one point of Resonance.
- [x] After the ending, a new moon starts: new seed, no ore, machines, drills, upgrades or Heart progress, player at the base.
- [x] Every point of Resonance adds a fixed share of output to every generator, for good.
- [x] Resonance lives in its own file next to the save, survives the reset, and shows on the HUD once above zero.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- The run save is deleted on launch, so a crash mid-reset cannot bring back the finished run.

---

## Out of Scope

- Spending Resonance on choices; more than one prestige currency.

---

## Files

- src/save/save_game.gd
- src/economy/economy.gd
- src/ui/ending.gd
- src/ui/hud.gd
- data/economy.json
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-028-wake-launch.md`
- Unlocks: `production/epics/heartwake/story-030-wake-pacing.md`
