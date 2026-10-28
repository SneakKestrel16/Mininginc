# Story 037: Strata you can read

> **Epic**: Heartwake
> **Status**: Complete
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 10 item 42` (Build order 42)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: MEDIUM
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 10 item 42), scoped to this story:*

- [x] `data/strata.json` lists Shallow from 0 m, Mid from 100, Deep from 150, Abyss from 250 and Core from 340, each with a rock tint, ambient light, ore glow, hardness (1.0 for all in this story) and a one-line banner. A bad file is refused with a reason.
- [x] Rock and crust take their stratum's tint; ore keeps its own colour and flecks.
- [x] Underground, the ambient light eases toward the stratum's, and ore flecks glow harder the deeper the player is.
- [x] The HUD shows the depth and stratum name, and a banner when the player enters a new stratum (3 m hysteresis, none on load).
- [x] The dev menu can drop the player into a chamber 10 m inside each stratum below the first (110, 160, 260, 350 m).
- [x] Digging costs exactly what it did (hardness 1.0); a `legacy_slider` simulator run matches story 036's.
- [x] Retained screenshots of each stratum, headlamp-lit, with ore in frame.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Numbers from the design panel, to be set by the screenshots. Tints multiply rock (0.50, 0.50, 0.56): shallow (1, 1, 1), mid (0.92, 0.96, 1.04), deep (0.84, 0.90, 0.80), abyss (1.00, 0.88, 0.70), core (0.72, 0.86, 0.90). Ambient colour x energy: shallow (0.45, 0.50, 0.65) x 0.60 (today's), mid x 0.50, deep x 0.34, abyss x 0.24, core (0.62, 0.48, 0.42) x 0.15. Ore glow 0.35 / 0.45 / 0.65 / 0.85 / 1.00. Ease 1.5/s.
- Guards in a pure `strata_error()`: first from 0, strictly increasing, last below max_depth, ambient energy at least 0.12, tint channels 0.5–1.5.
- Tint is keyed on depth, never on the frozen line, so Breath never forces a rebuild.
- The shader's fixed fleck emission becomes a uniform `ore_glow`.
- Built with the HUD's Heart line saying "up" when the Heart is above the player (it said "0 m down" all through the deep).

---

## Out of Scope

- Harder deep rock (story 038 turns it on with the ores that pay for it).
- Fog and seam lines at stratum boundaries.

---

## Files

- data/strata.json
- src/world/voxel_world.gd
- src/world/terrain.gdshader
- src/world/depth_sense.gd
- src/main.tscn
- src/ui/hud.gd
- src/ui/dev_menu.gd
- tests/unit/heartwake/strata_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-037-*`.

**Status**: [x] `production/qa/evidence/story-037-strata/` (2026-10-27): the surface, a tunnel at 110, 160, 260 and 350 m looking at a deposit, and 160 m with Sight. `tests/unit/heartwake/strata_check.gd` passes, and was seen failing with the tint, the hysteresis or the hardness broken. A `legacy_slider` simulator run on seed 1234 prints the same 28 lines as before the story.

---

## Dependencies

- Depends on: `production/epics/heartwake/story-036-honest-simulator.md`
- Unlocks: `production/epics/heartwake/story-038-deep-ores.md`
