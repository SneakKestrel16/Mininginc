## Heart stage Sight: ore near the player glows through the rock (brief: Milestone 2 item 12,
## as rewritten for Milestone 3D). The reach comes from the stage index every refresh, so a
## loaded save glows at once.
class_name OreSight
extends MultiMeshInstance3D

## Seconds between scans while the player stands in one block.
const RESCAN_SECONDS := 0.5

@export var economy: Economy
@export var world: VoxelWorld
@export var player: Player

var _last_block := Vector3i(0, 1 << 30, 0)
var _since_scan := 0.0
var _dirty := true


## Every hidden ore block within [param reach] blocks of [param center] in [param on_world],
## as pairs of position and block id. Rock, crust, air and bedrock are left out, and so is
## ore already showing on an open face.
static func scan(on_world: VoxelWorld, center: Vector3i, reach: int) -> Array:
	var found := []
	for x in range(center.x - reach, center.x + reach + 1):
		for y in range(center.y - reach, center.y + reach + 1):
			for z in range(center.z - reach, center.z + reach + 1):
				var pos := Vector3i(x, y, z)
				if (pos - center).length_squared() > reach * reach:
					continue
				var id := on_world.block_at(pos)
				if id > Blocks.ROCK and not _exposed(on_world, pos):
					found.append([pos, id])
	return found


static func _exposed(on_world: VoxelWorld, pos: Vector3i) -> bool:
	for face in VoxelWorld.FACES:
		if not on_world.is_solid(pos + face[0]):
			return true
	return false


func _ready() -> void:
	var cube := BoxMesh.new()
	cube.size = Vector3(0.3, 0.3, 0.3)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.vertex_color_use_as_albedo = true
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.no_depth_test = true
	cube.material = glow
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = cube
	world.block_broken.connect(func(_pos: Vector3i, _name: String) -> void: _dirty = true)


func _process(delta: float) -> void:
	var reach := int(economy.heart.effect_total("ore_sight"))
	visible = reach > 0
	if not visible:
		return
	_since_scan += delta
	var at := Vector3i(player.global_position.floor())
	if at == _last_block and not _dirty and _since_scan < RESCAN_SECONDS:
		return
	_last_block = at
	_dirty = false
	_since_scan = 0.0
	var found := scan(world, at, reach)
	multimesh.instance_count = found.size()
	for i in found.size():
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(found[i][0]) + Vector3(0.5, 0.5, 0.5)))
		var color: Color = Blocks.COLORS[found[i][1]]
		color.a = 0.7
		multimesh.set_instance_color(i, color)
