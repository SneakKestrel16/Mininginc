# Story 030: Pacing through Wake

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 7 item 35` (Build order 35)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 7 item 35), scoped to this story:*

- [ ] The pacing simulator plays until Wake and reports when it was reached.
- [ ] A second pass with one point of Resonance reaches Wake clearly faster than the first.
- [ ] No strategy gets stuck; every self-check passes.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Results table goes in this story file.

---

## Out of Scope

- Tuning the Voice-and-earlier thresholds.

---

## Files

- tools/pacing_sim.gd
- data/heart_stages.json
- data/economy.json

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-029-resonance.md`
- Unlocks: none
