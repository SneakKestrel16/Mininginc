## The Drills/Heart slider and the upgrade shop, opened from the power console (stories
## 017, 025). While it is open the player has no control and the mouse is free; Esc, E or
## Tab closes it.
class_name Overlay
extends CanvasLayer

## Loses its controls while the overlay is open.
@export var player: Player


func _ready() -> void:
	visible = false
	$Center.theme = _solid_theme()


# Opaque panels with an amber border (brief: Milestone 9 item 40), so nothing of the game
# shows through the text.
static func _solid_theme() -> Theme:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.07, 0.08, 0.11)
	box.border_color = Color(0.95, 0.6, 0.12, 0.85)
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	var theme := Theme.new()
	theme.set_stylebox("panel", "PanelContainer", box)
	return theme


## Shows the slider and frees the mouse.
func open() -> void:
	visible = true
	player.hint_blocked = true
	player.set_controls(false)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode in [KEY_ESCAPE, KEY_E, KEY_TAB]:
		visible = false
		player.hint_blocked = false
		player.set_controls(true)
		get_viewport().set_input_as_handled()
