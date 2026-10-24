## The Drills/Heart slider, opened from the power console (story 017). While it is open
## the player has no control and the mouse is free; Esc, E or Tab closes it.
class_name Overlay
extends CanvasLayer

## Loses its controls while the overlay is open.
@export var player: Player


func _ready() -> void:
	visible = false


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
