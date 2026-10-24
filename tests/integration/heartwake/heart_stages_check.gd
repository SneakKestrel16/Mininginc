## Self-check for Heart stages and the frozen floor until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/integration/heartwake/heart_stages_check.gd
## Exits 0 when every check passes, 1 on the first failure.
extends SceneTree

const STAGES := [
	{ "name": "Flicker", "threshold": 10.0, "effect": "drones", "value": 0, "line": "a" },
	{ "name": "Pulse", "threshold": 20.0, "effect": "output_bonus", "value": 0.25, "line": "b" },
	{ "name": "Breath", "threshold": 30.0, "effect": "thaw_to_depth", "value": 100, "line": "c" },
]


func _init() -> void:
	var failures := 0
	var heart := Heart.new(STAGES)

	failures += _check(heart.add(9.0).is_empty() and heart.stage == 0, "below the threshold: no stage")
	failures += _check(heart.add(2.0) == [0] and heart.stage == 1, "crossing the threshold reaches Flicker once")
	failures += _check(is_equal_approx(heart.progress, 1.0), "excess carries toward the next stage")
	failures += _check(heart.has_effect("drones") and heart.effect_total("output_bonus") == 0.0, "Flicker grants drones only")
	failures += _check(heart.add(0.0).is_empty() and heart.stage == 1, "a stage is never reached twice")

	failures += _check(heart.add(100.0) == [1, 2] and heart.is_awake(), "one big add can reach several stages, in order")
	failures += _check(heart.effect_total("output_bonus") == 0.25 and heart.effect_total("thaw_to_depth") == 100.0, "Pulse and Breath bonuses apply")
	failures += _check(heart.add(50.0).is_empty() and heart.progress == 0.0 and heart.threshold() == 0.0, "awake: the meter has nothing further to fill")

	var restored := Heart.new(STAGES)
	restored.stage = 2
	failures += _check(restored.has_effect("drones") and restored.effect_total("output_bonus") == 0.25, "bonuses follow from the stage index alone")

	var shaft := DigShaft.new(1, 1.0, 0.0, [], 2)
	shaft.dig(10.0)
	failures += _check(shaft.depth == 2 and shaft.is_frozen() and shaft.damage == 0.0, "digging stops at the frozen floor")
	failures += _check(shaft.dig(5.0).is_empty() and shaft.depth == 2, "frozen rock cannot be dug")
	shaft.frozen_from = 100
	failures += _check(shaft.dig(1.0).size() == 1 and shaft.depth == 3, "thawed rock digs again")

	print("heart_stages_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
