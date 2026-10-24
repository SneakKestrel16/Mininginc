## Self-check for FissionReactor and the Mid layer's uranium until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/fission_reactor_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _init() -> void:
	var failures := 0
	var reactor := FissionReactor.new(5, 30.0, 100.0, 1.0, 100.0)

	failures += _check(reactor.tick(1.0) == 0.0 and reactor.heat == 0.0 and not reactor.is_running(), "no uranium: no power, no heat")
	failures += _check(reactor.core.feed(9) == 5, "uranium loads up to the fuel capacity")
	failures += _check(is_equal_approx(reactor.tick(1.0), 100.0) and is_equal_approx(reactor.heat, 1.0), "running: full power, heat rises")

	# 149 s of uranium left: a 200 s tick runs 149 s.
	failures += _check(is_equal_approx(reactor.tick(200.0), 100.0 * 149.0 / 200.0) and not reactor.is_running(), "stops when uranium runs out mid-tick")
	failures += _check(reactor.heat == 100.0, "heat never passes the limit")

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
