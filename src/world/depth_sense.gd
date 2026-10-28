## The light underground (brief: Milestone 10 item 42): eases the ambient light and the ore
## glow toward the stratum the player is in, and tells when the player enters a new one.
class_name DepthSense
extends WorldEnvironment

## Emitted when the player moves into stratum [param index] of [member VoxelWorld.strata];
## never for the stratum the player starts in.
signal stratum_entered(index: int)

## How fast the light follows the stratum: the share of the gap closed per second, as a rate.
const EASE_RATE := 1.5
## Metres past a stratum's edge before it counts as entered, so standing on the line does not
## flicker the banner.
const HYSTERESIS := 3.0

## Whose depth sets the light.
@export var player: Node3D
## The world whose strata and ore glow these are.
@export var world: VoxelWorld

## Index of the stratum the player is in; -1 until the first depth is read.
var stratum := -1
var _glow := 0.0


func _process(delta: float) -> void:
	if player and world and not world.strata.is_empty():
		sense(-player.global_position.y, delta)


## Reads the player's [param depth] in metres and eases the light [param delta] seconds toward
## its stratum's. The first reading sets the light at once and enters silently, so a loaded
## save does not replay a banner.
func sense(depth: float, delta: float) -> void:
	if stratum < 0:
		stratum = world.stratum_at(floori(depth))
		_ease(1.0)
		return
	var deeper := world.stratum_at(floori(depth - HYSTERESIS))
	var shallower := world.stratum_at(floori(depth + HYSTERESIS))
	var now := deeper if deeper > stratum else shallower if shallower < stratum else stratum
	if now != stratum:
		stratum = now
		stratum_entered.emit(stratum)
	_ease(1.0 - exp(-EASE_RATE * delta))


func _ease(weight: float) -> void:
	var target: Dictionary = world.strata[stratum]
	var rgb: Array = target["ambient_color"]
	environment.ambient_light_color = environment.ambient_light_color.lerp(Color(rgb[0], rgb[1], rgb[2]), weight)
	environment.ambient_light_energy = lerpf(environment.ambient_light_energy, target["ambient_energy"], weight)
	_glow = lerpf(_glow, target["ore_glow"], weight)
	world.set_ore_glow(_glow)
