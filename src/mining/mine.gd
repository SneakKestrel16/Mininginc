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
var drill_cost: Dictionary = {}

## Rock an auto-drill bores per hit of its share of drill power, against the hand tool's 1
## (data/world.json drill_efficiency, 1.0 when absent).
var drill_efficiency := 1.0

## True while the hand tool is cutting; it takes its share of drill power only then.
var hand_cutting := false

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
	if not world_config is Dictionary or not world_config.has("drill_cost"):
		_fail("res://data/world.json is missing \"drill_cost\"")
		return
	drill_cost = world_config["drill_cost"]
	drill_efficiency = world_config.get("drill_efficiency", 1.0)
	if world:
		world.world_seed = shaft.shaft_seed
		world.carved.connect(_collect)


## Shares [param hits] of drill power between the drills still digging and the hand tool,
## which takes one share only while it cuts; with no drills placed the hand tool gets all
## of it ([method hand_share]). Each drill bores [member drill_efficiency] times its share.
## Ore the drills break is collected through the world's signal.
func dig(hits: float = 1.0) -> void:
	var working := working_drills()
	if hits <= 0.0 or working.is_empty():
		return
	var shares := working.size() + (1 if hand_cutting else 0)
	for drill in working:
		drill.dig(hits / shares * drill_efficiency)
	changed.emit()


## Auto-drills not yet stopped at bedrock.
func working_drills() -> Array:
	return drills.filter(func(d: AutoDrill) -> bool: return not d.stopped)


## Hits per second drill power adds to the hand tool, out of [param drill_hits_per_second]
## for all drills: one share among the working drills and the tool.
func hand_share(drill_hits_per_second: float) -> float:
	return drill_hits_per_second / (working_drills().size() + 1)


## True when the inventory covers [param cost]: item id to amount.
func can_afford(cost: Dictionary) -> bool:
	for id in cost:
		if ores.get(id, 0) < cost[id]:
			return false
	return true


## Takes [param cost] from the inventory; check [method can_afford] first.
func pay(cost: Dictionary) -> void:
	for id in cost:
		take(id, int(cost[id]))


## Gives [param cost] back, [param times] over.
func refund(cost: Dictionary, times: int = 1) -> void:
	for id in cost:
		ores[id] = ores.get(id, 0) + int(cost[id]) * times  # JSON numbers are floats
	changed.emit()


## [param cost] as text for prompts: "2 iron plate, 2 wire".
static func cost_text(cost: Dictionary) -> String:
	var parts := PackedStringArray()
	for id in cost:
		parts.append("%d %s" % [int(cost[id]), id.replace("_", " ")])
	return ", ".join(parts)


## [param value] for text, without trailing zeros: "2" for 2.0, "2.25" for 2.25.
static func number_text(value: float) -> String:
	return ("%.2f" % value).rstrip("0").rstrip(".")


## Pays [member drill_cost] and places an auto-drill at cell [param at]. Returns the drill,
## or null when the inventory falls short, there is no world, the cell is the machines'
## protected ground, or a drill already stands there.
func place_drill(at: Vector3i) -> AutoDrill:
	if world == null or world.is_protected(at) or not can_afford(drill_cost):
		return null
	for drill in drills:
		if drill.column == Vector2i(at.x, at.z):
			return null
	pay(drill_cost)
	return restore_drill(at, at.y, false)


## Puts back a drill a save recorded at cell [param at], already dug down to
## [param depth_y]. Costs nothing: it was paid for when placed.
func restore_drill(at: Vector3i, depth_y: int, stopped: bool) -> AutoDrill:
	var drill := AutoDrill.new()
	drill.setup(world, self, at)
	drill.depth_y = depth_y
	drill.stopped = stopped
	world.add_child(drill)
	drills.append(drill)
	changed.emit()
	return drill


## Picks [param drill] up and gives back what it cost. Its column stays dug.
func remove_drill(drill: AutoDrill) -> void:
	drills.erase(drill)
	drill.queue_free()
	refund(drill_cost)


## Thaws the shaft down to [param depth], so rock above it digs at normal hardness; never
## refreezes above the surface layer's floor.
func thaw_to(depth: int) -> void:
	var floor_depth := maxi(_base_frozen_from, depth)
	if floor_depth != shaft.frozen_from:
		shaft.frozen_from = floor_depth
		changed.emit()
	if world:
		world.thaw_to(depth)


func _collect(_center: Vector3, collected: Dictionary) -> void:
	for what in collected:
		if what in ores:
			ores[what] += collected[what]
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
