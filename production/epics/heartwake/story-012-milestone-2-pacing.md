# Story 012: Milestone 2 pacing retune

> **Epic**: Heartwake
> **Status**: Ready
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
- data/economy.json
- data/ores.json
- data/heart_stages.json

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
