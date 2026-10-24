## Self-check for FissionReactor and the Mid layer's uranium until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/fission_reactor_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _init() -> void:
	var failures := 0
	# No passive cooling here, so heat follows burn time exactly.
	var reactor := FissionReactor.new(5, 30.0, 100.0, 1.0, 1000.0, 50.0, 0.0, 10.0, 1.0)

	failures += _check(reactor.tick(1.0) == 0.0 and reactor.heat == 0.0 and not reactor.is_running(), "no uranium: no power, no heat")
	failures += _check(reactor.core.feed(9) == 5, "uranium loads up to the fuel capacity")
	failures += _check(is_equal_approx(reactor.tick(1.0), 100.0) and is_equal_approx(reactor.heat, 1.0), "running: full power, heat rises")

	# 149 s of uranium left: a 200 s tick runs 149 s.
	failures += _check(is_equal_approx(reactor.tick(200.0), 100.0 * 149.0 / 200.0) and not reactor.is_running(), "stops when uranium runs out mid-tick")
	failures += _check(is_equal_approx(reactor.heat, 150.0) and is_equal_approx(reactor.waste, 5.0), "every uranium burned leaves one waste")
	failures += _check(reactor.cool(99) == 15 and reactor.heat == 0.0, "ice removes heat, using only as much as it takes")

	# Heat 1/s, cooling 0.2/s: net 0.8/s, so from 0 it reaches 100 after 125 s.
	var hot := FissionReactor.new(5, 30.0, 100.0, 1.0, 100.0, 50.0, 0.2, 10.0, 1.0)
	hot.core.feed(5)
	var avg := hot.tick(200.0)
	failures += _check(hot.scrammed and not hot.is_running() and hot.core.is_burning(), "heat at the limit scrams, with uranium left")
	failures += _check(is_equal_approx(avg, 100.0 * 125.0 / 200.0) and is_equal_approx(hot.heat, 100.0 - 0.2 * 75.0),
			"a long step scrams at the right moment, then cools")
	failures += _check(hot.tick(1.0) == 0.0, "a scrammed reactor makes no power")
	hot.tick(100.0)  # 85 - 20 = 65: still above the restart level
	failures += _check(hot.scrammed, "stays off above the restart level")
	failures += _check(hot.cool(2) == 2 and not hot.scrammed and hot.is_running(), "cooled to the restart level, it runs again on its own")
	failures += _check(hot.tick(1.0) > 0.0, "and makes power again")

	# Offline steps scram and restart like live ticks.
	var live := FissionReactor.new(5, 30.0, 100.0, 1.0, 100.0, 50.0, 0.2, 10.0, 1.0)
	var offline := FissionReactor.new(5, 30.0, 100.0, 1.0, 100.0, 50.0, 0.2, 10.0, 1.0)
	live.core.feed(5)
	offline.core.feed(5)
	var live_energy := 0.0
	var offline_energy := 0.0
	for i in 4000:
		live_energy += live.tick(0.1) * 0.1
	for i in 80:
		offline_energy += offline.tick(5.0) * 5.0
	failures += _check(absf(live_energy - offline_energy) <= 100.0 * 5.0 and absf(live.waste - offline.waste) <= 0.1,
			"5 s steps match 0.1 s ticks over 400 s, within one step of power (got %.0f vs %.0f)" % [live_energy, offline_energy])

	var ores: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/ores.json"))["ores"]
	var shaft := DigShaft.new(77, 3.0, 0.25, ores)
	var shallow := 0
	var deep := 0
	for d in range(0, 400):
		if shaft.block_at(d) == "uranium":
			if d < 100:
				shallow += 1
			else:
				deep += 1
	failures += _check(shallow == 0 and deep > 0, "uranium appears only from depth 100")

	print("fission_reactor_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
