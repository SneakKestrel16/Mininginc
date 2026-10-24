## Self-check for the voxel moon until /test-setup installs gdUnit4.
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
		same = same and world.generated(pos) == twin.generated(pos)
		differs = differs or world.generated(pos) != other.generated(pos)
	failures += _check(same and differs, "the same seed gives the same blocks; another seed does not")

	failures += _check(world.block_at(Vector3i(5, 0, 5)) == Blocks.CRUST and world.block_at(Vector3i(5, 1, 5)) == Blocks.AIR,
			"the surface is ice crust with air above")
	var found := {}
	for x in range(1, 127):
		for y in range(-300, -1):
			var id := world.generated(Vector3i(x, y, 9))
			found[Blocks.NAMES[id] + ("@shallow" if -y < 50 else "@mid" if -y < 100 else "@deep")] = true
	failures += _check(found.has("coal@shallow") and not found.has("ice@shallow") and not found.has("copper@shallow"),
			"coal near the top, no ice or copper there")
	failures += _check(found.has("ice@mid") and found.has("copper@mid") and not found.has("uranium@mid"), "ice and copper below 50 m")
	failures += _check(found.has("uranium@deep") and not found.has("uranium@shallow"), "uranium from 100 m")

	var shallow := Vector3i(5, -10, 5)
	var frozen := Vector3i(5, -60, 5)
	failures += _check(world.hardness(shallow) == ceilf(3.0 + 0.15 * 10), "hardness follows depth like the shaft")
	failures += _check(world.hardness(frozen) == ceilf((3.0 + 0.15 * 60) * 2.0) and world.is_frozen(frozen), "frozen rock is harder")
	world.thaw_to(100)
	failures += _check(world.hardness(frozen) == ceilf(3.0 + 0.15 * 60) and not world.is_frozen(frozen), "Breath thaws it")
	world.thaw_to(0)
	failures += _check(world.frozen_from == 50, "never refreezes above the frozen floor")

	failures += _check(is_inf(world.hardness(Vector3i(0, 0, 5))) and world.hit(Vector3i(0, 0, 5), 1000.0) == ""
			and is_inf(world.hardness(Vector3i(5, -400, 5))), "edge walls and the floor are unbreakable bedrock")
	failures += _check(world.is_solid(Vector3i(0, 4, 5)) and not world.is_solid(Vector3i(0, 5, 5)), "the edge wall rises above the surface")

	var ore_pos := Vector3i(-1, 0, 0)
	for y in range(-49, -1):
		if world.generated(Vector3i(20, y, 20)) == Blocks.id_of("coal"):
			ore_pos = Vector3i(20, y, 20)
			break
	var need := world.hardness(ore_pos)
	failures += _check(world.hit(ore_pos, need - 1.0) == "" and world.block_at(ore_pos) == Blocks.id_of("coal"),
			"a block holds until its hardness is reached")
	failures += _check(world.hit(ore_pos, 1.0) == "coal" and world.block_at(ore_pos) == Blocks.AIR and not world.damage.has(ore_pos),
			"then breaks, reporting what it held")

	# Drawing: a flat inner surface chunk shows one top face per column and nothing else.
	world.update_around(Vector3(40, 1, 40))  # the player calls this every frame
	var inner: Node3D = world.chunk_node(Vector3i(2, 0, 2))
	var mesh: ArrayMesh = (inner.get_child(0) as MeshInstance3D).mesh
	failures += _check(mesh.surface_get_array_len(0) == 16 * 16 * 4, "only faces next to air are drawn")
	failures += _check(inner.get_child(1) is StaticBody3D, "chunks have collision")
	failures += _check(world.built_count() < 64 * 3, "chunks are built around a point, not all at once (%d)" % world.built_count())

	world.break_block(Vector3i(40, 0, 40))
	world.update_around(Vector3(40, 1, 40))  # the player calls this every frame
	var after: ArrayMesh = (world.chunk_node(Vector3i(2, 0, 2)).get_child(0) as MeshInstance3D).mesh
	# The broken block's top goes; the four sides around the hole and the block below show.
	failures += _check(after.surface_get_array_len(0) == (16 * 16 - 1 + 4) * 4 and world.chunk_node(Vector3i(2, -1, 2)) != null,
			"breaking a block redraws the chunks that can see it")

	print("voxel_world_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _world(seed_value: int) -> VoxelWorld:
	var world := VoxelWorld.new()
	world.world_seed = seed_value
	root.add_child(world)
	return world


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
