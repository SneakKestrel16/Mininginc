# Heartwake: concept drafts

Two early drafts of the same idea, transcribed from the owner's screenshots on 2026-10-23. They
disagree in places (setting, tier table, Heart stages, prestige). `/brainstorm` reconciles them
into `design/game-brief.md`; this file is source material, not the design record.

## Draft A: dead planet

**Working title:** Heartwake

You're a lone miner on a cold, dead planet. Under the surface sleeps an enormous machine called
the Heart. No one knows what it does. Every bit of power you feed it wakes up a little more of it,
and what it reveals pulls you deeper.

### Core loop

1. **Dig** to get ore (clicking at first, drills later).
2. **Convert** ore into power using generators.
3. **Split** the power between two uses:
   - **Your operation:** faster drills, more generators, automation.
   - **The Heart:** a progress meter that unlocks new systems and story at each threshold.

That split is the main tension. Reinvesting grows your output faster. Feeding the Heart unlocks
new mechanics. Players always have something to weigh.

### Power tiers (each tied to a new depth layer)

Each generator should play differently, so the game isn't just bigger numbers.

| Depth | Resource | Generator | Twist |
|---|---|---|---|
| Surface | Coal, peat | Furnace + steam turbine | Needs water from an ice vein, a second resource to balance |
| Shallow | Copper, iron | Dynamos and wiring | Wiring upgrades reduce power lost in transmission (an efficiency multiplier) |
| Mid | Uranium | Fission reactor | Produces heat and waste. Overheating shuts it down. Waste piles up but becomes valuable later |
| Deep | Resonant crystal | Piezo arrays | Placement matters: crystals boost their neighbors, so it becomes a small grid puzzle |
| Abyss | Deuterium ice | Fusion | Needs a large burst of stored power to start, then outputs enormously. Batteries become essential |
| Core edge | Exotic matter | Antimatter | Containment drains constant upkeep. If power dips, you lose stock |
| Core | Heart-stuff | Singularity tap | Draws on the Heart itself, which closes the loop |

### What the Heart unlocks

- **10%:** Lights flicker on and reveal a map of deeper layers.
- **25%:** Maintenance drones appear (automation).
- **40%:** Data logs hint that the planet was moved here on purpose.
- **60%:** The Heart starts *giving back*, such as passive bonuses and a new resource.
- **80%:** Seismic events. The planet is shaking.
- **100%:** The reveal. The Heart is a world-engine, and the planet begins to move.

### Prestige: "Overload"

You dump everything into the Heart at once for a surge. This resets your mine but earns
**Sparks**, a permanent currency. Sparks buy things like:

- Starting at a deeper layer
- Generators that remember their upgrades
- Waste that converts automatically
- New starting perks with story flavor ("the drones remember you")

Each Overload also moves the planet a bit along a star map, so prestige feels like progress rather
than a wipe. That could set up a late-game goal of reaching a dying star and reigniting it.

### Small touches that add flavor

- The ambient hum gets louder and changes pitch as total power grows.
- Colors shift from coal orange to reactor green, crystal violet, and fusion white.
- Old reactor waste becomes fuel for a later tier, so early "junk" pays off.
- Random cave-ins and discoveries: an ore pocket, an old miner's journal, a buried relic.

### Other themes, if this one doesn't fit

- **Lighthouse:** Power a beacon on a pitch-black ocean world. Ships arrive as it grows brighter.
- **Night city:** Restore power to a dark city district by district. Citizens return and give
  bonuses.
- **Portal:** Charge a gate that opens to progressively stranger dimensions, each with new ores.

## Draft B: frozen moon

**The pitch:** You're a lone miner on a frozen moon. Far under the ice sits a huge dormant
machine, called the Heart. Nobody knows what it does. It wakes in stages as you feed it power, and
each stage shows a bit more of what it is.

### The core tension

Power has two uses, and you split it with one slider:

- **Drills.** Deeper rock is harder, so mining needs power. More power to the drills means more
  ore, faster.
- **The Heart.** Power sent here moves you toward the next stage, which unlocks new tech and story.

Sending everything to the drills grows your economy but stalls progress. Sending everything to the
Heart moves you forward but chokes your income. Players will keep adjusting that slider all game,
which beats just buying the next upgrade.

### Depth layers and power tiers

Each layer of rock holds the ore for the next generator, and each generator adds one new thing to
manage, so the game changes instead of only getting bigger.

| Depth | Resource | Generator | New mechanic |
|---|---|---|---|
| Surface | Coal | Furnace | Must be fed by hand, then automated with conveyors |
| Shallow | Ice + copper | Steam turbine | Ice melts into water; turbines need both fuel and water |
| Mid | Uranium | Fission reactor | Produces heat; you mine ice to cool it or it scrams and shuts down |
| Deep | Helium-3 + rare earths | Fusion torus | Magnets made from rare earths contain the plasma; weak containment means flickering output |
| Abyss | Strange matter | Antimatter cell | Huge output, but unstable; you choose between safe and overcharged modes |
| Core | ??? | The Heart itself | Late game, the Heart starts producing power and feeding you back |

### The Heart's stages

Each stage gives a permanent bonus and a story beat:

1. **Flicker.** Lights come on below. Unlocks automation drones.
2. **Pulse.** A heartbeat you can hear in the ice. Generator output +25%.
3. **Breath.** Vents open and thaw deeper layers. Unlocks fission.
4. **Sight.** It scans the moon and marks rich ore veins on your map.
5. **Voice.** It talks to you, showing it's a seed ship or a beacon or something stranger.
6. **Wake.** It launches. This is the prestige reset.

### Prestige

When the Heart launches, you start again on a new moon. You keep **Resonance**, earned from how
much total power you produced, and spend it on permanent perks such as starting deeper, cheaper
generators, or a better split ratio. Each new moon could change one rule, like no ice (so cooling
is hard) or a fast-burning sun (so you have solar but only during daytime cycles).

### Small touches

- **Overload events.** Pushing a generator past its rating gives a burst of power with a chance of
  breaking it. This rewards active players without punishing idle ones.
- **Power you can see.** Cables glow brighter as output climbs, and the Heart's pulse speeds up.
- **Offline progress.** Generators keep running, but furnaces burn out of fuel. That's a reason to
  automate.
