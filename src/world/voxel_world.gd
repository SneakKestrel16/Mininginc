## The smooth moon (brief: Milestone 4 items 24–25): a density field on a 1 m grid, generated
## from a seed, meshed per chunk with surface nets, and carved in round scoops. A sample is
## solid where its density is above 0. Samples are never stored whole: a sample is what the
## seed generates unless [member edits] says otherwise, so only carved ground needs saving.
## Flat ground lies at y = 1, the top of the old block world; depth is -y.
class_name VoxelWorld
extends Node3D

## Emitted after each scoop with what it removed: material name to samples removed.
signal carved(center: Vector3, collected: Dictionary)
## Emitted the first time a scoop breaks into vault [param index] of [member vaults];
## [param ore] is what its walls hold. Not saved: a reload may tell it once more.
signal vault_opened(index: int, ore: String)

const WORLD_PATH := "res://data/world.json"
const ORES_PATH := "res://data/ores.json"
const STRATA_PATH := "res://data/strata.json"
## Darkest ambient a stratum may ask for: below it a tunnel lit by the headlamp alone is
## too dark to read.
const MIN_AMBIENT := 0.12
## The six neighbours of a sample.
const SIDES: Array[Vector3i] = [Vector3i.UP, Vector3i.DOWN, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
## Density outside the world and in bedrock: far inside, so no scoop opens it.
const SOLID := 100.0
## Metres past a scoop that a loose piece of ground may reach and still fall: ground that
## connects to nothing within this distance counts as held up.
const SUPPORT_REACH := 6
## Metres per side of the cells vaults are looked up by.
const VAULT_CELL := 16.0
## A vault is this many times wider than it is tall.
const VAULT_SQUASH := 1.4
## Metres a vault's wall wanders in and out of its round shape.
const VAULT_LUMPS := 0.8
## Metres of plain rock kept between a vault's shell and a wall, a stratum's edge or another vault.
const VAULT_CLEAR := 2.0
## Places tried for each vault before it is left out.
const VAULT_TRIES := 20
# Neighbours in the order a support fill pushes them: down last, so it is tried first.
const FILL_ORDER: Array[Vector3i] = [Vector3i.UP, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK, Vector3i.DOWN]

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
## Bands of rock by depth, shallowest first, as data/strata.json lists them: each has a name,
## from_depth, hardness, a rock tint, ambient light, ore glow and a banner line, and the deep
## ones a vaults block.
var strata: Array = []
## Sealed hollows in the deep strata (brief: Milestone 10 item 45), placed from the seed so
## nothing about them is saved. Each has center, radius, shell, ore (block id), cutoff (of
## the patch noise, from the stratum's cover), stratum, glow, glow_range and glow_energy.
var vaults: Array[Dictionary] = []
## Metres within which the HUD names the nearest vault once the Heart has Sight.
var vault_sight_range: float
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
var _material := ShaderMaterial.new()
var _ready_done := false
# Vault lookup cell to the indices of the vaults reaching into it.
var _vault_cells: Dictionary = {}
# Highest y any vault reaches; samples above it never look vaults up.
var _vault_top := -INF
# Chunks opened only because a vault is in them: closed again on a reseed.
var _vault_chunks: Array[Vector3i] = []
var _vault_noise := FastNoiseLite.new()
var _patch_noise := FastNoiseLite.new()
# Vault index to the light glowing inside it, for vaults near the player.
var _vault_lights: Dictionary = {}
# Vault indices a scoop has broken into this session.
var _opened: Dictionary = {}


func _ready() -> void:
	var world := _load_json(WORLD_PATH, ["chunk_size", "world_size", "max_depth", "crust_depth", "wall_height",
			"view_radius_chunks", "heart_cavern_center", "heart_cavern_radius", "surface_bumps", "ore_noise_frequency",
			"bite_radius", "bite_cost", "base_min", "base_max", "machines_min", "machines_max", "vault_sight_range"])
	var ores := _load_json(ORES_PATH, ["hardness_base", "hardness_per_block", "frozen_from_depth",
			"frozen_hardness_multiplier", "ores"])
	var strata_data := _load_json(STRATA_PATH, ["strata"])
	if world.is_empty() or ores.is_empty() or strata_data.is_empty():
		return
	var refused := strata_error(strata_data["strata"], world["max_depth"])
	if refused != "":
		_fail("%s: %s" % [STRATA_PATH, refused])
		return
	strata = strata_data["strata"]
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
	vault_sight_range = world["vault_sight_range"]
	var base_low := Vector3(world["base_min"][0], world["base_min"][1], world["base_min"][2])
	var base_high := Vector3(world["base_max"][0], world["base_max"][1], world["base_max"][2])
	_base = AABB(base_low, base_high - base_low)
	# Only the row the machines and console stand on is never carved, so nothing floats; the
	# rest of the base, where the player starts, digs like anywhere else.
	var machines_low := Vector3(world["machines_min"][0], world["machines_min"][1], world["machines_min"][2])
	var machines_high := Vector3(world["machines_max"][0], world["machines_max"][1], world["machines_max"][2])
	_protected.append(AABB(machines_low, machines_high - machines_low))
	_add_platform(machines_low, machines_high)
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
	_material.shader = load("res://src/world/terrain.gdshader")
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
## An edit only ever carves: one from a save made before the seed hollowed that spot (a vault)
## cannot fill it back in.
func density_at(pos: Vector3i) -> float:
	var generated := generated_density(pos)
	return minf(edits.get(pos, generated), generated)


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
	var density := minf(ground, Vector3(pos).distance_to(heart_center) - heart_radius)
	if pos.y <= _vault_top:
		var near = _vault_cells.get(_vault_cell(pos))
		if near:
			for i in near:
				# Only the vault's own ground changes: past its shell the rock keeps its density.
				var cavity := _cavity(vaults[i], Vector3(pos))
				if cavity <= vaults[i]["shell"] + 1.0:
					density = minf(density, cavity)
	return density


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
	# A vault's wall: patches of its stratum's ore in the shell around the hollow.
	if pos.y <= _vault_top:
		var near = _vault_cells.get(_vault_cell(pos))
		if near:
			for i in near:
				var vault: Dictionary = vaults[i]
				var cavity := _cavity(vault, Vector3(pos))
				if cavity > 0.0 and cavity <= vault["shell"] and _patch_noise.get_noise_3d(pos.x, pos.y, pos.z) > vault["cutoff"]:
					return vault["ore"]
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
	return hits * _bite_cost * float(strata[stratum_at(depth)]["hardness"])


## Index in [member strata] of the stratum at [param depth] metres; the first above ground.
func stratum_at(depth: int) -> int:
	var index := 0
	for i in strata.size():
		if depth >= strata[i]["from_depth"]:
			index = i
	return index


## Colour the ground at [param pos] is drawn in: its material's colour, with rock and crust
## tinted by their stratum. Alpha is 1 on ore, which the terrain shader flecks.
func surface_color(pos: Vector3i) -> Color:
	var what := material_at(pos)
	var color: Color = Blocks.COLORS[what]
	if what == Blocks.ROCK or what == Blocks.CRUST:
		color *= _color(strata[stratum_at(-pos.y)]["tint"])
	color.a = 1.0 if what > Blocks.ROCK else 0.0
	return color


## Sets how brightly ore flecks glow; the depth the player is at sets it.
func set_ore_glow(glow: float) -> void:
	_material.set_shader_parameter("ore_glow", glow)


## Why [param list] is not a usable strata list for a world [param depth_limit] metres deep,
## or "" when it is.
static func strata_error(list: Array, depth_limit: int) -> String:
	if list.is_empty() or int(list[0]["from_depth"]) != 0:
		return "the first stratum must start at 0 m"
	var rock: Color = Blocks.COLORS[Blocks.ROCK]
	for i in list.size():
		var stratum: Dictionary = list[i]
		for key in ["name", "from_depth", "hardness", "tint", "ambient_color", "ambient_energy", "ore_glow", "line"]:
			if not stratum.has(key):
				return "stratum %d is missing \"%s\"" % [i, key]
		if i > 0 and stratum["from_depth"] <= list[i - 1]["from_depth"]:
			return "%s must start deeper than %s" % [stratum["name"], list[i - 1]["name"]]
		if stratum["from_depth"] >= depth_limit:
			return "%s starts below bedrock" % stratum["name"]
		if stratum["ambient_energy"] < MIN_AMBIENT:
			return "%s is darker than %.2f ambient" % [stratum["name"], MIN_AMBIENT]
		for channel in stratum["tint"]:
			if channel < 0.5 or channel > 1.5:
				return "%s's tint must stay within 0.5 to 1.5" % stratum["name"]
		# Tinted rock stays rock-coloured, so ore keeps standing out against it.
		var tinted: Color = rock * _color(stratum["tint"])
		var lightness := tinted.get_luminance() / rock.get_luminance()
		if lightness < 0.75 or lightness > 1.1 or tinted.s > 0.3:
			return "%s's tint changes rock too much" % stratum["name"]
		if stratum.has("vaults"):
			var spec: Dictionary = stratum["vaults"]
			for key in ["count", "radius", "shell", "cover", "ore", "glow", "glow_range", "glow_energy"]:
				if not spec.has(key):
					return "%s's vaults are missing \"%s\"" % [stratum["name"], key]
			if Blocks.id_of(spec["ore"]) <= Blocks.ROCK:
				return "%s's vaults are walled with \"%s\", which is no ore" % [stratum["name"], spec["ore"]]
	return ""


## True when [param pos] lies below the frozen floor.
func is_frozen(pos: Vector3i) -> bool:
	return -pos.y >= frozen_from


## Thaws rock down to [param depth]; never refreezes above the base frozen floor.
func thaw_to(depth: int) -> void:
	frozen_from = maxi(_base_frozen_from, depth)


## Radius of a scoop now, upgrades included.
func scoop_radius() -> float:
	return bite_radius + bite_bonus


## Lands [param hits] of digging at [param point]. When they reach a scoop's hardness the
## scoop is carved there and what it removed is returned (material name to samples);
## else returns an empty Dictionary and the hits wait for the next call at that spot.
func dig(point: Vector3, hits: float) -> Dictionary:
	var cell := Vector3i(point.floor())
	var needed := hardness_at(cell)
	# Zero hits still finish a scoop whose damage already covers it: after Breath thaws
	# rock, damage landed while it was frozen can exceed the new, lower hardness.
	if hits < 0.0 or is_inf(needed) or _is_protected(cell):
		return {}
	damage[cell] = damage.get(cell, 0.0) + hits
	# A hair under counts: hits are summed in floats, which can stop just short.
	if damage[cell] < needed - 0.0001:
		return {}
	damage.erase(cell)
	return carve(point, scoop_radius())


## Carves a ball of [param radius] at [param center] out of the ground, sparing bedrock and
## protected areas. Returns what it removed: material name to samples.
func carve(center: Vector3, radius: float) -> Dictionary:
	var collected := {}
	var low := Vector3i((center - Vector3.ONE * radius).floor())
	var high := Vector3i((center + Vector3.ONE * radius).ceil())
	var touched := {}
	# Samples this scoop turned from rock to air.
	var aired: Array[Vector3i] = []
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
					aired.append(pos)
					var what: String = Blocks.NAMES[material_at(pos)]
					collected[what] = collected.get(what, 0) + 1
				# A sample moves the vertices of the cells around it, and those are used by
				# quads of edges up to one sample further on each side.
				_touch(pos, touched)
	_drop_floating(center, radius, collected, touched, aired)
	for key in touched:
		_open_chunks[key] = true
		if _built.has(key):
			_build(key)
	carved.emit(center, collected)
	_open_vaults(aired)
	return collected


# A vault is broken into by the scoop that turns a sample beside its hollow to air, from any
# side: a distance from the scoop's middle comes late from above or below, where the squash
# puts the hollow nearer than it says.
func _open_vaults(aired: Array[Vector3i]) -> void:
	for pos in aired:
		if pos.y > _vault_top + 1.0:
			continue
		for side in SIDES:
			var next: Vector3i = pos + side
			var near = _vault_cells.get(_vault_cell(next))
			if not near:
				continue
			for i in near:
				if not _opened.has(i) and _cavity(vaults[i], Vector3(next)) <= 0.0:
					_opened[i] = true
					vault_opened.emit(i, Blocks.NAMES[vaults[i]["ore"]])


# Ground a scoop cut loose falls and breaks whole (playtest: "no floating ground anywhere"):
# every solid sample beside the scoop is flood-filled; a piece that never reaches
# SUPPORT_REACH metres from the scoop is held up by nothing and is removed, its ore collected.
# ponytail: a bounded fill, so a huge piece hanging by a long thin bridge stays up; a global
# connectivity pass would catch it if that ever shows in play.
func _drop_floating(center: Vector3, radius: float, collected: Dictionary, touched: Dictionary, aired: Array[Vector3i]) -> void:
	var reach := int(ceil(radius)) + SUPPORT_REACH
	var middle := Vector3i(center.round())
	# Sample to its fill's verdict: HELD once that fill found support. Samples of a loose
	# piece become air, so they never need a verdict.
	var seen := {}
	var low := Vector3i((center - Vector3.ONE * (radius + 1.5)).floor())
	var high := Vector3i((center + Vector3.ONE * (radius + 1.5)).ceil())
	for x in range(low.x, high.x + 1):
		for y in range(low.y, high.y + 1):
			for z in range(low.z, high.z + 1):
				var start := Vector3i(x, y, z)
				if seen.has(start) or not is_solid(start):
					continue
				# Depth first, down first: solid ground usually finds support straight below
				# in a few steps.
				var stack: Array[Vector3i] = [start]
				var piece: Array[Vector3i] = []
				var mine := {start: true}
				var held := false
				while not stack.is_empty():
					var pos: Vector3i = stack.pop_back()
					piece.append(pos)
					var off := (pos - middle).abs()
					if maxi(off.x, maxi(off.y, off.z)) >= reach or material_at(pos) == Blocks.BEDROCK or _is_protected(pos):
						held = true
						break
					for side in FILL_ORDER:
						var next: Vector3i = pos + side
						if seen.has(next):  # reached a piece already found held
							held = true
							break
						if not mine.has(next) and is_solid(next):
							mine[next] = true
							stack.append(next)
					if held:
						break
				if held:
					for pos in mine:
						seen[pos] = true
					continue
				for pos in piece:
					var what: String = Blocks.NAMES[material_at(pos)]
					collected[what] = collected.get(what, 0) + 1
					edits[pos] = -1.0
					aired.append(pos)
					_touch(pos, touched)


# A sample moves the vertices of the cells around it, and those are used by quads of edges up
# to one sample further on each side: every chunk that can see it must be redrawn.
func _touch(pos: Vector3i, touched: Dictionary) -> void:
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				touched[chunk_of(pos + Vector3i(dx, dy, dz))] = true


# A steel deck over the ground the machines stand on, so it reads as built, not diggable.
func _add_platform(low: Vector3, high: Vector3) -> void:
	var deck := MeshInstance3D.new()
	deck.name = "Platform"
	# 16 cm thick, centred on the ground: an 8 cm lip the player walks up without jumping
	# (a CharacterBody3D capsule of radius 0.35 takes lips under about 10 cm as floor).
	var size := Vector3(high.x - low.x, 0.16, high.z - low.z)
	deck.mesh = BoxMesh.new()
	deck.mesh.size = size
	deck.position = Vector3((low.x + high.x) / 2.0, 1.0, (low.z + high.z) / 2.0)
	var steel := StandardMaterial3D.new()
	steel.albedo_color = Color(0.22, 0.23, 0.26)
	steel.metallic = 0.6
	steel.roughness = 0.5
	deck.material_override = steel
	add_child(deck)
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color(0.95, 0.6, 0.1)
	trim.emission_enabled = true
	trim.emission = Color(0.95, 0.55, 0.1)
	trim.emission_energy_multiplier = 0.4
	for edge in [[Vector3(size.x, 0.02, 0.25), Vector3(0, 0.09, size.z / 2.0)], [Vector3(size.x, 0.02, 0.25), Vector3(0, 0.09, -size.z / 2.0)],
			[Vector3(0.25, 0.02, size.z), Vector3(size.x / 2.0, 0.09, 0)], [Vector3(0.25, 0.02, size.z), Vector3(-size.x / 2.0, 0.09, 0)]]:
		var stripe := MeshInstance3D.new()
		stripe.mesh = BoxMesh.new()
		stripe.mesh.size = edge[0]
		stripe.position = edge[1]
		stripe.material_override = trim
		deck.add_child(stripe)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	body.add_child(shape)
	deck.add_child(body)


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
	# A light inside each vault near enough to be drawn: unshadowed, so its glow reaches
	# through the rock and tints the walls of a tunnel coming toward it.
	var near := view_radius * chunk_size
	for i in vaults.size():
		var away := center.distance_to(vaults[i]["center"])
		if away <= near and not _vault_lights.has(i):
			var light := OmniLight3D.new()
			light.position = vaults[i]["center"]
			light.light_color = vaults[i]["glow"]
			light.omni_range = vaults[i]["glow_range"]
			light.light_energy = vaults[i]["glow_energy"]
			light.shadow_enabled = false
			add_child(light)
			_vault_lights[i] = light
		elif away > near + chunk_size and _vault_lights.has(i):
			_vault_lights[i].queue_free()
			_vault_lights.erase(i)


## Vaults within [param reach] metres of [param pos], nearest first: each with index, center,
## radius, ore (name) and distance.
func vaults_near(pos: Vector3, reach: float) -> Array:
	var found := []
	for i in vaults.size():
		var away := pos.distance_to(vaults[i]["center"])
		if away <= reach:
			found.append({ "index": i, "center": vaults[i]["center"], "radius": vaults[i]["radius"],
					"ore": Blocks.NAMES[vaults[i]["ore"]], "distance": away })
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["distance"] < b["distance"])
	return found


## Number of vault lights alive now; checks use it.
func vault_light_count() -> int:
	return _vault_lights.size()


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
		noise.frequency = _ores[i].get("frequency", _ore_frequency)  # deep lodes are fewer and bigger
		_ore_noise.append(noise)
		var values := PackedFloat32Array()
		for s in 4096:
			values.append(noise.get_noise_3d(s * 7.13, s * 3.71, s * 5.29))
		values.sort()
		var chance: float = _ores[i]["chance"]
		_ore_cutoff.append(values[clampi(int((1.0 - chance) * values.size()), 0, values.size() - 1)])
	_place_vaults()


# Places each deep stratum's vaults from the seed: inside the stratum, clear of the world's
# walls and of each other, so every one is sealed until dug into. A vault that finds no room
# in VAULT_TRIES places is left out.
func _place_vaults() -> void:
	for key in _vault_chunks:
		_open_chunks.erase(key)
	_vault_chunks.clear()
	for light in _vault_lights.values():
		light.queue_free()
	_vault_lights.clear()
	vaults.clear()
	_vault_cells.clear()
	_opened.clear()
	_vault_top = -INF
	_vault_noise.seed = world_seed + 104729
	_vault_noise.frequency = 0.2
	_patch_noise.seed = world_seed + 130363
	_patch_noise.frequency = 0.35
	var patch := PackedFloat32Array()
	for s in 4096:
		patch.append(_patch_noise.get_noise_3d(s * 7.13, s * 3.71, s * 5.29))
	patch.sort()
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed
	for s in strata.size():
		if not strata[s].has("vaults"):
			continue
		var spec: Dictionary = strata[s]["vaults"]
		var top: float = strata[s]["from_depth"]
		var bottom: float = strata[s + 1]["from_depth"] if s + 1 < strata.size() else max_depth
		var cutoff := patch[clampi(int((1.0 - float(spec["cover"])) * patch.size()), 0, patch.size() - 1)]
		for n in int(spec["count"]):
			for attempt in VAULT_TRIES:
				var radius := rng.randf_range(spec["radius"][0], spec["radius"][1])
				var outer: float = radius + VAULT_LUMPS + spec["shell"]
				var side := outer + VAULT_CLEAR
				var half := outer / VAULT_SQUASH + VAULT_CLEAR
				var center := Vector3(rng.randf_range(side, world_size - side), -rng.randf_range(top + half, bottom - half),
						rng.randf_range(side, world_size - side))
				if bottom - top < 2.0 * half or vaults.any(func(v: Dictionary) -> bool:
						return center.distance_to(v["center"]) < outer + v["radius"] + VAULT_LUMPS + v["shell"] + 2.0 * VAULT_CLEAR):
					continue
				vaults.append({ "center": center, "radius": radius, "shell": float(spec["shell"]),
						"ore": Blocks.id_of(spec["ore"]), "cutoff": cutoff, "stratum": s, "glow": _color(spec["glow"]),
						"glow_range": float(spec["glow_range"]), "glow_energy": float(spec["glow_energy"]) })
				_register_vault(vaults.size() - 1)
				break


# Files vault [param i] under every lookup cell and chunk its shell reaches, one sample past.
func _register_vault(i: int) -> void:
	var vault: Dictionary = vaults[i]
	var outer: float = vault["radius"] + VAULT_LUMPS + vault["shell"] + 1.0
	var reach := Vector3(outer, outer / VAULT_SQUASH, outer)
	var low := Vector3i((vault["center"] - reach).floor())
	var high := Vector3i((vault["center"] + reach).ceil())
	_vault_top = maxf(_vault_top, high.y)
	var cell_low := _vault_cell(low)
	var cell_high := _vault_cell(high)
	for x in range(cell_low.x, cell_high.x + 1):
		for y in range(cell_low.y, cell_high.y + 1):
			for z in range(cell_low.z, cell_high.z + 1):
				var key := Vector3i(x, y, z)
				if not _vault_cells.has(key):
					_vault_cells[key] = []
				_vault_cells[key].append(i)
	var chunk_low := chunk_of(low - Vector3i.ONE)
	var chunk_high := chunk_of(high + Vector3i.ONE)
	for x in range(chunk_low.x, chunk_high.x + 1):
		for y in range(chunk_low.y, chunk_high.y + 1):
			for z in range(chunk_low.z, chunk_high.z + 1):
				var key := Vector3i(x, y, z)
				if not _open_chunks.has(key):
					_open_chunks[key] = true
					_vault_chunks.append(key)


# How far [param pos] is outside vault [param vault]'s hollow, in squashed metres: below 0 is
# inside, in the air.
func _cavity(vault: Dictionary, pos: Vector3) -> float:
	var offset: Vector3 = pos - vault["center"]
	offset.y *= VAULT_SQUASH
	return offset.length() - vault["radius"] - VAULT_LUMPS * _vault_noise.get_noise_3dv(pos)


func _vault_cell(pos: Vector3i) -> Vector3i:
	return Vector3i(floori(pos.x / VAULT_CELL), floori(pos.y / VAULT_CELL), floori(pos.z / VAULT_CELL))


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
				var color := surface_color(at)
				var ore := color.a  # the shader flecks ore
				color *= 0.92 + 0.12 * _shade(at)
				color.a = ore
				colors.append(color)
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


static func _color(rgb: Array) -> Color:
	return Color(rgb[0], rgb[1], rgb[2])


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
