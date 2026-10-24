## The miner, in first person (brief: Milestone 3D item 16, Milestone 4 item 25). Walks the
## moon and scoops round bites out of the ground under the crosshair while the left button
## is held.
class_name Player
extends CharacterBody3D

const CONFIG_PATH := "res://data/world.json"

## The moon the player walks and digs.
@export var world: VoxelWorld
## Where ore goes and auto-drills are placed from.
@export var mine: Mine
## Its drill power adds to the hand tool's speed.
@export var economy: Economy

## The point just inside the ground under the crosshair within reach, or null.
var target: Variant = null
## The machine, drill or console under the crosshair within reach, or null: anything
## with prompt(), use_primary() and use_secondary().
var machine: Node3D = null
## True while the player is in control. A click on the game turns it on and takes the
## mouse; Esc or an overlay turns it off. Never on at start, so the game (or a check run)
## never grabs the mouse by itself.
var controls_enabled := false
## Surface normal at [member target]; a drill goes on ground facing mostly up.
var _target_normal := Vector3.ZERO
## True while an overlay is open, which hides the "click to play" hint.
var hint_blocked := false
## Dev menu fly mode: no gravity, no collision, Space up and Ctrl down, three times the speed.
var flying := false:
	set(on):
		flying = on
		$Shape.disabled = on
		velocity = Vector3.ZERO

var _move_speed: float
var _jump_velocity: float
var _gravity: float
var _reach: float
var _drill_rate: float
var _sensitivity: float
var _power_bonus: float

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera
@onready var _marker: MeshInstance3D = $TargetMarker
@onready var _marker_material: StandardMaterial3D = _marker.material_override
@onready var _hint: Label = $Crosshair/Hint
@onready var _prompt: Label = $Crosshair/Prompt


func _ready() -> void:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	var keys := ["move_speed", "jump_velocity", "gravity", "reach", "hand_drill_hits_per_second", "mouse_sensitivity",
			"hand_power_bonus"]
	if not config is Dictionary or not config.has_all(keys):
		var message := "%s is missing one of %s" % [CONFIG_PATH, ", ".join(keys)]
		push_error(message)
		OS.alert(message, "Heartwake cannot start")
		get_tree().quit(1)
		return
	_move_speed = config["move_speed"]
	_jump_velocity = config["jump_velocity"]
	_gravity = config["gravity"]
	_reach = config["reach"]
	_drill_rate = config["hand_drill_hits_per_second"]
	_sensitivity = config["mouse_sensitivity"]
	_power_bonus = config["hand_power_bonus"]
	_marker.top_level = true


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled:
		if event is InputEventMouseButton and event.pressed and _hint.visible:
			set_controls(true)
			get_viewport().set_input_as_handled()  # this click only takes the mouse
		return
	# Only a held mouse turns the view: a free cursor passing over the window must not.
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * _sensitivity)
		_head.rotate_x(-event.relative.y * _sensitivity)
		_head.rotation.x = clampf(_head.rotation.x, -PI / 2.0 + 0.01, PI / 2.0 - 0.01)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ESCAPE:
				set_controls(false)
			KEY_E:
				if machine:
					machine.use_primary()
			KEY_Q:
				if machine:
					machine.use_secondary()
			KEY_F:
				if target != null and _target_normal.y > 0.7:
					mine.place_drill(Vector3i(target.floor()))


## Hits per second the hand tool lands: its own rate plus its share of drill power.
func hand_rate() -> float:
	if economy == null:
		return _drill_rate
	var bonus := mine.hand_share(economy.drill_hits_per_second) * _power_bonus
	return (_drill_rate + bonus) * (1.0 + economy.upgrades.effect("hand_speed"))


## Hands control (and the mouse) to the player, or takes it away.
func set_controls(on: bool) -> void:
	controls_enabled = on
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	world.update_around(global_position)
	if not flying:
		velocity.y -= _gravity * delta
	var wish := Vector2.ZERO
	var drilling := false
	if controls_enabled:
		wish = Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		if flying:
			velocity.y = (float(Input.is_physical_key_pressed(KEY_SPACE)) - float(Input.is_physical_key_pressed(KEY_CTRL))) * _move_speed * 3.0
		elif Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
			velocity.y = _jump_velocity
		drilling = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var move := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized() * _move_speed * (3.0 if flying else 1.0)
	velocity.x = move.x
	velocity.z = move.z
	move_and_slide()
	_aim()
	if drilling and target != null:
		world.dig(target, hand_rate() * delta)
	_show_target()
	_hint.visible = not controls_enabled and not hint_blocked
	_prompt.visible = machine != null and controls_enabled
	if machine:
		_prompt.text = machine.prompt()


## Finds the ground under the crosshair within reach.
func _aim() -> void:
	var from := _camera.global_position
	var reach := _reach + (economy.upgrades.effect("reach") if economy else 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, from - _camera.global_basis.z * reach)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	target = null
	machine = null
	if hit.is_empty():
		return
	var owner_node: Node = hit["collider"].get_parent()
	if owner_node.has_method("prompt"):
		machine = owner_node
		return
	_target_normal = hit["normal"]
	# A little into the ground, so the point's cell is the rock being dug, not the air.
	target = hit["position"] - hit["normal"] * 0.25


## Marks the spot being dug, redder and more solid the closer the next scoop is.
func _show_target() -> void:
	_marker.visible = target != null
	if target == null:
		return
	_marker.global_position = target
	var cell := Vector3i(target.floor())
	var needed: float = world.hardness_at(cell)
	var done: float = world.damage.get(cell, 0.0) / needed if needed > 0.0 and not is_inf(needed) else 0.0
	_marker_material.albedo_color = Color(1.0, 0.55 - 0.4 * done, 0.15, 0.35 + 0.6 * done)
