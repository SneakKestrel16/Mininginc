## Self-check for drill digging (DigShaft.dig) until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/drills_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree

const ORES := [{ "id": "coal", "min_depth": 0, "max_depth": 99, "chance": 0.5 }]


func _init() -> void:
	var failures := 0

	var shaft := DigShaft.new(3, 3.0, 0.0, ORES)
	failures += _check(shaft.dig(0.0).is_empty() and not shaft.revealed, "zero drill power digs nothing")

	var broken: Array[String] = []
	for i in 30:
		broken.append_array(shaft.dig(0.1))
	failures += _check(broken.size() == 1 and shaft.depth == 1, "30 drill ticks of 0.1 hits break one 3-hit block")

	var a := DigShaft.new(9, 3.0, 0.5, ORES)
	var b := DigShaft.new(9, 3.0, 0.5, ORES)
	var from_big := a.dig(20.0)
	var from_small: Array[String] = []
	for i in 200:
		from_small.append_array(b.dig(0.1))
	failures += _check(from_big == from_small and a.depth == b.depth, "excess hits carry into the next block")

	var deep := DigShaft.new(9, 3.0, 0.5, ORES)
	deep.depth = 40
	var shallow := DigShaft.new(9, 3.0, 0.5, ORES)
	failures += _check(deep.dig(20.0).size() < shallow.dig(20.0).size(), "same hits break fewer blocks deeper down")

	var mixed := DigShaft.new(5, 4.0, 0.0, ORES)
	mixed.dig(2.5)  # drills
	var first := mixed.block_at(0)
	failures += _check(mixed.hit() == "" and mixed.hit() == first and mixed.depth == 1, "clicks finish a block the drills started, once")

	print("drills_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
