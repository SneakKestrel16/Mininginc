## Dev menu (brief: Milestone 4 item 22): F1 opens it. Adds ore, sets the Heart's stage or
## fills its meter, skips time, toggles fly mode, and teleports. Built in code: it is a
## testing tool, not part of the game's look.
class_name DevMenu
extends CanvasLayer

## Seconds per step when skipping time; the same step offline progress uses.
const SKIP_STEP := 5.0

@export var economy: Economy
@export var player: Player
## Where "Heart" teleports to.
@export var heart: Node3D

var _amount: SpinBox
var _stage: SpinBox
var _fly: CheckButton
var _status: Label


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

	var ore_row := _row(rows, "Ore")
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

	_status = _label(rows, "")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		visible = not visible
		player.hint_blocked = visible
		player.set_controls(not visible)
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
