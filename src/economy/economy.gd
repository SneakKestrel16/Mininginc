## Runs the economy on a fixed tick, with tuning values from data/economy.json.
class_name Economy
extends Node

## Emitted after every tick, once the split is updated.
signal ticked
## Emitted when the Heart reaches a stage; [param index] points into [member Heart.stages].
signal stage_reached(index: int)

const CONFIG_PATH := "res://data/economy.json"
const STAGES_PATH := "res://data/heart_stages.json"

## The mine the drills dig and the furnace's coal comes from.
@export var mine: Mine

## The drills/Heart split this economy feeds.
var split: PowerSplit

## The hand-fed furnace.
var furnace: Furnace

## The steam turbine; it produces nothing until [member turbine_built].
var turbine: SteamTurbine

## True once the turbine has been built with copper.
var turbine_built: bool = false

## Copper the turbine costs to build.
var turbine_cost: int

## The fission reactor; it produces nothing until [member reactor_built].
var reactor: FissionReactor

## True once the reactor has been built with copper.
var reactor_built: bool = false

## Copper the reactor costs to build.
var reactor_cost: int

## The Heart, which stores the Heart share and grants each stage's bonus.
var heart: Heart

## Power produced per second by all generators over the last tick.
var power_per_second: float = 0.0
## The furnace's part of [member power_per_second], bonus included.
var furnace_output: float = 0.0
## The turbine's part of [member power_per_second], bonus included.
var turbine_output: float = 0.0
## The reactor's part of [member power_per_second], bonus included.
var reactor_output: float = 0.0

## Hits per second each unit of drill power lands on the shaft.
var drill_hits_per_power: float

## Hits per second the drills landed over the last tick.
var drill_hits_per_second: float = 0.0

var _tick_seconds: float
var _elapsed: float = 0.0


func _ready() -> void:
	var config := _load_json(CONFIG_PATH, ["tick_seconds", "heart_share_default",
			"furnace_fuel_capacity", "furnace_burn_seconds_per_coal", "furnace_power_per_second",
			"drill_hits_per_power_second", "turbine_build_copper", "turbine_fuel_capacity",
			"turbine_burn_seconds_per_coal", "turbine_power_per_second", "turbine_water_capacity",
			"turbine_water_per_second", "water_per_ice", "reactor_build_copper", "reactor_fuel_capacity",
			"reactor_burn_seconds_per_uranium", "reactor_power_per_second", "reactor_heat_per_second",
			"reactor_heat_limit", "reactor_heat_restart", "reactor_cooling_per_second", "reactor_heat_per_ice",
			"reactor_waste_per_uranium"])
	var stage_config := _load_json(STAGES_PATH, ["stages"])
	if config.is_empty() or stage_config.is_empty() or not _valid_stages(stage_config["stages"]):
		set_process(false)
		return
	_tick_seconds = config["tick_seconds"]
	split = PowerSplit.new(config["heart_share_default"])
	heart = Heart.new(stage_config["stages"])
	furnace = Furnace.new(
		config["furnace_fuel_capacity"],
		config["furnace_burn_seconds_per_coal"],
		config["furnace_power_per_second"],
	)
	drill_hits_per_power = config["drill_hits_per_power_second"]
	turbine = SteamTurbine.new(
		config["turbine_fuel_capacity"],
		config["turbine_burn_seconds_per_coal"],
		config["turbine_power_per_second"],
		config["turbine_water_capacity"],
		config["turbine_water_per_second"],
		config["water_per_ice"],
	)
	turbine_cost = config["turbine_build_copper"]
	reactor = FissionReactor.new(
		config["reactor_fuel_capacity"],
		config["reactor_burn_seconds_per_uranium"],
		config["reactor_power_per_second"],
		config["reactor_heat_per_second"],
		config["reactor_heat_limit"],
		config["reactor_heat_restart"],
		config["reactor_cooling_per_second"],
		config["reactor_heat_per_ice"],
		config["reactor_waste_per_uranium"],
	)
	reactor_cost = config["reactor_build_copper"]


func _process(delta: float) -> void:
	_elapsed += delta
	while _elapsed >= _tick_seconds:
		_elapsed -= _tick_seconds
		_tick(_tick_seconds)


## Runs [param seconds] of play in ticks of [param step] seconds: the same simulation as
## live play, in bigger steps. Offline progress uses it.
func advance(seconds: float, step: float) -> void:
	var left := seconds
	while left > 0.0:
		_tick(minf(step, left))
		left -= step


## Applies every stage bonus that does not wait for a tick, after a save is loaded.
func apply_heart() -> void:
	mine.thaw_to(int(heart.effect_total("thaw_to_depth")))


# Bonuses are read from the Heart's stage every tick, never stored in the systems they
# change, so the stage index alone restores them.
func _tick(seconds: float) -> void:
	if heart.has_effect("drones"):
		feed_furnace()
	var bonus := 1.0 + heart.effect_total("output_bonus")
	furnace_output = furnace.tick(seconds) * bonus
	turbine_output = turbine.tick(seconds) * bonus if turbine_built else 0.0
	reactor_output = reactor.tick(seconds) * bonus if reactor_built else 0.0
	power_per_second = furnace_output + turbine_output + reactor_output
	split.tick(power_per_second)
	drill_hits_per_second = split.drill_power * drill_hits_per_power
	mine.dig(drill_hits_per_second * seconds)
	for index in heart.add(split.heart_power * seconds):
		stage_reached.emit(index)
	apply_heart()
	ticked.emit()


## Moves as much of the mine's coal into the furnace as fits. Returns how many went in.
func feed_furnace() -> int:
	return mine.take("coal", furnace.feed(mine.ores.get("coal", 0)))


## True when the turbine is not built yet and the mine holds enough copper for it.
func can_build_turbine() -> bool:
	return not turbine_built and mine.ores.get("copper", 0) >= turbine_cost


## Spends the copper and builds the turbine. Does nothing when [method can_build_turbine] is false.
func build_turbine() -> void:
	if can_build_turbine():
		mine.take("copper", turbine_cost)
		turbine_built = true


## Moves as much of the mine's coal into the turbine as fits. Returns how many went in.
func feed_turbine() -> int:
	return mine.take("coal", turbine.boiler.feed(mine.ores.get("coal", 0)))


## Melts as much of the mine's ice into the turbine's tank as fits. Returns how many melted.
func melt_ice() -> int:
	return mine.take("ice", turbine.melt(mine.ores.get("ice", 0)))


## True when the reactor is not built yet and the mine holds enough copper for it.
func can_build_reactor() -> bool:
	return not reactor_built and mine.ores.get("copper", 0) >= reactor_cost


## Spends the copper and builds the reactor. Does nothing when [method can_build_reactor] is false.
func build_reactor() -> void:
	if can_build_reactor():
		mine.take("copper", reactor_cost)
		reactor_built = true


## Moves as much of the mine's uranium into the reactor as fits. Returns how many went in.
func feed_reactor() -> int:
	return mine.take("uranium", reactor.core.feed(mine.ores.get("uranium", 0)))


## Melts as much of the mine's ice against the reactor's heat as it takes. Returns how many melted.
func cool_reactor() -> int:
	return mine.take("ice", reactor.cool(mine.ores.get("ice", 0)))


## Returns the JSON object at [param path], or an empty Dictionary after reporting why it
## is unusable. Not assert(): release exports strip asserts, and friends run release builds.
func _load_json(path: String, keys: Array) -> Dictionary:
	var config = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not config is Dictionary:
		_fail("Cannot read %s (open error %d)" % [path, FileAccess.get_open_error()])
		return {}
	for key in keys:
		if not config.has(key):
			_fail("%s is missing \"%s\"" % [path, key])
			return {}
	for key in ["tick_seconds", "furnace_burn_seconds_per_coal", "turbine_burn_seconds_per_coal",
			"turbine_water_per_second", "water_per_ice", "reactor_burn_seconds_per_uranium",
			"reactor_power_per_second", "reactor_heat_limit", "reactor_heat_per_ice"]:
		if config.has(key) and config[key] <= 0.0:
			_fail("%s: %s must be above 0" % [path, key])
			return {}
	if config.has("reactor_heat_restart") and not config["reactor_heat_restart"] < config["reactor_heat_limit"]:
		_fail("%s: reactor_heat_restart must be below reactor_heat_limit" % path)
		return {}
	return config


func _valid_stages(stages: Array) -> bool:
	for stage in stages:
		for key in ["name", "threshold", "effect", "value", "line"]:
			if not stage.has(key):
				_fail("%s: a stage is missing \"%s\"" % [STAGES_PATH, key])
				return false
		if stage["threshold"] <= 0.0:
			_fail("%s: stage %s threshold must be above 0" % [STAGES_PATH, stage["name"]])
			return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	OS.alert(message, "Heartwake cannot start")
	get_tree().quit(1)
