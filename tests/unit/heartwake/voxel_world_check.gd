## Self-check for the smooth moon until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/voxel_world_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var world := _world(7)
	var twin := _world(7)
	var other := _world(8)
	await process_frame  # _ready runs on the next frame

	var same := true
	var differs := false
	for i in 2000:
		var pos := Vector3i(1 + i % 120, -(i % 300), 1 + (i * 7) % 120)
		same = same and world.density_at(pos) == twin.density_at(pos) and world.material_at(pos) == twin.material_at(pos)
		differs = differs or world.material_at(pos) != other.material_at(pos)
	failures += _check(same and differs, "the same seed gives the same ground; another seed does not")

	failures += _check(world.is_solid(Vector3i(64, 0, 60)) and not world.is_solid(Vector3i(64, 1, 60))
			and world.material_at(Vector3i(64, 0, 60)) == Blocks.CRUST, "the base is flat ice crust at y = 1")
	var heights := {}
	for x in range(1, 50):
		var y := 6
		while not world.is_solid(Vector3i(x, y, 20)):
			y -= 1
		heights[y] = true
	failures += _check(heights.size() >= 2, "the ground outside the base is bumpy (%d heights)" % heights.size())

	# Deposits fill about the share of rock data/ores.json asks for, in lumps, not specks.
	var counts := {}
	var lumpy := 0
	var total := 0
	for x in range(2, 126, 2):
		for y in range(-299, -2, 3):
			var pos := Vector3i(x, y, 40)
			var id := world.material_at(pos)
			var key: String = Blocks.NAMES[id] + ("@shallow" if -y < 50 else "@mid" if -y < 100 else "@deep")
			counts[key] = counts.get(key, 0) + 1
			if id > Blocks.ROCK:
				total += 1
				lumpy += int(world.material_at(pos + Vector3i.RIGHT) == id)
	failures += _check(counts.has("coal@shallow") and not counts.has("ice@shallow") and not counts.has("copper@shallow"),
			"coal near the top, no ice or copper there")
	failures += _check(counts.has("ice@mid") and counts.has("copper@mid") and not counts.has("uranium@mid"), "ice and copper below 50 m")
	failures += _check(counts.has("uranium@deep") and not counts.has("uranium@shallow"), "uranium from 100 m")
	var coal_share: float = counts.get("coal@shallow", 0) / float(counts.get("coal@shallow", 0) + counts.get("rock@shallow", 0))
	failures += _check(coal_share > 0.04 and coal_share < 0.13, "coal is about 8%% of shallow rock (%.3f)" % coal_share)
	failures += _check(lumpy > total / 2, "ore comes in deposits: most ore has the same ore beside it (%d of %d)" % [lumpy, total])

	var shallow := Vector3i(5, -10, 5)
	var frozen := Vector3i(5, -60, 5)
	failures += _check(is_equal_approx(world.hardness_at(shallow), (3.0 + 0.15 * 10) * 2.0), "a scoop costs hardness by depth times bite cost")
	failures += _check(is_equal_approx(world.hardness_at(frozen), (3.0 + 0.15 * 60) * 2.0 * 2.0) and world.is_frozen(frozen),
			"frozen rock is harder")
	world.thaw_to(100)
	failures += _check(is_equal_approx(world.hardness_at(frozen), (3.0 + 0.15 * 60) * 2.0) and not world.is_frozen(frozen), "Breath thaws it")
	world.thaw_to(0)
	failures += _check(world.frozen_from == 50, "never refreezes above the frozen floor")

	failures += _check(is_inf(world.hardness_at(Vector3i(0, 0, 5))) and world.dig(Vector3(0.5, 0.5, 5.5), 1000.0).is_empty()
			and is_inf(world.hardness_at(Vector3i(5, -400, 5))), "edge walls and the floor are bedrock no scoop opens")
	failures += _check(world.is_solid(Vector3i(0, 4, 5)) and not world.is_solid(Vector3i(0, 5, 5)), "the edge wall rises above the surface")
	world.carve(Vector3(1, 0, 5), 3.0)
	failures += _check(world.is_solid(Vector3i(0, 0, 5)) and not world.is_solid(Vector3i(2, 0, 5)), "a scoop spares bedrock")
	world.carve(Vector3(64, 0, 60), 3.0)
	failures += _check(world.is_solid(Vector3i(64, 0, 60)) and world.dig(Vector3(64.5, 0.5, 60.5), 1e6).is_empty() \
			and not world.damage.has(Vector3i(64, 0, 60)), "the machines' ground is never carved, and digging it wastes no hits")
	failures += _check(not world.dig(Vector3(64.5, 0.5, 66.5), 1e6).is_empty(), "the rest of the base, where the player starts, digs")

	# The Heart's cavern: open air deep down, sealed by rock all the way up.
	var top := Vector3i(world.heart_center.floor())
	var sealed := true
	for y in range(top.y + int(world.heart_radius) + 1, 1):
		sealed = sealed and world.is_solid(Vector3i(top.x, y, top.z))
	failures += _check(not world.is_solid(top) and world.heart_center.y < -30 and sealed,
			"the Heart's cavern is open air 30 m+ down, sealed above")

	# Digging: hits wait until a scoop's hardness, then a ball of ground goes and its ore counts.
	var spot := Vector3(20.5, -20.5, 20.5)
	var cell := Vector3i(spot.floor())
	var need := world.hardness_at(cell)
	var heard := []
	world.carved.connect(func(_center: Vector3, collected: Dictionary) -> void: heard.append(collected))
	failures += _check(world.dig(spot, need - 1.0).is_empty() and world.is_solid(cell), "ground holds until a scoop's hardness")
	var got := world.dig(spot, 1.0)
	var removed := 0
	for what in got:
		removed += got[what]
	failures += _check(removed >= 7 and removed <= 9 and not world.is_solid(cell) and not world.damage.has(cell),
			"then a scoop of about 8 samples goes (%d)" % removed)
	failures += _check(heard.size() == 1 and heard[0] == got, "the world tells the mine what the scoop held")
	failures += _check(not world.dig(Vector3(30.5, 0.5, 30.5), world.hardness_at(Vector3i(30, 0, 30)) - 0.00001).is_empty(),
			"a hair short of the hardness still scoops")

	# Ground cut loose falls whole: a lump left hanging in a hole goes with the next scoop.
	var hole := Vector3(90, -15, 90)
	world.carve(hole, 4.0)
	var lump: Array[Vector3i] = []
	for p in [Vector3i(90, -15, 90), Vector3i(91, -15, 90), Vector3i(90, -14, 90), Vector3i(90, -15, 91)]:
		world.edits[p] = 1.0
		lump.append(p)
	var fell := world.carve(Vector3(88, -15, 90), 1.0)
	var fallen := 0
	for what in fell:
		fallen += fell[what]
	failures += _check(lump.all(func(p: Vector3i) -> bool: return not world.is_solid(p)) and fallen >= 4,
			"a lump held up by nothing falls whole, and its ground is collected (%d)" % fallen)
	failures += _check(world.is_solid(Vector3i(90, -21, 90)), "ground below the hole stays")

	# Drawing: surface nets give a closed surface with collision, built only near the player.
	world.update_around(Vector3(40, 1, 40))  # the player calls this every frame
	var inner: Node3D = world.chunk_node(world.chunk_of(Vector3i(40, 0, 40)))
	failures += _check(inner.get_child_count() == 2 and inner.get_child(1) is StaticBody3D, "surface chunks have a mesh and collision")
	failures += _check(world.chunk_node(world.chunk_of(Vector3i(40, -40, 40))) == null, "solid rock far below is not drawn")
	failures += _check(world.built_count() < 16 * 16 * 3, "chunks are built around a point, not all at once (%d)" % world.built_count())
	var before := _triangles(inner)
	world.carve(Vector3(44, 0, 44), 2.5)
	failures += _check(_triangles(world.chunk_node(world.chunk_of(Vector3i(40, 0, 40)))) > before
			and world.chunk_node(world.chunk_of(Vector3i(40, -8, 40))) != null, "a scoop redraws the chunks that can see it")

	print("voxel_world_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _triangles(chunk: Node3D) -> int:
	if chunk == null or chunk.get_child_count() == 0:
		return 0
	return (chunk.get_child(0) as MeshInstance3D).mesh.surface_get_array_index_len(0) / 3


func _world(seed_value: int) -> VoxelWorld:
	var world := VoxelWorld.new()
	world.world_seed = seed_value
	root.add_child(world)
	return world


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
