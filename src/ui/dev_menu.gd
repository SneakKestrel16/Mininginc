## Dev menu (brief: Milestone 4 item 22): F1 opens it. Adds ore, sets the Heart's stage or
## fills its meter, skips time, toggles fly mode, teleports, and drops into a chamber at a
## stratum's depth. Built in code: it is a
## testing tool, not part of the game's look.
class_name DevMenu
extends CanvasLayer

## Seconds per step when skipping time; the same step offline progress uses.
const SKIP_STEP := 5.0
## Radius of the chamber the Depth buttons carve to stand in.
const CHAMBER_RADIUS := 3.0
## Metres below a stratum's top the chamber is carved: past the banner's hysteresis.
const CHAMBER_INSIDE := 10

@export var economy: Economy
@export var player: Player
## Where "Heart" teleports to.
@export var heart: Node3D

var _amount: SpinBox
var _stage: SpinBox
var _fly: CheckButton
var _status: Label
# The player's control state when the menu opened, put back when it closes: the launch or
# the console overlay may have taken control first.
var _was_on := false
var _was_blocked := false


func _ready() -> void:
	layer = 3
	visible = false
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 90)
	add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	panel.add_child(_margin(rows))
	_label(rows, "DEV MENU  (F1 closes)")

	# Every ore and part has a button: they wrap rather than run off the screen.
	var ore_row := HFlowContainer.new()
	ore_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_row(rows, "Ore").add_child(ore_row)
	_amount = _spin(ore_row, 1, 1000, 10)
	for id in economy.mine.ores:
		_button(ore_row, "+ %s" % id.capitalize(), _add_ore.bind(id))

	var heart_row := _row(rows, "Heart")
	_stage = _spin(heart_row, 0, economy.heart.stages.size(), economy.heart.stage)
	_button(heart_row, "Set stage", _set_stage)
	_button(heart_row, "Fill meter", _fill_meter)

	var time_row := _row(rows, "Skip")
	for minutes in [1, 10, 60]:
		_button(time_row, "+%d min" % minutes, _skip.bind(minutes * 60.0))

	var move_row := _row(rows, "Move")
	_fly = CheckButton.new()
	_fly.text = "Fly (Space up, Ctrl down)"
	_fly.toggled.connect(func(on: bool) -> void: player.flying = on)
	move_row.add_child(_fly)
	var noclip := CheckButton.new()
	noclip.text = "Noclip"
	noclip.toggled.connect(func(on: bool) -> void: player.noclip = on)
	move_row.add_child(noclip)
	_button(move_row, "To base", _teleport.bind(Vector3(64.5, 1.5, 64.5)))
	_button(move_row, "To Heart", func() -> void: _teleport(heart.global_position + Vector3(0, 0, 5)))

	var depth_row := _row(rows, "Depth")
	for stratum in economy.mine.world.strata.slice(1):
		var depth := int(stratum["from_depth"]) + CHAMBER_INSIDE
		_button(depth_row, "%s %d m" % [stratum["name"], depth], _drop_to.bind(depth))

	_status = _label(rows, "")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		if not visible:
			_was_on = player.controls_enabled
			_was_blocked = player.hint_blocked
		visible = not visible
		player.hint_blocked = true if visible else _was_blocked
		player.set_controls(false if visible else _was_on)
		get_viewport().set_input_as_handled()


func _add_ore(id: String) -> void:
	economy.mine.ores[id] += int(_amount.value)
	economy.mine.changed.emit()
	_status.text = "Added %d %s" % [int(_amount.value), id]


func _set_stage() -> void:
	economy.heart.stage = int(_stage.value)
	economy.heart.progress = 0.0
	economy.apply_heart()
	_status.text = "Heart at stage %d" % economy.heart.stage


# Adds exactly what the meter lacks, the way power does, so the stage's line and bonuses
# play as in normal play.
func _fill_meter() -> void:
	if economy.heart.is_awake():
		_status.text = "Every stage is reached"
		return
	for index in economy.heart.add(economy.heart.threshold() - economy.heart.progress):
		economy.stage_reached.emit(index)
	economy.apply_heart()
	_status.text = "Heart reached stage %d" % economy.heart.stage


func _skip(seconds: float) -> void:
	economy.advance(seconds, SKIP_STEP)
	_status.text = "Skipped %d min" % int(seconds / 60.0)


# Carves a chamber under the player's column [param depth] metres down and stands the player
# in it, the chunks around it drawn first so there is ground to land on.
func _drop_to(depth: int) -> void:
	var world := economy.mine.world
	var center := Vector3(floorf(player.global_position.x) + 0.5, -depth, floorf(player.global_position.z) + 0.5)
	world.carve(center, CHAMBER_RADIUS)
	world.update_around(center)
	_teleport(center - Vector3(0, CHAMBER_RADIUS - 0.2, 0))


func _teleport(to: Vector3) -> void:
	player.global_position = to
	player.velocity = Vector3.ZERO
	_status.text = "Teleported to %s" % to


func _margin(inner: Control) -> MarginContainer:
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	margin.add_child(inner)
	return margin


func _row(parent: Control, title: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	var label := _label(row, title)
	label.custom_minimum_size.x = 50
	return row


func _label(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	parent.add_child(label)
	return label


func _spin(parent: Control, low: float, high: float, value: float) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = low
	spin.max_value = high
	spin.value = value
	parent.add_child(spin)
	return spin


func _button(parent: Control, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
