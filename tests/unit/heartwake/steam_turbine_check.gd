## Self-check for SteamTurbine and the Shallow layer's ores until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/steam_turbine_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _init() -> void:
	var failures := 0
	var turbine := SteamTurbine.new(10, 5.0, 25.0, 50.0, 1.0, 10.0)

	failures += _check(turbine.melt(9) == 5 and turbine.water == 50.0, "ice melts into water up to the tank size")
	failures += _check(turbine.tick(1.0) == 0.0 and not turbine.is_running(), "water but no coal: no power")

	var dry := SteamTurbine.new(10, 5.0, 25.0, 50.0, 1.0, 10.0)
	dry.boiler.feed(3)
	failures += _check(dry.tick(1.0) == 0.0 and dry.boiler.fuel == 3, "coal but no water: no power, no coal burned")

	turbine.boiler.feed(1)
	failures += _check(is_equal_approx(turbine.tick(1.0), 25.0) and is_equal_approx(turbine.water, 49.0), "coal and water: full power, water used")

	# 4 s of coal left, 49 water: a 10 s tick runs 4 s.
	failures += _check(is_equal_approx(turbine.tick(10.0), 25.0 * 4.0 / 10.0) and is_equal_approx(turbine.water, 45.0), "stops when coal runs out mid-tick")

	var thirsty := SteamTurbine.new(10, 5.0, 25.0, 50.0, 1.0, 10.0)
	thirsty.melt(1)
	thirsty.boiler.feed(5)
	failures += _check(is_equal_approx(thirsty.tick(20.0), 25.0 * 10.0 / 20.0) and thirsty.water == 0.0, "stops when water runs out mid-tick")
	failures += _check(not thirsty.is_running() and thirsty.boiler.is_burning(), "out of water while coal remains")

	var ores: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ores.json"))["ores"]
	var shaft := DigShaft.new(77, 3.0, 0.25, ores)
	var found := {}
	for d in range(0, 100):
		found[shaft.block_at(d) + ("_deep" if d >= 50 else "")] = true
	failures += _check(found.has("ice_deep") and found.has("copper_deep"), "ice and copper appear below depth 50")
	failures += _check(not found.has("ice") and not found.has("copper"), "no ice or copper in the surface layer")

	print("steam_turbine_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
