## Pacing simulator: plays Heartwake headless with the shipped data and prints when each
## Heart stage is reached, or where the run gets stuck.
## Run: <godot> --headless --path . -s res://tools/pacing_sim.gd [-- seed=N] [-- legacy]
## Every seed in SEEDS is played unless seed=N picks one; legacy swaps in only the slider rule
## from before story 036. Its numbers match the story 033 and 036 tables only at those commits:
## later stories changed the shipped data, and since the Milestone 10 review the hand column
## takes its share of drill power, which the older tables left out.
## TUNINGS lists candidate changes laid over the shipped data; "shipped" changes nothing.
## Each strategy is an attentive player in the 3D game: hand-drills one column down from
## the base, refuels and cools everything whenever there is room, builds the turbine and the
## reactor as soon as its parts can be crafted, places auto-drills, then spends spare ore on
## upgrades (keeping coal and ice for the machines). Parts are crafted when a purchase needs
## them. It runs live play's simulation (Economy.advance) and scoops the real smooth world.
## The hand cuts for the attention share of every CUT_CYCLE and, as in play, takes its share
## of drill power only while it cuts (story 041). A sittings tuning plays on and away in turns;
## time away runs the way a save's offline progress does, and the run prints its active time.
## After each tuning marked "verdict" it prints whether the best 6-drill split woke the Heart
## at least DRILLS_MUST_WIN_BY sooner than the best hand-only row (brief Milestone 11 item 50),
## and the process exits 1 if any did not.
extends SceneTree

const STEP := 0.5
const LIMIT_SECONDS := 3.0 * 3600.0
## Fraction of the time the player spends cutting by hand rather than walking and feeding,
## unless a tuning sets "attention". The verdict is taken at this value, the one most
## favourable to hand only of those played.
const ATTENTION := 0.5
## Seconds of one cutting cycle: the hand cuts for the first attention share of each, then
## the player walks and feeds the machines while the drills take all the drill power.
const CUT_CYCLE := 20.0
## Share by which the best 6-drill split must wake the Heart sooner than the best hand-only
## row for the verdict to be met.
const DRILLS_MUST_WIN_BY := 0.02
## Upgrades bought first, in this order, once machines and drills stand; every other upgrade
## in data/upgrades.json follows in file order, so new rows are played without an edit here.
const UPGRADE_ORDER := ["generator_tuning", "drill_gearing", "tool_motor", "wide_scoop", "long_arm"]
## World seeds played: three, because one seed's deposits can make a strategy look better than it is.
const SEEDS := [1234, 7, 99]
## Changed samples a world may hold at Wake before its save grows too big.
const EDITS_BUDGET := 150000
## Depths at which the time the deepest drill passes them is printed.
const DEPTH_MARKS := [150, 250, 340, 400]
## Ore kept back from upgrades for the furnace, turbine and reactor cooling.
const RESERVE := { "coal": 10, "ice": 10 }
const TUNINGS := [
	{ "name": "shipped", "verdict": true },
	{ "name": "second moon, Resonance 1", "resonance": 1, "verdict": true },
	{ "name": "attention 0.35", "attention": 0.35 },
	{ "name": "attention 0.25", "attention": 0.25 },
	{ "name": "sittings, 10 min on, 30 off", "sittings": [600.0, 1800.0] },
]
const STRATEGIES := [
	{ "name": "hand only, 50% Heart", "share": 0.5, "drills": 0 },
	{ "name": "hand only, 35% Heart", "share": 0.35, "drills": 0 },
	{ "name": "drills, 25% Heart", "share": 0.25, "drills": 6 },
	{ "name": "drills, 35% Heart", "share": 0.35, "drills": 6 },
	{ "name": "drills, 50% Heart", "share": 0.5, "drills": 6 },
	{ "name": "drills, 65% Heart", "share": 0.65, "drills": 6 },
	{ "name": "drills, 100% Heart", "share": 1.0, "drills": 6 },
	{ "name": "2 drills, 35% Heart", "share": 0.35, "drills": 2 },
	{ "name": "3 drills, 35% Heart", "share": 0.35, "drills": 3 },
]

var _t := 0.0
# Deposit scoops since the hand column last went down; a player follows a deposit a while,
# then gets back to digging down.
var _followed := 0
## Deposit scoops a player takes before going on down.
const FOLLOW_LIMIT := 40


func _initialize() -> void:
	var seeds: Array = SEEDS
	var legacy := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("seed="):
			seeds = [int(arg.trim_prefix("seed="))]
		elif arg == "legacy":
			legacy = true
	var failed := false
	for world_seed in seeds:
		for tuning in TUNINGS:
			var played: Dictionary = tuning.duplicate()
			if legacy:
				played["legacy_slider"] = true
			print("== seed %d, %s%s" % [world_seed, tuning["name"], ", legacy slider" if legacy else ""])
			var times := []
			for strategy in STRATEGIES:
				times.append(await _run(strategy, played, world_seed))
			if tuning.get("verdict", false) and not _verdict(world_seed, tuning, times):
				failed = true
	quit(1 if failed else 0)


## Prints whether the best 6-drill split woke the Heart at least DRILLS_MUST_WIN_BY sooner
## than the best hand-only row, from [param times] (seconds to Wake, INF when not awake, in
## STRATEGIES order). Returns true when it did.
func _verdict(world_seed: int, tuning: Dictionary, times: Array) -> bool:
	var best := { 0: INF, 6: INF }
	var names := { 0: "-", 6: "-" }
	for i in STRATEGIES.size():
		var drills: int = STRATEGIES[i]["drills"]
		if best.has(drills) and times[i] < best[drills]:
			best[drills] = times[i]
			names[drills] = STRATEGIES[i]["name"]
	var margin: float = 1.0 if is_inf(best[0]) else (best[0] - best[6]) / best[0]
	var met: bool = not is_inf(best[6]) and margin >= DRILLS_MUST_WIN_BY
	print("verdict seed %d, %s: best hand only %s (%s), best 6 drills %s (%s), drills %.1f%% sooner: %s" % [
		world_seed, tuning["name"], _clock(best[0]), names[0], _clock(best[6]), names[6], margin * 100.0,
		"met" if met else "FAIL under %d%%" % roundi(DRILLS_MUST_WIN_BY * 100.0)])
	return met


## Plays [param strategy] on [param tuning] and returns the seconds to Wake, or INF.
func _run(strategy: Dictionary, tuning: Dictionary, world_seed: int) -> float:
	var world := VoxelWorld.new()
	var mine := Mine.new()
	var economy := Economy.new()
	mine.world = world
	economy.mine = mine
	root.add_child(world)
	root.add_child(mine)
	root.add_child(economy)
	await process_frame
	economy.set_process(false)
	mine.shaft.shaft_seed = world_seed
	world.world_seed = world_seed
	_apply(tuning, economy, mine, world)
	var world_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/world.json"))
	var hand_rate: float = world_data["hand_drill_hits_per_second"]
	var hand_power_bonus: float = world_data["hand_power_bonus"]
	var attention: float = tuning.get("attention", ATTENTION)
	var sittings: Array = tuning.get("sittings", [])
	var offline_step: float = JSON.parse_string(FileAccess.get_file_as_string("res://data/save.json"))["offline_step_seconds"]
	var active := 0.0
	var sitting_left: float = sittings[0] if sittings else INF
	# The player's own column, dug like a drill so hits carry from scoop to scoop; ore seen
	# in its walls is mined out first.
	var hand := AutoDrill.new()
	hand.setup(world, mine, Vector3i(10, 0, 10))
	var veins: Array[Vector3i] = []
	var events := PackedStringArray()
	economy.stage_reached.connect(func(i: int) -> void:
		events.append("%s %s" % [economy.heart.stages[i]["name"], _clock(_t)]))
	var order := _upgrade_order(economy.upgrades)
	var opened := [0]  # an array: a lambda captures locals by value
	world.vault_opened.connect(func(_i: int, _ore: String) -> void: opened[0] += 1)
	var marks := PackedStringArray()
	_t = 0.0
	var stuck_since := -1.0
	while _t < LIMIT_SECONDS and not economy.heart.is_awake():
		economy.feed_furnace()
		if economy.can_build_turbine():
			economy.build_turbine()
			events.append("turbine %s" % _clock(_t))
		if economy.turbine_built:
			economy.melt_ice()
			economy.feed_turbine()
		if economy.turbine_built and not economy.reactor_built:
			economy.crafting.make_for(economy.reactor_cost, mine)
		if economy.turbine_built and economy.can_build_reactor():
			economy.build_reactor()
			events.append("reactor %s" % _clock(_t))
		if economy.reactor_built:
			economy.feed_reactor()
			if economy.reactor.heat > economy.reactor.heat_limit * 0.6:
				economy.cool_reactor()
		var placed := mine.drills.size()
		var saving := not economy.turbine_built or (not economy.reactor_built and hand.depth_y < -100)
		if placed < strategy["drills"] and not saving and economy.crafting.make_for(mine.drill_cost, mine) 				and mine.place_drill(Vector3i(20 + 4 * placed, 0, 20)):
			events.append("drill %d %s" % [placed + 1, _clock(_t)])
		if economy.reactor_built and placed >= strategy["drills"]:
			for id in order:
				if economy.upgrades.is_maxed(id):
					continue
				economy.crafting.make_for(economy.upgrades.cost(id), mine)
				if _can_spare(economy, id) and economy.buy_upgrade(id):
					events.append("%s %d %s" % [id, economy.upgrades.levels[id], _clock(_t)])
		# The slider sits at the strategy's share while drill power has somewhere to go: a
		# working drill, or the hand tool, which takes a share of it (Mine.hand_share). With
		# neither, the player sends everything to the Heart. The legacy rule ignored the hand
		# and waited for every upgrade to be bought, which tool_motor never is (its plates need
		# iron above 80 m).
		var digging := not mine.working_drills().is_empty() or not hand.stopped
		if tuning.get("legacy_slider", false):
			digging = not mine.drills.is_empty() and not economy.upgrades.defs.all(
					func(u: Dictionary) -> bool: return economy.upgrades.is_maxed(u["id"]))
		economy.split.heart_share = strategy["share"] if digging else 1.0
		# The hand cuts for the attention share of each cycle, at Player.hand_rate's rate: the
		# tool's own rate plus its share of drill power, which it takes only while it cuts.
		var cutting := not hand.stopped and fmod(active, CUT_CYCLE) < attention * CUT_CYCLE
		mine.hand_cutting = cutting
		if cutting:
			var hand_hits := hand_rate + mine.hand_share(economy.drill_hits_per_second) * hand_power_bonus
			_hand_dig(world, hand, veins, hand_hits * (1.0 + economy.upgrades.effect("hand_speed")) * STEP)
		economy.advance(STEP, STEP)
		if marks.size() < DEPTH_MARKS.size() and mine.drills:
			var deepest: int = mine.drills.map(func(d: AutoDrill) -> int: return -d.depth_y).max()
			while marks.size() < DEPTH_MARKS.size() and deepest >= DEPTH_MARKS[marks.size()]:
				marks.append("%d m %s" % [DEPTH_MARKS[marks.size()], _clock(_t)])
		if economy.power_per_second == 0.0 and mine.ores["coal"] == 0 and hand.stopped:
			if stuck_since < 0.0:
				stuck_since = _t
		else:
			stuck_since = -1.0
		if stuck_since >= 0.0 and _t - stuck_since > 60.0:
			break
		_t += STEP
		active += STEP
		sitting_left -= STEP
		if sitting_left <= 0.0:
			_away(economy, mine, sittings[1], offline_step)
			sitting_left = sittings[0]
	var awake := economy.heart.is_awake()
	var outcome: String = "awake %s" % _clock(_t) if awake \
			else "STUCK %s" % _clock(stuck_since) if stuck_since >= 0.0 else "not awake after %s" % _clock(_t)
	if sittings:
		outcome += " (active %s)" % _clock(active)
	print("%-22s %s | hand %d m, stage %d (%.0f/%.0f), %.0f/s | %s" % [
		strategy["name"], outcome, -hand.depth_y, economy.heart.stage, economy.heart.progress,
		economy.heart.threshold(), economy.power_per_second, ", ".join(events)])
	var left := PackedStringArray()
	for id in mine.ores:
		if mine.ores[id] > 0:
			left.append("%s %d" % [id, mine.ores[id]])
	print("%-22s   depth: %s | edits %d%s | vaults opened %d | left: %s" % ["", ", ".join(marks) if marks else "-",
		world.edits.size(), " FAIL over %d" % EDITS_BUDGET if world.edits.size() > EDITS_BUDGET else "",
		opened[0], ", ".join(left)])
	hand.free()
	for node in [world, mine, economy]:
		node.free()
	return _t if awake else INF


# Time away between sittings, played as a save plays it on load: Economy.advance in the
# save's offline steps, with the hand idle and nothing fed, built or bought. Stops at Wake.
func _away(economy: Economy, mine: Mine, seconds: float, step: float) -> void:
	mine.hand_cutting = false
	var left := seconds
	while left > 0.0 and not economy.heart.is_awake():
		economy.advance(step, step)
		_t += step
		left -= step


## Lands [param hits] the way an attentive player digs: ore showing in the walls of the
## hand column (or of a vein being followed) comes out first, then the column goes on down.
func _hand_dig(world: VoxelWorld, hand: AutoDrill, veins: Array[Vector3i], hits: float) -> void:
	var left := hits
	while left > 0.0 and not hand.stopped:
		if veins.is_empty():
			var before := hand.depth_y
			hand.dig(minf(left, 1.0))
			left -= 1.0
			if hand.depth_y != before:
				_followed = 0
				_see_ore(world, Vector3i(hand.column.x, before, hand.column.y), veins)
			continue
		var pos: Vector3i = veins[0]
		var remaining: float = maxf(world.hardness_at(pos) - world.damage.get(pos, 0.0), 0.0)
		if not world.is_solid(pos) or world.material_at(pos) <= Blocks.ROCK or is_inf(remaining):
			veins.pop_front()
			continue
		var used := minf(left, remaining)
		left -= used
		world.dig(Vector3(pos), used)
		if not world.damage.has(pos):
			veins.pop_front()
			_followed += 1
			_see_ore(world, pos, veins)


# Queues the ore just past the wall of the scoop at [param pos] that has come into view (a
# deposit is followed, but never more than 30 scoops at once).
func _see_ore(world: VoxelWorld, pos: Vector3i, veins: Array[Vector3i]) -> void:
	for side in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK, Vector3i.UP]:
		var next: Vector3i = pos + side * 2
		if _followed >= FOLLOW_LIMIT:
			return
		if world.is_solid(next) and world.material_at(next) > Blocks.ROCK and not next in veins and veins.size() < 30:
			veins.append(next)


# UPGRADE_ORDER's upgrades that the data has, then every other upgrade in file order.
func _upgrade_order(upgrades: Upgrades) -> Array:
	var order := UPGRADE_ORDER.filter(func(id: String) -> bool: return not upgrades.find(id).is_empty())
	for def in upgrades.defs:
		if not def["id"] in order:
			order.append(def["id"])
	return order


# True when upgrade [param id]'s next level leaves the reserve untouched.
func _can_spare(economy: Economy, id: String) -> bool:
	var spare := economy.mine.ores.duplicate()
	for ore in RESERVE:
		spare[ore] = maxi(spare.get(ore, 0) - RESERVE[ore], 0)
	return economy.upgrades.can_buy(id, spare)


## Lays [param tuning] over the loaded data. Keys: ore_scale (multiplies every ore
## chance), drill_rate (hits per power-second), thresholds (one per stage), drill_cost,
## reactor_cost, resonance (points carried from earlier moons), legacy_slider (the slider
## rule from before story 036, read in _run), no_vaults (a moon without vaults),
## drill_efficiency (rock a drill bores per hit of its share). Read in _run: attention (share
## of the time the hand cuts), sittings ([seconds on, seconds away]), verdict.
func _apply(tuning: Dictionary, economy: Economy, mine: Mine, world: VoxelWorld) -> void:
	if tuning.has("ore_scale"):
		for ore in world._ores:
			ore["chance"] *= tuning["ore_scale"]
		world._seed_noise()  # the deposit cutoffs follow the chances
	if tuning.has("drill_rate"):
		economy.drill_hits_per_power = tuning["drill_rate"]
	if tuning.has("thresholds"):
		for i in tuning["thresholds"].size():
			economy.heart.stages[i]["threshold"] = tuning["thresholds"][i]
	if tuning.has("drill_cost"):
		mine.drill_cost = tuning["drill_cost"]  # item id to amount
	if tuning.has("reactor_cost"):
		economy.reactor_cost = tuning["reactor_cost"]
	if tuning.has("resonance"):
		economy.resonance = tuning["resonance"]
	if tuning.has("drill_efficiency"):
		mine.drill_efficiency = tuning["drill_efficiency"]
	if tuning.get("no_vaults", false):
		for stratum in world.strata:
			stratum.erase("vaults")
		world._seed_noise()


func _clock(seconds: float) -> String:
	if is_inf(seconds):
		return "-"
	return "%d:%02d" % [int(seconds) / 60, int(seconds) % 60]
