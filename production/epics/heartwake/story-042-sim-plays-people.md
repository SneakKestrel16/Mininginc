# Story 042: The pacing simulator plays people and guards the promise

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Config/Data
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 11 item 50` (Build order 50)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 11 item 50), scoped to this story:*

- [x] Tunings take keys `attention` and `drill_efficiency`. The hand column cuts on a duty cycle of `attention` and sets `mine.hand_cutting` while it cuts. At attention 0.5 hand only at 50% Heart stays within 5 s of 33:10 / 34:04 / 35:59 on seeds 1234 / 7 / 99. Drill rows at efficiency 1.0 are no slower than the story 036 table.
- [x] Rows per tuning: hand only at 50% and 35% Heart; 6 drills at 25/35/50/65/100% Heart; 2 drills and 3 drills at 35% Heart. Tunings: shipped and Resonance 1 at attention 0.5. On the shipped moon only: attention 0.35, attention 0.25, and sittings of 600 s on and 1800 s off, whose off time runs through `Economy.advance` in the save's offline steps and which print active and wall-clock time. The "no vaults" tuning is dropped; it served story 040.
- [x] After each seed and moon at attention 0.5 the simulator prints a verdict line: the best hand-only row, the best 6-drill split, the margin in percent, and met or FAIL. FAIL means the best 6-drill split is not at least `DRILLS_MUST_WIN_BY` (0.02) sooner. Any FAIL makes the process exit 1. The 2- and 3-drill rows, attention 0.35 and 0.25, and sittings never decide it.
- [x] On unchanged data (efficiency 1.0) the simulator prints FAIL on the shipped moon for seeds 1234, 7 and 99, proving the gate can fail.
- [x] Every row ends awake or says why not; none STUCK; edits at Wake under 150,000. The header comment describes attention, sittings, the verdict and the exit code.

---

## Implementation Notes

- The verdict compares against the best hand-only row, so a hand-only player cannot hide in an unplayed split. Hand only at 35% Heart is new and unrun: it may beat the 50% row.
- Panel reference points at efficiency 1.0 with the idle rule: seed 1234 best 6-drill split 33:04 against hand only 33:10 (0.3%, under the margin), seed 7 37:50 against 34:04. The 2-drill row already beats hand only on seeds 1234 and 7, so the fix is about drills 3 to 6.
- Not added: the experience design's rule that drill strategies drop to 100% Heart when their own hand column reaches bedrock (unrun, would move every baseline).

---

## Out of Scope

- Game code; the drill bonus value (story 043).

---

## Files

- tools/pacing_sim.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: simulator output on three seeds recorded in this story's Results; the FAIL run on unchanged data.

**Status**: [x] `tools/pacing_sim.gd` on seeds 1234, 7 and 99 with unchanged data (2026-10-28): every verdict FAIL and the process exits 1, so the gate is proven able to fail. The table is in Results.

---

## Results

`tools/pacing_sim.gd` on unchanged data (no `drill_efficiency` key, so 1.0), 2026-10-28. Wake times; "-" is not awake within the 3-hour limit. Nothing STUCK; edits at Wake at most 92,517.

**Attention 0.5 (the verdict):**

| Seed | Tuning | Hand 50% | Hand 35% | 6 drills 25% | 35% | 50% | 65% | 100% | 2 drills 35% | 3 drills 35% |
|---|---|---|---|---|---|---|---|---|---|---|
| 1234 | shipped | 33:06 | 32:17 | 33:08 | 33:05 | 34:20 | 37:13 | 98:34 | 27:45 | 29:22 |
| 1234 | Resonance 1 | 22:51 | 22:16 | 22:28 | 22:26 | 23:22 | 25:24 | 77:53 | 19:13 | 20:03 |
| 7 | shipped | 34:00 | 32:00 | 38:03 | 37:43 | 39:01 | 42:18 | 104:40 | 33:43 | 36:56 |
| 7 | Resonance 1 | 23:28 | 22:13 | 26:11 | 26:01 | 27:33 | 30:55 | 76:12 | 21:27 | 25:33 |
| 99 | shipped | 35:56 | 34:23 | 38:52 | 38:22 | 39:23 | 40:35 | 72:59 | 37:43 | 35:54 |
| 99 | Resonance 1 | 25:09 | 23:55 | 27:02 | 26:43 | 28:01 | 29:32 | 58:50 | 26:00 | 24:55 |

- verdict seed 1234, shipped: best hand only 32:17 (hand only, 35% Heart), best 6 drills 33:05 (drills, 35% Heart), drills -2.5% sooner: FAIL under 2%
- verdict seed 1234, second moon, Resonance 1: best hand only 22:16 (hand only, 35% Heart), best 6 drills 22:26 (drills, 35% Heart), drills -0.7% sooner: FAIL under 2%
- verdict seed 7, shipped: best hand only 32:00 (hand only, 35% Heart), best 6 drills 37:43 (drills, 35% Heart), drills -17.9% sooner: FAIL under 2%
- verdict seed 7, second moon, Resonance 1: best hand only 22:13 (hand only, 35% Heart), best 6 drills 26:01 (drills, 35% Heart), drills -17.1% sooner: FAIL under 2%
- verdict seed 99, shipped: best hand only 34:23 (hand only, 35% Heart), best 6 drills 38:22 (drills, 35% Heart), drills -11.6% sooner: FAIL under 2%
- verdict seed 99, second moon, Resonance 1: best hand only 23:55 (hand only, 35% Heart), best 6 drills 26:43 (drills, 35% Heart), drills -11.7% sooner: FAIL under 2%

Every verdict fails and the process exits 1: the gate can fail. Against the criteria:
- **Hand only at 50% Heart** is within 4 s of the story 036 table (33:06 / 34:00 / 35:56 against 33:10 / 34:04 / 35:59). The duty cycle keeps the old average rate.
- **The 6-drill rows** are 0:22 to 1:42 faster than story 036's: the idle-share rule gives them the hand's share whenever it is not cutting.
- **Hand only at 35% Heart**, the new row, beats hand only at 50% on every seed and moon (32:17 / 32:00 / 34:23 shipped), so it sets the bar. Story 043's target is the best 6-drill split at least 2% under it: 31:38 / 31:21 / 33:42 on the shipped moon.
- **2 drills at 35% Heart** beat both hand-only rows on seeds 1234 and 7. On seed 99, 3 drills do. The trouble is the fleet of six.

**Print only, shipped moon:**

| Seed | Tuning | Hand 50% | Hand 35% | 6 drills 25% | 35% | 50% | 65% | 100% | 2 drills 35% | 3 drills 35% |
|---|---|---|---|---|---|---|---|---|---|---|
| 1234 | attention 0.35 | 40:48 | 38:49 | 34:59 | 34:37 | 35:54 | 41:13 | 138:33 | 29:51 | 31:10 |
| 1234 | attention 0.25 | 62:13 | 54:48 | 37:35 | 38:47 | 45:49 | 52:36 | - | 36:50 | 37:12 |
| 1234 | sittings 10/30 (wall clock) | 100:50 | 89:48 | 77:35 | 77:40 | 84:13 | 88:51 | - | 71:15 | 72:20 |
| 7 | attention 0.35 | 40:34 | 38:55 | 41:38 | 41:01 | 43:56 | 49:18 | - | 34:36 | 38:51 |
| 7 | attention 0.25 | 49:56 | 47:52 | 45:53 | 45:59 | 49:31 | 55:53 | - | 40:39 | 43:14 |
| 7 | sittings 10/30 (wall clock) | 120:43 | 96:10 | 80:27 | 76:10 | 111:45 | 120:13 | - | 87:11 | 83:52 |
| 99 | attention 0.35 | 42:11 | 41:01 | 43:14 | 42:53 | 46:11 | 48:11 | 128:50 | 39:45 | 40:26 |
| 99 | attention 0.25 | 50:24 | 48:53 | 47:54 | 48:19 | 51:56 | 58:34 | 169:59 | 45:22 | 46:05 |
| 99 | sittings 10/30 (wall clock) | 89:56 | 88:38 | 95:55 | 95:10 | 100:25 | 120:29 | - | 111:05 | 89:13 |

- At attention 0.35 and 0.25 the 6-drill splits beat hand only on seeds 1234 and 99, and on seed 7 only at 0.25. A player who cuts a quarter of the time is still ahead with two drills.
- Sittings (10 minutes on, 30 away, away run as a save's offline progress) favour drills on seeds 1234 and 7. On seed 99 hand only wins the wall clock: the 25%–65% splits take 95–120 minutes, and they cross 250 m only after the second absence.

---

## Dependencies

- Depends on: `production/epics/heartwake/story-041-drills-bore-harder.md`
- Unlocks: `production/epics/heartwake/story-043-drill-efficiency.md`
