# Story 041: Drills bore harder; idle power goes to the drills

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 11 item 46, 47` (Build order 46, 47)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 11 item 46, 47), scoped to this story:*

- [x] `Mine` reads `drill_efficiency` from `data/world.json` with a default of 1.0, and `Mine.dig` multiplies each drill's share by it. The key is not added to the data file yet. `auto_drill_check`: a drill in a Mine at 2.0 after `dig(40.0)` ends at exactly the depth a Mine at 1.0 reaches after `dig(80.0)`.
- [x] `Mine.hand_cutting` (default false): `Mine.dig` counts the hand tool as a share only while it is true. `auto_drill_check`: a lone drill after `dig(40.0)` with the hand not cutting ends where `dig(80.0)` with it cutting does, and deeper than `dig(40.0)` with it cutting.
- [x] `Mine.hand_share` does not read `hand_cutting`: `hand_share(6.0) == 6.0` with no drills and `== 2.0` with two still hold, so item 23 holds exactly.
- [x] The player sets `mine.hand_cutting` false at the start of every physics frame and true while a cut lands. Run and observe: a placed drill's depth grows faster with the mouse up than while cutting; retained evidence in `production/qa/evidence/story-041-*`.
- [x] Offline progress goes through the same `Mine.dig`, so it gets both rules: a check advances 60 s with one drill and finds it deeper at 2.0 than at 1.0.
- [x] All 16 checks pass.

---

## Implementation Notes

- `data/world.json` keeps no `drill_efficiency` key in this story: story 042's simulator must first fail against 1.0.
- Until story 042 the simulator never sets `hand_cutting`, so its drill rows run as if the hand never cuts. Panel runs put that 0:20 to 2:00 faster than the story 036 table. Story 042 records the baseline; nothing compares against the simulator in between.
- Economy ticks every 0.1 s and the flag is per physics frame. The flag only moves who gets a share, never the total.

---

## Out of Scope

- The bonus value (story 043), console text (story 044), simulator changes (story 042).

---

## Files

- src/mining/mine.gd
- src/player/player.gd
- tests/unit/heartwake/auto_drill_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: headless checks pass; a run-and-observe capture in `production/qa/evidence/story-041-*`.

**Status**: [x] `production/qa/evidence/story-041-idle-share/cutting.png` (2026-10-28): a windowed run of the real game with one drill and 10 power/s all on Drills. The drill dug 11 m in 10 s with the hand idle, then 5 m in 10 s while the hand cut (596 of 600 frames), then 8 m idle again in deeper rock. The screenshot shows the hand tool at 9.0 hits/s, its own 4 plus one drill's share of 5. `auto_drill_check` passes: twice the efficiency digs from 40 hits what 1.0 digs from 80, a lone drill with the hand idle digs from 40 hits what 80 dig while it cuts, and the hand's share does not depend on cutting. `save_offline_check` passes: 5 minutes away bore deeper at 2.0. All three were seen failing before the rules were wired. All 16 checks pass.

---

## Results

- `Mine.dig` divides drill power among the working drills, plus the hand tool only while `hand_cutting` is set, and multiplies each drill's share by `drill_efficiency`. The player sets `hand_cutting` on every physics frame it cuts rock. `hand_share` is unchanged, so item 23 holds exactly.
- `data/world.json` has no `drill_efficiency` key yet: story 042's simulator must first fail against 1.0.

---

## Dependencies

- Depends on: `production/epics/heartwake/story-040-vaults.md`
- Unlocks: `production/epics/heartwake/story-042-sim-plays-people.md`
