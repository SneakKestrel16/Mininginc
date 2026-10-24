## Self-check for auto-drills until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/auto_drill_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var a := await _mine(5)
	a.dig(100.0)
	failures += _check(a.ores.values().all(func(n: int) -> bool: return n == 0) and a.shaft.depth == 0,
			"no drills: drill power does nothing, and the old shaft is not dug")
	failures += _check(a.place_drill(Vector3i(20, 0, 20)) == null, "a drill needs copper")
	failures += _check(a.hand_share(6.0) == 6.0, "no drills: all drill power goes to the hand tool")

	a.ores["copper"] = a.drill_cost * 2
	var first := a.place_drill(Vector3i(20, 0, 20))
	failures += _check(first != null and a.ores["copper"] == a.drill_cost and a.place_drill(Vector3i(20, 0, 20)) == null,
			"placing costs copper; one drill per column")
	var second := a.place_drill(Vector3i(30, 0, 30))
	failures += _check(a.hand_share(6.0) == 2.0, "two drills: the hand tool takes one share of three")
	a.dig(40.0)
	failures += _check(first.depth_y < 0 and second.depth_y < 0 and absi(first.depth_y - second.depth_y) <= 2,
			"drill power is shared between the drills (%d, %d)" % [first.depth_y, second.depth_y])
	failures += _check(not a.world.is_solid(Vector3i(20, 0, 20)) and a.world.is_solid(Vector3i(20, first.depth_y - 1, 20)),
			"a drill scoops its column top down")

	# Hits carry from scoop to scoop: one big dig reaches as deep as many small ones.
	var b := await _mine(5)
	var c := await _mine(5)
	b.ores["copper"] = 10
	c.ores["copper"] = 10
	var big := b.place_drill(Vector3i(40, 0, 40))
	var small := c.place_drill(Vector3i(40, 0, 40))
	b.dig(300.0)
	for i in 3000:
		c.dig(0.1)
	failures += _check(big.depth_y == small.depth_y and b.ores == c.ores, "one big dig matches many small ones (%d vs %d)" % [big.depth_y, small.depth_y])

	b.dig(1e9)
	failures += _check(big.stopped and big.depth_y == -b.world.max_depth, "stops at bedrock")

	var copper_before: int = b.ores["copper"]
	b.remove_drill(big)
	failures += _check(b.ores["copper"] == copper_before + b.drill_cost and b.drills.is_empty()
			and not b.world.is_solid(Vector3i(40, -10, 40)), "picking a drill up returns its copper; the column stays dug")

	print("auto_drill_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _mine(seed_value: int) -> Mine:
	var world := VoxelWorld.new()
	var mine := Mine.new()
	mine.world = world
	root.add_child(world)
	root.add_child(mine)
	await process_frame  # _ready runs on the next frame
	mine.shaft.shaft_seed = seed_value
	world.world_seed = seed_value
	return mine


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
