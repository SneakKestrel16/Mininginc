## Runs the economy on a fixed tick, with tuning values from data/economy.json.
class_name Economy
extends Node

## Emitted after every tick, once the split is updated.
signal ticked

const CONFIG_PATH := "res://data/economy.json"

## Where the furnace's coal comes from.
@export var mine: Mine

## The drills/Heart split this economy feeds.
var split: PowerSplit

## The hand-fed furnace, the only generator until story 006.
var furnace: Furnace

## Power produced per second by all generators over the last tick.
var power_per_second: float = 0.0

var _tick_seconds: float
var _elapsed: float = 0.0


func _ready() -> void:
	var config := _load_config()
	if config.is_empty():
		set_process(false)
		return
	_tick_seconds = config["tick_seconds"]
	split = PowerSplit.new(config["heart_first_threshold"], config["heart_share_default"])
	furnace = Furnace.new(
		config["furnace_fuel_capacity"],
		config["furnace_burn_seconds_per_coal"],
		config["furnace_power_per_second"],
	)


func _process(delta: float) -> void:
	_elapsed += delta
	while _elapsed >= _tick_seconds:
		_elapsed -= _tick_seconds
		power_per_second = furnace.tick(_tick_seconds)
		split.tick(power_per_second, _tick_seconds)
		ticked.emit()


## Moves as much of the mine's coal into the furnace as fits. Returns how many went in.
func feed_furnace() -> int:
	return mine.take("coal", furnace.feed(mine.ores.get("coal", 0)))


## Returns the config, or an empty Dictionary after reporting why it is unusable.
## Not assert(): release exports strip asserts, and friends run release builds.
func _load_config() -> Dictionary:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary:
		_fail("Cannot read %s (open error %d)" % [CONFIG_PATH, FileAccess.get_open_error()])
		return {}
	for key in ["tick_seconds", "heart_share_default", "heart_first_threshold",
			"furnace_fuel_capacity", "furnace_burn_seconds_per_coal", "furnace_power_per_second"]:
		if not config.has(key):
			_fail("%s is missing \"%s\"" % [CONFIG_PATH, key])
			return {}
	for key in ["tick_seconds", "furnace_burn_seconds_per_coal"]:
		if config[key] <= 0.0:
			_fail("%s: %s must be above 0" % [CONFIG_PATH, key])
			return {}
	return config


func _fail(message: String) -> void:
	push_error(message)
	OS.alert(message, "Heartwake cannot start")
	get_tree().quit(1)
