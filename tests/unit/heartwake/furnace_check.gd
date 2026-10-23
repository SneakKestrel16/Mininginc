## Self-check for Furnace until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/furnace_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _init() -> void:
	var failures := 0
	var furnace := Furnace.new(3, 2.0, 10.0)

	failures += _check(furnace.tick(1.0) == 0.0 and not furnace.is_burning(), "empty furnace makes no power")
	failures += _check(furnace.feed(0) == 0, "feeding no coal does nothing")
	failures += _check(furnace.feed(5) == 3 and furnace.fuel == 3, "feed stops at capacity")

	failures += _check(is_equal_approx(furnace.tick(1.0), 10.0), "burning gives full power")
	failures += _check(furnace.space() == 0, "the burning piece still takes a slot")
	failures += _check(is_equal_approx(furnace.fuel_level(), 2.5), "fuel level counts the burning part")

	# 2.5 pieces left = 5 s of burning; a 6 s tick burns out 1 s before its end.
	failures += _check(is_equal_approx(furnace.tick(6.0), 10.0 * 5.0 / 6.0), "power averages over a tick that runs dry")
	failures += _check(not furnace.is_burning() and furnace.tick(1.0) == 0.0, "out of fuel: output stops (the stall)")

	var a := Furnace.new(10, 5.0, 10.0)
	var b := Furnace.new(10, 5.0, 10.0)
	a.feed(4)
	b.feed(4)
	var total_a := 0.0
	for i in 100:
		total_a += a.tick(0.1)
	failures += _check(is_equal_approx(total_a * 0.1, b.tick(10.0) * 10.0), "same burn for many small ticks or one large one")

	print("furnace_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
