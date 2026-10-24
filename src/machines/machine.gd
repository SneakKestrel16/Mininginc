## A generator standing in the world: the furnace, steam turbine or fission reactor
## (brief: Milestone 3D item 17). Looked at, it tells the player its state and what E and Q
## do; the economy runs it exactly as the 2D panels did.
class_name WorldMachine
extends Node3D

const LIT := Color(1.0, 0.6, 0.2)
const DARK := Color(0.08, 0.08, 0.1)
const SCRAM := Color(1.0, 0.1, 0.05)

## The economy whose generator this is.
@export var economy: Economy
## Which generator: "furnace", "turbine" or "reactor".
@export_enum("furnace", "turbine", "reactor") var kind: String = "furnace"
## Body size, in blocks.
@export var size := Vector3(2, 2, 2)
## Body colour.
@export var color := Color(0.3, 0.3, 0.34)

var _body_material := StandardMaterial3D.new()
var _light_material := StandardMaterial3D.new()
var _gauge: MeshInstance3D


func _ready() -> void:
	_body_material.albedo_color = color
	_body_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_light_material.emission_enabled = true
	var body := _box(size, Vector3(0, size.y / 2.0, 0), _body_material)
	var collider := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	shape.position = body.position
	collider.add_child(shape)
	add_child(collider)
	# A lamp on the front, and a gauge beside it that fills upward.
	_box(Vector3(size.x * 0.5, 0.25, 0.05), Vector3(0, size.y * 0.8, size.z / 2.0 + 0.03), _light_material)
	var gauge_material := StandardMaterial3D.new()
	gauge_material.albedo_color = Color(0.3, 0.8, 1.0)
	gauge_material.emission_enabled = true
	gauge_material.emission = Color(0.1, 0.4, 0.6)
	_gauge = _box(Vector3(0.2, 1.0, 0.05), Vector3(size.x * 0.4, 0, size.z / 2.0 + 0.03), gauge_material)
	economy.ticked.connect(_refresh)
	_refresh()


## What the player sees while looking at the machine: its state, then what E and Q do.
func prompt() -> String:
	var ores := economy.mine.ores
	match kind:
		"furnace":
			var furnace := economy.furnace
			return "Furnace: %s\nCoal %.1f / %d\n[E] Feed coal (%d)" % [
				"burning, %.1f/s" % economy.furnace_output if furnace.is_burning() else "out of fuel",
				furnace.fuel_level(), furnace.capacity, ores.get("coal", 0)]
		"turbine":
			if not economy.turbine_built:
				return "Steam turbine: not built\n[E] Build (%d / %d copper)" % [ores.get("copper", 0), economy.turbine_cost]
			var turbine := economy.turbine
			var state := "running, %.1f/s" % economy.turbine_output if turbine.is_running() \
					else "out of coal" if not turbine.boiler.is_burning() else "out of water"
			return "Steam turbine: %s\nCoal %.1f / %d   Water %.0f / %.0f\n[E] Feed coal (%d)   [Q] Melt ice (%d)" % [
				state, turbine.boiler.fuel_level(), turbine.boiler.capacity, turbine.water, turbine.water_capacity,
				ores.get("coal", 0), ores.get("ice", 0)]
		_:
			if not economy.reactor_built:
				return "Fission reactor: not built\n[E] Build (%d / %d copper)" % [ores.get("copper", 0), economy.reactor_cost]
			var reactor := economy.reactor
			var state := "SCRAM, overheated: restarts at heat %.0f" % reactor.restart_heat if reactor.scrammed \
					else "running, %.1f/s" % economy.reactor_output if reactor.is_running() else "out of uranium"
			return "Fission reactor: %s\nUranium %.1f / %d   Heat %.0f / %.0f   Waste %d\n[E] Feed uranium (%d)   [Q] Cool with ice (%d)" % [
				state, reactor.core.fuel_level(), reactor.core.capacity, reactor.heat, reactor.heat_limit,
				floori(reactor.waste), ores.get("uranium", 0), ores.get("ice", 0)]


## E: build the machine if it is not built, else feed it its fuel.
func use_primary() -> void:
	match kind:
		"furnace":
			economy.feed_furnace()
		"turbine":
			if economy.turbine_built:
				economy.feed_turbine()
			else:
				economy.build_turbine()
		_:
			if economy.reactor_built:
				economy.feed_reactor()
			else:
				economy.build_reactor()
	_refresh()


## Q: melt ice into the turbine, or cool the reactor with it.
func use_secondary() -> void:
	match kind:
		"turbine":
			if economy.turbine_built:
				economy.melt_ice()
		"reactor":
			if economy.reactor_built:
				economy.cool_reactor()
	_refresh()


func _refresh() -> void:
	var built := true
	var running := false
	var fill := 0.0
	var scram := false
	match kind:
		"furnace":
			running = economy.furnace.is_burning()
			fill = economy.furnace.fuel_level() / economy.furnace.capacity
		"turbine":
			built = economy.turbine_built
			running = economy.turbine.is_running()
			fill = economy.turbine.water / economy.turbine.water_capacity
		_:
			built = economy.reactor_built
			running = economy.reactor.is_running()
			scram = economy.reactor.scrammed
			fill = economy.reactor.heat / economy.reactor.heat_limit
	# Not built: a see-through frame showing where it will stand.
	_body_material.albedo_color.a = 1.0 if built else 0.25
	var lamp := SCRAM if scram else LIT if running and built else DARK
	_light_material.albedo_color = lamp
	_light_material.emission = lamp if lamp != DARK else Color.BLACK
	_gauge.visible = built
	_gauge.scale.y = maxf(fill, 0.01) * size.y * 0.6
	_gauge.position.y = _gauge.scale.y / 2.0 + 0.1


func _box(box_size: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
	var view := MeshInstance3D.new()
	view.mesh = BoxMesh.new()
	view.mesh.size = box_size
	view.position = at
	view.material_override = material
	add_child(view)
	return view
