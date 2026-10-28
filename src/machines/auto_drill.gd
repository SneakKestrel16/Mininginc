## An auto-drill the player places on the ground (brief: Milestone 3D item 20). It bores
## straight down its column with its share of drill power, one scoop per metre, digging
## exactly as the hand tool does, so hardness and Breath apply the same.
class_name AutoDrill
extends Node3D

## The world it digs.
var world: VoxelWorld
## The mine that placed it; picking it up goes back through the mine.
var mine: Mine
## Cell x and z of the column it digs.
var column: Vector2i
## Cell y it stands on.
var top_y: int
## Cell y it is digging now.
var depth_y: int
## True once it has reached bedrock; it then takes no more power.
var stopped := false

var _rod: MeshInstance3D


## Places the drill at cell [param at], digging that cell first.
func setup(on_world: VoxelWorld, owner_mine: Mine, at: Vector3i) -> void:
	world = on_world
	mine = owner_mine
	column = Vector2i(at.x, at.z)
	top_y = at.y
	depth_y = at.y
	position = Vector3(at.x + 0.5, at.y + 0.5, at.z + 0.5)


func _ready() -> void:
	var frame_material := StandardMaterial3D.new()
	frame_material.albedo_color = Color(0.75, 0.55, 0.15)
	for corner in [Vector3(-0.4, 0, -0.4), Vector3(0.4, 0, -0.4), Vector3(-0.4, 0, 0.4), Vector3(0.4, 0, 0.4)]:
		_add_box(Vector3(0.1, 1.6, 0.1), corner + Vector3(0, 0.8, 0), frame_material)
	_add_box(Vector3(0.9, 0.3, 0.9), Vector3(0, 1.6, 0), frame_material)
	var rod_material := StandardMaterial3D.new()
	rod_material.albedo_color = Color(0.5, 0.5, 0.55)
	rod_material.metallic = 0.8
	_rod = _add_box(Vector3(0.15, 1, 0.15), Vector3.ZERO, rod_material)
	# Seen by the player's aim ray, but not solid: layer 2 is outside the player's mask,
	# so the open column below stays open to climb into.
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(0.9, 1.8, 0.9)
	shape.position = Vector3(0, 0.9, 0)
	body.add_child(shape)
	add_child(body)
	_show_rod()


## Lands [param hits] down the column, carrying what is left after each scoop into the
## next one, so a long offline step digs as far as many short ones.
func dig(hits: float) -> void:
	var left := hits
	while left > 0.0 and not stopped:
		if depth_y < -world.max_depth:  # past the floor: only if the world is not set up
			stopped = true
			break
		var pos := Vector3i(column.x, depth_y, column.y)
		# Open air the seed made (a vault's hollow) costs nothing to pass, even where a wide
		# scoop has written an edit into it. Ground a scoop already carved still costs a
		# scoop, as it always has.
		if world.generated_density(pos) <= 0.0:
			depth_y -= 1
			continue
		var needed := world.hardness_at(pos)
		if is_inf(needed):
			stopped = true
			break
		# Never below zero: thawing lowers hardness under damage already landed.
		var remaining: float = maxf(needed - world.damage.get(pos, 0.0), 0.0)
		var used := minf(left, remaining)
		world.dig(Vector3(pos) + Vector3(0.5, 0.5, 0.5), used)
		left -= used
		# The world decides when a scoop is done: it forgives a float's hair short.
		if not world.damage.has(pos):
			depth_y -= 1
	_show_rod()


## What the player sees while looking at the drill.
func prompt() -> String:
	var state := "stopped at bedrock" if stopped else "digging at %d m" % maxi(-depth_y, 0)
	return "Auto-drill: %s\n[E] Pick up (returns %s)" % [state, Mine.cost_text(mine.drill_cost)]


## E: pick the drill up.
func use_primary() -> void:
	mine.remove_drill(self)


func use_secondary() -> void:
	pass


func _show_rod() -> void:
	if _rod == null:
		return
	var length := float(top_y - depth_y) + 1.2
	_rod.scale.y = length
	_rod.position.y = 0.2 - length / 2.0


func _add_box(size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
	var view := MeshInstance3D.new()
	view.mesh = BoxMesh.new()
	view.mesh.size = size
	view.position = at
	view.material_override = material
	add_child(view)
	return view
