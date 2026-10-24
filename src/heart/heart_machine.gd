## The Heart as the player sees it: a huge machine in an open pit by the base
## (brief: Milestone 3D item 18). It glows and pulses brighter and faster at each stage,
## read from the stage index every frame, so a loaded save looks right at once.
class_name HeartMachine
extends Node3D

## The economy whose Heart this shows.
@export var economy: Economy
## Radius of the core, in blocks.
@export var radius := 3.0

var _core_material := StandardMaterial3D.new()
var _light := OmniLight3D.new()


func _ready() -> void:
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
	_light.omni_range = radius * 6.0
	add_child(_light)


func _process(_delta: float) -> void:
	var stage := economy.heart.stage
	var count := maxi(economy.heart.stages.size(), 1)
	var awake := float(stage) / count
	# Asleep it barely smoulders; each stage brightens it and quickens the beat.
	var beat := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * (0.3 + 0.5 * awake))
	_core_material.emission_energy_multiplier = (0.15 + 2.5 * awake) * (0.7 + 0.3 * beat)
	_light.light_energy = (0.2 + 4.0 * awake) * (0.7 + 0.3 * beat)
