# Story 033: Parts as costs

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 8 item 38` (Build order 38)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 8 item 38), scoped to this story:*

- [x] An auto-drill costs iron plates and copper wire.
- [x] The reactor costs copper, iron plates and glass (circuits need gold from 100 m down, too deep and rare to gate the reactor).
- [x] Upgrade levels cost parts as well as ore.
- [x] The pacing simulator crafts the parts each purchase needs; no strategy gets stuck, and a drills-heavy split stays ahead.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Results table goes in this story file.

---

## Out of Scope

- New machines built from parts.

---

## Files

- data/world.json
- data/economy.json
- data/upgrades.json
- src/mining/mine.gd
- src/economy/economy.gd
- tools/pacing_sim.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-032-crafting.md`
- Unlocks: none

## Results (shipped tuning, seed 1234, tools/pacing_sim.gd)

| Strategy | Reactor | Voice | Wake | Wake, Resonance 1 |
|---|---|---|---|---|
| hand only, 50% Heart | 28:07 | 69:42 | 96:42 | 76:01 |
| 6 drills, 50% Heart | 19:45 | 38:06 | 60:04 | 42:33 |
| 6 drills, 100% Heart | 31:26 | 71:40 | 98:36 | 78:00 |
| 6 drills, 25% Heart | 17:45 | 47:05 | 90:59 | 62:57 |

First cut had the reactor cost 2 circuits. Circuits need gold, from 100 m down at 2.5%, so
hand-only and 100% Heart never built it in 3 hours. The reactor now costs copper, 4 iron plates
and 2 glass; circuits are the late cost of Generator tuning.

The simulated hand digger also stopped near 61 m, following deposits forever. It now follows
at most 40 deposit scoops before digging on down (FOLLOW_LIMIT).

Runs are slower than before crafting (Wake 52-65 min, now 60-99 min): parts take ore that
used to go straight to purchases. One seed, one player model.
