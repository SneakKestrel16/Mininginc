## Pacing simulator: plays Heartwake headless with the shipped data and prints when each
## Heart stage is reached, or where the run gets stuck.
## Run: <godot> --headless --path . -s res://tools/pacing_sim.gd
## TUNINGS lists candidate changes laid over the shipped data; "shipped" changes nothing.
## Each strategy is an attentive player in the 3D game: hand-drills one column down from
## the base, refuels and cools everything whenever there is room, builds the turbine and the
## reactor as soon as copper allows, then places auto-drills with the copper left. It runs
## live play's simulation (Economy.advance) and digs the real voxel world.
extends SceneTree

const STEP := 0.5
const LIMIT_SECONDS := 3.0 * 3600.0
## Fraction of the time the player spends hand-drilling rather than walking and feeding.
const HAND_ATTENTION := 0.5
const TUNINGS := [
	{ "name": "shipped" },
]
const STRATEGIES := [
	{ "name": "hand only, 50% Heart", "share": 0.5, "drills": 0 },
	{ "name": "drills, 50% Heart", "share": 0.5, "drills": 6 },
	{ "name": "drills, 100% Heart", "share": 1.0, "drills": 6 },
	{ "name": "drills, 25% Heart", "share": 0.25, "drills": 6 },
]

var _t := 0.0


func _initialize() -> void:
	for tuning in TUNINGS:
		print("== %s" % tuning["name"])
		for strategy in STRATEGIES:
			await _run(strategy, tuning)
	quit()


func _run(strategy: Dictionary, tuning: Dictionary) -> void:
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
	mine.shaft.shaft_seed = 1234
	world.world_seed = 1234
	_apply(tuning, economy, mine, world)
	var hand_rate: float = JSON.parse_string(FileAccess.get_file_as_string("res://data/world.json"))["hand_drill_hits_per_second"]
	# The player's own column, dug like a drill so hits carry from block to block; ore seen
	# in its walls is mined out first.
	var hand := AutoDrill.new()
	hand.setup(world, mine, Vector3i(10, 0, 10))
	var veins: Array[Vector3i] = []
	var events := PackedStringArray()
	economy.stage_reached.connect(func(i: int) -> void:
		events.append("%s %s" % [economy.heart.stages[i]["name"], _clock(_t)]))
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
		if economy.turbine_built and economy.can_build_reactor():
			economy.build_reactor()
			events.append("reactor %s" % _clock(_t))
		if economy.reactor_built:
			economy.feed_reactor()
			if economy.reactor.heat > economy.reactor.heat_limit * 0.6:
				economy.cool_reactor()
		var placed := mine.drills.size()
		var saving := not economy.turbine_built or (not economy.reactor_built and hand.depth_y < -100)
		if placed < strategy["drills"] and not saving and mine.place_drill(Vector3i(20 + 4 * placed, 0, 20)):
			events.append("drill %d %s" % [placed + 1, _clock(_t)])
		# Drill power does nothing until a drill stands: until then everything goes to the Heart.
		economy.split.heart_share = strategy["share"] if mine.drills else 1.0
		_hand_dig(world, hand, veins, hand_rate * HAND_ATTENTION * STEP)
		economy.advance(STEP, STEP)
		if economy.power_per_second == 0.0 and mine.ores["coal"] == 0 and hand.stopped:
			if stuck_since < 0.0:
				stuck_since = _t
		else:
			stuck_since = -1.0
		if stuck_since >= 0.0 and _t - stuck_since > 60.0:
			break
		_t += STEP
	var outcome: String = "awake %s" % _clock(_t) if economy.heart.is_awake() \
			else "STUCK %s" % _clock(stuck_since) if stuck_since >= 0.0 else "not awake after %s" % _clock(_t)
	print("%-22s %s | hand %d m, stage %d (%.0f/%.0f), %.0f/s | %s" % [
		strategy["name"], outcome, -hand.depth_y, economy.heart.stage, economy.heart.progress,
		economy.heart.threshold(), economy.power_per_second, ", ".join(events)])
	hand.free()
	for node in [world, mine, economy]:
		node.free()


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
				_see_ore(world, Vector3i(hand.column.x, before, hand.column.y), veins)
			continue
		var pos: Vector3i = veins[0]
		var remaining: float = world.hardness(pos) - world.damage.get(pos, 0.0)
		if world.block_at(pos) <= Blocks.ROCK or is_inf(remaining):
			veins.pop_front()
			continue
		var used := minf(left, remaining)
		left -= used
		if world.hit(pos, used) != "":
			veins.pop_front()
			_see_ore(world, pos, veins)


# Queues the ore around [param pos] that has just come into view (a vein is followed, but
# never more than 30 blocks at once).
func _see_ore(world: VoxelWorld, pos: Vector3i, veins: Array[Vector3i]) -> void:
	for side in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK, Vector3i.UP]:
		var next: Vector3i = pos + side
		if world.block_at(next) > Blocks.ROCK and not next in veins and veins.size() < 30:
			veins.append(next)


## Lays [param tuning] over the loaded data. Keys: ore_scale (multiplies every ore
## chance), drill_rate (hits per power-second), thresholds (one per stage), drill_cost,
## reactor_cost.
func _apply(tuning: Dictionary, economy: Economy, mine: Mine, world: VoxelWorld) -> void:
	if tuning.has("ore_scale"):
		for ore in world._ores:
			ore["chance"] *= tuning["ore_scale"]
	if tuning.has("drill_rate"):
		economy.drill_hits_per_power = tuning["drill_rate"]
	if tuning.has("thresholds"):
		for i in tuning["thresholds"].size():
			economy.heart.stages[i]["threshold"] = tuning["thresholds"][i]
	if tuning.has("drill_cost"):
		mine.drill_cost = tuning["drill_cost"]
	if tuning.has("reactor_cost"):
		economy.reactor_cost = tuning["reactor_cost"]


func _clock(seconds: float) -> String:
	return "%d:%02d" % [int(seconds) / 60, int(seconds) % 60]
