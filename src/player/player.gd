## The miner, in first person (brief: Milestone 3D item 16, Milestone 4 item 25). Walks the
## moon and scoops round bites out of the ground under the crosshair while the left button
## is held.
class_name Player
extends CharacterBody3D

## Emitted after each scoop the player digs, with what it removed: material name to samples.
signal scooped(collected: Dictionary)

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
## Dev menu fly mode: no gravity, Space up and Ctrl down, three times the speed. It still
## collides unless [member noclip] is on.
var flying := false:
	set(on):
		flying = on
		$Shape.disabled = flying and noclip
		velocity = Vector3.ZERO
## Where Recall (hold R) and the dev menu's To base put the player: the machines' deck, which
## no scoop or drill opens, so a shaft dug at the spawn cannot drop them back down.
var recall_point: Vector3
## Dev menu: while flying, pass through the ground. Off by default.
var noclip := false:
	set(on):
		noclip = on
		$Shape.disabled = flying and noclip

var _move_speed: float
var _jump_velocity: float
var _gravity: float
var _reach: float
var _drill_rate: float
var _sensitivity: float
var _power_bonus: float
var _recall: Recall
var _effects := DigEffects.new()
## Hits the tool has built up toward its next scoop. Kept in the tool, not in the ground, so
## small aim shifts while holding the button never lose progress.
var _progress := 0.0
var _drilling := false
## The drill held in view; built on first use, so a live reload adds it to a running game.
var _tool: Node3D = null
var _bit: Node3D = null

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera
@onready var _marker: MeshInstance3D = $TargetMarker
@onready var _marker_material: StandardMaterial3D = _marker.material_override
@onready var _hint: Label = $Crosshair/Hint
@onready var _prompt: Label = $Crosshair/Prompt


func _ready() -> void:
	var config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	var keys := ["move_speed", "jump_velocity", "gravity", "reach", "hand_drill_hits_per_second", "mouse_sensitivity",
			"hand_power_bonus", "recall_seconds", "recall_point"]
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
	_recall = Recall.new(config["recall_seconds"])
	recall_point = Vector3(config["recall_point"][0], config["recall_point"][1], config["recall_point"][2])
	_marker.top_level = true
	add_child(_effects)


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


## Puts the player at [member recall_point], standing still, with the ground there drawn first
## so there is something to land on.
func recall_home() -> void:
	world.update_around(recall_point)
	global_position = recall_point
	velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if _recall.tick(delta, controls_enabled and Input.is_physical_key_pressed(KEY_R)):
		recall_home()
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
	_drilling = drilling and target != null and not world.is_protected(Vector3i(target.floor()))
	if not drilling:
		_progress = 0.0
	# The hand tool takes its share of drill power only on frames it cuts rock (story 041).
	var cutting := false
	if _drilling:
		var needed := world.hardness_at(Vector3i(target.floor()))
		if not is_inf(needed):
			cutting = true
			_progress += hand_rate() * delta
			# A hair under counts: hits are summed in floats, which can stop just short.
			if _progress >= needed - 0.0001:
				_progress = 0.0
				var got := world.carve(target, world.scoop_radius())
				_effects.play(target, got)
				scooped.emit(got)
	if mine:
		mine.hand_cutting = cutting
	_animate_tool(delta)
	_show_target()
	_hint.visible = not controls_enabled and not hint_blocked
	var guarded := target != null and world.is_protected(Vector3i(target.floor()))
	_prompt.visible = (machine != null or guarded or _recall.is_holding()) and controls_enabled
	if _recall.is_holding():
		_prompt.text = "Recalling to the base: %.1f s" % (_recall.seconds - _recall.held)
	elif machine:
		_prompt.text = machine.prompt()
	elif guarded:
		_prompt.text = "The machines stand on this ground: dig further out"


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
	# Half a metre into the ground: each scoop bites in, not just skims the surface.
	target = hit["position"] - hit["normal"] * 0.5


## Shows the scoop the tool will cut as a glowing dome over the ground: the part above the
## surface shows, the ground hides the rest. It fills in as the scoop nears, and goes grey
## where nothing can be dug.
func _show_target() -> void:
	_marker.visible = target != null
	if target == null:
		return
	if not _marker.mesh is SphereMesh or (_marker.mesh as SphereMesh).radius != 1.0:
		var dome := SphereMesh.new()
		dome.radius = 1.0
		dome.height = 2.0
		_marker.mesh = dome
		_marker_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_marker.global_position = target
	_marker.scale = Vector3.ONE * world.scoop_radius()
	var cell := Vector3i(target.floor())
	var needed: float = world.hardness_at(cell)
	if is_inf(needed) or world.is_protected(cell):
		_marker_material.albedo_color = Color(0.6, 0.6, 0.65, 0.12)
		return
	var done := clampf(_progress / needed, 0.0, 1.0) if needed > 0.0 else 0.0
	_marker_material.albedo_color = Color(1.0, 0.6 - 0.4 * done, 0.15, 0.12 + 0.33 * done)


# The drill in view: spins and shakes while digging, pushes toward the ground on each scoop
# and eases back when idle.
func _animate_tool(delta: float) -> void:
	if _tool == null:
		_tool = Node3D.new()
		_tool.position = Vector3(0.32, -0.28, -0.55)
		_tool.scale = Vector3.ONE * 0.55
		_camera.add_child(_tool)
		var metal := StandardMaterial3D.new()
		metal.albedo_color = Color(0.35, 0.36, 0.4)
		metal.metallic = 0.7
		metal.roughness = 0.35
		var accent := StandardMaterial3D.new()
		accent.albedo_color = Color(0.85, 0.55, 0.15)
		var body := MeshInstance3D.new()
		body.mesh = CylinderMesh.new()
		body.mesh.top_radius = 0.07
		body.mesh.bottom_radius = 0.09
		body.mesh.height = 0.36
		body.rotation.x = PI / 2.0
		body.material_override = accent
		_tool.add_child(body)
		_bit = Node3D.new()
		_bit.position = Vector3(0, 0, -0.26)
		_tool.add_child(_bit)
		var cone := MeshInstance3D.new()
		cone.mesh = CylinderMesh.new()
		cone.mesh.top_radius = 0.0
		cone.mesh.bottom_radius = 0.06
		cone.mesh.height = 0.2
		cone.rotation.x = -PI / 2.0
		cone.material_override = metal
		_bit.add_child(cone)
		for i in 3:  # flutes, so the spin shows
			var flute := MeshInstance3D.new()
			flute.mesh = BoxMesh.new()
			flute.mesh.size = Vector3(0.012, 0.09, 0.16)
			flute.rotation.z = i * TAU / 3.0
			flute.material_override = metal
			_bit.add_child(flute)
	_tool.visible = controls_enabled  # put away while an overlay or menu has the mouse
	var rest := Vector3(0.32, -0.28, -0.55)
	if _drilling:
		_bit.rotate_z(delta * 40.0)
		var push := 0.04 + 0.03 * sin(Time.get_ticks_msec() / 25.0)
		var shake := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * 0.008
		_tool.position = rest + Vector3(0, 0, -push) + shake
	else:
		_bit.rotate_z(delta * 3.0)
		_tool.position = _tool.position.lerp(rest + Vector3(0, sin(Time.get_ticks_msec() / 600.0) * 0.006, 0), delta * 8.0)
