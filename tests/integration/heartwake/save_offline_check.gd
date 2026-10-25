## Self-check for saving, loading and offline progress until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/integration/heartwake/save_offline_check.gd
## Exits 0 when every check passes, 1 on the first failure. Writes only user://check_*.json.
extends SceneTree


func _initialize() -> void:
	var failures := 0

	# A game in a known state: Flicker reached, coal in stock and in the furnace, turbine and
	# reactor built, one drill placed and dug in, the player moved and turned.
	var a := await _game()
	a.mine.shaft.shaft_seed = 99
	a.mine.world.world_seed = 99
	a.mine.ores["copper"] = a.mine.drill_cost
	a.mine.place_drill(Vector3i(20, 0, 20))
	a.mine.dig(30.0)
	a.mine.ores["coal"] = 40
	a.player.global_position = Vector3(30.5, 1.0, 40.25)
	a.player.rotation.y = 1.25
	a.player.get_node("Head").rotation.x = -0.5
	a.economy.split.heart_share = 0.25
	a.economy.heart.stage = 1
	a.economy.heart.progress = 40.0
	a.economy.furnace.fuel = 3
	a.economy.furnace.burn_left = 2.0
	a.economy.turbine_built = true
	a.economy.turbine.water = 12.0
	# The economy checks below run without the reactor: its power would race the Heart past
	# the stages they test.
	var base := SaveGame.capture(a.economy, a.mine, 1000.0, a.player)
	a.mine.ores["uranium"] = 2
	a.economy.reactor_built = true
	a.economy.reactor.core.fuel = 1
	a.economy.reactor.heat = 80.0
	a.economy.reactor.scrammed = true
	a.economy.reactor.waste = 3.5
	a.economy.upgrades.levels["long_arm"] = 2
	var data := SaveGame.capture(a.economy, a.mine, 1000.0, a.player)
	failures += _check(a.mine.drills[0].depth_y < 0 and data["world"]["edits"].size() == 4 * a.mine.world.edits.size(),
			"the world is saved as its changed samples only")
	failures += _check(data["version"] == SaveGame.FORMAT_VERSION, "the save carries its format version")

	# Round trip through JSON text, as on disk.
	var b := await _game()
	SaveGame.apply(JSON.parse_string(JSON.stringify(data)), b.economy, b.mine, b.player)
	failures += _check(SaveGame.capture(b.economy, b.mine, 1000.0, b.player) == data, "loading restores every saved field")
	failures += _check(not b.mine.world.is_solid(Vector3i(20, 0, 20)) and b.mine.drills.size() == 1
			and b.mine.drills[0].depth_y == a.mine.drills[0].depth_y, "dug tunnels stay dug, and the drill is back where it was")

	# Offline in big steps matches live play in small ticks.
	var live := await _game()
	var offline := await _game()
	for g in [live, offline]:
		SaveGame.apply(JSON.parse_string(JSON.stringify(base)), g.economy, g.mine)
	for i in 3000:
		live.economy.advance(0.1, 0.1)
	offline.economy.advance(300.0, 5.0)
	failures += _check(offline.mine.drills[0].depth_y < a.mine.drills[0].depth_y,
			"placed drills keep boring down while away")
	# Within one block: the stage bonus starts at the end of the 5 s step it is reached in.
	failures += _check(absi(live.mine.drills[0].depth_y - offline.mine.drills[0].depth_y) <= 1 and live.mine.ores == offline.mine.ores
			# A stage reached inside a 5 s step starts its bonus at the step's end: within one step of power.
			and absf(live.economy.heart.progress - offline.economy.heart.progress) < 20.0,
			"5 s offline steps match 0.1 s live ticks over 5 minutes")

	# Drones keep a fed furnace burning while coal lasts; without them it burns out.
	var hand := await _game()
	SaveGame.apply(JSON.parse_string(JSON.stringify(base)), hand.economy, hand.mine)
	hand.economy.heart.stage = 0
	hand.economy.advance(600.0, 5.0)
	failures += _check(not hand.economy.furnace.is_burning() and hand.mine.ores["coal"] >= 40, "offline without drones: the furnace burns out, no coal fed in")
	failures += _check(offline.economy.furnace.is_burning(), "offline with drones: coal is fed in, so the furnace still burns")

	failures += _check(SaveGame.validate("x") != "" and SaveGame.validate({}) != "" and SaveGame.validate({ "version": 99 }) != "", "bad saves are refused")
	failures += _check(SaveGame.validate(data) == "", "a good save is accepted")

	# A v0.1.x save (format 1) has no reactor: it loads with the reactor unbuilt.
	var old: Dictionary = JSON.parse_string(JSON.stringify(data))
	old["version"] = 1
	old.erase("reactor")
	var v1 := await _game()
	var v1_start: Vector3 = v1.player.global_position
	failures += _check(SaveGame.validate(old) == "", "a format 1 save is accepted")
	SaveGame.apply(old, v1.economy, v1.mine)
	failures += _check(v1.mine.ores["coal"] == 40 and v1.economy.turbine_built and not v1.economy.reactor_built,
			"a format 1 save loads, with no reactor")
	failures += _check(v1.mine.world.edits.is_empty() and v1.mine.drills.is_empty() and v1.player.global_position == v1_start,
			"a pre-3D save starts a fresh world, with the player at the base")
	old["version"] = 2
	failures += _check(SaveGame.validate(old) != "", "a format 2 save without a reactor is refused")

	# A v0.2.x save (format 3) holds a block world: fresh smooth ground, drills refunded.
	var v3_save: Dictionary = JSON.parse_string(JSON.stringify(data))
	v3_save["version"] = 3
	var v3 := await _game()
	SaveGame.apply(v3_save, v3.economy, v3.mine, v3.player)
	failures += _check(v3.mine.world.edits.is_empty() and v3.mine.drills.is_empty()
			and v3.mine.ores["copper"] == int(data["mine"]["ores"]["copper"]) + data["drills"].size() * v3.mine.drill_cost
			and v3.economy.reactor_built, "a format 3 save keeps its economy on fresh ground, its drills as copper")

	# An unreadable file is moved aside, not overwritten, and the game starts new.
	var path := "user://check_save.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string("{ not json")
	f.close()
	var c := await _game()
	var saver := SaveGame.new()
	saver.economy = c.economy
	saver.mine = c.mine
	saver.away_dialog = AcceptDialog.new()
	root.add_child(saver.away_dialog)
	saver.save_path = path
	saver.load_game()
	var kept: Array = Array(DirAccess.get_files_at("user://")).filter(func(n: String) -> bool: return n.begins_with("check_save.unreadable-"))
	failures += _check(not FileAccess.file_exists(path) and kept.size() == 1, "unreadable save kept under a new name")
	failures += _check(c.mine.world.edits.is_empty() and c.mine.ores["coal"] == 0, "unreadable save starts a new game")
	saver.save_game()
	var reread: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	failures += _check(SaveGame.validate(reread) == "", "the next save writes a fresh, valid file")
	for n in kept:
		DirAccess.remove_absolute("user://" + n)
	DirAccess.remove_absolute(path)

	# Resonance lives beside the save, never in it, and raises every generator's output.
	failures += _check(saver.load_resonance() == 0 and not saver.resonance_path().ends_with("savegame.resonance.json"),
			"no Resonance before a launch, and a check never reads the real file")
	var file := FileAccess.open(saver.resonance_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify({ "resonance": 2 }))
	file.close()
	failures += _check(saver.load_resonance() == 2 and not SaveGame.capture(c.economy, c.mine, 0.0).has("resonance"),
			"Resonance reads back from its own file")
	DirAccess.remove_absolute(saver.resonance_path())
	c.economy.furnace.fuel = 5
	c.economy._tick(1.0)
	var plain: float = c.economy.power_per_second
	c.economy.resonance = 2
	c.economy.furnace.fuel = 5
	c.economy._tick(1.0)
	failures += _check(is_equal_approx(c.economy.power_per_second, plain * (1.0 + 2 * c.economy.resonance_power_bonus)), "Resonance makes every generator stronger (%.1f vs %.1f)" % [c.economy.power_per_second, plain])
	saver.free()

	print("save_offline_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _game() -> Dictionary:
	var world := VoxelWorld.new()
	var mine := Mine.new()
	var economy := Economy.new()
	var player: Player = load("res://src/player/player.tscn").instantiate()
	mine.world = world
	economy.mine = mine
	player.world = world
	player.mine = mine
	player.position = Vector3(64.5, 1, 64.5)
	root.add_child(world)
	root.add_child(mine)
	root.add_child(economy)
	root.add_child(player)
	await process_frame  # _ready runs on the next frame
	economy.set_process(false)
	player.set_physics_process(false)
	return { "mine": mine, "economy": economy, "player": player }


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
