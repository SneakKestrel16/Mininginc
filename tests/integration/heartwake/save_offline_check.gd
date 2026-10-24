## Self-check for saving, loading and offline progress until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/integration/heartwake/save_offline_check.gd
## Exits 0 when every check passes, 1 on the first failure. Writes only user://check_*.json.
extends SceneTree


func _initialize() -> void:
	var failures := 0

	# A game in a known state: Flicker reached, coal in stock and in the furnace, turbine built.
	var a := await _game()
	a.mine.shaft.shaft_seed = 99
	a.mine.shaft.depth = 7
	a.mine.shaft.damage = 1.5
	a.mine.ores["coal"] = 6
	a.economy.split.heart_share = 0.25
	a.economy.heart.stage = 1
	a.economy.heart.progress = 40.0
	a.economy.furnace.fuel = 3
	a.economy.furnace.burn_left = 2.0
	a.economy.turbine_built = true
	a.economy.turbine.water = 12.0
	var data := SaveGame.capture(a.economy, a.mine, 1000.0)
	failures += _check(data["version"] == SaveGame.FORMAT_VERSION, "the save carries its format version")

	# Round trip through JSON text, as on disk.
	var b := await _game()
	SaveGame.apply(JSON.parse_string(JSON.stringify(data)), b.economy, b.mine)
	failures += _check(SaveGame.capture(b.economy, b.mine, 1000.0) == data, "loading restores every saved field")

	# Offline in big steps matches live play in small ticks.
	var live := await _game()
	var offline := await _game()
	for g in [live, offline]:
		SaveGame.apply(JSON.parse_string(JSON.stringify(data)), g.economy, g.mine)
	for i in 3000:
		live.economy.advance(0.1, 0.1)
	offline.economy.advance(300.0, 5.0)
	failures += _check(live.mine.shaft.depth == offline.mine.shaft.depth and live.mine.ores == offline.mine.ores
			and is_equal_approx(live.economy.heart.progress, offline.economy.heart.progress),
			"5 s offline steps match 0.1 s live ticks over 5 minutes")

	# Drones keep a fed furnace burning while coal lasts; without them it burns out.
	var hand := await _game()
	SaveGame.apply(JSON.parse_string(JSON.stringify(data)), hand.economy, hand.mine)
	hand.economy.heart.stage = 0
	hand.economy.advance(600.0, 5.0)
	failures += _check(not hand.economy.furnace.is_burning() and hand.mine.ores["coal"] >= 6, "offline without drones: the furnace burns out, no coal fed in")
	failures += _check(offline.mine.ores["coal"] < 6, "offline with drones: coal is fed in")

	failures += _check(SaveGame.validate("x") != "" and SaveGame.validate({}) != "" and SaveGame.validate({ "version": 99 }) != "", "bad saves are refused")
	failures += _check(SaveGame.validate(data) == "", "a good save is accepted")

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
	failures += _check(c.mine.shaft.depth == 0, "unreadable save starts a new game")
	saver.save_game()
	var reread: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	failures += _check(SaveGame.validate(reread) == "", "the next save writes a fresh, valid file")
	for n in kept:
		DirAccess.remove_absolute("user://" + n)
	DirAccess.remove_absolute(path)
	saver.free()

	print("save_offline_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _game() -> Dictionary:
	var mine := Mine.new()
	var economy := Economy.new()
	economy.mine = mine
	root.add_child(mine)
	root.add_child(economy)
	await process_frame  # _ready runs on the next frame
	economy.set_process(false)
	return { "mine": mine, "economy": economy }


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
