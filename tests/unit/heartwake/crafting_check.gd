## Self-check for crafting until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/crafting_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _initialize() -> void:
	var failures := 0
	var mine := Mine.new()
	var economy := Economy.new()
	economy.mine = mine
	root.add_child(mine)
	root.add_child(economy)
	await process_frame  # _ready runs on the next frame
	economy.set_process(false)
	var crafting := economy.crafting
	var ores := mine.ores

	failures += _check(ores.has("iron_plate") and ores.has("wire") and ores.has("glass") and ores.has("circuit")
			and ores["circuit"] == 0, "parts sit in the inventory beside ore, starting at zero")
	failures += _check(not crafting.make("iron_plate", mine) and ores["iron"] == 0, "refused without the ore")
	ores["iron"] = 5
	failures += _check(crafting.make("iron_plate", mine) and ores["iron"] == 3 and ores["iron_plate"] == 1,
			"a plate takes 2 iron")
	failures += _check(not crafting.can_make("iron_plate", ores, 5) and not crafting.make("iron_plate", mine, 5)
			and ores["iron"] == 3, "five at once needs all five runs' ore, or takes nothing")
	ores["copper"] = 1
	crafting.make("wire", mine)
	failures += _check(ores["wire"] == 2 and ores["copper"] == 0, "one copper makes two wire")

	# make_for crafts whole chains: a circuit from raw copper, quartz and gold.
	ores["copper"] = 1
	ores["wire"] = 0
	ores["quartz"] = 2
	ores["gold"] = 1
	failures += _check(crafting.make_for({ "circuit": 1 }, mine) and ores["circuit"] == 1 and ores["quartz"] == 0
			and ores["gold"] == 0, "make_for crafts a circuit through wire and glass")
	failures += _check(not crafting.make_for({ "circuit": 2 }, mine) and ores["circuit"] == 1,
			"and reports when the ore runs short")

	print("crafting_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
