## The smooth moon (brief: Milestone 4 items 24–25): a density field on a 1 m grid, generated
## from a seed, meshed per chunk with surface nets, and carved in round scoops. A sample is
## solid where its density is above 0. Samples are never stored whole: a sample is what the
## seed generates unless [member edits] says otherwise, so only carved ground needs saving.
## Flat ground lies at y = 1, the top of the old block world; depth is -y.
class_name VoxelWorld
extends Node3D

## Emitted after each scoop with what it removed: material name to samples removed.
signal carved(center: Vector3, collected: Dictionary)

const WORLD_PATH := "res://data/world.json"
const ORES_PATH := "res://data/ores.json"
## The six neighbours of a sample.
const SIDES: Array[Vector3i] = [Vector3i.UP, Vector3i.DOWN, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
## Density outside the world and in bedrock: far inside, so no scoop opens it.
const SOLID := 100.0

## Seed every generated sample follows.
var world_seed: int = 0:
	set(value):
		world_seed = value
		_seed_noise()
## Samples changed from what the seed generates: position to density.
var edits: Dictionary = {}
## Hits landed toward the next scoop, keyed by the 1 m cell scooped at.
var damage: Dictionary = {}
## Depth from which rock is frozen; Breath moves it down.
var frozen_from: int

var chunk_size: int
var world_size: int
var max_depth: int
var crust_depth: int
var wall_height: int
var view_radius: int
## Radius of one scoop, in metres.
var bite_radius: float
## Metres the Wider scoop upgrade adds to [member bite_radius].
var bite_bonus := 0.0
## Centre of the Heart's cavern: a sealed ball of air deep under the base.
var heart_center: Vector3
## Radius of the Heart's cavern, in metres.
var heart_radius: float
# The base: flat ground around the machines.
var _base := AABB()

var _ores: Array
var _ore_ids: PackedInt32Array
var _ore_noise: Array[FastNoiseLite] = []
var _ore_cutoff: PackedFloat32Array
var _ground_noise := FastNoiseLite.new()
var _bumps: float
var _ore_frequency: float
var _hardness_base: float
var _hardness_per_block: float
var _frozen_multiplier: float
var _bite_cost: float
var _base_frozen_from: int
# Areas no scoop may touch, so machines never float.
var _protected: Array[AABB] = []
# Chunks the surface may pass through, so are worth meshing; the rest is solid rock.
var _open_chunks: Dictionary = {}
# Chunk key to its drawn node.
var _built: Dictionary = {}
var _material := StandardMaterial3D.new()
var _ready_done := false


func _ready() -> void:
	var world := _load_json(WORLD_PATH, ["chunk_size", "world_size", "max_depth", "crust_depth", "wall_height",
			"view_radius_chunks", "heart_cavern_center", "heart_cavern_radius", "surface_bumps", "ore_noise_frequency",
			"bite_radius", "bite_cost", "base_min", "base_max", "machines_min", "machines_max"])
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
	_bumps = world["surface_bumps"]
	_ore_frequency = world["ore_noise_frequency"]
	bite_radius = world["bite_radius"]
	_bite_cost = world["bite_cost"]
	heart_center = Vector3(world["heart_cavern_center"][0], world["heart_cavern_center"][1], world["heart_cavern_center"][2])
	heart_radius = world["heart_cavern_radius"]
	var base_low := Vector3(world["base_min"][0], world["base_min"][1], world["base_min"][2])
	var base_high := Vector3(world["base_max"][0], world["base_max"][1], world["base_max"][2])
	_base = AABB(base_low, base_high - base_low)
	# Only the row the machines and console stand on is never carved, so nothing floats; the
	# rest of the base, where the player starts, digs like anywhere else.
	var machines_low := Vector3(world["machines_min"][0], world["machines_min"][1], world["machines_min"][2])
	var machines_high := Vector3(world["machines_max"][0], world["machines_max"][1], world["machines_max"][2])
	_protected.append(AABB(machines_low, machines_high - machines_low))
	_ores = ores["ores"]
	for ore in _ores:
		var id := Blocks.id_of(ore["id"])
		if id < 0:
			_fail("%s: no material for ore \"%s\"" % [ORES_PATH, ore["id"]])
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
			_open_chunks[Vector3i(cx, -1, cz)] = true
	var low := chunk_of(Vector3i((heart_center - Vector3.ONE * (heart_radius + 1)).floor()))
	var high := chunk_of(Vector3i((heart_center + Vector3.ONE * (heart_radius + 1)).ceil()))
	for cx in range(low.x, high.x + 1):
		for cy in range(low.y, high.y + 1):
			for cz in range(low.z, high.z + 1):
				_open_chunks[Vector3i(cx, cy, cz)] = true
	_ready_done = true
	_seed_noise()


## Density of the sample at [param pos]: its edit if it has one, else what the seed generates.
func density_at(pos: Vector3i) -> float:
	return edits.get(pos, generated_density(pos))


## Density the seed generates at [param pos], ignoring edits.
func generated_density(pos: Vector3i) -> float:
	if pos.x < 0 or pos.z < 0 or pos.x >= world_size or pos.z >= world_size:
		return SOLID if pos.y <= wall_height else -1.0
	if -pos.y >= max_depth:
		return SOLID
	if _is_wall(pos):
		return SOLID if pos.y <= wall_height else -1.0
	var bumps := 0.0 if _base.has_point(Vector3(pos.x, _base.position.y, pos.z)) else _bumps
	var ground := 1.0 - pos.y + bumps * _ground_noise.get_noise_2d(pos.x, pos.z)
	# The cavern: a smooth ball of air, cut the way a scoop cuts.
	return minf(ground, Vector3(pos).distance_to(heart_center) - heart_radius)


## True when the sample at [param pos] is solid ground.
func is_solid(pos: Vector3i) -> bool:
	return density_at(pos) > 0.0


## What the sample at [param pos] is made of, solid or not: one of [constant Blocks.NAMES].
func material_at(pos: Vector3i) -> int:
	if _is_wall(pos) or -pos.y >= max_depth or pos.x < 0 or pos.z < 0 or pos.x >= world_size or pos.z >= world_size:
		return Blocks.BEDROCK
	var depth := -pos.y
	if depth < crust_depth:
		return Blocks.CRUST
	for i in _ores.size():
		var ore: Dictionary = _ores[i]
		if depth >= ore["min_depth"] and depth <= ore["max_depth"] \
				and _ore_noise[i].get_noise_3d(pos.x, pos.y, pos.z) > _ore_cutoff[i]:
			return _ore_ids[i]
	return Blocks.ROCK


## Hits one scoop at [param pos] costs; INF in bedrock.
func hardness_at(pos: Vector3i) -> float:
	if material_at(pos) == Blocks.BEDROCK:
		return INF
	var depth := maxi(-pos.y, 0)
	var hits := _hardness_base + _hardness_per_block * depth
	if depth >= frozen_from:
		hits *= _frozen_multiplier
	return hits * _bite_cost


## True when [param pos] lies below the frozen floor.
func is_frozen(pos: Vector3i) -> bool:
	return -pos.y >= frozen_from


## Thaws rock down to [param depth]; never refreezes above the base frozen floor.
func thaw_to(depth: int) -> void:
	frozen_from = maxi(_base_frozen_from, depth)


## Lands [param hits] of digging at [param point]. When they reach a scoop's hardness the
## scoop is carved there and what it removed is returned (material name to samples);
## else returns an empty Dictionary and the hits wait for the next call at that spot.
func dig(point: Vector3, hits: float) -> Dictionary:
	var cell := Vector3i(point.floor())
	var needed := hardness_at(cell)
	if hits <= 0.0 or is_inf(needed) or _is_protected(cell):
		return {}
	damage[cell] = damage.get(cell, 0.0) + hits
	# A hair under counts: hits are summed in floats, which can stop just short.
	if damage[cell] < needed - 0.0001:
		return {}
	damage.erase(cell)
	return carve(point, bite_radius + bite_bonus)


## Carves a ball of [param radius] at [param center] out of the ground, sparing bedrock and
## protected areas. Returns what it removed: material name to samples.
func carve(center: Vector3, radius: float) -> Dictionary:
	var collected := {}
	var low := Vector3i((center - Vector3.ONE * radius).floor())
	var high := Vector3i((center + Vector3.ONE * radius).ceil())
	var touched := {}
	for x in range(low.x, high.x + 1):
		for y in range(low.y, high.y + 1):
			for z in range(low.z, high.z + 1):
				var pos := Vector3i(x, y, z)
				var old := density_at(pos)
				var cut := minf(old, Vector3(pos).distance_to(center) - radius)
				if cut >= old or material_at(pos) == Blocks.BEDROCK or _is_protected(pos):
					continue
				edits[pos] = cut
				if old > 0.0 and cut <= 0.0:
					var what: String = Blocks.NAMES[material_at(pos)]
					collected[what] = collected.get(what, 0) + 1
				# A sample moves the vertices of the cells around it, and those are used by
				# quads of edges up to one sample further on each side.
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						for dz in [-1, 0, 1]:
							touched[chunk_of(pos + Vector3i(dx, dy, dz))] = true
	for key in touched:
		_open_chunks[key] = true
		if _built.has(key):
			_build(key)
	carved.emit(center, collected)
	return collected


## Keeps every scoop away from [param box] (a machine's footprint, say), so nothing floats.
func protect(box: AABB) -> void:
	_protected.append(box.grow(0.5))


## The key of the chunk holding sample [param pos].
func chunk_of(pos: Vector3i) -> Vector3i:
	return Vector3i(floori(pos.x / float(chunk_size)), floori(pos.y / float(chunk_size)),
			floori(pos.z / float(chunk_size)))


## Meshes open chunks within the view radius of [param center] and frees those well outside it.
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


## [member edits] as a flat list of x, y, z, density: small in a JSON save.
func edits_flat() -> Array:
	var flat := []
	for pos in edits:
		flat.append_array([pos.x, pos.y, pos.z, snappedf(edits[pos], 0.001)])
	return flat


## Replaces [member edits] with a list from [method edits_flat], and opens every chunk that
## can see a changed sample.
func load_edits(flat: Array) -> void:
	edits.clear()
	damage.clear()
	for i in range(0, flat.size() - 3, 4):
		var pos := Vector3i(int(flat[i]), int(flat[i + 1]), int(flat[i + 2]))
		edits[pos] = float(flat[i + 3])
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				for dz in [-1, 0, 1]:
					_open_chunks[chunk_of(pos + Vector3i(dx, dy, dz))] = true
	for key in _built.keys():
		_build(key)


## Number of chunks drawn now; checks use it.
func built_count() -> int:
	return _built.size()


## The drawn node of chunk [param key], or null. Checks use it.
func chunk_node(key: Vector3i) -> Node3D:
	return _built.get(key)


func _is_wall(pos: Vector3i) -> bool:
	return pos.x == 0 or pos.z == 0 or pos.x == world_size - 1 or pos.z == world_size - 1


## True when no scoop may touch [param pos]: ground under the machines.
func is_protected(pos: Vector3i) -> bool:
	return _is_protected(pos)


func _is_protected(pos: Vector3i) -> bool:
	for box in _protected:
		if box.has_point(Vector3(pos)):
			return true
	return false


# One noise per ore band, seeded from the world seed. Each band's cutoff is the noise value
# that the band's chance of samples lies above, measured on this noise, so deposits fill the
# same share of rock that data/ores.json asks for.
func _seed_noise() -> void:
	if not _ready_done:
		return
	_ground_noise.seed = world_seed
	_ground_noise.frequency = 0.03
	_ore_noise.clear()
	_ore_cutoff.clear()
	for i in _ores.size():
		var noise := FastNoiseLite.new()
		noise.seed = world_seed + 7919 * (i + 1)
		noise.frequency = _ore_frequency
		_ore_noise.append(noise)
		var values := PackedFloat32Array()
		for s in 4096:
			values.append(noise.get_noise_3d(s * 7.13, s * 3.71, s * 5.29))
		values.sort()
		var chance: float = _ores[i]["chance"]
		_ore_cutoff.append(values[clampi(int((1.0 - chance) * values.size()), 0, values.size() - 1)])


# Surface nets: one vertex per cell the surface crosses, at the average of its edge crossings;
# one quad across every grid edge with solid on one end and air on the other.
func _build(key: Vector3i) -> void:
	if _built.has(key):
		_built[key].queue_free()
		_built.erase(key)
	var n := chunk_size
	var origin := key * n
	var span := n + 2  # samples origin-1 .. origin+n
	var dens := PackedFloat32Array()
	dens.resize(span * span * span)
	var any_solid := false
	var any_air := false
	for x in span:
		for y in span:
			for z in span:
				var d := density_at(origin + Vector3i(x - 1, y - 1, z - 1))
				dens[(x * span + y) * span + z] = d
				any_solid = any_solid or d > 0.0
				any_air = any_air or d <= 0.0
	var node := Node3D.new()
	node.name = "Chunk_%d_%d_%d" % [key.x, key.y, key.z]
	_built[key] = node
	add_child(node)
	if not (any_solid and any_air):
		return
	# Cells -1 .. n-1 (by their low corner), stored as vertex index or -1.
	var cells := n + 1
	var vertex_of := PackedInt32Array()
	vertex_of.resize(cells * cells * cells)
	vertex_of.fill(-1)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	for cx in cells:
		for cy in cells:
			for cz in cells:
				var corner := PackedFloat32Array()
				corner.resize(8)
				var inside := 0
				for c in 8:
					var d := dens[((cx + (c & 1)) * span + cy + ((c >> 1) & 1)) * span + cz + ((c >> 2) & 1)]
					corner[c] = d
					if d > 0.0:
						inside += 1
				if inside == 0 or inside == 8:
					continue
				var sum := Vector3.ZERO
				var crossings := 0
				for edge in [[0, 1], [2, 3], [4, 5], [6, 7], [0, 2], [1, 3], [4, 6], [5, 7], [0, 4], [1, 5], [2, 6], [3, 7]]:
					var a: float = corner[edge[0]]
					var b: float = corner[edge[1]]
					if (a > 0.0) == (b > 0.0):
						continue
					var t := a / (a - b)
					var pa := Vector3(edge[0] & 1, (edge[0] >> 1) & 1, (edge[0] >> 2) & 1)
					var pb := Vector3(edge[1] & 1, (edge[1] >> 1) & 1, (edge[1] >> 2) & 1)
					sum += pa.lerp(pb, t)
					crossings += 1
				var low := origin + Vector3i(cx - 1, cy - 1, cz - 1)
				vertex_of[(cx * cells + cy) * cells + cz] = verts.size()
				verts.append(Vector3(low) + sum / crossings)
				# Density falls toward air, so the outward normal is against its gradient.
				var grad := Vector3(
					corner[1] + corner[3] + corner[5] + corner[7] - corner[0] - corner[2] - corner[4] - corner[6],
					corner[2] + corner[3] + corner[6] + corner[7] - corner[0] - corner[1] - corner[4] - corner[5],
					corner[4] + corner[5] + corner[6] + corner[7] - corner[0] - corner[1] - corner[2] - corner[3])
				normals.append(-grad.normalized() if grad.length_squared() > 0.0 else Vector3.UP)
				# Colour of the most solid corner: what the surface here is cut into.
				var best := 0
				for c in 8:
					if corner[c] > corner[best]:
						best = c
				var at := low + Vector3i(best & 1, (best >> 1) & 1, (best >> 2) & 1)
				colors.append(Blocks.COLORS[material_at(at)] * (0.92 + 0.12 * _shade(at)))
	var indices := PackedInt32Array()
	# Edges from samples this chunk owns (origin .. origin+n-1) along +x, +y, +z.
	for axis in 3:
		var step := Vector3i.ZERO
		step[axis] = 1
		var u := (axis + 1) % 3
		var v := (axis + 2) % 3
		for sx in n:
			for sy in n:
				for sz in n:
					var a := dens[((sx + 1) * span + sy + 1) * span + sz + 1]
					var b := dens[((sx + 1 + step.x) * span + sy + 1 + step.y) * span + sz + 1 + step.z]
					if (a > 0.0) == (b > 0.0):
						continue
					# The four cells around this edge, by their offsets along u and v.
					var quad := PackedInt32Array()
					for offset in [[0, 0], [0, -1], [-1, -1], [-1, 0]]:
						var cell := Vector3i(sx + 1, sy + 1, sz + 1)
						cell[u] += offset[0]
						cell[v] += offset[1]
						quad.append(vertex_of[(cell.x * cells + cell.y) * cells + cell.z])
					if quad.has(-1):
						continue
					if a > 0.0:  # solid then air along the axis: the surface faces +axis
						indices.append_array([quad[0], quad[1], quad[2], quad[0], quad[2], quad[3]])
					else:
						indices.append_array([quad[0], quad[2], quad[1], quad[0], quad[3], quad[2]])
	if indices.is_empty():
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


# A number in [0, 1) fixed by the seed and the position, for a slight shade per spot.
func _shade(pos: Vector3i) -> float:
	return (hash([world_seed, pos.x, pos.y, pos.z]) & 0xFFFF) / float(0x10000)


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
