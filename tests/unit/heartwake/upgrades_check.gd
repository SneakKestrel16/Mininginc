## Self-check for the upgrade shop until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/upgrades_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var world := VoxelWorld.new()
	var mine := Mine.new()
	var economy := Economy.new()
	mine.world = world
	economy.mine = mine
	root.add_child(world)
	root.add_child(mine)
	root.add_child(economy)
	await process_frame  # _ready runs on the next frame
	economy.set_process(false)
	var upgrades := economy.upgrades

	failures += _check(upgrades.defs.size() == 4 and upgrades.levels.values().all(func(n: int) -> bool: return n == 0),
			"four upgrades, none bought at start")
	var first: Dictionary = upgrades.cost("tool_motor")
	failures += _check(not economy.buy_upgrade("tool_motor") and upgrades.levels["tool_motor"] == 0, "refused without the ore")
	mine.ores["coal"] = 1000
	failures += _check(economy.buy_upgrade("tool_motor") and mine.ores["coal"] == 1000 - first["coal"]
			and upgrades.levels["tool_motor"] == 1, "buying takes the ore and raises the level")
	failures += _check(upgrades.cost("tool_motor")["coal"] > first["coal"], "each level costs more than the last")
	while economy.buy_upgrade("tool_motor"):
		pass
	failures += _check(upgrades.is_maxed("tool_motor") and upgrades.levels["tool_motor"] == 8 and mine.ores["coal"] > 0,
			"refused at the cap even with ore left (%d coal)" % mine.ores["coal"])
	failures += _check(is_equal_approx(upgrades.effect("hand_speed"), 2.0), "eight tool motor levels: +200%% hand speed")

	mine.ores["ice"] = 1000
	mine.ores["copper"] = 1000
	var radius := world.bite_radius
	economy.buy_upgrade("wide_scoop")
	var spot := Vector3(20, -20, 20)
	var got := world.dig(spot, world.hardness_at(Vector3i(spot.floor())))
	var removed := 0
	for what in got:
		removed += got[what]
	failures += _check(is_equal_approx(world.bite_bonus, 0.25) and removed > 7,
			"a wider scoop carves a bigger chunk (%d samples at %.2f m)" % [removed, radius + world.bite_bonus])

	economy.split.heart_share = 0.0
	economy.furnace.fuel = 5
	economy._tick(1.0)
	var plain := economy.drill_hits_per_second
	mine.ores["uranium"] = 10
	economy.buy_upgrade("drill_gearing")
	economy._tick(1.0)
	failures += _check(is_equal_approx(economy.drill_hits_per_second, plain * 1.25), "drill gearing speeds drill power")

	# Levels load clamped, unknown ids dropped, missing ones at zero.
	upgrades.load_levels({ "tool_motor": 99, "gone": 3 })
	failures += _check(upgrades.levels["tool_motor"] == 8 and not upgrades.levels.has("gone") and upgrades.levels["long_arm"] == 0,
			"saved levels load within their caps")

	print("upgrades_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
