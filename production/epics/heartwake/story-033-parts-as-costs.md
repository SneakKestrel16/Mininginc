# Story 033: Parts as costs

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 8 item 38` (Build order 38)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 8 item 38), scoped to this story:*

- [ ] An auto-drill costs iron plates and copper wire.
- [ ] The reactor costs copper and circuits.
- [ ] Upgrade levels cost parts as well as ore.
- [ ] The pacing simulator crafts the parts each purchase needs; no strategy gets stuck, and a drills-heavy split stays ahead.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Results table goes in this story file.

---

## Out of Scope

- New machines built from parts.

---

## Files

- data/world.json
- data/economy.json
- data/upgrades.json
- src/mining/mine.gd
- src/economy/economy.gd
- tools/pacing_sim.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-032-crafting.md`
- Unlocks: none
