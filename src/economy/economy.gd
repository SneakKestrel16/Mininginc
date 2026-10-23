## Runs the economy on a fixed tick, with tuning values from data/economy.json.
## Until story 003 adds the furnace, power comes from a fake source at a fixed rate.
class_name Economy
extends Node

## Emitted after every tick, once the split is updated.
signal ticked

const CONFIG_PATH := "res://data/economy.json"

## The drills/Heart split this economy feeds.
var split: PowerSplit

## Power produced per second by all generators.
var power_per_second: float = 0.0

var _tick_seconds: float
var _elapsed: float = 0.0


func _ready() -> void:
	var config := _load_config()
	if config.is_empty():
		set_process(false)
		return
	_tick_seconds = config["tick_seconds"]
	power_per_second = config["fake_power_per_second"]
	split = PowerSplit.new(config["heart_first_threshold"], config["heart_share_default"])


func _process(delta: float) -> void:
	_elapsed += delta
	while _elapsed >= _tick_seconds:
		_elapsed -= _tick_seconds
		split.tick(power_per_second, _tick_seconds)
		ticked.emit()


## Returns the config, or an empty Dictionary after reporting why it is unusable.
## Not assert(): release exports strip asserts, and friends run release builds.
func _load_config() -> Dictionary:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary:
		_fail("Cannot read %s (open error %d)" % [CONFIG_PATH, FileAccess.get_open_error()])
		return {}
	for key in ["tick_seconds", "fake_power_per_second", "heart_share_default", "heart_first_threshold"]:
		if not config.has(key):
			_fail("%s is missing \"%s\"" % [CONFIG_PATH, key])
			return {}
	if config["tick_seconds"] <= 0.0:
		_fail("%s: tick_seconds must be above 0" % CONFIG_PATH)
		return {}
	return config


func _fail(message: String) -> void:
	push_error(message)
	OS.alert(message, "Heartwake cannot start")
	get_tree().quit(1)
