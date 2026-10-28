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
	failures += _check(a.place_drill(Vector3i(20, 0, 20)) == null, "a drill needs its parts")
	failures += _check(a.hand_share(6.0) == 6.0, "no drills: all drill power goes to the hand tool")

	a.refund(a.drill_cost, 2)
	var first := a.place_drill(Vector3i(20, 0, 20))
	failures += _check(first != null and a.ores["iron_plate"] == a.drill_cost["iron_plate"] and a.place_drill(Vector3i(20, 0, 20)) == null,
			"placing costs its parts; one drill per column")
	failures += _check(a.place_drill(Vector3i(64, 0, 60)) == null and a.can_afford(a.drill_cost),
			"no drill on the machines' protected ground, and nothing is paid")
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
	b.refund(b.drill_cost, 5)
	c.refund(c.drill_cost, 5)
	var big := b.place_drill(Vector3i(40, 0, 40))
	var small := c.place_drill(Vector3i(40, 0, 40))
	b.dig(300.0)
	for i in 3000:
		c.dig(0.1)
	failures += _check(big.depth_y == small.depth_y and b.ores == c.ores, "one big dig matches many small ones (%d vs %d)" % [big.depth_y, small.depth_y])

	# A drill bores drill_efficiency times the rock per hit of its share; the hand tool takes
	# a share only while it cuts (story 041).
	var single := await _mine(5)
	var doubled := await _mine(5)
	var cutting := await _mine(5)
	var cutting_half := await _mine(5)
	var lone := {}
	for m in [single, doubled, cutting, cutting_half]:
		m.refund(m.drill_cost)
		lone[m] = m.place_drill(Vector3i(40, 0, 40))
	doubled.drill_efficiency = 2.0
	single.dig(80.0)
	doubled.dig(40.0)
	failures += _check(lone[doubled].depth_y == lone[single].depth_y and doubled.world.damage == single.world.damage,
			"a drill at twice the efficiency digs from 40 hits what one at 1.0 digs from 80 (%d vs %d)" % [lone[doubled].depth_y, lone[single].depth_y])
	cutting.hand_cutting = true
	cutting_half.hand_cutting = true
	cutting.dig(80.0)
	cutting_half.dig(40.0)
	var idle := await _mine(5)
	idle.refund(idle.drill_cost)
	var idle_drill := idle.place_drill(Vector3i(40, 0, 40))
	idle.dig(40.0)
	failures += _check(idle_drill.depth_y == lone[cutting].depth_y and idle_drill.depth_y < lone[cutting_half].depth_y,
			"with the hand idle a lone drill takes all the power: 40 hits dig what 80 do while it cuts (%d, %d, %d)"
			% [idle_drill.depth_y, lone[cutting].depth_y, lone[cutting_half].depth_y])
	failures += _check(cutting.hand_share(6.0) == 3.0 and idle.hand_share(6.0) == 3.0, "the hand's share does not depend on whether it cuts")

	b.dig(1e9)
	failures += _check(big.stopped and big.depth_y == -b.world.max_depth, "stops at bedrock")

	var plates_before: int = b.ores["iron_plate"]
	b.remove_drill(big)
	failures += _check(b.ores["iron_plate"] == plates_before + b.drill_cost["iron_plate"] and b.drills.is_empty()
			and not b.world.is_solid(Vector3i(40, -10, 40)), "picking a drill up returns its parts; the column stays dug")

	# Thawing under a half-dug frozen cell must not hang the drill: damage then exceeds the
	# new hardness (this once looped forever in the pacing simulator).
	var d := await _mine(6)
	d.refund(d.drill_cost, 5)
	var deep := d.place_drill(Vector3i(50, -60, 50))
	var cell := Vector3i(50, -60, 50)
	d.world.damage[cell] = d.world.hardness_at(cell) * 0.9
	d.world.thaw_to(100)
	d.dig(2.0)
	failures += _check(deep.depth_y < -60 and not d.world.damage.has(cell), "thawing under a half-dug cell finishes it, no hang")

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
