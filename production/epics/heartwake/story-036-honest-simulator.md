# Story 036: An honest pacing simulator

> **Epic**: Heartwake
> **Status**: Complete
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

- [x] With every placed drill stopped at bedrock, the simulator sends all power to the Heart. The old rule (only once every upgrade is maxed) stays as tuning key `legacy_slider`, and with it the simulator prints the story 033 table to the second: hand 96:42, 6 drills 50% 60:04, 100% 98:36, 25% 90:59; Resonance 1: 76:01 / 42:33 / 78:00 / 62:57.
- [x] Seeds 1234, 7 and 99 run by default (`-- seed=N` runs one); strategies add 35% and 65% Heart.
- [x] Each drill run prints when the deepest drill passes 150, 250, 340 and 400 m, the world's edits at Wake (FAIL above 150,000), and the ore left over at Wake.
- [x] Upgrades are bought from a short preferred list, then every other upgrade in `data/upgrades.json` order; an id the data lacks is skipped without error.
- [x] Every strategy prints a finish time or a reason; none is STUCK. The three-seed table is in Results below.

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

**Status**: [x] Results below (2026-10-27)

---

## Results

Wake times from `tools/pacing_sim.gd`, 2026-10-27. Every run ends awake; none STUCK. Edits at Wake: 11,539–75,261, all under the 150,000 budget.

**Legacy slider, seed 1234** (run with `no_such_upgrade` injected at the head of the upgrade list; it was skipped): hand 96:42, drills 25% 90:59, 50% 60:04, 100% 98:36; Resonance 1: 76:01 / 62:57 / 42:33 / 78:00. The story 033 table, to the second.

**New baseline (idle drills send all power to the Heart):**

| Seed | Tuning | Hand only | 25% | 35% | 50% | 65% | 100% |
|---|---|---|---|---|---|---|---|
| 1234 | shipped | 96:42 | 46:05 | 47:14 | 49:28 | 55:24 | 98:36 |
| 1234 | Resonance 1 | 76:01 | 33:25 | 34:09 | 35:33 | 37:43 | 78:00 |
| 7 | shipped | 82:05 | 54:55 | 55:58 | 57:24 | 60:22 | 94:13 |
| 7 | Resonance 1 | 66:50 | 44:11 | 44:53 | 45:42 | 47:47 | 76:13 |
| 99 | shipped | 75:39 | 59:15 | 60:17 | 61:15 | 62:37 | 73:07 |
| 99 | Resonance 1 | 59:07 | 48:33 | 49:14 | 49:51 | 51:46 | 58:54 |

**Deepest drill passes 150 / 250 / 340 / 400 m (shipped, 50% Heart):** seed 1234 27:43 / 31:32 / 35:58 / 38:50; seed 7 36:41 / 40:29 / 45:13 / 47:19; seed 99 41:12 / 44:43 / 49:04 / 51:03.

The drill rows drop by about 11 minutes against the legacy rule (60:04 to 49:28 at 50%): the old model left half the power on drills parked at bedrock. That is the simulator, not the game; later stories compare against this table.

---

## Dependencies

- Depends on: `production/epics/heartwake/story-035-solid-panels.md`
- Unlocks: `production/epics/heartwake/story-037-strata.md`
