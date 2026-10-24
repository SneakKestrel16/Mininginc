# Story 012: Milestone 2 pacing retune

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Config/Data
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-23

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 2 item 14` (Build order 14)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 2 item 14), scoped to this story:*

- [ ] `tools/pacing_sim.gd` plays through to Voice, building and cooling the reactor.
- [ ] A split favouring the drills reaches Voice sooner than 100% to the Heart.
- [ ] No simulated strategy soft-locks before Voice.
- [ ] At 50% to the Heart, Voice is reached in a time recorded in the story's Completion Notes, with Breath still under about 20 minutes.
- [ ] Every new number is in `data/*.json`; every self-check still passes after the retune.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- If no tuning makes the drills pay off, record why and what content would fix it, rather than forcing the numbers.

---

## Out of Scope

- Hand playtesting: separate from this story.

---

## Files

- tools/pacing_sim.gd
- data/ores.json
- data/economy.json
- data/heart_stages.json
- src/world/voxel_world.gd
- tests/unit/heartwake/voxel_world_check.gd
- tests/integration/heartwake/save_offline_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Config/Data
**Required evidence**: smoke check: pacing simulator output in Completion Notes — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-009-reactor-cooling-waste.md`, `production/epics/heartwake/story-011-heart-voice.md`
- Unlocks: none

## Completion Notes
**Completed**: 2026-10-23
**Criteria**: 5/5 passing. `tools/pacing_sim.gd`, shipped data, seed 1234:

| Strategy | Breath | Sight | Voice (awake) |
|---|---|---|---|
| hand only, 50% Heart | 11:02 | 65:41 | 101:47 |
| 6 drills, 50% Heart | 11:02 | 21:41 | 41:21 |
| 6 drills, 100% Heart | 11:02 | 65:41 | 101:47 |
| 6 drills, 25% Heart | 11:02 | 24:00 | 97:16 |

**Changes**: ore chances halved (shallow coal 0.35 to 0.175), drill rate 0.1 to 1.0 hits per power-second, reactor 15 to 10 copper, thresholds 300/1500/6000/25000/90000.
**Deviations**: Rebuilt for the 3D game (story 017 had left the simulator digging nothing): the player model hand-drills a column, mines ore seen in its walls first, builds the turbine, then the reactor, then places up to 6 drills, and keeps the slider on the Heart until a drill stands. At 0.1 hits per power-second a block cost more power than its coal returned, so drills never paid.
**Fixed in passing**: `VoxelWorld.hit` compared summed float hits exactly, so damage could stop a hair short of the hardness; the simulator spun on such a block for two hours. A block now breaks within 0.0001 of its hardness (`voxel_world_check.gd` fails without the fix). The save check allows one block of drift between 5 s offline steps and live ticks, from stage bonuses starting at a step's end.
**Known gap**: one seed, one player model; a hand playtest should confirm. The simulator takes about a minute per strategy.
**Test Evidence**: smoke check: simulator output above
**Reviewed by**: self, no independent review
