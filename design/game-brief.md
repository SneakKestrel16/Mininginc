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

## Milestone 5 — upgrade shop
Chosen 2026-10-24 after v0.3.0: once the turbine, reactor and drills are built, ore has nothing left to buy. An upgrade shop gives every ore a use for the rest of the run.

28. Upgrade shop at the power console: spend ore on upgrade levels, each level dearer than the last, with a cap per upgrade.
29. Upgrades: a faster tool motor (hand digging speed), a wider scoop (bigger chunks per scoop), a longer arm (reach), drill gearing (auto-drill and tool power speed) and generator tuning (more power from every generator, so ore keeps feeding the Heart once the reactor runs flat out). They are saved and take effect at once.
30. The pacing simulator buys upgrades as an attentive player would; the shipped costs keep every ore worth digging and no strategy stuck.

Build order: 28 + 29 → 30.

## Milestone 6 — digging feel
Chosen 2026-10-24 after v0.4.0, by Claude on the user's "just keep going": the dig is the action the player repeats most, and it gives no feedback beyond the hole and the inventory count.

31. Each scoop the player digs throws a puff of dust in the colour of what it cut, plays a short crunch, and shows the ore it gained ("+2 coal") by the crosshair.

Build order: 31.

## Milestone 7 — Wake, launch and Resonance
Chosen 2026-10-24 by the user after v0.4.0 and story 027: the run needs an ending, and a reason to play again.

32. Heart stage 6, Wake: a last, much larger threshold after Voice. When it is reached the Heart rises in its cavern and says its last lines.
33. Launch: the awake Heart offers to launch. Launching plays a short ending (fade, the moon falling away, the Heart's closing words) and shows what the run earned.
34. Resonance, the first prestige: each launch earns Resonance. A new moon starts from scratch (new seed, no ore, machines, upgrades or Heart progress), but every point of Resonance makes every generator stronger for good. Resonance is kept apart from the run's save.
35. The pacing simulator plays through Wake, and a second run with the first launch's Resonance wakes the Heart clearly faster.

Build order: 32 + 33 → 34 → 35.

## Milestone 8 — crafting
Chosen 2026-10-24 by the user during the v0.5.0 playtest ("we should add crafting to it to craft different items and with that add more ores that are used for crafting"). The same playtest asked for coal to look clearly different from plain ground; that waits for a graphics pass.

36. New ores: iron (shallow to mid), quartz (mid) and gold (deep, rare), in deposits like the others, coloured and shown by Sight.
37. Crafting at the power console: recipes turn ore into parts — iron plate, copper wire, glass, circuit — each taking a moment's worth of ore, made one at a time or five at a time.
38. Parts are what things cost: auto-drills take plates and wire, the reactor takes plates and glass, and upgrade levels take parts as well as ore; circuits, which need deep gold, are the late-game cost of generator tuning. The pacing simulator crafts what it needs.

Build order: 36 → 37 → 38.

## Milestone 9 — reading the ground
Chosen 2026-10-24 by Claude when the user said "keep working on your stuff": the v0.5.0 playtest found coal hard to tell from plain ground ("we can work on that later with graphics"), and the console panels let the game show through.

39. Ore reads at a glance: rock and crust have a fine grain, and every ore surface is flecked with glinting specks in its own colour, so a deposit stands out from plain ground even in shadow.
40. The console's panels are solid and easy to read over the game.

Build order: 39 → 40.

## Out of scope — not building this
- Deeper tiers (Deep, Abyss, Core) and their twists: waste that later becomes fuel, the crystal placement grid, transmission loss.
- The star map, and Resonance spent on anything but generator strength.
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
