# Story 036: An honest pacing simulator

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Config/Data
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 10 item 41` (Build order 41)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 10 item 41), scoped to this story:*

- [ ] With every placed drill stopped at bedrock, the simulator sends all power to the Heart. The old rule (only once every upgrade is maxed) stays as tuning key `legacy_slider`, and with it the simulator prints the story 033 table to the second: hand 96:42, 6 drills 50% 60:04, 100% 98:36, 25% 90:59; Resonance 1: 76:01 / 42:33 / 78:00 / 62:57.
- [ ] Seeds 1234, 7 and 99 run by default (`-- seed=N` runs one); strategies add 35% and 65% Heart.
- [ ] Each drill run prints when the deepest drill passes 150, 250, 340 and 400 m, the world's edits at Wake (FAIL above 150,000), and the ore left over at Wake.
- [ ] Upgrades are bought from a short preferred list, then every other upgrade in `data/upgrades.json` order; an id the data lacks is skipped without error.
- [ ] Every strategy prints a finish time or a reason; none is STUCK. The three-seed table is in Results below.

---

## Implementation Notes

- `tools/pacing_sim.gd` only; no game code changes.
- The old rule left half the power on drills parked at bedrock for 10–20 minutes, because `tool_motor` never maxes (its plates need iron above 80 m). The panel measured 6 drills at 50% at 49:28 on seed 1234 under the new rule against 60:04 under the old; that moves the baseline, not the game.

---

## Out of Scope

- Walking, Recall and vault diving: the simulator does not model them.

---

## Files

- tools/pacing_sim.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: the simulator's output, kept in Results below.

**Status**: [ ] Not yet created

---

## Results

*Filled in when the story is built.*

---

## Dependencies

- Depends on: `production/epics/heartwake/story-035-solid-panels.md`
- Unlocks: `production/epics/heartwake/story-037-strata.md`
