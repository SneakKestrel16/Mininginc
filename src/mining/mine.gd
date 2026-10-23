## Owns the dig shaft and the ores found in it, with tuning values from data/ores.json.
class_name Mine
extends Node

## Emitted after every hit on the shaft, broken or not.
signal dug

const CONFIG_PATH := "res://data/ores.json"

## The shaft being dug.
var shaft: DigShaft

## Ore id to amount found so far. Rock is not counted.
var ores: Dictionary = {}


func _ready() -> void:
	var config := _load_config()
	if config.is_empty():
		return
	for ore in config["ores"]:
		ores[ore["id"]] = 0
	# A new game rolls its shaft; story 007 restores a saved seed instead.
	shaft = DigShaft.new(randi(), config["hardness_base"], config["hardness_per_block"], config["ores"])


## Lands one hit of [param power] on the shaft and collects any ore it breaks out.
func hit(power: float = 1.0) -> void:
	var contents := shaft.hit(power)
	if contents in ores:
		ores[contents] += 1
	dug.emit()


## Returns the config, or an empty Dictionary after reporting why it is unusable.
## Not assert(): release exports strip asserts, and friends run release builds.
func _load_config() -> Dictionary:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary:
		_fail("Cannot read %s (open error %d)" % [CONFIG_PATH, FileAccess.get_open_error()])
		return {}
	for key in ["hardness_base", "hardness_per_block", "ores"]:
		if not config.has(key):
			_fail("%s is missing \"%s\"" % [CONFIG_PATH, key])
			return {}
	for ore in config["ores"]:
		for key in ["id", "min_depth", "max_depth", "chance"]:
			if not ore.has(key):
				_fail("%s: an ore is missing \"%s\"" % [CONFIG_PATH, key])
				return {}
	return config


func _fail(message: String) -> void:
	push_error(message)
	OS.alert(message, "Heartwake cannot start")
	get_tree().quit(1)
