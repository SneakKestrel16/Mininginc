## Self-check for Heart stage Sight until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/ore_sight_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var stages: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/heart_stages.json"))["stages"]
	var heart := Heart.new(stages)
	failures += _check(stages[3]["name"] == "Sight" and stages[3]["effect"] == "ore_sight", "Sight is the fourth stage, after Breath")
	heart.stage = 3
	failures += _check(heart.effect_total("ore_sight") == 0.0, "before Sight nothing glows")
	heart.stage = 4
	var reach := int(heart.effect_total("ore_sight"))
	failures += _check(reach > 0, "Sight's reach follows from the stage index")

	var world := VoxelWorld.new()
	world.world_seed = 3
	root.add_child(world)
	await process_frame  # _ready runs on the next frame
	var center := Vector3i(40, -60, 40)
	var found := OreSight.scan(world, center, reach)
	var expected := 0
	for x in range(-reach, reach + 1):
		for y in range(-reach, reach + 1):
			for z in range(-reach, reach + 1):
				if Vector3i(x, y, z).length_squared() <= reach * reach and world.is_solid(center + Vector3i(x, y, z)) 						and world.material_at(center + Vector3i(x, y, z)) > Blocks.ROCK:
					expected += 1
	failures += _check(found.size() == expected and expected > 0, "every ore within reach glows, nothing else (%d)" % expected)
	var all_match := true
	for item in found:
		all_match = all_match and world.material_at(item[0]) == item[1]
	failures += _check(all_match, "a glowing spot holds the ore it shows")
	var first: Vector3i = found[0][0]
	var ore_name: String = Blocks.NAMES[found[0][1]]
	failures += _check(world.carve(Vector3(first), 1.2).get(ore_name, 0) > 0, "digging it yields that ore")
	var after := OreSight.scan(world, center, reach)
	failures += _check(after.size() < expected and not after.any(func(item: Array) -> bool: return item[0] == first),
			"a dug spot stops glowing, and so does ore it opens to view")

	print("ore_sight_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
