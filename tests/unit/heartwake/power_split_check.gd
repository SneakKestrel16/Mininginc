## Self-check for PowerSplit until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/power_split_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree


func _init() -> void:
	var failures := 0
	var split := PowerSplit.new(0.25)

	split.tick(10.0)
	failures += _check(is_equal_approx(split.heart_power, 2.5), "25% Heart sends 2.5 of 10")
	failures += _check(is_equal_approx(split.drill_power + split.heart_power, 10.0), "shares add up to the total")

	split.heart_share = 0.0
	split.tick(10.0)
	failures += _check(split.heart_power == 0.0 and is_equal_approx(split.drill_power, 10.0), "0% Heart: drills get everything")

	split.heart_share = 1.0
	split.tick(10.0)
	failures += _check(split.drill_power == 0.0 and is_equal_approx(split.heart_power, 10.0), "100% Heart: drill share is 0")

	split.heart_share = 7.0
	failures += _check(split.heart_share == 1.0, "share clamps to 0..1")

	print("power_split_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
