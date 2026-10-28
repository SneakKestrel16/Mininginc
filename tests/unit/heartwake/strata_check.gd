## Self-check for the strata (brief: Milestone 10 item 42) until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/strata_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var world := VoxelWorld.new()
	world.world_seed = 7
	root.add_child(world)
	await process_frame  # _ready runs on the next frame

	# Which stratum each depth is in, edges included.
	var expected := { -5: 0, 0: 0, 99: 0, 100: 1, 149: 1, 150: 2, 249: 2, 250: 3, 339: 3, 340: 4, 399: 4 }
	var wrong := expected.keys().filter(func(d: int) -> bool: return world.stratum_at(d) != expected[d])
	failures += _check(wrong.is_empty(), "each depth lies in its stratum (wrong at %s)" % [wrong])

	# The shipped file is accepted; each kind of bad file is refused with a reason.
	failures += _check(VoxelWorld.strata_error(world.strata, world.max_depth) == "", "the shipped strata are accepted")
	var bad := {
		"first not at 0": func(l: Array) -> void: l[0]["from_depth"] = 5,
		"not increasing": func(l: Array) -> void: l[2]["from_depth"] = l[1]["from_depth"],
		"below bedrock": func(l: Array) -> void: l[4]["from_depth"] = world.max_depth,
		"too dark": func(l: Array) -> void: l[3]["ambient_energy"] = 0.1,
		"tint out of range": func(l: Array) -> void: l[1]["tint"] = [0.4, 1.0, 1.0],
		"rock too dark": func(l: Array) -> void: l[1]["tint"] = [0.6, 0.6, 0.6],
		"rock too coloured": func(l: Array) -> void: l[1]["tint"] = [1.4, 0.8, 0.6],
		"missing key": func(l: Array) -> void: l[2].erase("line"),
	}
	for what in bad:
		var list: Array = world.strata.duplicate(true)
		bad[what].call(list)
		failures += _check(VoxelWorld.strata_error(list, world.max_depth) != "", "a strata list is refused: %s" % what)

	# Rock takes its stratum's tint, a different one at each depth; ore keeps its own colour.
	var rock: Color = Blocks.COLORS[Blocks.ROCK]
	var seen := {}
	for depth in [20, 120, 200, 300, 360]:
		var pos := _find(world, depth, func(id: int) -> bool: return id == Blocks.ROCK)
		var color := world.surface_color(pos)
		var rgb: Array = world.strata[world.stratum_at(depth)]["tint"]
		var want := rock * Color(rgb[0], rgb[1], rgb[2])
		failures += _check(color.a == 0.0 and Vector3(color.r, color.g, color.b).distance_to(Vector3(want.r, want.g, want.b)) < 0.001,
				"rock at %d m is drawn in its stratum's tint" % depth)
		seen[color] = true
	failures += _check(seen.size() == 5, "rock looks different in each stratum")
	var ore_ok := true
	for depth in [20, 120, 200, 300, 360]:
		var pos := _find(world, depth, func(id: int) -> bool: return id > Blocks.ROCK)
		var color := world.surface_color(pos)
		var own: Color = Blocks.COLORS[world.material_at(pos)]
		ore_ok = ore_ok and color.a == 1.0 and color.r == own.r and color.g == own.g and color.b == own.b
	failures += _check(ore_ok, "ore keeps its own colour and fleck flag at every depth")

	# Above the Deep digging costs what it did before strata; below, each stratum multiplies it.
	var same := true
	for depth in 150:
		var hits := world._hardness_base + world._hardness_per_block * depth
		if depth >= world.frozen_from:
			hits *= world._frozen_multiplier
		same = same and world.hardness_at(Vector3i(30, -depth, 30)) == hits * world._bite_cost
	failures += _check(same, "above 150 m every depth costs what it did before strata")
	# (3 + 0.15 d) x 2 frozen x stratum x 2 per scoop, with Breath's thaw to 100 m.
	world.thaw_to(100)
	var table := { 149: 101.4, 150: 153.0, 249: 242.1, 250: 324.0, 339: 430.8, 340: 648.0, 399: 754.2 }
	var off := table.keys().filter(func(d: int) -> bool: return not is_equal_approx(world.hardness_at(Vector3i(30, -d, 30)), table[d]))
	failures += _check(off.is_empty(), "deep rock is harder by stratum (off at %s)" % [off])
	world.thaw_to(0)

	# The banner fires on entering, with 3 m of hysteresis, and never for the first reading.
	var sense := DepthSense.new()
	sense.environment = Environment.new()
	sense.world = world
	# Each banner as [stratum, depth it fired at]: within 3 m of the line nothing fires.
	var entered := []
	var at := [0.0]  # an array: a lambda captures locals by value
	sense.stratum_entered.connect(func(i: int) -> void: entered.append([i, at[0]]))
	for depth in [0.0, 60.0, 98.0, 101.0, 104.0, 99.0, 96.0, 104.0, 102.0]:
		at[0] = depth
		sense.sense(depth, 0.1)
	failures += _check(entered == [[1, 104.0], [0, 96.0], [1, 104.0]],
			"entering strata fires mid at 104 m, shallow at 96 m, mid at 104 m (got %s)" % [entered])

	# The light follows the stratum, and the glow reaches the shader.
	for i in 30:
		sense.sense(200.0, 0.1)
	var deep_energy: float = world.strata[2]["ambient_energy"]
	failures += _check(absf(sense.environment.ambient_light_energy - deep_energy) < deep_energy * 0.05,
			"after 3 s at 200 m the light is the Deep's (%.3f)" % sense.environment.ambient_light_energy)
	for i in 50:
		sense.sense(0.0, 0.1)
	var top_energy: float = world.strata[0]["ambient_energy"]
	failures += _check(absf(sense.environment.ambient_light_energy - top_energy) < top_energy * 0.01,
			"after 5 s back at the surface the light is the surface's (%.3f)" % sense.environment.ambient_light_energy)
	world.set_ore_glow(1.0)
	failures += _check(world._material.get_shader_parameter("ore_glow") == 1.0, "the ore glow reaches the terrain shader")
	sense.free()

	print("strata_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


# A sample [param depth] metres down whose material passes [param test].
func _find(world: VoxelWorld, depth: int, test: Callable) -> Vector3i:
	for x in range(2, 126):
		for z in range(2, 126, 3):
			var pos := Vector3i(x, -depth, z)
			if test.call(world.material_at(pos)):
				return pos
	push_error("nothing found at %d m" % depth)
	return Vector3i(64, -depth, 64)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
