## Self-check for DigShaft until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/dig_shaft_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree

const ORES := [{ "id": "coal", "min_depth": 0, "max_depth": 9, "chance": 0.5 }]


func _init() -> void:
	var failures := 0

	var a := DigShaft.new(42, 3.0, 0.5, ORES)
	var b := DigShaft.new(42, 3.0, 0.5, ORES)
	var same := true
	for d in 50:
		same = same and a.block_at(d) == b.block_at(d)
	failures += _check(same, "same seed gives the same shaft")

	failures += _check(a.hardness(0) == 3 and a.hardness(10) == 8, "hardness grows with depth")

	var coal_shallow := 0
	var coal_deep := 0
	for d in 10:
		coal_shallow += int(a.block_at(d) == "coal")
	for d in range(10, 200):
		coal_deep += int(a.block_at(d) == "coal")
	failures += _check(coal_shallow > 0, "coal appears near the top")
	failures += _check(coal_deep == 0, "no coal outside its depth band")

	var shaft := DigShaft.new(7, 3.0, 0.0, ORES)
	var expected := shaft.block_at(0)
	failures += _check(shaft.hit() == "" and shaft.revealed, "first hit reveals but does not break")
	failures += _check(shaft.hit() == "" and shaft.depth == 0, "second hit does not break a 3-hit block")
	failures += _check(shaft.hit() == expected and shaft.depth == 1, "third hit breaks it and returns its contents")
	failures += _check(not shaft.revealed and shaft.damage == 0.0, "next block starts hidden and undamaged")

	print("dig_shaft_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
