## The power console at the base (brief: Milestone 3D item 20). E opens the Drills/Heart
## slider; the player looks at it like any machine.
class_name PowerConsole
extends Node3D

## The economy whose split the console sets.
@export var economy: Economy
## The panel the console opens.
@export var overlay: Overlay


func _ready() -> void:
	var desk_material := StandardMaterial3D.new()
	desk_material.albedo_color = Color(0.22, 0.22, 0.26)
	var screen_material := StandardMaterial3D.new()
	screen_material.albedo_color = Color(0.1, 0.3, 0.35)
	screen_material.emission_enabled = true
	screen_material.emission = Color(0.2, 0.8, 0.9)
	_add_box(Vector3(1.2, 1.0, 0.6), Vector3(0, 0.5, 0), desk_material)
	var screen := _add_box(Vector3(1.0, 0.6, 0.05), Vector3(0, 1.3, -0.1), screen_material)
	screen.rotation.x = -0.3
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = Vector3(1.2, 1.6, 0.6)
	shape.position = Vector3(0, 0.8, 0)
	body.add_child(shape)
	add_child(body)


## What the player sees while looking at the console.
func prompt() -> String:
	return "Power console: %.0f%% to the Heart\n[E] Set the Drills/Heart split" % (economy.split.heart_share * 100.0)


## E: open the slider.
func use_primary() -> void:
	overlay.open()


func use_secondary() -> void:
	pass


func _add_box(size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
	var view := MeshInstance3D.new()
	view.mesh = BoxMesh.new()
	view.mesh.size = size
	view.position = at
	view.material_override = material
	add_child(view)
	return view
