# Story 043: Set the drill bonus and record the new baseline

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Core
> **Type**: Config/Data
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 11 item 46, 50` (Build order 46)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 11 item 46, 50), scoped to this story:*

- [ ] `data/world.json` gains `"drill_efficiency": 2.0` after `hand_power_bonus`. With shipped data the simulator exits 0 and prints met for seeds 1234, 7 and 99 on the shipped moon and on Resonance 1, at attention 0.5. Panel targets for the best 6-drill split at the 2% margin, shipped moon: seed 1234 at most 32:30, seed 7 at most 33:23, seed 99 at most 35:17. Resonance 1 at 2.0 is measured here for the first time.
- [ ] Hand only at 50% Heart stays within 5 s of 33:10 / 34:04 / 35:59. If hand only at 35% Heart beats the best 6-drill split anywhere, or seed 7 falls short of the margin, raise `drill_efficiency` to 2.25, then 2.5, and re-run every seed on both moons. `hand_power_bonus` is not touched.
- [ ] Record whether the 25%, 35% and 50% Heart splits each beat hand only (advisory, not a gate).
- [ ] The best 6-drill split is no slower than the story 036 table (34:13 / 38:31 / 38:53). The panel measured 15–19% faster; the compression is accepted and recorded, and the Wake threshold is not raised here.
- [ ] The attention 0.35 and 0.25 rows and the sittings rows end awake with edits at Wake under 150,000 (print only).
- [ ] The full baseline table goes into this story's Results; story 036's balance finding points here.

---

## Implementation Notes

- No panel run covered efficiency 2.0 together with the idle-share rule, the new rows or Resonance 1. Every number above for those is inference until this story runs them. Write the Results from the simulator output, not from these targets.
- Seed 7 is the thinnest (3.9% margin in the panel's run). If the combined run leaves it short, raise the value rather than loosen the gate.

---

## Out of Scope

- Raising the Wake threshold or lowering `offline_cap_seconds`: no run covers either; a playtest decides.

---

## Files

- data/world.json
- production/epics/heartwake/story-036-honest-simulator.md

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: simulator exit 0 on three seeds; the table in Results.

**Status**: [ ] not yet

---

## Dependencies

- Depends on: `production/epics/heartwake/story-042-sim-plays-people.md`
- Unlocks: `production/epics/heartwake/story-044-drill-console.md`
