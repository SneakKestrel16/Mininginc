## The miner, in first person (brief: Milestone 3D item 16). Walks the voxel moon and
## breaks the block under the crosshair with the hand drill while the left button is held.
class_name Player
extends CharacterBody3D

const CONFIG_PATH := "res://data/world.json"

## The moon the player walks and digs.
@export var world: VoxelWorld

## The block under the crosshair within reach, or null.
var target: Variant = null
## True while the player is in control. A click on the game turns it on and takes the
## mouse; Esc or an overlay turns it off. Never on at start, so the game (or a check run)
## never grabs the mouse by itself.
var controls_enabled := false
## True while an overlay is open, which hides the "click to play" hint.
var hint_blocked := false

var _move_speed: float
var _jump_velocity: float
var _gravity: float
var _reach: float
var _drill_rate: float
var _sensitivity: float

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera
@onready var _marker: MeshInstance3D = $TargetMarker
@onready var _marker_material: StandardMaterial3D = _marker.material_override
@onready var _hint: Label = $Crosshair/Hint


func _ready() -> void:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	var keys := ["move_speed", "jump_velocity", "gravity", "reach", "hand_drill_hits_per_second", "mouse_sensitivity"]
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
	_marker.top_level = true


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled:
		if event is InputEventMouseButton and event.pressed and _hint.visible:
			set_controls(true)
			get_viewport().set_input_as_handled()  # this click only takes the mouse
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * _sensitivity)
		_head.rotate_x(-event.relative.y * _sensitivity)
		_head.rotation.x = clampf(_head.rotation.x, -PI / 2.0 + 0.01, PI / 2.0 - 0.01)
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		set_controls(false)


## Hands control (and the mouse) to the player, or takes it away.
func set_controls(on: bool) -> void:
	controls_enabled = on
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if on else Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	world.update_around(global_position)
	velocity.y -= _gravity * delta
	var wish := Vector2.ZERO
	var drilling := false
	if controls_enabled:
		wish = Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
		if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
			velocity.y = _jump_velocity
		drilling = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var move := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized() * _move_speed
	velocity.x = move.x
	velocity.z = move.z
	move_and_slide()
	_aim()
	if drilling and target != null:
		world.hit(target, _drill_rate * delta)
	_show_target()
	_hint.visible = not controls_enabled and not hint_blocked


## Finds the block under the crosshair within reach.
func _aim() -> void:
	var from := _camera.global_position
	var query := PhysicsRayQueryParameters3D.create(from, from - _camera.global_basis.z * _reach)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		target = null
		return
	# Step half a block into the face hit, so the point lands inside the solid block.
	target = Vector3i((hit["position"] - hit["normal"] * 0.5).floor())


## Outlines the target block, darker the more damage it has taken.
func _show_target() -> void:
	_marker.visible = target != null
	if target == null:
		return
	_marker.global_position = Vector3(target) + Vector3(0.5, 0.5, 0.5)
	var needed: float = world.hardness(target)
	var done: float = world.damage.get(target, 0.0) / needed if needed > 0.0 and not is_inf(needed) else 0.0
	_marker_material.albedo_color = Color(0.05, 0.02, 0.0, 0.12 + 0.6 * done)
