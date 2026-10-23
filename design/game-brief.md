# Game Brief: Heartwake

**One-sentence pitch:** A lone miner on a frozen moon splits every watt between the drills that keep them alive and a buried machine called the Heart, which wakes one stage at a time and shows more of what it is.

## Core loop
- Dig down into the ground, by clicking at first and then with power-hungry drills. Ores are hidden in the rock and show up as you dig; deeper rock is harder and costs more power.
- Burn ore in generators to make power.
- Set the slider: power to the drills grows income, power to the Heart moves it toward its next stage.
- Each stage gives a permanent bonus and a story beat, which changes the best slider setting.

## Player goal & fail state — what "working" looks like
- Goal: wake the Heart stage by stage. A session feels complete when the Heart reaches its next stage.
- No game over. The soft fail is a stall: furnaces run dry or a turbine runs out of water and income stops until you fix it.

## MVP — what must exist to be the game
1. A dig shaft you click to cut downward block by block. Each block is rock or an ore found where it lies (coal near the top), with a depth meter and ore counters.
2. Furnace that burns hand-fed coal into power.
3. Power slider that splits output between the drills and the Heart.
4. Drills that use power to keep digging down on their own, slowing as rock gets harder with depth, and collecting the ores they hit.
5. Heart meter with stages 1–3: Flicker (drones automate feeding), Pulse (+25% output), Breath (thaws the next layer).
6. Shallow layer: ice + copper and a steam turbine that needs both fuel and water.
7. Save/load with offline progress, where furnaces burn out unless automated.

## Out of scope — not building this
- Fission and deeper tiers (Mid, Deep, Abyss, Core) and their twists: heat/scram, waste that later becomes fuel, the crystal placement grid, transmission loss.
- Heart stages 4–6 (Sight, Voice, Wake), launch, the star map and Resonance prestige.
- Overload events, new-moon rule changes, story logs beyond one line per stage.

## Build order
1. Slider + Heart meter fed by a fake power source: proves the split is a real decision.
2. Dig shaft with ore found along the way + furnace.
3. Drills with depth cost.
4. Heart stages 1–3 and their bonuses.
5. Shallow layer and steam turbine.
6. Save/load and offline progress.

---
**Who it's for / what they feel:** incremental-game fans who want a slow mystery reveal; curiosity and steady growth.

**Art & audio direction:** dark blue-white ice with warm cables that glow brighter as output climbs; a low hum that rises in pitch with total power.

**Reference game:** Universal Paperclips — the reveal-through-progress unlocks; the MVP keeps the first three reveals and none of the late game.
