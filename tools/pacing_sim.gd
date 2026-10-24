## Pacing simulator: plays Heartwake headless with the shipped data and prints when each
## Heart stage is reached, or where the run gets stuck.
## Run: <godot> --headless --path . -s res://tools/pacing_sim.gd
## TUNINGS lists candidate changes laid over the shipped data; "shipped" changes nothing.
## Each strategy is an attentive player: refuels whenever there is room, builds the turbine
## as soon as copper allows, clicks at a steady rate. Runs live play's simulation (Economy.advance).
extends SceneTree

const STEP := 0.5
const LIMIT_SECONDS := 2.0 * 3600.0
const TUNINGS := [
	{ "name": "shipped" },
]
const STRATEGIES := [
	{ "name": "idle, 50% Heart", "clicks": 0.0, "share": 0.5 },
	{ "name": "3 clicks/s, 50% Heart", "clicks": 3.0, "share": 0.5 },
	{ "name": "3 clicks/s, 100% Heart", "clicks": 3.0, "share": 1.0 },
	{ "name": "3 clicks/s, 25% Heart", "clicks": 3.0, "share": 0.25 },
]


func _initialize() -> void:
	for tuning in TUNINGS:
		print("== %s" % tuning["name"])
		for strategy in STRATEGIES:
			await _run(strategy, tuning)
	quit()


func _run(strategy: Dictionary, tuning: Dictionary) -> void:
	var mine := Mine.new()
	var economy := Economy.new()
	economy.mine = mine
	root.add_child(mine)
	root.add_child(economy)
	await process_frame
	economy.set_process(false)
	mine.shaft.shaft_seed = 1234
	_apply(tuning, economy, mine)
	economy.split.heart_share = strategy["share"]
	var events := PackedStringArray()
	economy.stage_reached.connect(func(i: int) -> void:
		events.append("%s at %s" % [economy.heart.stages[i]["name"], _clock(_t)]))
	_t = 0.0
	var mined_coal := 0
	var last_coal: int = mine.ores["coal"]
	var stuck_since := -1.0
	while _t < LIMIT_SECONDS and not economy.heart.is_awake():
		economy.feed_furnace()
		if economy.can_build_turbine():
			economy.build_turbine()
			events.append("turbine built at %s" % _clock(_t))
		if economy.turbine_built:
			economy.melt_ice()
			economy.feed_turbine()
		mine.dig(strategy["clicks"] * STEP)
		economy.advance(STEP, STEP)
		mined_coal += maxi(mine.ores["coal"] - last_coal, 0)
		last_coal = mine.ores["coal"]
		var running := economy.furnace.is_burning() or economy.turbine.is_running()
		var can_dig: bool = strategy["clicks"] > 0.0
		if not running and not can_dig and mine.ores["coal"] == 0:
			if stuck_since < 0.0:
				stuck_since = _t
			if _t - stuck_since > 60.0:
				break
		else:
			stuck_since = -1.0
		_t += STEP
	var outcome: String = "awake at %s" % _clock(_t) if economy.heart.is_awake() \
			else "STUCK at %s" % _clock(stuck_since) if stuck_since >= 0.0 else "not awake after %s" % _clock(_t)
	print("%-24s %s | depth %d, Heart stage %d (%.0f / %.0f) | %s" % [
		strategy["name"], outcome, mine.shaft.depth, economy.heart.stage, economy.heart.progress,
		economy.heart.threshold(), ", ".join(events) if events else "no stage reached"])
	mine.free()
	economy.free()


var _t := 0.0


func _clock(seconds: float) -> String:
	return "%d:%02d" % [int(seconds) / 60, int(seconds) % 60]


# Overrides the loaded data with a candidate tuning. Keys mirror the data files.
func _apply(tuning: Dictionary, economy: Economy, mine: Mine) -> void:
	if tuning.has("frozen_from_depth"):
		mine.shaft.frozen_from = tuning["frozen_from_depth"]
		mine._base_frozen_from = tuning["frozen_from_depth"]
	if tuning.has("hardness_per_block"):
		mine.shaft._hardness_per_block = tuning["hardness_per_block"]
	if tuning.has("frozen_hardness_multiplier"):
		mine.shaft.frozen_multiplier = tuning["frozen_hardness_multiplier"]
	if tuning.has("ores"):
		mine.shaft._ores = tuning["ores"]
		for ore in tuning["ores"]:
			mine.ores[ore["id"]] = 0
	if tuning.has("thresholds"):
		for i in tuning["thresholds"].size():
			economy.heart.stages[i]["threshold"] = tuning["thresholds"][i]
	if tuning.has("thaw_to_depth"):
		economy.heart.stages[2]["value"] = tuning["thaw_to_depth"]
	if tuning.has("furnace_power_per_second"):
		economy.furnace.power_per_second = tuning["furnace_power_per_second"]
	if tuning.has("furnace_burn_seconds_per_coal"):
		economy.furnace.burn_seconds = tuning["furnace_burn_seconds_per_coal"]
