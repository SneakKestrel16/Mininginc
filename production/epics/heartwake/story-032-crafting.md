# Story 032: Crafting at the console

> **Epic**: Heartwake
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-24

## Context

**GDD**: `design/game-brief.md`
**Requirement**: `Brief Milestone 8 item 37` (Build order 37)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Milestone 8 item 37), scoped to this story:*

- [ ] The console overlay has a Crafting panel listing each recipe, what it takes and what it makes.
- [ ] Craft 1 and Craft 5 take the inputs and add the outputs; they are disabled when inputs are short.
- [ ] Recipes: iron plate (2 iron), copper wire (1 copper makes 2), glass (2 quartz), circuit (2 wire, 1 glass, 1 gold).
- [ ] Parts are saved with the inventory.

---

## Implementation Notes

- Check `docs/engine-reference/godot/` before any engine API call: 4.7 is past the model's training data.
- Recipes are data in data/recipes.json. Parts live in the same inventory as ore, so every cost can name them.

---

## Out of Scope

- Crafting time or queues; a separate workbench machine.

---

## Files

- data/recipes.json
- src/economy/crafting.gd
- src/ui/crafting_panel.gd
- src/mining/mine.gd
- src/main.tscn
- tests/unit/heartwake/crafting_check.gd

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: a headless self-check, plus a probe screenshot for anything on screen — advisory at `qa.level: minimal`.

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/heartwake/story-031-new-ores.md`
- Unlocks: `production/epics/heartwake/story-033-parts-as-costs.md`
