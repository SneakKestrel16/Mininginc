# Story 002: Dig shaft with ore discovery

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief MVP feature 1` (Build order 2)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Core loop step 1, MVP feature 1), scoped to this story:*

- [ ] The shaft is a column of blocks below the surface; the player digs it downward one block at a time by clicking.
- [ ] Each block takes a number of clicks to break that grows with depth (deeper rock is harder).
- [ ] Each block is either plain rock or holds an ore; what a block holds is hidden until the player digs into it.
- [ ] Coal appears near the top; which ores can appear at which depth comes from a data file.
- [ ] Breaking an ore block adds that ore to its counter; breaking rock adds nothing.
- [ ] A depth meter shows the current depth, and ore counters show each ore found so far.
- [ ] The same seed gives the same shaft, so a dig can be reproduced and tested.
- [ ] Block hardness, ore depth bands and ore chances are read from a data file, not hardcoded.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Generate blocks from a seeded RNG so a save (story 007) can store the seed and depth, not every block.
- The project is configured 3D (Forward+, Jolt); how the shaft is drawn is open, but keep the shaft data independent of the view.

---

## Out of Scope

- Story 004: drills digging without clicks.
- Story 006: ice and copper in the Shallow layer.

---

## Files

- `src/mining/dig_shaft.gd`
- `src/mining/dig_shaft_view.tscn`
- `data/ores.json`
- `tests/unit/heartwake/dig_shaft_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/heartwake/dig_shaft_test.gd` — advisory at `qa.level: minimal` (waived, not required).

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/heartwake/story-003-furnace.md`, `production/epics/heartwake/story-004-drills.md`
