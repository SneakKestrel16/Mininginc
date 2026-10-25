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

	var shaft := DigShaft.new(1, 1.0, 0.0, [], 2, 5.0)
	shaft.dig(2.0)
	failures += _check(shaft.depth == 2 and shaft.is_frozen(), "the shaft reaches the frozen floor")
	failures += _check(shaft.hardness(2) == 5 and shaft.dig(4.0).is_empty() and shaft.dig(1.0).size() == 1,
			"frozen rock digs, at 5x the hits (never a dead end)")
	shaft.frozen_from = 100
	failures += _check(shaft.hardness(3) == 1 and shaft.dig(1.0).size() == 1, "thawed rock digs at normal hardness")

	# The shipped stages: Voice is the fifth, speaks, and doubles the drills; Wake is the last.
	var shipped: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/heart_stages.json"))["stages"]
	var voice := Heart.new(shipped)
	voice.stage = 4
	failures += _check(shipped[4]["name"] == "Voice" and voice.effect_total("drill_bonus") == 0.0 and not voice.is_awake(), "Voice comes after Sight")
	voice.stage = 5
	failures += _check(voice.effect_total("drill_bonus") == 1.0 and not voice.is_awake() and shipped[4]["lines"].size() >= 3,
			"Voice speaks and doubles the drills")
	voice.stage = 6
	failures += _check(shipped.size() == 6 and shipped[5]["name"] == "Wake" and voice.is_awake()
			and shipped[5]["threshold"] > shipped[4]["threshold"] and shipped[5]["lines"].size() >= 2,
			"Wake is the sixth and last stage, the largest, and speaks")

	print("heart_stages_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
