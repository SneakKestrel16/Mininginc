# Game Brief: Heartwake

**One-sentence pitch:** A lone miner on a frozen moon splits every watt between the drills that keep them alive and a buried machine called the Heart, which wakes one stage at a time and shows more of what it is.

## Core loop
- Walk the moon in first person and dig into voxel rock with a hand drill, then with power-hungry auto-drills. Ores are hidden in the rock and show up as you dig; deeper rock is harder and costs more power.
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

## Milestone 2 — Mid layer and Heart stages 4–5
Shipped MVP is v0.1.1. This milestone gives power spent on the drills a payoff past Breath: today sending 100% to the Heart is always fastest (`tools/pacing_sim.gd`).

8. Mid layer: uranium is found in the rock below Breath's thaw (depth 100 and down), alongside coal and ice.
9. Fission reactor: built with copper, burns uranium for far more power than the turbine, and builds heat while it runs.
10. Cooling and scram: melting ice into the reactor removes heat; if heat reaches the limit it scrams and stays off until it has cooled.
11. Waste: every uranium burned leaves waste, which piles up in a store shown on screen. It has no use yet.
12. Heart stage 4, Sight: the Heart scans the moon and marks blocks with rich ore on the shaft before you dig them.
13. Heart stage 5, Voice: the Heart talks to you; a short run of lines hints that it is a seed ship or a beacon.
14. Retune with the pacing simulator so that a split favouring the drills reaches Voice sooner than 100% to the Heart.

Build order: 8 → 9 → 10 → 11 → 12 → 13 → 14. Thresholds and reactor numbers live in `data/*.json` and are set by step 14.

## Milestone 3D — first-person on the moon
Chosen 2026-10-23 after stories 008–009: the 2D panels did not feel like the intended game. The player picked a first-person miner on voxel terrain. The economy (furnace, turbine, reactor, Heart, slider, saves) stays; what you see and do moves into a 3D world. Stories 010–012 (Sight, Voice, pacing) wait until this lands; Sight then becomes ore veins glowing through the rock.

15. Voxel moon: block terrain generated from the seed in chunks. The surface is an ice crust; ores sit in the rock by depth (coal near the top, then ice and copper, uranium from 100 m down). Frozen rock below 50 m is harder until Breath.
16. First-person miner: walk, jump, look; hold click with the hand drill to break the block you aim at. Harder blocks take longer. Broken ore goes into your inventory (the old ore counters).
17. Base machines in the world: the furnace, turbine and reactor are 3D objects. Look at one and press E to feed it, melt ice into it or cool it. Its state shows on the machine (glow, gauge) plus a small prompt.
18. The Heart: a huge buried machine near the base. It glows and pulses brighter each stage; stage lines appear as on-screen text.
19. HUD: crosshair, inventory strip, power readout and Heart stage.
20. Power console and auto-drills: a terminal at the base holds the Drills/Heart slider. Auto-drills are machines you place on the ground; they bore straight down using drill power and collect what they hit.
21. Saves keep the world's dug blocks, the player's position and placed drills, plus the economy; offline progress still runs.

Build order: 15 → 16 → 17 → 18 → 19 → 20 → 21.

## Milestone 4 — smooth moon
Chosen 2026-10-24 after the first hand playtest of v0.2.1: the player does not want to mine blocks. They want Astroneer-style digging, scooping round chunks out of smooth ground to uncover ore. The Heart should be buried in the planet, not sitting in an open pit. A dev menu is wanted for testing. Drill power did nothing without placed auto-drills, which read as a bug.

22. Dev menu: a key opens a panel to add ore, set the Heart's stage or meter, skip time, fly through the ground, and jump to the base or the Heart.
23. Drill power also drives the hand tool: the more power on the Drills side, the faster the player digs, so drill power is never wasted.
24. Smooth terrain: the moon is a smooth surface, not blocks, built in chunks from the seed. Ore lies in deposits (blobs and veins) inside the rock, coloured where they show.
25. Carving tool: holding the tool scoops a round chunk out of the ground where the player aims; harder rock takes longer. Ore scooped out goes into the inventory. Auto-drills and Sight work on the smooth ground.
26. The Heart lies buried deep below the base, in a cavern the player digs down to; its glow and hum grow as they get close.
27. Saves keep the carved ground; the pacing simulator is redone for carving.

Build order: 22 → 23 → 24 → 25 → 26 → 27.

## Out of scope — not building this
- Deeper tiers (Deep, Abyss, Core) and their twists: waste that later becomes fuel, the crystal placement grid, transmission loss.
- Heart stage 6 (Wake), launch, the star map and Resonance prestige.
- An upgrade shop or other ore sinks.
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
