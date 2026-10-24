## The Heart as the player sees it: a huge machine sealed in a cavern deep under the base
## (brief: Milestone 3D item 18, Milestone 4 item 26). It glows and pulses brighter and
## faster at each stage, read from the stage index every frame, so a loaded save looks
## right at once. Its light and a low hum reach up through the rock, so the player can
## dig toward it.
class_name HeartMachine
extends Node3D

## The economy whose Heart this shows.
@export var economy: Economy
## The world whose cavern it sits in; it moves to the cavern's centre.
@export var world: VoxelWorld
## Radius of the core, in metres.
@export var radius := 3.0
## Pitch of the hum, in hertz.
@export var hum_hz := 55.0

var _core_material := StandardMaterial3D.new()
var _light := OmniLight3D.new()
var _hum := AudioStreamPlayer3D.new()
var _hum_phase := 0.0


func _ready() -> void:
	if world:
		global_position = world.heart_center
	var core := MeshInstance3D.new()
	core.mesh = SphereMesh.new()
	core.mesh.radius = radius
	core.mesh.height = radius * 2.0
	_core_material.albedo_color = Color(0.25, 0.1, 0.08)
	_core_material.emission_enabled = true
	_core_material.emission = Color(1.0, 0.35, 0.15)
	core.material_override = _core_material
	add_child(core)
	# A dark cage around the core, so it reads as a machine rather than a ball.
	var cage_material := StandardMaterial3D.new()
	cage_material.albedo_color = Color(0.12, 0.12, 0.14)
	cage_material.metallic = 0.6
	for angle in [0.0, PI / 3.0, PI * 2.0 / 3.0]:
		var ring := MeshInstance3D.new()
		ring.mesh = TorusMesh.new()
		ring.mesh.inner_radius = radius * 1.05
		ring.mesh.outer_radius = radius * 1.2
		ring.material_override = cage_material
		ring.rotation = Vector3(PI / 2.0, angle, 0)
		add_child(ring)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = radius * 1.2
	body.add_child(shape)
	add_child(body)
	_light.light_color = Color(1.0, 0.5, 0.25)
	# No shadows, on purpose: the glow leaks through the rock onto tunnel walls near it.
	_light.omni_range = radius * 8.0
	add_child(_light)
	var tone := AudioStreamGenerator.new()
	tone.mix_rate = 22050.0
	tone.buffer_length = 0.25
	_hum.stream = tone
	_hum.max_distance = 60.0
	_hum.unit_size = 6.0
	add_child(_hum)
	_hum.play()


func _process(_delta: float) -> void:
	var stage := economy.heart.stage
	var count := maxi(economy.heart.stages.size(), 1)
	var awake := float(stage) / count
	# Asleep it barely smoulders; each stage brightens it and quickens the beat.
	var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * (0.3 + 0.5 * awake))
	_core_material.emission_energy_multiplier = (0.15 + 2.5 * awake) * (0.7 + 0.3 * beat)
	_light.light_energy = (0.2 + 4.0 * awake) * (0.7 + 0.3 * beat)
	_hum.volume_db = linear_to_db(0.3 + 0.7 * awake) - 6.0
	_feed_hum()


# A low sine with its second harmonic, written into the generator as it plays.
func _feed_hum() -> void:
	var playback := _hum.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var rate: float = (_hum.stream as AudioStreamGenerator).mix_rate
	for i in playback.get_frames_available():
		var value := 0.6 * sin(_hum_phase) + 0.25 * sin(_hum_phase * 2.0)
		playback.push_frame(Vector2(value, value))
		_hum_phase = fmod(_hum_phase + TAU * hum_hz / rate, TAU * 2.0)
