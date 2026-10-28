## Self-check for Recall (brief: Milestone 10 item 44) until /test-setup installs gdUnit4.
## Run: <godot> --headless --path . -s res://tests/unit/heartwake/recall_check.gd
## Exits 0 when every check passes, 1 on the first failure. Presses R through Input; never
## takes the mouse.
extends SceneTree


func _initialize() -> void:
	var failures := 0

	# The hold: 3 s of R recalls once; letting go early starts over; holding on does not repeat.
	var recall := Recall.new(3.0)
	var fired := 0
	for i in 29:
		fired += int(recall.tick(0.1, true))
	failures += _check(fired == 0 and recall.is_holding(), "2.9 s of R does not recall yet")
	fired += int(recall.tick(0.1, true))
	failures += _check(fired == 1 and not recall.is_holding(), "3 s of R recalls")
	for i in 50:
		fired += int(recall.tick(0.1, true))
	failures += _check(fired == 1, "holding on past it does not recall again")
	recall.tick(0.1, false)
	for i in 20:
		fired += int(recall.tick(0.1, true))
	recall.tick(0.1, false)
	failures += _check(fired == 1 and not recall.is_holding(), "letting go at 2 s cancels")
	for i in 29:
		fired += int(recall.tick(0.1, true))
	failures += _check(fired == 1, "and the next hold starts from zero")

	# The player: deep in a chamber, R held does nothing without control, then brings the
	# player home onto solid ground.
	var world := VoxelWorld.new()
	world.world_seed = 7
	root.add_child(world)
	var player: Player = load("res://src/player/player.tscn").instantiate()
	player.world = world
	root.add_child(player)
	await process_frame  # _ready runs on the next frame
	world.carve(Vector3(20.5, -300, 20.5), 3.0)
	world.update_around(Vector3(20.5, -300, 20.5))
	player.global_position = Vector3(20.5, -302.8, 20.5)
	var home := player.recall_point
	failures += _check(world.is_solid(Vector3i(home.floor()) + Vector3i.DOWN) and not world.is_solid(Vector3i(home.floor()))
			and not world.is_solid(Vector3i(home.floor()) + Vector3i.UP), "the recall point stands on ground, with room above")
	var press := InputEventKey.new()
	press.physical_keycode = KEY_R
	press.pressed = true
	Input.parse_input_event(press)
	for i in 240:
		await physics_frame
	failures += _check(player.global_position.y < -290.0, "without control R does nothing")
	player.controls_enabled = true  # not set_controls(): a check never takes the mouse
	for i in 240:
		await physics_frame
	player.controls_enabled = false
	var release := press.duplicate()
	release.pressed = false
	Input.parse_input_event(release)
	var landed := player.global_position
	failures += _check(Vector2(landed.x, landed.z).distance_to(Vector2(home.x, home.z)) < 0.01 and landed.y > 0.8 and landed.y < home.y + 0.01,
			"holding R for 3 s brings the player to the base (%s)" % landed)
	for i in 60:
		await physics_frame
	failures += _check(player.is_on_floor() and player.global_position.y > 0.8, "and the player stands on the ground there (y %.2f)" % player.global_position.y)

	print("recall_check: %s" % ("PASS" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)


func _check(ok: bool, what: String) -> int:
	if not ok:
		printerr("FAIL: " + what)
	return 0 if ok else 1
