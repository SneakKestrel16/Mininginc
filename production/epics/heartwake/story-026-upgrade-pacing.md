# Story 026: Pacing with upgrades

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 5 item 30` (Build order 30)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 5 item 30), scoped to this story:*

- [ ] The pacing simulator buys upgrades with ore not needed for machines or drills.
- [ ] With the shipped costs every strategy still wakes the Heart, none gets stuck, and a drills-heavy split stays ahead of 100% to the Heart.
- [ ] Every self-check passes.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Results table goes in this story file.

---

## Out of Scope

- Retuning Heart thresholds for the faster game, unless a strategy becomes trivially fast.

---

## Files

- tools/pacing_sim.gd
- data/upgrades.json

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: a headless self-check — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-025-upgrade-shop.md`
- Unlocks: none
