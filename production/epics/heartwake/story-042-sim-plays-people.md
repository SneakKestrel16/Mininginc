# Story 042: The pacing simulator plays people and guards the promise

> **Epic**: Heartwake
> **Status**: Ready
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

- [ ] Tunings take keys `attention` and `drill_efficiency`. The hand column cuts on a duty cycle of `attention` and sets `mine.hand_cutting` while it cuts. At attention 0.5 hand only at 50% Heart stays within 5 s of 33:10 / 34:04 / 35:59 on seeds 1234 / 7 / 99. Drill rows at efficiency 1.0 are no slower than the story 036 table.
- [ ] Rows per tuning: hand only at 50% and 35% Heart; 6 drills at 25/35/50/65/100% Heart; 2 drills and 3 drills at 35% Heart. Tunings: shipped and Resonance 1 at attention 0.5. On the shipped moon only: attention 0.35, attention 0.25, and sittings of 600 s on and 1800 s off, whose off time runs through `Economy.advance` in the save's offline steps and which print active and wall-clock time. The "no vaults" tuning is dropped; it served story 040.
- [ ] After each seed and moon at attention 0.5 the simulator prints a verdict line: the best hand-only row, the best 6-drill split, the margin in percent, and met or FAIL. FAIL means the best 6-drill split is not at least `DRILLS_MUST_WIN_BY` (0.02) sooner. Any FAIL makes the process exit 1. The 2- and 3-drill rows, attention 0.35 and 0.25, and sittings never decide it.
- [ ] On unchanged data (efficiency 1.0) the simulator prints FAIL on the shipped moon for seeds 1234, 7 and 99, proving the gate can fail.
- [ ] Every row ends awake or says why not; none STUCK; edits at Wake under 150,000. The header comment describes attention, sittings, the verdict and the exit code.

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

**Status**: [ ] not yet

---

## Dependencies

- Depends on: `production/epics/heartwake/story-041-drills-bore-harder.md`
- Unlocks: `production/epics/heartwake/story-043-drill-efficiency.md`
