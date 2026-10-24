## Owns the ores found so far and the auto-drills placed in the voxel world, with tuning
## values from data/ores.json and data/world.json.
class_name Mine
extends Node

## Emitted after every hit on the shaft, broken or not, and whenever ore is taken.
signal changed

const CONFIG_PATH := "res://data/ores.json"

## The voxel moon the player digs; ore broken there is collected here. Optional, so
## checks can run a Mine alone.
@export var world: VoxelWorld

## Holds the world seed and the MVP's shaft fields that saves still carry; the economy's
## drills no longer dig it (story 017).
var shaft: DigShaft

## Placed auto-drills, oldest first.
var drills: Array[AutoDrill] = []

## Copper one auto-drill costs.
var drill_cost: int = 0

## Ore id to amount found so far. Rock is not counted.
var ores: Dictionary = {}

var _base_frozen_from: int


func _ready() -> void:
	var config := _load_config()
	if config.is_empty():
		return
	for ore in config["ores"]:
		ores[ore["id"]] = 0
	# A new game rolls its shaft; story 007 restores a saved seed instead.
	shaft = DigShaft.new(randi(), config["hardness_base"], config["hardness_per_block"], config["ores"],
			config["frozen_from_depth"], config["frozen_hardness_multiplier"])
	_base_frozen_from = config["frozen_from_depth"]
	var world_config = JSON.parse_string(FileAccess.get_file_as_string("res://data/world.json"))
	if not world_config is Dictionary or not world_config.has("drill_build_copper"):
		_fail("res://data/world.json is missing \"drill_build_copper\"")
		return
	drill_cost = world_config["drill_build_copper"]
	if world:
		world.world_seed = shaft.shaft_seed
		world.block_broken.connect(_collect)


## Shares [param hits] of drill power between the drills still digging; with none placed
## the power does nothing. Ore they break is collected through the world's signal.
func dig(hits: float = 1.0) -> void:
	var working := drills.filter(func(d: AutoDrill) -> bool: return not d.stopped)
	if hits <= 0.0 or working.is_empty():
		return
	for drill in working:
		drill.dig(hits / working.size())
	changed.emit()


## Spends copper and places an auto-drill on top of block [param at]. Returns the drill,
## or null when there is not enough copper, no world, or a drill already stands there.
func place_drill(at: Vector3i) -> AutoDrill:
	if world == null or ores.get("copper", 0) < drill_cost:
		return null
	for drill in drills:
		if drill.column == Vector2i(at.x, at.z):
			return null
	take("copper", drill_cost)
	var drill := AutoDrill.new()
	drill.setup(world, self, at)
	world.add_child(drill)
	drills.append(drill)
	changed.emit()
	return drill


## Picks [param drill] up and gives back its copper. Its column stays dug.
func remove_drill(drill: AutoDrill) -> void:
	drills.erase(drill)
	drill.queue_free()
	ores["copper"] = ores.get("copper", 0) + drill_cost
	changed.emit()


## Thaws the shaft down to [param depth], so rock above it digs at normal hardness; never
## refreezes above the surface layer's floor.
func thaw_to(depth: int) -> void:
	var floor_depth := maxi(_base_frozen_from, depth)
	if floor_depth != shaft.frozen_from:
		shaft.frozen_from = floor_depth
		changed.emit()
	if world:
		world.thaw_to(depth)


func _collect(_pos: Vector3i, block_name: String) -> void:
	if block_name in ores:
		ores[block_name] += 1
		changed.emit()


## Removes up to [param amount] of ore [param id]. Returns how much was taken.
func take(id: String, amount: int) -> int:
	var taken := mini(amount, ores.get(id, 0))
	if taken > 0:
		ores[id] -= taken
		changed.emit()
	return taken


## Returns the config, or an empty Dictionary after reporting why it is unusable.
## Not assert(): release exports strip asserts, and friends run release builds.
func _load_config() -> Dictionary:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not config is Dictionary:
		_fail("Cannot read %s (open error %d)" % [CONFIG_PATH, FileAccess.get_open_error()])
		return {}
	for key in ["hardness_base", "hardness_per_block", "frozen_from_depth", "frozen_hardness_multiplier", "ores"]:
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
