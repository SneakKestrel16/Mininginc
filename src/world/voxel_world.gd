## The voxel moon: block terrain generated from a seed, drawn and collided in chunks
## (brief: Milestone 3D item 15). Blocks are never stored whole: a block is its generated
## type unless [member edits] says otherwise, so only changed blocks need saving.
## Block (x, y, z) fills the unit cube from that corner; the surface is the top of y = 0,
## and depth is -y.
class_name VoxelWorld
extends Node3D

## Emitted when a block breaks; [param block_name] is one of [constant Blocks.NAMES].
signal block_broken(pos: Vector3i, block_name: String)

const WORLD_PATH := "res://data/world.json"
const ORES_PATH := "res://data/ores.json"

## Normal, the four corners of the face (clockwise seen from outside: Godot's front face),
## and how much light the face gets, so block edges read without lighting.
const FACES := [
	[Vector3i.UP, [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)], 1.0],
	[Vector3i.DOWN, [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0)], 0.55],
	[Vector3i.LEFT, [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1)], 0.75],
	[Vector3i.RIGHT, [Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)], 0.75],
	[Vector3i.FORWARD, [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0)], 0.85],
	[Vector3i.BACK, [Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1)], 0.85],
]

## Seed every generated block follows.
var world_seed: int = 0
## Blocks changed from what the seed generates: position to block id.
var edits: Dictionary = {}
## Hits landed on blocks not yet broken: position to hits.
var damage: Dictionary = {}
## Depth from which rock is frozen; Breath moves it down.
var frozen_from: int

var chunk_size: int
var world_size: int
var max_depth: int
var crust_depth: int
var wall_height: int
var view_radius: int
## The open pit the Heart sits in, generated as air: corners, inclusive.
var chamber := AABB()

var _ores: Array
var _ore_ids: PackedInt32Array
var _hardness_base: float
var _hardness_per_block: float
var _frozen_multiplier: float
var _base_frozen_from: int
# Chunks that may hold a face next to air, so are worth drawing; the rest is solid rock.
var _open_chunks: Dictionary = {}
# Chunk key to its drawn node.
var _built: Dictionary = {}
var _material := StandardMaterial3D.new()


func _ready() -> void:
	var world := _load_json(WORLD_PATH, ["chunk_size", "world_size", "max_depth", "crust_depth", "wall_height",
			"view_radius_chunks", "heart_chamber_min", "heart_chamber_max"])
	var ores := _load_json(ORES_PATH, ["hardness_base", "hardness_per_block", "frozen_from_depth",
			"frozen_hardness_multiplier", "ores"])
	if world.is_empty() or ores.is_empty():
		return
	chunk_size = world["chunk_size"]
	world_size = world["world_size"]
	max_depth = world["max_depth"]
	crust_depth = world["crust_depth"]
	wall_height = world["wall_height"]
	view_radius = world["view_radius_chunks"]
	var low := Vector3(world["heart_chamber_min"][0], world["heart_chamber_min"][1], world["heart_chamber_min"][2])
	var high := Vector3(world["heart_chamber_max"][0], world["heart_chamber_max"][1], world["heart_chamber_max"][2])
	chamber = AABB(low, high - low)
	_ores = ores["ores"]
	for ore in _ores:
		var id := Blocks.id_of(ore["id"])
		if id < 0:
			_fail("%s: no block type for ore \"%s\"" % [ORES_PATH, ore["id"]])
			return
		_ore_ids.append(id)
	_hardness_base = ores["hardness_base"]
	_hardness_per_block = ores["hardness_per_block"]
	_frozen_multiplier = ores["frozen_hardness_multiplier"]
	_base_frozen_from = ores["frozen_from_depth"]
	frozen_from = _base_frozen_from
	_material.vertex_color_use_as_albedo = true
	_material.roughness = 0.95
	var chunks := ceili(world_size / float(chunk_size))
	for cx in chunks:
		for cz in chunks:
			_open_chunks[Vector3i(cx, 0, cz)] = true
	for x in [chamber.position.x, chamber.end.x]:
		for y in [chamber.position.y - 1, chamber.end.y]:
			for z in [chamber.position.z, chamber.end.z]:
				_open_chunks[chunk_of(Vector3i(x, y, z))] = true


## The block at [param pos]: its edit if it has one, else what the seed generates.
func block_at(pos: Vector3i) -> int:
	return edits.get(pos, generated(pos))


## What the seed generates at [param pos], ignoring edits.
func generated(pos: Vector3i) -> int:
	if not _solid_generated(pos):
		return Blocks.AIR
	if _is_wall(pos) or -pos.y >= max_depth:
		return Blocks.BEDROCK
	var depth := -pos.y
	if depth < crust_depth:
		return Blocks.CRUST
	for i in _ores.size():
		var ore: Dictionary = _ores[i]
		if depth >= ore["min_depth"] and depth <= ore["max_depth"] and _roll(pos, i) < ore["chance"]:
			return _ore_ids[i]
	return Blocks.ROCK


## True when [param pos] holds anything but air. Cheaper than [method block_at]: it never
## rolls for ores.
func is_solid(pos: Vector3i) -> bool:
	if edits.has(pos):
		return edits[pos] != Blocks.AIR
	return _solid_generated(pos)


## Hits it takes to break the block at [param pos]; INF for bedrock, 0 for air.
func hardness(pos: Vector3i) -> float:
	var id := block_at(pos)
	if id == Blocks.AIR:
		return 0.0
	if id == Blocks.BEDROCK:
		return INF
	var depth := maxi(-pos.y, 0)
	var hits := _hardness_base + _hardness_per_block * depth
	if depth >= frozen_from:
		hits *= _frozen_multiplier
	return ceilf(hits)


## True when the block at [param pos] is rock below the frozen floor.
func is_frozen(pos: Vector3i) -> bool:
	return -pos.y >= frozen_from and is_solid(pos)


## Thaws rock down to [param depth]; never refreezes above the base frozen floor.
func thaw_to(depth: int) -> void:
	frozen_from = maxi(_base_frozen_from, depth)


## Lands [param hits] on the block at [param pos]. Returns its name when this breaks it,
## else an empty String. Damage stays on the block between calls.
func hit(pos: Vector3i, hits: float) -> String:
	var needed := hardness(pos)
	if hits <= 0.0 or needed == 0.0 or is_inf(needed):
		return ""
	damage[pos] = damage.get(pos, 0.0) + hits
	# A hair under counts: hits are summed in floats, which can stop just short of a
	# whole number and leave a block that one more tiny hit never breaks.
	if damage[pos] < needed - 0.0001:
		return ""
	var block_name: String = Blocks.NAMES[block_at(pos)]
	break_block(pos)
	block_broken.emit(pos, block_name)
	return block_name


## [member edits] as a flat list of x, y, z, id: small in a JSON save.
func edits_flat() -> Array:
	var flat := []
	for pos in edits:
		flat.append_array([pos.x, pos.y, pos.z, edits[pos]])
	return flat


## Replaces [member edits] with a list from [method edits_flat], and marks every chunk
## that can see a changed block for drawing.
func load_edits(flat: Array) -> void:
	edits.clear()
	damage.clear()
	for i in range(0, flat.size() - 3, 4):
		var pos := Vector3i(int(flat[i]), int(flat[i + 1]), int(flat[i + 2]))
		edits[pos] = int(flat[i + 3])
		_open_chunks[chunk_of(pos)] = true
		for face in FACES:
			_open_chunks[chunk_of(pos + face[0])] = true
	for key in _built.keys():
		_build(key)


## Turns the block at [param pos] to air and redraws the chunks that can see it.
func break_block(pos: Vector3i) -> void:
	edits[pos] = Blocks.AIR
	damage.erase(pos)
	var touched := {}
	touched[chunk_of(pos)] = true
	for face in FACES:
		touched[chunk_of(pos + face[0])] = true
	for key in touched:
		_open_chunks[key] = true
		if _built.has(key):
			_build(key)


## The key of the chunk holding [param pos].
func chunk_of(pos: Vector3i) -> Vector3i:
	return Vector3i(floori(pos.x / float(chunk_size)), floori(pos.y / float(chunk_size)),
			floori(pos.z / float(chunk_size)))


## Draws open chunks within the view radius of [param center] and frees those well outside it.
func update_around(center: Vector3) -> void:
	var at := chunk_of(Vector3i(center.floor()))
	for key in _open_chunks:
		var reach: Vector3i = (key - at).abs()
		if maxi(reach.x, maxi(reach.y, reach.z)) <= view_radius and not _built.has(key):
			_build(key)
	for key in _built.keys():
		var reach: Vector3i = (key - at).abs()
		if maxi(reach.x, maxi(reach.y, reach.z)) > view_radius + 1:
			_built[key].queue_free()
			_built.erase(key)


## Number of chunks drawn now; checks use it.
func built_count() -> int:
	return _built.size()


## The drawn node of chunk [param key], or null. Checks use it.
func chunk_node(key: Vector3i) -> Node3D:
	return _built.get(key)


func _solid_generated(pos: Vector3i) -> bool:
	if pos.x < 0 or pos.z < 0 or pos.x >= world_size or pos.z >= world_size or -pos.y > max_depth:
		return false
	if _is_wall(pos):
		return pos.y <= wall_height
	if _in_chamber(pos):
		return false
	return pos.y <= 0


func _in_chamber(pos: Vector3i) -> bool:
	return pos.x >= chamber.position.x and pos.x <= chamber.end.x and pos.y >= chamber.position.y 			and pos.y <= chamber.end.y and pos.z >= chamber.position.z and pos.z <= chamber.end.z


func _is_wall(pos: Vector3i) -> bool:
	return pos.x == 0 or pos.z == 0 or pos.x == world_size - 1 or pos.z == world_size - 1


# A number in [0, 1) fixed by the seed, the position and the ore band.
func _roll(pos: Vector3i, band: int) -> float:
	return (hash([world_seed, pos.x, pos.y, pos.z, band]) & 0xFFFFFF) / float(0x1000000)


func _build(key: Vector3i) -> void:
	if _built.has(key):
		_built[key].queue_free()
		_built.erase(key)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var origin := key * chunk_size
	var y_top := mini(origin.y + chunk_size - 1, wall_height)
	var y_bottom := maxi(origin.y, -max_depth)
	for x in range(origin.x, origin.x + chunk_size):
		for z in range(origin.z, origin.z + chunk_size):
			for y in range(y_bottom, y_top + 1):
				var pos := Vector3i(x, y, z)
				if not is_solid(pos):
					continue
				var color := Color()
				var colored := false
				for face in FACES:
					if is_solid(pos + face[0]):
						continue
					if not colored:
						# A slight per-block shade, so a flat face still reads as blocks.
						color = Blocks.COLORS[block_at(pos)] * (0.92 + 0.12 * _roll(pos, -1))
						colored = true
					var start := verts.size()
					for corner in face[1]:
						verts.append(Vector3(pos) + corner)
						normals.append(Vector3(face[0]))
						colors.append(color * face[2])
					indices.append_array([start, start + 1, start + 2, start, start + 2, start + 3])
	var node := Node3D.new()
	node.name = "Chunk_%d_%d_%d" % [key.x, key.y, key.z]
	_built[key] = node
	add_child(node)
	if verts.is_empty():
		return
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _material)
	var view := MeshInstance3D.new()
	view.mesh = mesh
	node.add_child(view)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	body.add_child(shape)
	node.add_child(body)


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
	return config


func _fail(message: String) -> void:
	push_error(message)
	OS.alert(message, "Heartwake cannot start")
	get_tree().quit(1)
