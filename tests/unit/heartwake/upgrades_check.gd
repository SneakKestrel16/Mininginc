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

	failures += _check(upgrades.defs.size() == 9 and upgrades.levels.values().all(func(n: int) -> bool: return n == 0),
			"nine upgrades, none bought at start")
	var first: Dictionary = upgrades.cost("tool_motor")
	failures += _check(not economy.buy_upgrade("tool_motor") and upgrades.levels["tool_motor"] == 0, "refused without the ore")
	mine.ores["coal"] = 5000
	for part in ["iron_plate", "wire", "circuit"]:
		mine.ores[part] = 1000
	failures += _check(economy.buy_upgrade("tool_motor") and mine.ores["coal"] == 5000 - first["coal"]
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
	var power := economy.power_per_second
	economy.furnace.fuel = 5
	economy.buy_upgrade("generator_tuning")
	economy._tick(1.0)
	failures += _check(is_equal_approx(economy.power_per_second, power * 1.1), "generator tuning adds 10%% power")

	# The deep shop: Deep tuning adds to the same bonus, the Carbide bit to drill speed, the
	# Core tap adds power that burns nothing, and the Thermal lance carries Breath's thaw deeper.
	for part in ["alloy", "lens", "core_cell"]:
		mine.ores[part] = 1000
	mine.ores["uranium"] = 1000
	var bonus_before := upgrades.effect("power_bonus")
	var speed_before := upgrades.effect("drill_speed")
	economy.buy_upgrade("deep_tuning")
	economy.buy_upgrade("deep_tuning")
	economy.buy_upgrade("carbide_bit")
	failures += _check(is_equal_approx(upgrades.effect("power_bonus") - bonus_before, 0.1)
			and is_equal_approx(upgrades.effect("drill_speed") - speed_before, 0.3), "Deep tuning and the Carbide bit add to their effects")
	economy.furnace.fuel = 0
	economy.furnace.burn_left = 0.0
	economy._tick(1.0)
	var bonus := 1.0 + upgrades.effect("power_bonus")
	failures += _check(is_zero_approx(economy.power_per_second), "no fuel, no Core tap: no power")
	economy.buy_upgrade("core_tap")
	economy._tick(1.0)
	failures += _check(is_equal_approx(economy.power_per_second, 10.0 * bonus) and is_equal_approx(economy.core_output, 10.0 * bonus),
			"a Core tap level gives 10 power/s with no fuel, times the generator bonus (%.2f)" % economy.power_per_second)
	economy.buy_upgrade("thermal_lance")
	failures += _check(world.frozen_from == 50, "the Thermal lance thaws nothing before Breath")
	economy.heart.stage = 3  # Breath
	economy.apply_heart()
	failures += _check(world.frozen_from == 200 and is_equal_approx(world.hardness_at(Vector3i(30, -150, 30)), 76.5),
			"after Breath it thaws 100 m deeper: 150 m costs 76.5")
	economy.buy_upgrade("thermal_lance")
	economy.buy_upgrade("thermal_lance")
	failures += _check(world.frozen_from == 400 and is_equal_approx(world.hardness_at(Vector3i(30, -399, 30)), 377.1),
			"at level 3 nothing above bedrock is frozen: 399 m costs 377.1")

	# Every panel line shows its whole number: 0.3 x 3 x 100 is 89.999... in floats.
	var shown := true
	for upgrade in upgrades.defs:
		for level in int(upgrade["max_level"]) + 1:
			var value: float = upgrade["per_level"] * level * upgrade["shown_scale"]
			var want: String = upgrade["describe"] % (roundi(value) if "%d" in upgrade["describe"] else value)
			shown = shown and UpgradePanel.effect_text(upgrade, level) == want
	failures += _check(shown and UpgradePanel.effect_text(upgrades.find("carbide_bit"), 3) == "+90% drill power speed",
			"every upgrade's panel line shows the right number at every level")

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
