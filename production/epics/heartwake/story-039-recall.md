# Story 039: Recall

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 10 item 44` (Build order 44)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: LOW
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 10 item 44), scoped to this story:*

- [ ] Holding R for 3 s pulls the player back to the base; letting go early cancels, and holding on does not fire twice.
- [ ] The crosshair prompt counts down ("Recalling 1.8 s").
- [ ] The player lands standing on the base ground, with chunks built before the move, and does not fall.
- [ ] R does nothing while the console or dev menu has control.
- [ ] Hold time and the base point are data; the dev menu's To base uses the same point.
- [ ] Retained screenshot of the recall prompt.

---

## Implementation Notes

- A free recall cannot soft-lock: a jump rises 1.6 m and one scoop at 300 m costs hundreds of hits, so nothing else brings a player up from depth.
- Panel numbers: recall_seconds 3.0, recall_point (64.5, 1.5, 64.5).

---

## Out of Scope

- A lift or relay pads; any cost for recalling.

---

## Files

- src/player/recall.gd
- src/player/player.gd
- src/ui/dev_menu.gd
- data/world.json
- tests/unit/heartwake/recall_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: headless check passes; prompt screenshot in `production/qa/evidence/story-039-*`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-038-deep-ores.md`
- Unlocks: `production/epics/heartwake/story-040-vaults.md`
